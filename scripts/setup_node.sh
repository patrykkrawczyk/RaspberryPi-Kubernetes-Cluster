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

printf '%s | Setting current working directory to script directory...\n' $hostname | tee -a /var/log/setup_node.log
cd "$(dirname "$0")"

printf '%s | Loading environment variables...\n' $hostname | tee -a /var/log/setup_node.log
set -a; source /etc/environment; set +a;

if [[ -z "${NODE_SETUP_COMPLETE}" ]]; then
    printf '%s | Initializing node...\n' $hostname | tee -a /var/log/setup_node.log
else
    printf '%s | ERROR | This node has already been initialized!\n' $hostname | tee -a /var/log/setup_node.log
    exit 1
fi

printf '%s | Updating system...\n' $hostname | tee -a /var/log/setup_node.log
apt-get update &>> /var/log/setup_node.log

#printf '%s | Upgrading system...\n' $hostname | tee -a /var/log/setup_node.log
#apt-get upgrade -y &>> /var/log/setup_node.log

printf '%s | Expanding filesystem...\n' $hostname | tee -a /var/log/setup_node.log
raspi-config nonint do_expand_rootfs &>> /var/log/setup_node.log

printf '%s | Adding permanent SSH toggle...\n' $hostname | tee -a /var/log/setup_node.log
touch /boot/ssh

printf '%s | Changing hostname to $hostname...\n' $hostname | tee -a /var/log/setup_node.log
hostnamectl --transient set-hostname $hostname
hostnamectl --static set-hostname $hostname
hostnamectl --pretty set-hostname $hostname
sed -i s/raspberrypi/$hostname/g /etc/hosts

printf '%s | Setting static IP to %s and DNS to %s...\n' $hostname $ip $dns | tee -a /var/log/setup_node.log
cat <<EOT >> /etc/dhcpcd.conf
interface eth0
static ip_address=$ip/24
static routers=$dns
static domain_name_servers=$dns
EOT

printf '%s | Installing Docker...\n' $hostname | tee -a /var/log/setup_node.log
curl -sSL get.docker.com | sh &>> /var/log/setup_node.log
usermod pi -aG docker &>> /var/log/setup_node.log

printf '%s | Disabling swap file...\n' $hostname | tee -a /var/log/setup_node.log
dphys-swapfile swapoff
dphys-swapfile uninstall
update-rc.d dphys-swapfile remove

printf '%s | Modifying node boot arguments...\n' $hostname | tee -a /var/log/setup_node.log
orig="$(head -n1 /boot/cmdline.txt) cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory"
echo $orig > /boot/cmdline.txt

printf '%s | Adding Google repository...\n' $hostname | tee -a /var/log/setup_node.log
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add &>> /var/log/setup_node.log
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list

printf '%s | Updating system...\n' $hostname | tee -a /var/log/setup_node.log
apt-get update &>> /var/log/setup_node.log

printf '%s | Checking if kubelet is already installed...\n' $hostname | tee -a /var/log/setup_node.log
dpkg -s kubelet &>> /dev/null
if [ $? -ne 0 ]; then
    printf '%s | Installing kubelet=%s...\n' $hostname $kubernetesVersion | tee -a /var/log/setup_node.log
    apt-get -y install kubelet=$kubernetesVersion &>> /var/log/setup_node.log
else
    printf '%s | kubelet is already installed.\n' $hostname | tee -a /var/log/setup_node.log
fi

printf '%s | Checking if kubectl is already installed...\n' $hostname | tee -a /var/log/setup_node.log
dpkg -s kubectl &>> /dev/null
if [ $? -ne 0 ]; then
    printf '%s | Installing kubectl=%s...\n' $hostname $kubernetesVersion | tee -a /var/log/setup_node.log
    apt-get -y install kubectl=$kubernetesVersion &>> /var/log/setup_node.log
else
    printf '%s | kubectl is already installed.\n' $hostname | tee -a /var/log/setup_node.log
fi

printf '%s | Checking if kubeadm is already installed...\n' $hostname | tee -a /var/log/setup_node.log
dpkg -s kubeadm &>> /dev/null
if [ $? -ne 0 ]; then
    printf '%s | Installing kubeadm=%s...\n' $hostname $kubernetesVersion | tee -a /var/log/setup_node.log
    apt-get -y install kubeadm=$kubernetesVersion &>> /var/log/setup_node.log
else
    printf '%s | kubeadm is already installed.\n' $hostname | tee -a /var/log/setup_node.log
fi

printf '%s | Marking node as initialized...\n' $hostname | tee -a /var/log/setup_node.log
echo "NODE_SETUP_COMPLETE=1" >> /etc/environment

printf '%s | Node initialized!\n' $hostname | tee -a /var/log/setup_node.log

printf '%s | Rebooting!\n' $hostname | tee -a /var/log/setup_node.log
reboot