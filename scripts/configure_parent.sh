#!/bin/bash

# Store the variables
server_ip=$1
domain=$2
a_record=$3
aaaa_record=$4

# Install bind
apt-get update
apt-get install -y bind9 

# Store the full zone name
zone=$domain
# Create the output directory
output_dir="/etc/bind/zones/$zone"
mkdir -p $output_dir
# Create a basic (valid) zone file
cat <<EOT > $output_dir/db.$zone
\$ORIGIN $zone.
\$TTL 600
@	SOA	ns1.$zone.	hostmaster.$zone. (
		$(date +%Y%m%d); serial
		21600      ; refresh after 6 hours
		3600       ; retry after 1 hour
		604800     ; expire after 1 week
		86400 )    ; minimum TTL of 1 day
@               IN      NS      ns1.$zone.
ns1             IN      A       $server_ip
@               IN      A       $a_record
@               IN      AAAA    $aaaa_record
EOT

# Next we need to add all the delegations and DS records of child zones
cat dsset_for_parent.txt >> $output_dir/db.$zone
cat glues.txt >> $output_dir/db.$zone

# First generate a KSK and a ZSK using RSASHA256 algorithm (number 8)
dnssec-keygen -K $output_dir -a RSASHA256 -b 2048 -n ZONE $zone 
dnssec-keygen -K $output_dir -f KSK -a RSASHA256 -b 2048 -n ZONE $zone 

# Add public keys into the zone file
cat $output_dir/*.key >> $output_dir/db.$zone

# Sign the zone
dnssec-signzone -3 $(head -c 1000 /dev/urandom | sha1sum | cut -b 1-16) -K $output_dir -e now+15000000 -o $zone $output_dir/db.$zone

# Generate the text file with DS records
mv dsset-$zone. $output_dir/dsset-$zone.

# Write to the named.conf.local the location of the signed zone file
cat <<EOT >> /etc/bind/named.conf.local
zone "$zone" {
    type master;
    file "/etc/bind/zones/$zone/db.$zone.signed";
};
EOT

# Restart BIND9
service bind9 restart

# Print the DS records and a glue record to be added to registrar's control panel
echo "Add these to your registrar!"
cat $output_dir/dsset-$zone.
echo "$zone     IN      NS      ns1.$zone."
echo "ns1.$zone     IN      A      $server_ip"
