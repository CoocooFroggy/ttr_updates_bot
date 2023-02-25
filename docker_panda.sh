#!/bin/bash

apt update
apt install -y python3-pip
#apt install -y build-essential pkg-config fakeroot python3-dev libpng-dev libjpeg-dev libtiff-dev zlib1g-dev libssl-dev libx11-dev libgl1-mesa-dev libxrandr-dev libxxf86dga-dev libxcursor-dev bison flex libfreetype6-dev libvorbis-dev libeigen3-dev libopenal-dev libode-dev libbullet-dev libgtk-3-dev libassimp-dev libopenexr-dev
#
#git clone 'https://github.com/panda3d/panda3d.git'
#cd panda3d/ || exit
#python3 makepanda/makepanda.py --everything --installer --no-egl --no-gles --no-gles2 --no-opencv
#dpkg -i panda3d*.deb
pip3 install panda3d