#!/usr/bin/env bash
#Build Arduino Yun Image for Dragino2. MS14, HE. 

USAGE="Usage: . ./build_image.sh oem-application"

REPO_PATH=$(pwd)
cd openwrt

APP=common

if [ $1 ]; then 
	APP=$1
	if [ -d files-$APP ] || [ -f .config.$APP ]; then
		#########################
		echo ''
		echo "Start build process for application $APP"
		echo ''
		###########################
	else
		echo ''
		echo 'APP directory or .config are not existing'
		echo ''
		exit 0
	fi
fi

VERSION=2.0.2
BUILD=$APP-$VERSION
BUILD_TIME="`date`"

echo ""
echo "Remove custom files from last build"
rm -rf files

cp -r files-common files

if [ -d files-$APP ];then
	echo ""
	echo "Find customized $APP files. Copy $APP files"
	echo "Copy files-$APP to default files directory"
	echo ""
	cp -rf files-$APP/* files
fi

if [ -f .config.$APP ];then
	echo ""
	echo "Find customized .config files"
	echo "Replace default .config file with .config.$APP"
	echo ""
	cp .config.$APP .config
fi

echo ""
echo "Update version and build date"
sed -i "s/VERSION/$BUILD/g" files/etc/banner
sed -i "s/TIME/$BUILD_TIME/g" files/etc/banner
echo ""

echo ""
echo "Run make for ms14"
make -j8 V=99

echo "Copy Image"
echo "Set up new directory name with date"
DATE=`date +%Y%m%d-%H%M`
mkdir -p $REPO_PATH/image/$APP-build--v$VERSION--$DATE
IMAGE_DIR=$REPO_PATH/image/$APP-build--v$VERSION--$DATE

echo  "Copy files to ./image folder"
cp ./bin/ar71xx/openwrt-ar71xx-generic-yun-16M-kernel.bin     $IMAGE_DIR/dragino2-yun-$APP-v$VERSION-kernel.bin
cp ./bin/ar71xx/openwrt-ar71xx-generic-yun-16M-rootfs-squashfs.bin   $IMAGE_DIR/dragino2-yun-$APP-v$VERSION-rootfs-squashfs.bin
cp ./bin/ar71xx/openwrt-ar71xx-generic-yun-16M-squashfs-sysupgrade.bin $IMAGE_DIR/dragino2-yun-$APP-v$VERSION-squashfs-sysupgrade.bin


echo "Update md5sums"
cat ./bin/ar71xx/md5sums | grep "yun-16M" | awk '{gsub(/openwrt-ar71xx-generic-yun-16M/,"dragino2-yun-'"$APP"'-v'"$VERSION"'")}{print}' >> $IMAGE_DIR/md5sums

echo ""
echo "End Dragino2 build"
echo ""


