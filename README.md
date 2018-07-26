# RPiClusterCloud
I've built RPi cluster, which is now used as my personal server for hosting and practicing cloud development

## Information
* OS: RASPBIAN STRETCH LITE
* https://downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-2017-12-01/
* Photos: https://photos.app.goo.gl/xIVB6uBk3uCoifJX2

## Installation instructions
* Ensure sudo rights
  * `sudo -i`
* Download this repository
  * `wget https://github.com/patrykkrawczyk/RPiClusterCloud/archive/master.zip`
* Unzip downloaded repository
  * `unzip master.zip`
* Move to installation directory
  * `cd RPiClusterCloud-master`
* Add required permissions to installation script
  * `sudo chmod 755 ./setup_node.sh`
* Execute installation script on each node
  * `sudo ./setup_node.sh`
