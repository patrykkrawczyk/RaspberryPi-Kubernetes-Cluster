#!/bin/bash
# Requires:
# Execute like:
# sudo ./setup_cluster.sh router_ip
# Example:
# sudo ./setup_cluster.sh 192.168.0.1

echo "SETUP_CLUSTER | Loading arguments as variables..." | tee -a ../setup_cluster.log
dns=$1 # should be of format: 192.168.0.1

echo "SETUP_CLUSTER | Setting current working directory to script directory..." | tee -a ../setup_cluster.log
cd "$(dirname "$0")"

echo "SETUP_CLUSTER | Parsing resource .txt files into arrays..." | tee -a ../setup_cluster.log
readarray ips < ../resources/ip_addresses.txt
readarray sips < ../resources/node_addresses.txt
readarray hostnames < ../resources/node_hostnames.txt

if [ ${#ips[@]} -ne ${#sips[@]} ] || [ ${#ips[@]} -ne ${#hostnames[@]} ] || [ ${#sips[@]} -ne ${#hostnames[@]} ]; then
    echo "SETUP_CLUSTER | ERROR | All .txt resource files must have the same number of lines!" | tee -a ../setup_cluster.log
    exit 1
else
    echo "SETUP_CLUSTER | All .txt resource files have the same number of lines..." | tee -a ../setup_cluster.log
fi

if [ ${#ips[@]} -eq 0 ]; then
    echo "SETUP_CLUSTER | ERROR | There must be at least a single node defined within all .txt resource files!" | tee -a ../setup_cluster.log
    exit 1
else
    echo "SETUP_CLUSTER | This configuration is available for initialization" | tee -a ../setup_cluster.log
fi

echo "SETUP_CLUSTER | Checking if sshpass is already installed..." | tee -a ../setup_cluster.log
dpkg -s sshpass &> /dev/null

if [ $? -ne 0 ]; then
    echo "SETUP_CLUSTER | Installing sshpass..." | tee -a ../setup_cluster.log
    apt-get -y install sshpass
else
    echo "SETUP_CLUSTER | sshpass is already installed." | tee -a ../setup_cluster.log
fi

echo "SETUP_CLUSTER | Initializing all nodes..." | tee -a ../setup_cluster.log
for ((i=0; i < ${#ips[@]}; i++)); do
    echo "SETUP_CLUSTER | Initializing node: ${hostnames[$i]}..." | tee -a ../setup_cluster.log
    sshpass -p "raspberry" ssh -o StrictHostKeyChecking=no pi@${ips[$i]} sudo bash -s < ./setup_node.sh ${hostnames[$i]} ${sips[$i]} $1
done

# Initialize Master Node
echo "SETUP_CLUSTER | Setting up Master Node..." | tee -a ../setup_cluster.log

# Connect Slave Nodes
for ((i=1; i < ${#ips[@]}; i++)); do
    echo "SETUP_CLUSTER | Connecting node: ${hostnames[$i]} to Master Node..." | tee -a ../setup_cluster.log
done

echo "SETUP_CLUSTER | Cluster initialized!" | tee -a ../setup_cluster.log