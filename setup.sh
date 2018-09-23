#!/bin/bash
currentUser=`whoami`
if [ $currentUser != "root" ]; then
	echo "ERROR! This script must be run as ROOT or SUDO!"
	exit 1
fi

#Colors for altering text
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

#Helper used for finding index of substrings
strindex() { 
  x="${1%%$2*}"
  [[ "$x" = "$1" ]] && echo -1 || echo "${#x}"
}

PACKAGE_ARRAY=();

echo -n "##Setting up DPKG for i386...";
sudo dpkg --add-architecture i386 2> /dev/null;
if [ $? -eq 0 ]
then
  echo "${GREEN}SUCCESS!${NC}"
else
  echo "${RED}FAILED!${NC}" >&2
fi

echo "##Updating apt-get database...";
sudo apt-get -y update 2> /dev/null;

echo "##Adding Software Properties package (for apt-add-repository)..."
sudo apt -y install software-properties-common 2> /dev/null;

echo -n "##Changing default Ubuntu shell from dash to bash..."
export DEBIAN_FRONTEND=noninteractive;
export DEBCONF_NONINTERACTIVE_SEEN=true;
echo "dash dash/sh boolean false" | debconf-set-selections;
dpkg-reconfigure dash 2> /dev/null;
unset DEBIAN_FRONTEND;
unset DEBCONF_NONINTERACTIVE_SEEN;
if [ $? -eq 0 ]
then
  echo "${GREEN}SUCCESS!${NC}"
else
  echo "${RED}FAILED!${NC}" >&2
fi

echo "##Checking for Intel CPU..."
echo "##Installing Intel microcode package..."
#AuthenticAMD / GenuineIntel
sudo apt-get -y install intel-microcode;
sudo apt-get -y install amd64-microcode;


echo "##Checking video adapter hardware..."
video_line=`lspci | grep VGA`;

