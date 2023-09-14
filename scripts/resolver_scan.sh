# The root directory of this repository
repo_dir=$(git rev-parse --show-toplevel)

# Load the configuration file
source $repo_dir/.env

# Save today's date
today=$(date +%Y%m%d)

# Create a scan directory
scan_dir=$repo_dir/data/resolver_scan/$today
mkdir -p $scan_dir

# Save the list of our subdomains
subdomains=$(cat $repo_dir/data/misconfigured_subdomains.txt)

# Create the input list
random_subdomain=$(echo $RANDOM | md5sum | head -c 10)

for resolver in $RESOLVER_BIND_IP $RESOLVER_UNBOUND_IP $RESOLVER_PDNS_IP $RESOLVER_KNOT_IP $RESOLVER_CLOUDFLARE $RESOLVER_QUAD9 $RESOLVER_OPENDNS; do
    for subdomain in $subdomains; do
        if [[ "$subdomain" == *"nsec3"* ]]; then
            echo "$random_subdomain.$subdomain.$DOMAIN,$resolver"
        else
            echo "$subdomain.$DOMAIN,$resolver"
        fi
    done
done > $scan_dir/input.txt

shuf $scan_dir/input.txt > $scan_dir/input_temp.txt
mv $scan_dir/input_temp.txt $scan_dir/input.txt

# Scan with zdns
cat $scan_dir/input.txt | $ZDNS_PATH A --dnssec --timeout 10 --metadata-file $scan_dir/zdns_metadata.json --local-addr $SCAN_SOURCE_IPS --output-file $scan_dir/output.json --log-file $scan_dir/zdns.log
