#!/bin/bash
#
# Execute like:
# sudo ./setup_cluster.sh router_ip
#
# Example:
# sudo ./setup_cluster.sh 192.168.0.1

touch /var/log/setup_cluster.log

dns=$1 # should be of format: 192.168.0.1
username="pi"
password="raspberry"

echo "SETUP_CLUSTER | Setting current working directory to script directory..." | tee -a /var/log/setup_cluster.log
cd "$(dirname "$0")"

echo "SETUP_CLUSTER | Parsing resource .txt files into arrays..." | tee -a /var/log/setup_cluster.log
readarray ips < ../resources/ip_addresses.txt
readarray sips < ../resources/node_addresses.txt
readarray hostnames < ../resources/node_hostnames.txt

if [ ${#ips[@]} -ne ${#sips[@]} ] || [ ${#ips[@]} -ne ${#hostnames[@]} ] || [ ${#sips[@]} -ne ${#hostnames[@]} ]; then
    echo "SETUP_CLUSTER | ERROR | All .txt resource files must have the same number of lines!" | tee -a /var/log/setup_cluster.log
    exit 1
else
    echo "SETUP_CLUSTER | All .txt resource files have the same number of lines..." | tee -a /var/log/setup_cluster.log
fi

if [ ${#ips[@]} -eq 0 ]; then
    echo "SETUP_CLUSTER | ERROR | There must be at least a single node defined within all .txt resource files!" | tee -a /var/log/setup_cluster.log
    exit 1
else
    echo "SETUP_CLUSTER | This configuration is available for initialization" | tee -a /var/log/setup_cluster.log
fi

echo "SETUP_CLUSTER | Checking if all devices are available on network..." | tee -a /var/log/setup_cluster.log
for ((i=0; i < ${#ips[@]}; i++)); do
    printf 'SETUP_CLUSTER | Checking IP: %s...\n' ${ips[$i]} | tee -a /var/log/setup_cluster.log
    ping -c 1 ${ips[$i]} &> /dev/null
    if [ $? -eq 0 ]; then
        printf 'SETUP_CLUSTER | IP: %s is available.\n' ${ips[$i]} | tee -a /var/log/setup_cluster.log
    else
        printf 'SETUP_CLUSTER | Device at IP: %s is unavailable!\n' ${ips[$i]} | tee -a /var/log/setup_cluster.log
        exit 1;
    fi
done

echo "SETUP_CLUSTER | Checking if sshpass is already installed..." | tee -a /var/log/setup_cluster.log
dpkg -s sshpass &>> /dev/null

if [ $? -ne 0 ]; then
    echo "SETUP_CLUSTER | Installing sshpass..." | tee -a /var/log/setup_cluster.log
    apt-get -y install sshpass &>> /var/log/setup_node.log
else
    echo "SETUP_CLUSTER | sshpass is already installed." | tee -a /var/log/setup_cluster.log
fi

echo "SETUP_CLUSTER | Initializing all nodes..." | tee -a /var/log/setup_cluster.log
for ((i=0; i < ${#ips[@]}; i++)); do
    printf 'SETUP_CLUSTER | Initializing node: %s...\n' ${hostnames[$i]} | tee -a /var/log/setup_cluster.log
    sshpass -p $password ssh -o StrictHostKeyChecking=no $username@${ips[$i]} sudo bash -s < ./setup_node.sh ${hostnames[$i]} ${sips[$i]} $dns
done

echo "SETUP_CLUSTER | Waiting 30s to ensure all nodes start after rebooting..." | tee -a /var/log/setup_cluster.log
sleep 30s &>> /var/log/setup_cluster.log

echo "SETUP_CLUSTER | Generating Cluster token..." | tee -a /var/log/setup_cluster.log
token_left=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 6 | head -n 1)
token_right=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 16 | head -n 1)
token="$token_left.$token_right"

if [[ -z "${token}" ]]; then
    echo "SETUP_CLUSTER | Token generation failed, cancelling..." | tee -a /var/log/setup_cluster.log
    exit 1
fi

echo "SETUP_CLUSTER | Setting up Master Node..." | tee -a /var/log/setup_cluster.log
sshpass -p $password ssh -o StrictHostKeyChecking=no $username@${sips[0]} sudo bash -s < ./setup_master.sh ${hostnames[0]} $token

for ((i=1; i < ${#sips[@]}; i++)); do
    printf 'SETUP_CLUSTER | Connecting node: %s to Master Node...\n' ${hostnames[$i]} | tee -a /var/log/setup_cluster.log
    sshpass -p $password ssh -o StrictHostKeyChecking=no $username@${sips[$i]} sudo bash -s < ./setup_slave.sh ${hostnames[$i]} ${sips[0]} $token
done

echo "SETUP_CLUSTER | Cluster initialized!" | tee -a /var/log/setup_cluster.log

echo "SETUP_CLUSTER | Deploying Kubernetes Dashboard on Master Node..." | tee -a /var/log/setup_cluster.log
sshpass -p $password ssh -o StrictHostKeyChecking=no $username@${sips[0]} sudo bash -s < ./setup_dashboard.sh ${hostnames[0]} ${sips[0]}

echo "SETUP_CLUSTER | That's all! Enjoy!" | tee -a /var/log/setup_cluster.log
