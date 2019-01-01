
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
   3. After burning OS image on card, place it in your Raspberry Pi node and start it
4. After you burn all of your nodes with fresh system image, continue to the next step 

### Step II - Setup Master Node

 1. SSH into your master node
 2. Ensure sudo rights
 3. `sudo -i`
 4. Download this repository
 5. `wget https://github.com/patrykkrawczyk/RPiClusterCloud/archive/master.zip`
 6. Unzip downloaded repository
 7. `unzip master.zip`
 8. Move to installation directory
 9. `cd RPiClusterCloud-master`
 10. Add required permissions to installation script
 11. `sudo chmod 755 ./setup_node.sh`
 12. Execute installation script on each node
 13. `sudo ./setup_node.sh hostname node_ip router_ip`
 14. `sudo ./setup_node.sh rpinode 192.168.0.102 192.168.0.1`
