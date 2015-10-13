#!/usr/bin/env bash
#Set up build environment for Dragino v2 Yun Firmware. Only need to run once on first compile. 

USAGE="Usage: . ./set_up_build_enviroment.sh"

REPO_PATH=$(pwd)
OPENWRT_PATH='openwrt'

echo "*** Download Dragino Packages"
git clone https://github.com/dragino/dragino-packages.git dragino-packages


echo "*** Update the feeds, update result please see feed_update.log"
echo "*** Update process may take several minutes"
sleep 2
$OPENWRT_PATH/scripts/feeds update > feeds_update.log
sleep 2
echo " "

echo "*** Install OpenWrt packages"
sleep 10
$OPENWRT_PATH/scripts/feeds install -a
echo " "

#Remove tmp directory
rm -rf $OPENWRT_PATH/tmp/

echo "*** Download dl source"
git clone https://github.com/dragino/Dragino2_dl_bak.git dl
mv dl/dl $OPENWRT_PATH
echo " "
echo "End of script"