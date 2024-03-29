#!/bin/bash
DISTRIB_CODENAME=`cat /etc/lsb-release | grep DISTRIB_CODENAME | sed 's/DISTRIB_CODENAME\=\(\.*\)/\1/g'`
WX_DEB="deb http://apt.wxwidgets.org/ $DISTRIB_CODENAME-wx main"
CB_DEB="deb http://lgp203.free.fr/ubuntu/ $DISTRIB_CODENAME universe"

echo $WX_DEB > /etc/apt/sources.list.d/wx.list
echo $CB_DEB > /etc/apt/sources.list.d/cb-nightly.list

wget -q http://apt.wxwidgets.org/key.asc -O- | apt-key add -
wget -q http://lgp203.free.fr/public.key -O- | apt-key add -

apt-get update

apt-get install libcodeblocks0 codeblocks libwxsmithlib0 codeblocks-contrib

apt-get install freeglut3-dev libasound2-dev libxmu-dev libxxf86vm-dev g++ libgl1-mesa-dev libglu1-mesa-dev libraw1394-dev
