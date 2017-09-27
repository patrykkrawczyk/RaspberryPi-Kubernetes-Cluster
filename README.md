# RPiClusterCloud
I've built RPi cluster, which is now used as my personal server for hosting and practicing cloud development

## Information
* OS: RASPBIAN STRETCH LITE

## Installation instructions
* Install git
  * `sudo apt install git -y`
* Prepare repository location
  * `[ -d /repository ] || sudo mkdir /repository`
  * `cd /repository`
* Clone this repository
  * `sudo git clone https://github.com/patrykkrawczyk/RPiClusterCloud.git`
* Move to installation directory
  * `cd RPiClusterCloud/nodes`
* Execute installation script
  * Regular: `sudo ./setup_node.sh`
  * Master: `sudo ./setup_node.sh master`
