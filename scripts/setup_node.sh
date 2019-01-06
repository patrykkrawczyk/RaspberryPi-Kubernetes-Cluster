#!/bin/bash
#
# Execute like:
# sudo ./setup_node.sh hostname node_ip router_ip
#
# Example:
# sudo ./setup_node.sh rpinode 192.168.0.102 192.168.0.1

touch /var/log/setup_node.log

kubernetesVersion=1.9.0-00
hostname=$1 # should be of format: rpinode
ip=$2 # should be of format: 192.168.0.100
dns=$3 # should be of format: 192.168.0.1

echo "$hostname | Setting current working directory to script directory..." | tee -a /var/log/setup_node.log
cd "$(dirname "$0")"

echo "$hostname | Loading environment variables..." | tee -a /var/log/setup_node.log
set -a; source /etc/environment; set +a;

if [[ -z "${NODE_SETUP_COMPLETE}" ]]; then
    echo "$hostname | Initializing node..." | tee -a /var/log/setup_node.log
else
    echo "$hostname | ERROR | This node has already been initialized!" | tee -a /var/log/setup_node.log
    exit 1
fi

echo "$hostname | Updating system..." | tee -a /var/log/setup_node.log
apt-get update &>> /var/log/setup_node.log

echo "$hostname | Upgrading system..." | tee -a /var/log/setup_node.log
apt-get upgrade -y &>> /var/log/setup_node.log

echo "$hostname | Expanding filesystem..." | tee -a /var/log/setup_node.log
raspi-config nonint do_expand_rootfs &>> /var/log/setup_node.log

echo "$hostname | Adding permanent SSH toggle..." | tee -a /var/log/setup_node.log
touch /boot/ssh

echo "$hostname | Changing hostname to $hostname..." | tee -a /var/log/setup_node.log
hostnamectl --transient set-hostname $hostname
hostnamectl --static set-hostname $hostname
hostnamectl --pretty set-hostname $hostname
sed -i s/raspberrypi/$hostname/g /etc/hosts

echo "$hostname | Setting static IP to $ip and DNS to $dns..." | tee -a /var/log/setup_node.log
cat <<EOT >> /etc/dhcpcd.conf
interface eth0
static ip_address=$ip/24
static routers=$dns
static domain_name_servers=$dns
EOT

echo "$hostname | Installing Docker..." | tee -a /var/log/setup_node.log
curl -sSL get.docker.com | sh &>> /var/log/setup_node.log
usermod pi -aG docker &>> /var/log/setup_node.log

echo "$hostname | Disabling swap file..." | tee -a /var/log/setup_node.log
dphys-swapfile swapoff
dphys-swapfile uninstall
update-rc.d dphys-swapfile remove

echo "$hostname | Modifying node boot arguments..." | tee -a /var/log/setup_node.log
orig="$(head -n1 /boot/cmdline.txt) cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory"
echo $orig > /boot/cmdline.txt

echo "$hostname | Adding Google repository..." | tee -a /var/log/setup_node.log
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add &>> /var/log/setup_node.log
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list

echo "$hostname | Updating system..." | tee -a /var/log/setup_node.log
apt-get update &>> /var/log/setup_node.log

echo "$hostname | Checking if kubelet is already installed..." | tee -a ../setup_cluster.log
dpkg -s kubelet &>> /dev/null
if [ $? -ne 0 ]; then
    echo "$hostname | Installing kubelet=$kubernetesVersion..." | tee -a ../setup_cluster.log
    apt-get -y install kubelet=$kubernetesVersion &>> /var/log/setup_node.log
else
    echo "$hostname | kubelet is already installed." | tee -a ../setup_cluster.log
fi

echo "$hostname | Checking if kubectl is already installed..." | tee -a ../setup_cluster.log
dpkg -s kubectl &>> /dev/null
if [ $? -ne 0 ]; then
    echo "$hostname | Installing kubectl=$kubernetesVersion..." | tee -a ../setup_cluster.log
    apt-get -y install kubectl=$kubernetesVersion &>> /var/log/setup_node.log
else
    echo "$hostname | kubectl is already installed." | tee -a ../setup_cluster.log
fi

echo "$hostname | Checking if kubeadm is already installed..." | tee -a ../setup_cluster.log
dpkg -s kubeadm &>> /dev/null
if [ $? -ne 0 ]; then
    echo "$hostname | Installing kubeadm=$kubernetesVersion..." | tee -a ../setup_cluster.log
    apt-get -y install kubeadm=$kubernetesVersion &>> /var/log/setup_node.log
else
    echo "$hostname | kubeadm is already installed." | tee -a ../setup_cluster.log
fi

echo "$hostname | Marking node as initialized..." | tee -a /var/log/setup_node.log
echo "NODE_SETUP_COMPLETE=1" >> /etc/environment

echo "$hostname | Node initialized!" | tee -a /var/log/setup_node.log

echo "$hostname | Rebooting!" | tee -a /var/log/setup_node.log
reboot