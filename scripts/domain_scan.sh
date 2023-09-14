#!/bin/bash

# The root directory of this repository
repo_dir=$(git rev-parse --show-toplevel)

# Load the configuration file
source $repo_dir/.env

# Save today's date
today=$(date +%Y%m%d)

# Create a scan directory
scan_dir=$repo_dir/data/domain_scan/$today
mkdir -p $scan_dir

# Scan
$ZDNS_PATH A --input-file $DOMAIN_LIST --name-servers $RESOLVER_DOMAIN_SCAN --dnssec --timeout 10 --threads $ZDNS_THREADS --metadata-file $scan_dir/zdns_metadata.json --local-addr $SCAN_SOURCE_IPS --output-file $scan_dir/output.json --log-file $scan_dir/zdns.log

# Extract domains and corresponding RCODES + EDEs
python3 <<EOF > $scan_dir/domains_with_errors.json
import json

with open("$scan_dir/output.json", "r") as f:
    for line in f:
        zdns_result = json.loads(line)
        if zdns_result["status"] != "NXDOMAIN":
            if "data" in zdns_result:
                if "additionals" in zdns_result["data"]:
                    for additional in zdns_result["data"]["additionals"]:
                        if "ede" in additional:
                            print(json.dumps({"domain": zdns_result["name"], "status": zdns_result["status"],"ede":additional["ede"]}))
EOF

# Process the scan results
python3 $repo_dir/src/analyze_domain_scan.py -i $scan_dir/domains_with_errors.json -m $scan_dir/zdns_metadata.json > $scan_dir/summary.txt
