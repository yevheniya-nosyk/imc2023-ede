#!/bin/bash

# Store the variables
server_ip=$1
domain=$2
a_record=$3
aaaa_record=$4

# Install bind
apt-get update
apt-get install -y bind9 

# Loop through the array of subdomains 

subdomains=("valid" "rrsig-exp-all" "allow-query-none" "allow-query-localhost" "no-ds" "no-zsk" "no-ksk" "ds-bad-tag" "ds-bad-key-algo" "ds-unassigned-key-algo" "ds-reserved-key-algo" "ds-bogus-digest-value" "ds-unassigned-digest-algo" "rrsig-exp-a" "rrsig-not-yet-a" "rrsig-not-yet-all" "rrsig-no-a" "rrsig-no-all" "nsec3-missing" "nsec3param-missing" "no-nsec3param-nsec3" "bad-nsec3-hash" "bad-nsec3-next" "nsec3-rrsig-missing" "bad-nsec3-rrsig" "bad-nsec3param-salt" "v6-mapped" "v6-unspecified" "v4-hex" "v6-link-local" "v6-localhost" "v6-mapped-dep" "v6-doc" "v6-unique-local" "v6-nat64" "v6-multicast" "v4-private-10" "v4-private-172" "v4-private-192" "v4-this-host" "v4-loopback" "v4-link-local" "v4-doc" "v4-reserved" "bad-zsk" "bad-ksk" "no-rrsig-ksk" "no-rrsig-dnskey" "bad-rrsig-ksk" "bad-rrsig-dnskey" "ed448" "rrsig-exp-before-all" "rrsig-exp-before-a" "no-dnskey-256" "no-dnskey-257" "no-dnskey-256-257" "bad-zsk-algo" "unassigned-zsk-algo" "reserved-zsk-algo" "unsigned")

for subdomain in ${subdomains[@]}; do 
    # Store the full zone name
    zone=$subdomain.$domain

    # Some domains are not intended to be reachable
    # No child zone will be created for those, only referrals and glues at the parent

    if [[ $subdomain = "v4-private-10" ]]; then
        cat <<EOT >> glues.txt
$zone.      IN      NS      ns1.$zone.
ns1.$zone.  IN      A      10.0.0.1
EOT
        continue
    fi 

    if [[ $subdomain = "v4-private-172" ]]; then
        cat <<EOT >> glues.txt
$zone.      IN      NS      ns1.$zone.
ns1.$zone.  IN      A      172.16.0.1
EOT
        continue
    fi 

    if [[ $subdomain = "v4-private-192" ]]; then
        cat <<EOT >> glues.txt
$zone.      IN      NS      ns1.$zone.
ns1.$zone.  IN      A      192.168.0.1
EOT
        continue
    fi 

    if [[ $subdomain = "v4-this-host" ]]; then
        cat <<EOT >> glues.txt
$zone.      IN      NS      ns1.$zone.
ns1.$zone.  IN      A      0.0.0.0
EOT
        continue
    fi 

    if [[ $subdomain = "v4-loopback" ]]; then
        cat <<EOT >> glues.txt
$zone.      IN      NS      ns1.$zone.
ns1.$zone.  IN      A      127.0.0.1
EOT
        continue
    fi 

    if [[ $subdomain = "v4-link-local" ]]; then
        cat <<EOT >> glues.txt
$zone.      IN      NS      ns1.$zone.
ns1.$zone.  IN      A      169.254.0.1
EOT
        continue
    fi 

    if [[ $subdomain = "v4-doc" ]]; then
        cat <<EOT >> glues.txt
$zone.      IN      NS      ns1.$zone.
ns1.$zone.  IN      A      198.51.100.0
EOT
        continue
    fi 

    if [[ $subdomain = "v4-reserved" ]]; then
        cat <<EOT >> glues.txt
$zone.      IN      NS      ns1.$zone.
ns1.$zone.  IN      A      240.0.0.1
EOT
        continue
    fi 

    if [[ $subdomain = "v6-mapped" ]]; then
        cat <<EOT >> glues.txt
