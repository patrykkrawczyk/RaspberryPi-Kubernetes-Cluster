#!/bin/bash
# Requires:
# setup_node.sh to be executed
# Execute like:
# sudo ./setup_master.sh hostname node_ip router_ip
# Example:
# sudo ./setup_master.sh rpinode 192.168.0.102 192.168.0.1

# Set current working directory to script directory
cd "$(dirname "$0")"

hostname=$1 # should be of format: host
ip=$2 # should be of format: 192.168.0.100
dns=$3 # should be of format: 192.168.0.1

# Initialize master node
sudo kubeadm init --config master_node_kubeadm_conf.yaml

# Kubernetes related configuration
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Add networking
kubectl apply -f https://git.io/weave-kube-1.6
