
# RaspberryPi Kubernetes Cluster

Here I'm sharing details on how to start your own in-house Kubernetes cluster using multiple Raspberry Pi computers. This can be beneficial for the development of your own projects and gives you a fun tool to play aroudn with.

I've built my cluster with these methods and now using it as my personal server for hosting and practicing cloud development.

## Information

| Term | Details |
|--|--|
| OS | RASPBIAN STRETCH LITE |
| Cluster | multiple computers that are able to communicate with each otehr to accomplish given task |
| Slave Node | a single computer running inside your cluster (in this case a single Raspberry Pi) |
| Master Node | pretty much the same as a typical node but is responsible for gluing all of your cluster together and managing it's state |

Photos - https://photos.app.goo.gl/xIVB6uBk3uCoifJX2

## Tutorial

### Step I - Prepare each Raspberry Pi

1. Download Raspbian Lite Operating System
   - `https://downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-2017-12-01/`
   - Pick `zip` file, no need to unzip it
2. Download balenaEtcher
   - `https://www.balena.io/etcher/`
3. For each of your Raspberry Pi (**this will erase all your data on the card!**)
   1. Insert it's microSD card to your computer
   2. Burn the card with Raspian system using balenaEtcher
   3. After burning OS image on card, enter card directory and add `ssh` file
      - `touch ssh`
      - this will allow us to connect to our nodes by ssh
   4. After adding this file, place card in your Raspberry Pi node and start it
4. After you prepare all of your nodes, continue to the next step

### Step II - Prepare your system to setup Cluster

1. Open your shell
   - If you are running Windows 10
     1. Open PowerShell as Administrator
     2. Run this command
        - `Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux`
     3. Reboot
     4. Install [Ubuntu on Windows](https://www.microsoft.com/en-us/p/ubuntu/9nblggh4msv6?activetab=pivot:overviewtab)
     5. Reboot
     6. If you want to browse your files with Windows Explorer then it's probably located at
        - `C:\Users\USER_NAME\AppData\Local\Packages\CanonicalGroupLimited.UbuntuonWindows_79rhkp1fndgsc\LocalState\rootfs`
2. Move to some directory dedicated to this project
    - `cd ~`
3. Clone this repository
    - `git clone https://github.com/patrykkrawczyk/RPiClusterCloud`
4. Change into repository directory
    - `cd RPiClusterCloud`

### Step III - Configure `ip_addresses.txt` file

#### Here we'll define IP addresses that our router automatically assigned to our nodes

1. Find out your router IP address, usually it's [192.168.0.1](http://192.168.0.1)
2. Log in to your router administration panel, usually you can find credentials on the sticker on the back of your router
3. Find out IP addresses of your Raspberry Pi nodes in your network
4. Edit `ip_addresses.txt` file in `RPiClusterCloud` directory
    - `nano resources/ip_addresses.txt`
5. Write all of the node IP addresses in separate lines
     - **Make sure to specify your Master Node IP address in the first line**

### Step IV - Configure `node_addresses` file

#### Here we'll define static IP addresses that should be assigned to each node after Cluster setup is complete

1. Edit `node_addresses.txt` file in `RPiClusterCloud` directory
    - `nano resources/node_addresses.txt`
2. Write all of the desired static node IP addresses in separate lines
    - **Make sure to specify your Master Node desired static IP address in the first line**

### Step V - Configure `node_hostnames` file

#### Here we'll define hostnames that should be assigned to each node after Cluster setup is complete

1. Edit `node_hostnames.txt` file in `RPiClusterCloud` directory
    - `nano resources/node_hostnames.txt`
2. Write all of the desired node hostnames in separate lines
    - **Make sure to specify your Master Node desired hostname in the first line**

### Step VI - Checkpoint

#### Make sure everything is configured properly

1. `ip_addresses`, `node_addresses.txt`, `node_hostnames.txt` has the same number of lines
2. All rows within these files refer to the same node

    | ip_addresses | node_addresses | node_hostnames |
    |---|---|---|
    | 192.168.0.204 | 192.168.0.101 | rpinode01 |
    | 192.168.0.205 | 192.168.0.102 | rpinode02 |
    | 192.168.0.202 | 192.168.0.103 | rpinode03 |

    Such configuration would result in 3 node cluster where
    - rpinode01 is a Master Node with static IP 192.168.0.101
    - rpinode02 is a Slave Node with static IP 192.168.0.102
    - rpinode03 is a Slave Node with static IP 192.168.0.103

### Step VII - Run Cluster setup script

1. Script assumes default Raspberry Pi credentials which are
   - `pi / raspberry`
2. Execute `setup_cluster.sh` script with `router_id` as argument and `sudo` rights
   - `sudo ./scripts/setup_cluster.sh 192.168.0.1`
