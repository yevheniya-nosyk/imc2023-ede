import collections
import argparse
import json

def get_response_codes(filename):
    """Analyze the zdns metadata file"""
    
    # Save the file to the dictionnary
    with open(filename) as f:
        metadata = json.load(f)

    # Find the number of registered domain names
    registered_domains = sum(metadata['statuses'][i] for i in metadata['statuses'] if i != "NXDOMAIN")
    
    # Print the stats
    print("--------------------")
    print(f"All domains: {metadata['names']:,}")
    for rcode in metadata['statuses']:
        print(f"  {rcode}: {metadata['statuses'][rcode]:,} ({metadata['statuses'][rcode]*100/metadata['names']:.2f}%)")
    print(f"Registered domains: {registered_domains:,}")
    print("--------------------")


def get_ede_count(filename):
    """Analyze the EDE domains"""

    ede_combination_count = collections.defaultdict(int)
    ede_individual_count = collections.defaultdict(int)

    domains = 0
    lame_delegations = 0

    # Open the text file
    with open(filename, "r") as f:
        for line in f:
            # Count the number of domains
            domains += 1
            # Load as json
            zdns_result = json.loads(line)
            # Extract the combination of EDEs
            ede_combination = tuple(sorted(i["info_code"] for i in zdns_result["ede"]))
            ede_combination_count[ede_combination] += 1 
            # Store individual EDEs (one packet can contain multiple INFO-CODES)
            for ede in ede_combination:
                ede_individual_count[ede] += 1
            # Save domains with lame delegations
            if 22 in ede_combination or 23 in ede_combination:
                lame_delegations += 1

    # Sort the defaultdict
    ede_individual_count = sorted(ede_individual_count.items(), key=lambda k: k[1], reverse=True)
    ede_combination_count = sorted(ede_combination_count.items(), key=lambda k: k[1], reverse=True)

    print(f"{domains:,} triggered EDEs")
    print(f"  {len(ede_combination_count)} combinations of EDE codes were found:")
    for i in ede_combination_count:
        print(f"    {i[0]}: {i[1]:,}")
    print(f"  {len(ede_individual_count)} individual EDE codes were found:")
    for i in ede_individual_count:
        print(f"    {i[0]}: {i[1]:,}")
    print("------------------------------")
    print(f"{lame_delegations:,} unique domains are involved in lame delegations (EDE22 or EDE23)")


if __name__ == "__main__":
    
    # Parse command-line arguments
    parser = argparse.ArgumentParser()
    parser.add_argument('-i', '--input', required=True, default=None, help="Path to the file with domains and EDEs")
    parser.add_argument('-m', '--metadata', required=True, default=None, help="Path to the zdns metadata file")
    args = parser.parse_args()

    # Print the medatata (response codes)
    get_response_codes(filename=args.metadata)

    # Analyze domains with EDEs
    get_ede_count(filename=args.input)
