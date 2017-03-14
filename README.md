Dragino Yun -- A customized Arduino Yún version for Dragino Devices
===============
**OpenWrt Yun** is the official source code installed in [Arduino Yun](arduino.cc/en/Main/ArduinoBoardYun).

This repository is forked from the OpenWrt Yun and add some customized feature to use in Dragino Devices such as:
[MS14](http://www.dragino.com/products/mother-board.html), [HE](http://www.dragino.com/products/linux-module/item/87-he.html) and [Yun Shield](http://www.dragino.com/products/yunshield.html).

There is another more generic firmware version for IoT,VoIP and Mesh. With the source in [this link](https://github.com/dragino/dragino2/)

Difference between these two firmware can be found [difference between IoT Mesh and Dragino Yun firmware](http://wiki.dragino.com/index.php?title=Firmware_and_Source_Code)

How to compile the image?
===============
``` bash
git clone https://github.com/dragino/openwrt-yun Dragino-Yun
cd Dragino-Yun
./set_up_build_enviroment.sh    //only need to run at the first time. 
./build_image.sh
```
After complination, the images can be found on **Dragino-Yun/image** folder. The folder includes:

* dragino2-yun-common-vxxx-kernel.bin  kernel files, for upgrade in u-boot
* dragino2-yun-common-vxxx-rootfs-squashfs.bin    rootfs file, for upgrade in u-boot
* dragino2-yun-common-vxxx-squashfs-sysupgrade.bin   sysupgrade file, used for web-ui upgrade
* md5sum  md5sum for above files


How to debug if build fails?
===============
``` bash
cd Dragino-Yun/openwrt
make V=s
```
Above commands will enable verbose and build in single thread to get a view of the error during build. 


How to make customized build?
===============
in **Dragino-Yun/openwrt folder**, creat the customized folder like **files-YOUR_BUILD_NAME** or customized config **.config.YOUR_BUILD_NAME**.

in **Dragino-Yun** folder, run 
``` bash
./build_image.sh YOUR_BUILD_NAME
``` 

The build process will replace default files and .config with the customized files, and generate the image in **Dragino-Yun/image**

Have fun on Dragino Yun !!!