$zone.      IN      NS      ns1.$zone.
ns1.$zone.  IN      AAAA      ::ffff:1.2.3.4
EOT
        continue
    fi 

    if [[ $subdomain = "v6-unspecified" ]]; then
        cat <<EOT >> glues.txt
$zone.      IN      NS      ns1.$zone.
ns1.$zone.  IN      AAAA      ::
EOT
        continue
    fi 

    if [[ $subdomain = "v4-hex" ]]; then
        cat <<EOT >> glues.txt
$zone.      IN      NS      ns1.$zone.
ns1.$zone.  IN      AAAA      c000:0201::
EOT
        continue
    fi 

    if [[ $subdomain = "v6-link-local" ]]; then
        cat <<EOT >> glues.txt
$zone.      IN      NS      ns1.$zone.
ns1.$zone.  IN      AAAA      fe80::a:b:c:d
EOT
        continue
    fi 

    if [[ $subdomain = "v6-localhost" ]]; then
        cat <<EOT >> glues.txt
$zone.      IN      NS      ns1.$zone.
ns1.$zone.  IN      AAAA      ::1
EOT
        continue
    fi 

    if [[ $subdomain = "v6-mapped-dep" ]]; then
        cat <<EOT >> glues.txt
$zone.      IN      NS      ns1.$zone.
ns1.$zone.  IN      AAAA      ::1.2.3.4
EOT
        continue
    fi 

    if [[ $subdomain = "v6-doc" ]]; then
        cat <<EOT >> glues.txt
$zone.      IN      NS      ns1.$zone.
ns1.$zone.  IN      AAAA      2001:db8::1
EOT
        continue
    fi 

    if [[ $subdomain = "v6-unique-local" ]]; then
        cat <<EOT >> glues.txt
$zone.      IN      NS      ns1.$zone.
ns1.$zone.  IN      AAAA      fc05::20:1
EOT
        continue
    fi 

    if [[ $subdomain = "v6-nat64" ]]; then
        cat <<EOT >> glues.txt
$zone.      IN      NS      ns1.$zone.
ns1.$zone.  IN      AAAA      64:ff9b::1.2.3.4
EOT
        continue
    fi 

    if [[ $subdomain = "v6-multicast" ]]; then
        cat <<EOT >> glues.txt
$zone.      IN      NS      ns1.$zone.
ns1.$zone.  IN      AAAA      ff02::16
EOT
        continue
    fi 

    # Create the output directory
    output_dir="/etc/bind/zones/$zone"
    mkdir -p $output_dir
    # Create a basic (valid) zone file
    cat <<EOT > $output_dir/db.$zone
\$ORIGIN $zone.
\$TTL 600
@	SOA	ns1.$zone.	hostmaster.$zone. (
		$(date +%Y%m%d) ; serial
		21600      ; refresh after 6 hours
		3600       ; retry after 1 hour
		604800     ; expire after 1 week
		86400 )    ; minimum TTL of 1 day
