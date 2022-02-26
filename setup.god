 #!/bin/bash

# Uncredible and fantastyk installation script of best terminal useful tools based on #
#        ----------> https://github.com/ibraheemdev/modern-unix <----------           #
#                                       |----------> <3U

mkdir -p ~/.flux-capacitor/logs
curr_tstamp=$(date "+%Y.%m.%d-%H.%M.%S")
log_file=~/.flux-capacitor/logs/flux-capacitor-$curr_tstamp.log

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
   if [ ! -x '$(command -v $1)' ]; then
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
   fi
   # WRITE TO CONFIG OR LOG
}

# banner $TEXT
# Prints a fantasy LGTBI* friendly banner with the given text
banner() {
   toilet -f bigmono9 -F gay $1 ; sleep 0.5 
}

ARCH=""
case $(uname -m) in
    i386)   ARCH="386" ;;
    i686)   ARCH="386" ;;
    x86_64) ARCH="amd64" ;;
    arm)    dpkg --print-ARCH | grep -q "arm64" && ARCH="arm64" || ARCH="arm" ;;
esac

echo " Architecture detected: $ARCH"
# Add some back to the future's car ASCII art

read -p "Ready to plug the flux capacitor to your computer? [Y/n]" INPUT

if [ "$INPUT" = "y" ] || [ "$INPUT" = "Y" ] || [ "$INPUT" = "" ]; then
   # TODO: Add fantasy ASCII gif of enabling time travels
   # install "ffmpeg zlib* libjpeg* python3-setuptools"
   # pip3 install --user gif-for-cli
   install "toilet"
   banner "Get Ready!"   
else
   echo "Ok."
   exit 0
fi


if [ ! -d ~/.oh-my-zsh ]; then
   banner "Oh-My-Zsh!"
   install "zsh curl wget git net-tools"
   wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh || true
fi

try_install bat https://github.com/sharkdp/bat/releases/download/v0.19.0/bat_0.19.0_$ARCH.deb
try_install lsd https://github.com/Peltoche/lsd/releases/download/0.21.0/lsd_0.21.0_$ARCH.deb
if [ $(grep ~/.zshrc -e lsd | wc -c) -eq 0 ] ; then echo "alias l='lsd -lah'" >> ~/.zshrc ; fi

try_install duf https://github.com/muesli/duf/releases/download/v0.8.1/duf_0.8.1_linux_$ARCH.deb
try_install broot

if [ $? -gt 0 ] && [ "$(uname -o)" = "GNU/Linux" ] && [ "$(uname -m)" = "x86_64" ]  ; then 
   wget https://dystroy.org/broot/download/x86_64-linux/broot
   sudo chmod a+x broot
   sudo mv broot /usr/local/bin/
else echo "broot not installed. Please install manually." >> $ERRLOG_FILE ; fi

try_install fd-find https://github.com/sharkdp/fd/releases/download/v8.3.2/fd_8.3.2_$ARCH.deb

banner "mcfly"
if [ "$(uname -o)" = "GNU/Linux" ] && [ "$(uname -m)" = "x86_64" ]  ; then 
   repo="https://github.com/cantino/mcfly/releases/download/v0.5.13/mcfly-v0.5.13-x86_64-unknown-linux-musl.tar.gz"
   wget $repo
   tar -zxvf $(basename $repo)
   sudo chmod a+x mcfly && sudo mv mcfly /usr/local/bin/
   rm -r $(basename $repo)*
   if [ $(grep ~/.zshrc -e mcfly | wc -c) -eq 0 ] ; then echo 'eval $(mcfly init zsh)' >> ~/.zshrc ; fi
   if [ $(grep ~/.bashrc -e mcfly | wc -c) -eq 0 ] ; then echo 'eval $(mcfly init bash)' >> ~/.bashrc ; fi
 fi 

banner "fzf"
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --all


banner "cheat"
mkdir tmp && cd tmp
repo="https://github.com/cheat/cheat/releases/download/4.2.3/cheat-linux-$ARCH.gz"
wget $repo
gzip -d $(basename $repo) && rm $(basename $repo)
sudo chmod a+x cheat* && sudo mv cheat* /usr/local/bin/cheat

# banner "exa"
# exa_repo="https://github.com/ogham/exa/releases/download/v0.10.1/exa-linux-x86_64-v0.10.1.zip"

# if [ "$(uname -m)" = "x86_64" ]; then
#    wget $exa_repo
#    mkdir tmp && unzip -d tmp $(basename $exa_repo) && sudo mv tmp/bin/exa /usr/local/bin/exa && sudo cp tmp/completions/exa.zsh /usr/local/share/zsh/site-functions/exa.zsh
#    rm -r tmp
#    rm -r $(basename $exa_repo)
# else  
#    echo "exa with repo $exa_repo not installed. Please install manually." >> $ERRLOG_FILE
# fi


spd-say -p 10 -l ES "¡De super puta madre socio!" 