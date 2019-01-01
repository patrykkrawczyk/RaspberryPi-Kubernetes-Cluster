#!/bin/bash
# Requires:
# setup_node.sh to be executed
# Execute like:
# sudo ./setup_slave.sh master_node_ip token
# Example:
# sudo ./setup_slave.sh 192.168.0.101 xxxyyyzzz

# Set current working directory to script directory
cd "$(dirname "$0")"

masterNodeIp=$1 # should be of format: 192.168.0.101
token=$2 # should be of format: xxxyyyzzz
