#!/bin/bash

# The root directory of this repository
repo_dir=$(git rev-parse --show-toplevel)

# Load the configuration file
source $repo_dir/.env

# Save today's date
today=$(date +%Y%m%d)

# Create a scan directory
scan_dir=$repo_dir/data/subdomains_test/$today
mkdir -p $scan_dir

# Build images of recursive resolvers
docker build -t bind9-9.19.23 configs/resolvers/bind9-9.19.23/
docker build -t unbound-1.20.0 configs/resolvers/unbound-1.20.0/
docker build -t pdns-recursor-5.0.4 configs/resolvers/pdns-recursor-5.0.4/
docker pull cznic/knot-resolver:v5.7.3

# Create the list of IPs to scan
printf "1.1.1.1\n8.8.8.8\n9.9.9.9\n208.67.222.222\n194.0.5.3\n" > $repo_dir/data/subdomains_test/$today/ips_to_scan.txt
printf "127.0.0.100\n127.0.0.101\n127.0.0.102\n127.0.0.103\n" >> $repo_dir/data/subdomains_test/$today/ips_to_scan.txt

# Query each subdomain one by one by each resolver

for subdomain in $(cat $repo_dir/data/misconfigured_subdomains.txt); do

    # Start containers
    container_bind=$(docker run -d -p 127.0.0.100:53:53/tcp -p 127.0.0.100:53:53/udp -t bind9-9.19.23)
    container_unbound=$(docker run -d -p 127.0.0.101:53:53/tcp -p 127.0.0.101:53:53/udp -t unbound-1.20.0)
    container_pdns=$(docker run -d -p 127.0.0.102:53:53/tcp -p 127.0.0.102:53:53/udp -t pdns-recursor-5.0.4)
    container_knot=$(docker run -d -p 127.0.0.103:53:53/tcp -p 127.0.0.103:53:53/udp -t cznic/knot-resolver:v5.7.3)

    # To test NSEC3 misconfigurations, we need to query a non-existing domain name
    if [[ "$subdomain" == *"nsec3"* ]]; then
        random_subdomain=$(echo $RANDOM | md5sum | head -c 10)
        domain_name=$random_subdomain.$subdomain.$DOMAIN
    else 
        domain_name=$subdomain.$DOMAIN
    fi

    # Send queries
    cat $repo_dir/data/subdomains_test/$today/ips_to_scan.txt | $ZDNS_PATH A --dnssec --timeout 10 --name-server-mode --override-name="$domain_name" >> $repo_dir/data/subdomains_test/$today/zdns_output.json

    # Remove containers
    docker rm -f $container_bind $container_unbound $container_knot $container_pdns
    sleep 1

done
