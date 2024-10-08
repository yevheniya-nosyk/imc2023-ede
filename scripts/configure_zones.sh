#!/bin/bash

# The root directory of this repository
repo_dir=$(git rev-parse --show-toplevel)

# Save today's date
today=$(date +%Y%m%d)

# Load the configuration file
source $repo_dir/.env

# We first need to configure zones that require using older version of dnssec-signzone
mkdir -p $repo_dir/data/zones/$today

# Build an image with the installation of old BIND9.11
docker build -t bind-9.11.9 $repo_dir/configs/dnssec-signzone
# Run a container
container_id=$(docker run -v $repo_dir/data/zones/$today:/mnt/zones -d -t bind-9.11.9)

for subdomain in "dsa" "nsec3-iter-1" "nsec3-iter-51" "nsec3-iter-101" "nsec3-iter-151" "nsec3-iter-200" "rsamd5"; do 
    mkdir -p $repo_dir/data/zones/$today/$subdomain
    # Store the full zone name
    zone=$subdomain.$DOMAIN
       # Create a basic (valid) zone file
    cat <<EOT > $repo_dir/data/zones/$today/$subdomain/db.$zone
\$ORIGIN $zone.
\$TTL 600
@	SOA	ns1.$zone.	hostmaster.$zone. (
		$(date +%Y%m%d) ; serial
		21600      ; refresh after 6 hours
		3600       ; retry after 1 hour
		604800     ; expire after 1 week
		86400 )    ; minimum TTL of 1 day
@               IN      NS      ns1.$zone.
ns1             IN      A       $NS_CHILD_IP
@               IN      A       $A_RECORD
@               IN      AAAA    $AAAA_RECORD
EOT

    if [[ $subdomain = "dsa" ]]; then
        docker exec $container_id /bin/bash -c "cd /mnt/zones/$subdomain && dnssec-keygen -a DSA -b 1024 -n ZONE $zone && dnssec-keygen -f KSK -a DSA -b 1024 -n ZONE $zone && cat *.key >> db.$zone && dnssec-signzone -e now+15000000 -o $zone db.$zone"
    elif [[ $subdomain = "rsamd5" ]]; then
        docker exec $container_id /bin/bash -c "cd /mnt/zones/$subdomain && dnssec-keygen -a RSAMD5 -b 1024 -n ZONE $zone && dnssec-keygen -f KSK -a RSAMD5 -b 1024 -n ZONE $zone && cat *.key >> db.$zone && dnssec-signzone -e now+15000000 -o $zone db.$zone"
    elif [[ $subdomain = "nsec3-iter-1" ]]; then
        docker exec $container_id /bin/bash -c "cd /mnt/zones/$subdomain && dnssec-keygen -a RSASHA256 -b 2048 -n ZONE $zone && dnssec-keygen -f KSK -a RSASHA256 -b 2048 -n ZONE $zone && cat *.key >> db.$zone && dnssec-signzone -3 - -H 1 -e now+15000000 -o $zone db.$zone"
    elif [[ $subdomain = "nsec3-iter-51" ]]; then
        docker exec $container_id /bin/bash -c "cd /mnt/zones/$subdomain && dnssec-keygen -a RSASHA256 -b 2048 -n ZONE $zone && dnssec-keygen -f KSK -a RSASHA256 -b 2048 -n ZONE $zone && cat *.key >> db.$zone && dnssec-signzone -3 - -H 51 -e now+15000000 -o $zone db.$zone"
    elif [[ $subdomain = "nsec3-iter-101" ]]; then
        docker exec $container_id /bin/bash -c "cd /mnt/zones/$subdomain && dnssec-keygen -a RSASHA256 -b 2048 -n ZONE $zone && dnssec-keygen -f KSK -a RSASHA256 -b 2048 -n ZONE $zone && cat *.key >> db.$zone && dnssec-signzone -3 - -H 101 -e now+15000000 -o $zone db.$zone"
    elif [[ $subdomain = "nsec3-iter-151" ]]; then
        docker exec $container_id /bin/bash -c "cd /mnt/zones/$subdomain && dnssec-keygen -a RSASHA256 -b 2048 -n ZONE $zone && dnssec-keygen -f KSK -a RSASHA256 -b 2048 -n ZONE $zone && cat *.key >> db.$zone && dnssec-signzone -3 - -H 151 -e now+15000000 -o $zone db.$zone"
    elif [[ $subdomain = "nsec3-iter-200" ]]; then
        docker exec $container_id /bin/bash -c "cd /mnt/zones/$subdomain && dnssec-keygen -a RSASHA256 -b 2048 -n ZONE $zone && dnssec-keygen -f KSK -a RSASHA256 -b 2048 -n ZONE $zone && cat *.key >> db.$zone && dnssec-signzone -3 - -H 200 -e now+15000000 -o $zone db.$zone"
    fi

    # Finally, send the newly created zone to the child nameserver
    ssh -i $SSH_KEY_PRIVATE $NS_CHILD_USERNAME@$NS_CHILD_IP "mkdir -p $zone"
    sudo scp -i $SSH_KEY_PRIVATE $repo_dir/data/zones/$today/$subdomain/* $NS_CHILD_USERNAME@$NS_CHILD_IP:./$zone

done

# Stop and remove the container
docker stop $container_id
docker rm $container_id

# We then configure the child, as child zones will produce resource records to be added to the parent zone

# Send the child configuration script to the child nameserver and run it
scp -i $SSH_KEY_PRIVATE $repo_dir/scripts/configure_child.sh $NS_CHILD_USERNAME@$NS_CHILD_IP:
# Run the script
ssh -i $SSH_KEY_PRIVATE $NS_CHILD_USERNAME@$NS_CHILD_IP "sudo ./configure_child.sh $NS_CHILD_IP $DOMAIN $A_RECORD $AAAA_RECORD"

# Send DS records and glues records from the child to the parent
# These will be included in the parent zone
scp -3 -i $SSH_KEY_PRIVATE $NS_CHILD_USERNAME@$NS_CHILD_IP:./dsset_for_parent.txt $NS_PARENT_USERNAME@$NS_PARENT_IP:
scp -3 -i $SSH_KEY_PRIVATE $NS_CHILD_USERNAME@$NS_CHILD_IP:./glues.txt $NS_PARENT_USERNAME@$NS_PARENT_IP:

# Send the parent configuration script to the parent nameserver and run it
scp -i $SSH_KEY_PRIVATE $repo_dir/scripts/configure_parent.sh $NS_PARENT_USERNAME@$NS_PARENT_IP:
# Run the script
ssh -i $SSH_KEY_PRIVATE $NS_PARENT_USERNAME@$NS_PARENT_IP "sudo ./configure_parent.sh $NS_PARENT_IP $DOMAIN $A_RECORD $AAAA_RECORD"

# Remove the text files with DS/glues and the script
ssh -i $SSH_KEY_PRIVATE $NS_CHILD_USERNAME@$NS_CHILD_IP "sudo rm dsset_for_parent.txt glues.txt configure_child.sh"
ssh -i $SSH_KEY_PRIVATE $NS_PARENT_USERNAME@$NS_PARENT_IP "sudo rm dsset_for_parent.txt glues.txt configure_parent.sh"
