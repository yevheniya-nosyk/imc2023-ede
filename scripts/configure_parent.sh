#!/bin/bash

# Store the variables
server_ip=$1
domain=$2
a_record=$3
aaaa_record=$4

# Create a directory to store the zone or empty an existing one

zone_dir="/etc/bind/zone_ede"
if [ -d "$zone_dir" ]; then
    rm -rf $zone_dir/*
else
    mkdir $zone_dir
fi

# Include a file with path to local zone
local_conf="/etc/bind/named.conf.local-ede"
> $local_conf
if [[ $(grep -c "include \"$local_conf\";" /etc/bind/named.conf) = 0 ]]; then
    echo "include \"$local_conf\";" >> /etc/bind/named.conf
fi

# Store the full zone name
zone=$domain

# Create the output directory
output_dir=$zone_dir/$zone
mkdir -p $output_dir

# Create a basic (valid) zone file
echo "\$ORIGIN $zone." >> $output_dir/db.$zone
echo "\$TTL 600" >> $output_dir/db.$zone
echo "@	SOA	ns1.$zone.	hostmaster.$zone. (" >> $output_dir/db.$zone
echo "        $(date +%Y%m%d) ; serial" >> $output_dir/db.$zone
echo "        21600      ; refresh after 6 hours" >> $output_dir/db.$zone
echo "        3600       ; retry after 1 hour" >> $output_dir/db.$zone
echo "        604800     ; expire after 1 week" >> $output_dir/db.$zone
echo "        86400 )    ; minimum TTL of 1 day" >> $output_dir/db.$zone
echo "" >> $output_dir/db.$zone
echo "@               IN      NS      ns1.$zone." >> $output_dir/db.$zone
echo "ns1             IN      A       $server_ip" >> $output_dir/db.$zone
echo "@               IN      A       $a_record" >> $output_dir/db.$zone
echo "@               IN      AAAA    $aaaa_record " >> $output_dir/db.$zone

# Next we need to add all the delegations and DS records of child zones
cat dsset_for_parent.txt >> $output_dir/db.$zone
cat glues.txt >> $output_dir/db.$zone

# First generate a KSK and a ZSK using RSASHA256 algorithm (number 8)
dnssec-keygen -K $output_dir -a RSASHA256 -b 2048 -n ZONE $zone 
dnssec-keygen -K $output_dir -f KSK -a RSASHA256 -b 2048 -n ZONE $zone 

# Add public keys into the zone file
cat $output_dir/*.key >> $output_dir/db.$zone

# Sign the zone
dnssec-signzone -3 - -K $output_dir -e now+15000000 -o $zone $output_dir/db.$zone

# Move the DS records to the zone directory
mv dsset-$zone. $output_dir/dsset-$zone.

# Write to the named.conf.local the location of the signed zone file
echo "zone \"$zone\" {" >> $local_conf
echo "    type master;" >> $local_conf
echo "    file \"$zone_dir/$zone/db.$zone.signed\";" >> $local_conf
echo "};" >> $local_conf

# Restart BIND9
service bind9 restart

# Print the DS records and a glue record to be added to registrar's control panel
echo "-------------------------------------------------"
echo "Add these to Porkbun!"
cat $output_dir/dsset-$zone.
echo "$zone     IN      NS      ns1.$zone."
echo "ns1.$zone     IN      A      $server_ip"
