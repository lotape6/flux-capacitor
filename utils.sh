#!/bin/bash

ARCH=""
case $(uname -m) in
    i386)   ARCH="386" ;;
    i686)   ARCH="386" ;;
    x86_64) ARCH="amd64" ;;
    arm)    dpkg --print-ARCH | grep -q "arm64" && ARCH="arm64" || ARCH="arm" ;;
esac

# install $PACKAGE_NAME 
# Checks which package manager exist and installs the package using the appropriate one
install (){
   if   [ -x "$(command -v apk)" ];       then sudo apk add --no-cache $1
   elif [ -x "$(command -v apt-get)" ]; then sudo apt-get install $1
   elif [ -x "$(command -v dnf)" ];     then sudo dnf install $1
   elif [ -x "$(command -v zypper)" ];  then sudo zypper install $1
   elif [ -x "$(command -v pacman)" ];  then sudo pacman -S $1
   else  echo "Sorry, package manager not detected. Please modify the script to run smoothly and share!" >> $log_file
   fi
}

# install_deb $DEB_FILE
install_deb (){
   if [ -x "$(command -v dpkg)" ];       then sudo dpkg -i $1
   else  echo "Sorry, deb installer not detected. Please modify the script to run smoothly and share!"  >> $log_file
   fi
}

# try_install $PACKAGE_NAME $PACKAGE_URL   [$ARCH flag supported]
# Checks if the package is already installed, if not, tries to install it from repositories or the given .deb URL
try_install () {
   if [ ${enable[$1]} = "true" ] && [ ! "$(command -v ${3:-$1})" ]; then
      banner $1
      install $1
      if [ $? -gt 0 ]
      then
         wget $2
         FILE=$(basename $2)
         install_deb $FILE 
         if [ $? -gt 0 ]; then echo "$1 with repo $2 not installed. Please install manually." >> $log_file ; fi
         rm $FILE 
      fi
   else 
      echo "$1 already installed!" >> $log_file
   fi
   # WRITE TO CONFIG OR LOG
}

# banner $TEXT
# Prints a fantasy LGTBI* friendly banner with the given text
banner() {
   toilet -f bigmono9 -F gay $1 ; sleep 0.5 
}