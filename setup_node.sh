#!/bin/sh
# Execute like:
# sudo ./setup_node.sh hostname node_ip router_ip
# Example:
# sudo ./setup_node.sh rpinode 192.168.0.102 192.168.0.1

# Set current working directory to script directory
cd "$(dirname "$0")"

# Update system
apt-get update
apt-get upgrade -y

# Expand filesystem
raspi-config nonint do_expand_rootfs

# Copy SSH file toggle
touch /boot/ssh

hostname=$1 # should be of format: host
ip=$2 # should be of format: 192.168.1.100
dns=$3 # should be of format: 192.168.1.1

# Change the hostname
hostnamectl --transient set-hostname $hostname
hostnamectl --static set-hostname $hostname
hostnamectl --pretty set-hostname $hostname
sed -i s/raspberrypi/$hostname/g /etc/hosts

# Set the static ip
cat <<EOT >> /etc/dhcpcd.conf
interface eth0
static ip_address=$ip/24
static routers=$dns
static domain_name_servers=$dns
EOT

# Install Docker
curl -sSL get.docker.com | sh
usermod pi -aG docker

# Disable Swap
dphys-swapfile swapoff
dphys-swapfile uninstall
update-rc.d dphys-swapfile remove

orig="$(head -n1 /boot/cmdline.txt) cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory"
echo $orig | tee /boot/cmdline.txt

# Add repo list and install kubeadm
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet=1.9.0-00 kubectl=1.9.0-00 kubeadm=1.9.0-00

reboot