@               IN      NS      ns1.$zone.
ns1             IN      A       $server_ip
@               IN      A       $a_record
@               IN      AAAA    $aaaa_record
EOT

    # First generate a KSK and a ZSK using RSASHA256 algorithm (number 8)
    if [[ $subdomain = "ed448" ]]; then
        dnssec-keygen -K $output_dir -a ED448 -n ZONE $zone 
        dnssec-keygen -K $output_dir -f KSK -a ED448 -n ZONE $zone 
    elif [[ $subdomain = "unsigned" ]]; then
        # Do not create keys
        true
    else
        dnssec-keygen -K $output_dir -a RSASHA256 -b 2048 -n ZONE $zone 
        dnssec-keygen -K $output_dir -f KSK -a RSASHA256 -b 2048 -n ZONE $zone 
    fi

    # Add public keys into the zone file
    if [[ $subdomain != "unsigned" ]]; then
        cat $output_dir/*.key >> $output_dir/db.$zone
    fi

    # Sign the zone
    if [[ $subdomain = "rrsig-exp-all" ]]; then
        dnssec-signzone -3 $(head -c 1000 /dev/urandom | sha1sum | cut -b 1-16) -K $output_dir -e now+300 -o $zone $output_dir/db.$zone
    elif [[ $subdomain = "unsigned" ]]; then
        # Do not sign the zone
        true
    else
        dnssec-signzone -3 $(head -c 1000 /dev/urandom | sha1sum | cut -b 1-16) -K $output_dir -e now+15000000 -o $zone $output_dir/db.$zone
    fi  

    # Set the ZSK Zone Key flag to 0
    if [[ $subdomain = "no-dnskey-256" ]]; then
        sed -i "s/DNSKEY.*256.*3.*8/DNSKEY	0 3 8/g" $output_dir/db.$zone.signed
    fi

    # Set the KSK Zone Key flag to 0
    if [[ $subdomain = "no-dnskey-257" ]]; then
        sed -i "s/DNSKEY.*257.*3.*8/DNSKEY	0 3 8/g" $output_dir/db.$zone.signed
    fi

    if [[ $subdomain = "no-dnskey-256-257" ]]; then
        sed -i "s/DNSKEY.*256.*3.*8/DNSKEY	0 3 8/g" $output_dir/db.$zone.signed
        sed -i "s/DNSKEY.*257.*3.*8/DNSKEY	0 3 8/g" $output_dir/db.$zone.signed
    fi

    # If we a dealing with 'no-zsk' subdomain, comment out the ZSK DNSKEY
    if [[ $subdomain = "no-zsk" ]]; then
        # Find numbers of lines where the key is located
        line_start=$(grep -n 'DNSKEY.*256' $output_dir/db.$zone.signed | cut -f1 -d:)
        line_end=$(grep -n 'ZSK' $output_dir/db.$zone.signed | cut -f1 -d:)
        sed -i "${line_start},${line_end}d" $output_dir/db.$zone.signed
    fi

    # Edit the part of the ZSK
    if [[ $subdomain = "bad-zsk" ]]; then
        # Find the first line with the ZSK
        line_key=$(grep -A 1 'DNSKEY.*256' $output_dir/db.$zone.signed | tail -1 | xargs )
        rand_substring=$(head -c 1000 /dev/urandom | sha1sum | cut -b 1-5)
        line_key_new=$rand_substring${line_key:5}
        sed -i "s@$line_key@$line_key_new@g" $output_dir/db.$zone.signed
    fi
    
    # Set the wrong algorithm number for the ZSK
    if [[ $subdomain = "bad-zsk-algo" ]]; then
        sed -i "s/DNSKEY.*256.*3.*8/DNSKEY	256 3 7/g" $output_dir/db.$zone.signed
    fi

    # Set the unassigned algorithm number for the ZSK
    if [[ $subdomain = "unassigned-zsk-algo" ]]; then
        sed -i "s/DNSKEY.*256.*3.*8/DNSKEY	256 3 100/g" $output_dir/db.$zone.signed
    fi

    # Set the reserved algorithm number for the ZSK
    if [[ $subdomain = "reserved-zsk-algo" ]]; then
        sed -i "s/DNSKEY.*256.*3.*8/DNSKEY	256 3 200/g" $output_dir/db.$zone.signed
    fi

    # Remove the signature over the KSK
    if [[ $subdomain = "no-rrsig-ksk" ]]; then
        # Find the ID of the key signing key
        ksk_id=$(grep "KSK;" $output_dir/db.$zone.signed | awk -F' = ' '{print $NF}')
        # Find the line containing the signature over KSK DNSKEY as well as where it starts and ends
        line_rrsig_middle=$(grep  -n "$ksk_id.*no-rrsig-ksk.*" $output_dir/db.$zone.signed | cut -f1 -d:)
        line_rrsig_start_num=$((line_rrsig_middle-1))
        line_rrsig_end=$(tail -n +$line_rrsig_start_num $output_dir/db.$zone.signed | grep -m 1 ")")
        line_rrsig_end_num=$(grep -n "$line_rrsig_end" $output_dir/db.$zone.signed | cut -f1 -d:)
        sed -i "${line_rrsig_start_num},${line_rrsig_end_num}d" $output_dir/db.$zone.signed
    fi

    # Remove both DNSKEY signatures
    if [[ $subdomain = "no-rrsig-dnskey" ]]; then
        # First delete the signature over the KSK
        ksk_id=$(grep "KSK;" $output_dir/db.$zone.signed | awk -F' = ' '{print $NF}')
        # Find the line containing the signature over KSK DNSKEY as well as where it starts and ends
        line_rrsig_middle=$(grep  -n "$ksk_id.*no-rrsig-dnskey.*" $output_dir/db.$zone.signed | cut -f1 -d:)
        line_rrsig_start_num=$((line_rrsig_middle-1))
        line_rrsig_end=$(tail -n +$line_rrsig_start_num $output_dir/db.$zone.signed | grep -m 1 ")")
        line_rrsig_end_num=$(grep -n "$line_rrsig_end" $output_dir/db.$zone.signed | cut -f1 -d:)
        sed -i "${line_rrsig_start_num},${line_rrsig_end_num}d" $output_dir/db.$zone.signed

        # Next delete the signature over the ZSK
        line_rrsig_start_num=$(grep -n "RRSIG.*DNSKEY.*8.*3.*600" $output_dir/db.$zone.signed | cut -f1 -d:)
        line_rrsig_end=$(tail -n +$line_rrsig_start_num $output_dir/db.$zone.signed | grep -m 1 ")")
        line_rrsig_end_num=$(grep -n "$line_rrsig_end" $output_dir/db.$zone.signed | cut -f1 -d:)
        sed -i "${line_rrsig_start_num},${line_rrsig_end_num}d" $output_dir/db.$zone.signed
    fi

    # Edit the signature over the KSK
    if [[ $subdomain = "bad-rrsig-ksk" ]]; then
        # Find the ID of the key signing key
        ksk_id=$(grep "KSK;" $output_dir/db.$zone.signed | awk -F' = ' '{print $NF}')
        # Find the first line of the KSK signature 
        line_rrsig=$(grep -A2 'RRSIG.*DNSKEY.*8.*3' $output_dir/db.$zone.signed | grep -A1 ".*${ksk_id}.*" | tail -1 | xargs)
        rand_substring=$(head -c 1000 /dev/urandom | sha1sum | cut -b 1-5)
        line_rrsig_new=$rand_substring${line_rrsig:5}
        sed -i "s@$line_rrsig@$line_rrsig_new@g" $output_dir/db.$zone.signed
    fi

    # Edit both DNSKEY RRSIGs
    if [[ $subdomain = "bad-rrsig-dnskey" ]]; then
        # Find the ID of the key signing key
        ksk_id=$(grep "KSK;" $output_dir/db.$zone.signed | awk -F' = ' '{print $NF}')
        # Find the ID of the zone signing key
        zsk_id=$(grep "ZSK;" $output_dir/db.$zone.signed | awk -F' = ' '{print $NF}')
        # Edit the KSK signature
        rand_substring=$(head -c 1000 /dev/urandom | sha1sum | cut -b 1-5)
        line_ksk_rrsig=$(grep -A2 'RRSIG.*DNSKEY.*8.*3' $output_dir/db.$zone.signed | grep -A1 ".*${ksk_id}.*" | tail -1 | xargs)
        line_ksk_rrsig_new=$rand_substring${line_ksk_rrsig:5}
        sed -i "s@$line_ksk_rrsig@$line_ksk_rrsig_new@g" $output_dir/db.$zone.signed
        # Edit the ZSK signature
        line_zsk_rrsig=$(grep -A2 'RRSIG.*DNSKEY.*8.*3' $output_dir/db.$zone.signed | grep -A1 ".*${zsk_id}.*" | tail -1 | xargs)
        line_zsk_rrsig_new=$rand_substring${line_zsk_rrsig:5}
        sed -i "s@$line_zsk_rrsig@$line_zsk_rrsig_new@g" $output_dir/db.$zone.signed
    fi

    # Edit the part of the KSK
    if [[ $subdomain = "bad-ksk" ]]; then
        # Find the first line with the KSK
        line_key=$(grep -A 1 'DNSKEY.*257' $output_dir/db.$zone.signed | tail -1 | xargs )
        rand_substring=$(head -c 1000 /dev/urandom | sha1sum | cut -b 1-5)
        line_key_new=$rand_substring${line_key:5}
        sed -i "s@$line_key@$line_key_new@g" $output_dir/db.$zone.signed
    fi

    # If we a dealing with 'no-ksk' subdomain, comment out the KSK DNSKEY
    if [[ $subdomain = "no-ksk" ]]; then
        # Find numbers of lines where the key is located
        line_start=$(grep -n 'DNSKEY.*257' $output_dir/db.$zone.signed | cut -f1 -d:)
        line_end=$(grep -n 'KSK' $output_dir/db.$zone.signed | cut -f1 -d:)
        sed -i "${line_start},${line_end}d" $output_dir/db.$zone.signed
    fi

    # Manipulate RRSIGs
    if [[ $subdomain = "rrsig-exp-a" ]]; then
        # Find line number with a signature over A RRset
        sig_start_line=$(grep -n "RRSIG\sA 8 3" $output_dir/db.$zone.signed | cut -f1 -d:)
        sig_dates_line=$((sig_start_line+1))
        # Get current timestamps
        expiry_date=$(awk "NR==$sig_dates_line" $output_dir/db.$zone.signed | grep -oP "\d{14}" | head -1)
        start_date=$(awk "NR==$sig_dates_line" $output_dir/db.$zone.signed | grep -oP "\d{14}" | tail -1)
        # Compute the last year
        this_year=$(date +'%Y')
        last_year=$((this_year-1))
        # Compute new timestamps
        expiry_date_new="$(echo $last_year)$(echo $expiry_date | cut -c 5-)"
        start_date_new="$(echo $last_year)$(echo $start_date | cut -c 5-)"
        # Replace
        sed -i "${sig_dates_line}s/$expiry_date/$expiry_date_new/" $output_dir/db.$zone.signed
        sed -i "${sig_dates_line}s/$start_date/$start_date_new/" $output_dir/db.$zone.signed
    elif [[ $subdomain = "rrsig-not-yet-a" ]]; then
        # Find line number with a signature over A RRset
        sig_start_line=$(grep -n "RRSIG\sA 8 3" $output_dir/db.$zone.signed | cut -f1 -d:)
        sig_dates_line=$((sig_start_line+1))
        # Get current timestamps
        expiry_date=$(awk "NR==$sig_dates_line" $output_dir/db.$zone.signed | grep -oP "\d{14}" | head -1)
        start_date=$(awk "NR==$sig_dates_line" $output_dir/db.$zone.signed | grep -oP "\d{14}" | tail -1)
        # Compute the next year
        this_year=$(date +'%Y')
        next_year=$((this_year+1))
        # Compute new timestamps
        expiry_date_new="$(echo $next_year)$(echo $expiry_date | cut -c 5-)"
        start_date_new="$(echo $next_year)$(echo $start_date | cut -c 5-)"
        # Replace
        sed -i "${sig_dates_line}s/$expiry_date/$expiry_date_new/" $output_dir/db.$zone.signed
        sed -i "${sig_dates_line}s/$start_date/$start_date_new/" $output_dir/db.$zone.signed
    elif [[ $subdomain = "rrsig-not-yet-all" ]]; then
        # Find line number with a signature over A RRset
        sig_start_line=$(grep -n "RRSIG\sA 8 3" $output_dir/db.$zone.signed | cut -f1 -d:)
        sig_dates_line=$((sig_start_line+1))
        # Get current timestamps
        expiry_date=$(awk "NR==$sig_dates_line" $output_dir/db.$zone.signed | grep -oP "\d{14}" | head -1)
        start_date=$(awk "NR==$sig_dates_line" $output_dir/db.$zone.signed | grep -oP "\d{14}" | tail -1)
        # Compute the next year
        this_year=$(date +'%Y')
        next_year=$((this_year+1))
        # Compute new timestamps
        expiry_date_new="$(echo $next_year)$(echo $expiry_date | cut -c 5-)"
        start_date_new="$(echo $next_year)$(echo $start_date | cut -c 5-)"
        # Replace all the signatures
        sed -i "s/$expiry_date/$expiry_date_new/g" $output_dir/db.$zone.signed
        sed -i "s/$start_date/$start_date_new/g" $output_dir/db.$zone.signed
    elif [[ $subdomain = "rrsig-exp-before-all" ]]; then
        # Find any signature and extract the expiry timestamp
        expiry_date_old=$(grep -A1  RRSIG $output_dir/db.$zone.signed | grep $zone | head -1 | xargs | awk '{print $1}')
        # Replace the year to 2010
        expiry_date_new=2010${expiry_date_old:4}
        # Replace all the expiry timestamps
        sed -i "s/$expiry_date_old/$expiry_date_new/g" $output_dir/db.$zone.signed
     elif [[ $subdomain = "rrsig-exp-before-a" ]]; then
        # Find any signature and extract the expiry timestamp
        expiry_date_a_line=$(grep -n -A1 "RRSIG\sA 8 3" $output_dir/db.$zone.signed | tail -1 | cut -f1 -d-)
        expiry_date_a_old=$(grep -A1  "RRSIG\sA 8 3" $output_dir/db.$zone.signed | grep $zone | head -1 | xargs | awk '{print $1}')
        # Replace the year to 2010
        expiry_date_new=2010${expiry_date_old:4}
        # Replace the expiry timestamp over A RRSIG
        sed -i "${expiry_date_a_line}s/$expiry_date_a_old/$expiry_date_new/g" $output_dir/db.$zone.signed
    elif [[ $subdomain = "rrsig-no-a" ]]; then
        line_rrsig_start_num=$(grep -n "RRSIG\sA\s8\s3" $output_dir/db.$zone.signed | cut -f1 -d:)
        line_rrsig_end=$(tail -n +$line_rrsig_start_num $output_dir/db.$zone.signed | grep -m 1 ")")
        line_rrsig_end_num=$(grep -n "$line_rrsig_end" $output_dir/db.$zone.signed | cut -f1 -d:)
        sed -i "${line_rrsig_start_num},${line_rrsig_end_num}d" $output_dir/db.$zone.signed
    elif [[ $subdomain = "rrsig-no-all" ]]; then
        while grep "0.*RRSIG.*" $output_dir/db.$zone.signed > /dev/null; do
            # Delete signatures one by one
            line_rrsig_start_num=$(grep -n "0.*RRSIG.*" $output_dir/db.$zone.signed | head -1 | cut -f1 -d:)
            line_rrsig_end=$(tail -n +$line_rrsig_start_num $output_dir/db.$zone.signed | grep -m 1 ")")
            line_rrsig_end_num=$(grep -n "$line_rrsig_end" $output_dir/db.$zone.signed | cut -f1 -d:)
            sed -i "${line_rrsig_start_num},${line_rrsig_end_num}d" $output_dir/db.$zone.signed
        done
    fi

    # Remove NSEC records
    if [[ $subdomain = "nsec3-missing" ]]; then
        while grep "IN.*NSEC3.*" $output_dir/db.$zone.signed > /dev/null; do
            # Delete NSEC3 records one by one
            line_start_num=$(grep -n "IN.*NSEC3.*" $output_dir/db.$zone.signed | head -1 | cut -f1 -d:)
            line_end=$(tail -n +$line_start_num $output_dir/db.$zone.signed | grep -m 1 ")")
            line_end_num=$(grep -n "$line_end" $output_dir/db.$zone.signed | cut -f1 -d:)
            sed -i "${line_start_num},${line_end_num}d" $output_dir/db.$zone.signed
        done
    fi

    # Remove NSEC records
    if [[ $subdomain = "bad-nsec3param-salt" ]]; then
        # Find NSEC3PARAM line number
        nsec3param_line=$(grep -n "0\sNSEC3PARAM" $output_dir/db.$zone.signed | cut -f1 -d:)
        # Find the salt value
        nsec3param_salt=$(grep "0\sNSEC3PARAM" $output_dir/db.$zone.signed | awk '{print $NF}')
        # Update the salt value
        # Change hashed subdomains
        rand_substring=$(head -c 1000 /dev/urandom | sha1sum | cut -b 1-3 | tr '[:lower:]' '[:upper:]')
        nsec3param_salt_new=$rand_substring${nsec3param_salt:3}
        sed -i "${nsec3param_line}s/$nsec3param_salt/$nsec3param_salt_new/" $output_dir/db.$zone.signed
    fi

    # Remove NSEC records
    if [[ $subdomain = "bad-nsec3-rrsig" ]]; then
        rand_substring=$(head -c 1000 /dev/urandom | sha1sum | cut -b 1-5)
        for rrsig in $(grep -n "RRSIG.*NSEC3\s8" $output_dir/db.$zone.signed | cut -f1 -d:); do
            line_rrsig_start_num=$rrsig
            line_rrsig_end=$(tail -n +$line_rrsig_start_num $output_dir/db.$zone.signed | grep ")" | head -1 | xargs)
            line_rrsig_end_num=$(grep -n "$line_rrsig_end" $output_dir/db.$zone.signed | cut -f1 -d:)
            line_rrsig_end_new=$rand_substring${line_rrsig_end:5}
            sed -i "s@$line_rrsig_end@$line_rrsig_end_new@g" $output_dir/db.$zone.signed
        done
    fi

    # Remove NSEC3 RRSIG records
    if [[ $subdomain = "nsec3-rrsig-missing" ]]; then
        while grep "RRSIG.*NSEC3\s8" $output_dir/db.$zone.signed > /dev/null; do
            # Delete signatures one by one
            line_rrsig_start_num=$(grep -n "RRSIG.*NSEC3\s8" $output_dir/db.$zone.signed | head -1 | cut -f1 -d:)
            line_rrsig_end=$(tail -n +$line_rrsig_start_num $output_dir/db.$zone.signed | grep -m 1 ")")
            line_rrsig_end_num=$(grep -n "$line_rrsig_end" $output_dir/db.$zone.signed | cut -f1 -d:)
            sed -i "${line_rrsig_start_num},${line_rrsig_end_num}d" $output_dir/db.$zone.signed
        done
    fi

    # Make wrong NSEC3 records
    if [[ $subdomain = "bad-nsec3-hash" ]]; then
        # Locate NSEC3 records
        nsec3_domain_1=$(grep ".$zone.\s600\sIN\sNSEC3" $output_dir/db.$zone.signed | head -1 | awk '{print $1}')
        nsec3_domain_2=$(grep ".$zone.\s600\sIN\sNSEC3" $output_dir/db.$zone.signed | tail -1 | awk '{print $1}')
        # Change hashed subdomains
        rand_substring=$(head -c 1000 /dev/urandom | sha1sum | cut -b 1-3 | tr '[:lower:]' '[:upper:]')
        new_nsec3_domain_1=$rand_substring${nsec3_domain_1:3}
        new_nsec3_domain_2=$rand_substring${nsec3_domain_2:3}
        # Replace in the zone file
        sed -i "s/$nsec3_domain_1/$new_nsec3_domain_1/g" $output_dir/db.$zone.signed
        sed -i "s/$nsec3_domain_2/$new_nsec3_domain_2/g" $output_dir/db.$zone.signed
    fi

    # Make wrong Next Hashed Owner Name field in NSEC3
    if [[ $subdomain = "bad-nsec3-next" ]]; then
        # Find NSEC3 hashes
        nsec3_hash_1=$(grep ".$zone.\s600\sIN\sNSEC3" $output_dir/db.$zone.signed | head -1 | awk '{print $1}' | awk -F'.' '{print $1}')
        nsec3_hash_2=$(grep ".$zone.\s600\sIN\sNSEC3" $output_dir/db.$zone.signed | tail -1 | awk '{print $1}' | awk -F'.' '{print $1}')
        # Change next hashed owners
        rand_substring=$(head -c 1000 /dev/urandom | sha1sum | cut -b 1-3 | tr '[:lower:]' '[:upper:]')
        nsec3_hash_1_new=$rand_substring${nsec3_hash_1:3}
        nsec3_hash_2_new=$rand_substring${nsec3_hash_2:3}
        # Replace in the zone file
        sed -i "s/$nsec3_hash_1$/$nsec3_hash_1_new/g" $output_dir/db.$zone.signed
        sed -i "s/$nsec3_hash_2$/$nsec3_hash_2_new/g" $output_dir/db.$zone.signed
    fi

    # Remove NSEC3PARAM records
    if [[ $subdomain = "nsec3param-missing" ]]; then
        sed -i '/NSEC3PARAM.*1/d' $output_dir/db.$zone.signed
    fi

    # Remove both NSEC3 and NSEC3PARAM records
    if [[ $subdomain = "no-nsec3param-nsec3" ]]; then
        # Delete NSEC3 records one by one
        while grep "IN.*NSEC3.*" $output_dir/db.$zone.signed > /dev/null; do
            line_start_num=$(grep -n "IN.*NSEC3.*" $output_dir/db.$zone.signed | head -1 | cut -f1 -d:)
            line_end=$(tail -n +$line_start_num $output_dir/db.$zone.signed | grep -m 1 ")")
            line_end_num=$(grep -n "$line_end" $output_dir/db.$zone.signed | cut -f1 -d:)
            sed -i "${line_start_num},${line_end_num}d" $output_dir/db.$zone.signed
        done
        # Delete the NSEC3PARAM resource record
        sed -i '/NSEC3PARAM.*1/d' $output_dir/db.$zone.signed
    fi

    # Manipulate the DS RR
    # Change the key tag to 0000 in DS record for "ds-bad-tag" subdomain
    if [[ $subdomain = "ds-bad-tag" ]]; then
        sed -i 's/DS.*8 2/DS 0000 8 2/g' dsset-$zone.
    # Set a different DNSKEY algorithm (8 -> 7)
    elif [[ $subdomain = "ds-bad-key-algo" ]]; then
        sed -i 's/8 2/7 2/g' dsset-$zone.
    # Set an unassigned DNSKEY algorithm (8 -> 100)
    elif [[ $subdomain = "ds-unassigned-key-algo" ]]; then
        sed -i 's/8 2/100 2/g' dsset-$zone.
    # Set an unassigned digest algorithm (2 -> 100)
    elif [[ $subdomain = "ds-unassigned-digest-algo" ]]; then
        sed -i 's/8 2/8 100/g' dsset-$zone.
    # Set a reserved DNSKEY algorithm (8 -> 200)
    elif [[ $subdomain = "ds-reserved-key-algo" ]]; then
        sed -i 's/8 2/200 2/g' dsset-$zone.
    # Change the digest value
    elif [[ $subdomain = "ds-bogus-digest-value" ]]; then
        sed -i "s/ 8 2.*/ 8 2 $(echo -n 'I am not a real DNSKEY digest' | sha256sum | cut -d' ' -f1)/" dsset-$zone.
    fi

    # Generate the text file with DS records
    if [[ $subdomain != "no-ds" && $subdomain != "unsigned" ]]; then
        cat dsset-$zone. >> dsset_for_parent.txt
    fi
    mv dsset-$zone. $output_dir/dsset-$zone.

    # Create a text file with glue records
    cat <<EOT >> glues.txt
$zone.      IN      NS      ns1.$zone.
ns1.$zone.  IN      A      $server_ip
EOT

    # Write to the named.conf.local the location of the signed zone file
    if [[ $subdomain = "allow-query-none" ]]; then
    cat <<EOT >> /etc/bind/named.conf.local
zone "$zone" {
        type master;
        file "/etc/bind/zones/$zone/db.$zone.signed";
        allow-query { none; };
};
EOT
    elif [[ $subdomain = "allow-query-localhost" ]]; then
    cat <<EOT >> /etc/bind/named.conf.local
zone "$zone" {
        type master;
        file "/etc/bind/zones/$zone/db.$zone.signed";
        allow-query { localhost; };
};
EOT
    elif [[ $subdomain = "unsigned" ]]; then
    cat <<EOT >> /etc/bind/named.conf.local
zone "$zone" {
        type master;
        file "/etc/bind/zones/$zone/db.$zone";
};
EOT
    else
    cat <<EOT >> /etc/bind/named.conf.local
zone "$zone" {
        type master;
        file "/etc/bind/zones/$zone/db.$zone.signed";
};
EOT
    fi

    sleep 5

done

# Restart BIND9
service bind9 restart
