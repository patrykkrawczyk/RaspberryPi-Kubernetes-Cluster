#!/bin/bash
#
# Requires:
# setup_node.sh to be executed
#
# Execute like:
# sudo ./setup_master.sh hostname token
#
# Example:
# sudo ./setup_master.sh rpinode a1b2c3.a1b2c3d4e5f6g7h8

touch /var/log/setup_master.log

hostname=$1 # should be of format: host
token=$2 # should be of format: a1b2c3.a1b2c3d4e5f6g7h8

echo "$hostname | Setting current working directory to script directory..." | tee -a /var/log/setup_master.log
cd "$(dirname "$0")"

if [[ -z "${token}" ]]; then
    echo "$hostname | Token not provided, generating..." | tee -a /var/log/setup_master.log
    token=$(kubeadm token generate)
fi

echo "$hostname | Generating Kubernetes Configuration file..." | tee -a /var/log/setup_master.log
cat <<EOT >> ./kubeConfig.yaml
apiVersion: kubeadm.k8s.io/v1alpha1
kind: MasterConfiguration
token: $token
tokenTTL: 0s
controllerManagerExtraArgs:
  pod-eviction-timeout: 10s
  node-monitor-grace-period: 10s
EOT

echo "$hostname | Initializing Kubernetes on Master Node..." | tee -a /var/log/setup_master.log
kubeadm init --config ./kubeConfig.yaml --ignore-preflight-errors=SystemVerification &>> /var/log/setup_master.log

echo "$hostname | Starting Kubernetes..." | tee -a /var/log/setup_master.log
mkdir -p $HOME/.kube
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo "$hostname | Setting KUBECONFIG environment variable..." | tee -a /var/log/setup_master.log
export KUBECONFIG=$HOME/.kube/config

echo "$hostname | Adding Kubernetes networking using Weave..." | tee -a /var/log/setup_master.log
kubectl apply -f https://git.io/weave-kube-1.6 &>> /var/log/setup_master.log

echo "$hostname | Master Node initialization complete!" | tee -a /var/log/setup_master.log