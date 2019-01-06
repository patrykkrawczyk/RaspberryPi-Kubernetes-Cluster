#!/bin/bash
#
# Requires:
# setup_node.sh to be executed
#
# Execute like:
# sudo ./setup_slave.sh hostname master_node_ip token
#
# Example:
# sudo ./setup_slave.sh rpinode 192.168.0.101 a1b2c3d4.a1b2c3d4e5f6g7h8a1b2c3d4e5f6g7h8

touch /var/log/setup_slave.log

hostname=$1 # should be of format: rpinode
masterNodeIp=$2 # should be of format: 192.168.0.101
masterNodePort=6443 # should be of format: 6443
token=$3 # should be of format: a1b2c3d4.a1b2c3d4e5f6g7h8a1b2c3d4e5f6g7h8

printf '%s | Setting current working directory to script directory...\n' $hostname | tee -a /var/log/setup_slave.log
cd "$(dirname "$0")"

if [[ -z "${token}" ]]; then
    printf '%s | ERROR | Token not provided!\n' $hostname | tee -a /var/log/setup_slave.log
    exit 1
fi

printf '%s | Joining cluster at %s:%s\n' $hostname $masterNodeIp $masterNodePort | tee -a /var/log/setup_slave.log
kubeadm join --token $token $masterNodeIp:$masterNodePort --discovery-token-unsafe-skip-ca-verification --ignore-preflight-errors=SystemVerification &>> /var/log/setup_slave.log

printf '%s | Slave Node initialization complete!\n' $hostname | tee -a /var/log/setup_slave.log
