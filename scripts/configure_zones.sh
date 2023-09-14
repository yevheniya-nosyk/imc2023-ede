#!/bin/bash

# The root directory of this repository
repo_dir=$(git rev-parse --show-toplevel)

# Load the configuration file
source $repo_dir/.env

# We start with configuring the child, as child zones will produce resource records to be added to the parent zone

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

# Remove the text files with DS and glues
ssh -i $SSH_KEY_PRIVATE $NS_CHILD_USERNAME@$NS_CHILD_IP "sudo rm dsset_for_parent.txt glues.txt"
ssh -i $SSH_KEY_PRIVATE $NS_PARENT_USERNAME@$NS_PARENT_IP "sudo rm dsset_for_parent.txt glues.txt"
