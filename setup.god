#!/bin/bash

# Uncredible and fantastyk installation script of best terminal useful tools based on #
#        ----------> https://github.com/ibraheemdev/modern-unix <----------           #
#                                       |----------> <3U

declare -A enable=( 
[omz]="true"
[bat]="true"
[lsd]="true"
[duf]="true"
[broot]="true"
[fd-find]="true"
[mcfly]="true"
[fzf]="false"
[echo]="true"
[cheat]="true"
[tldr]="true"
[bottom]="true"
[exa]="false"
)


source ./utils.sh

mkdir -p ~/.flux-capacitor/logs
curr_tstamp=$(date "+%Y-%m-%d_%H-%M-%S")
log_file=~/.flux-capacitor/logs/$curr_tstamp-flux-capacitor.log


echo " Architecture detected: $ARCH"
# Add some back to the future's car ASCII art


read -p "Ready to plug the flux capacitor to your computer? [Y/n]" INPUT

echo "   Flux-Capacitor modules summary:"
for key in "${!enable[@]}"; do
    echo "      Enable $key? ${enable[$key]}"
done


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


########################
#         omz!         #
########################

if [ $enable[omz] = "true" ] && [ ! -d ~/.oh-my-zsh ]; then
   banner "Oh-My-Zsh!"
   install "zsh curl wget git net-tools"
   wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh || true
   else 
      echo "Oh-My-ZSH already installed!" >> $log_file
fi


########################
#         bat          #
########################

try_install bat https://github.com/sharkdp/bat/releases/download/v0.19.0/bat_0.19.0_$ARCH.deb


########################
#         lsd          #
########################

try_install lsd https://github.com/Peltoche/lsd/releases/download/0.21.0/lsd_0.21.0_$ARCH.deb
if [ $(grep ~/.zshrc -e lsd | wc -c) -eq 0 ] ; then echo "alias l='lsd -lah'" >> ~/.zshrc ; fi
if [ $(grep ~/.bashrc -e lsd | wc -c) -eq 0 ] ; then echo "alias l='lsd -lah'" >> ~/.zshrc ; fi


########################
#         duf          #
########################

try_install duf https://github.com/muesli/duf/releases/download/v0.8.1/duf_0.8.1_linux_$ARCH.deb


########################
#        broot         #
########################

# try_install broot
if [ $enable[broot] = "true" ] && [ ! "$(command -v broot)" ]; then
   banner "broot"
   if [ $? -gt 0 ] && [ "$(uname -o)" = "GNU/Linux" ] && [ "$(uname -m)" = "x86_64" ]  ; then 
      wget https://dystroy.org/broot/download/x86_64-linux/broot
      sudo chmod a+x broot
      sudo mv broot /usr/local/bin/
   else echo "broot not installed. Please install manually." >> $log_file ; fi
   else 
      echo "broot already installed!" >> $log_file
fi


########################
#       fd-find        #
########################

try_install fd-find https://github.com/sharkdp/fd/releases/download/v8.3.2/fd_8.3.2_$ARCH.deb fd


########################
#        mcfly         #
########################

if [ $enable[mcfly] = "true" ] && [ ! "$(command -v mcfly)" ]; then
   banner "mcfly"
   if [ "$(uname -o)" = "GNU/Linux" ] && [ "$(uname -m)" = "x86_64" ]  ; then 
      repo="https://github.com/cantino/mcfly/releases/download/v0.5.13/mcfly-v0.5.13-x86_64-unknown-linux-musl.tar.gz"
      wget $repo
      tar -zxvf $(basename $repo)
      sudo chmod a+x mcfly && sudo mv mcfly /usr/local/bin/
      rm -r $(basename $repo)*
      if [ $(grep ~/.zshrc -e mcfly | wc -c) -eq 0 ] ; then echo 'eval "$(mcfly init zsh)"' >> ~/.zshrc ; fi
      if [ $(grep ~/.bashrc -e mcfly | wc -c) -eq 0 ] ; then echo 'eval "$(mcfly init bash)"' >> ~/.bashrc ; fi
   fi 
   else 
      echo "mcfly already installed!" >> $log_file
fi


########################
#         fzf          #
########################

if [ $enable[fzf] = "true" ] && [ ! -d ~/.fzf ]; then
   banner "fzf"
   git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
   ~/.fzf/install --all
   else 
      echo "fzf already installed!" >> $log_file
fi


########################
#         cheat        #
########################

if [ $enable[cheat] = "true" ] && [ ! "$(command -v cheat)" ]; then
   banner "cheat"
   mkdir tmp && cd tmp
   repo="https://github.com/cheat/cheat/releases/download/4.2.3/cheat-linux-$ARCH.gz"
   wget $repo
   gzip -d $(basename $repo) && rm $(basename $repo)
   sudo chmod a+x cheat* && sudo mv cheat* /usr/local/bin/cheat
   cd .. && rm -r tmp
   else 
      echo "cheat already installed!" >> $log_file
fi

########################
#         tldr         #
########################

try_install "tldr"


########################
#        bottom        #
########################

try_install "bottom" https://github.com/ClementTsang/bottom/releases/download/0.6.8/bottom_0.6.8_amd64.deb


########################
#          exa         #
########################

if [ $enable[exa] = "true" ] && [ ! "$(command -v exa)" ]; then
   banner "exa"
   exa_repo="https://github.com/ogham/exa/releases/download/v0.10.1/exa-linux-x86_64-v0.10.1.zip"

   if [ "$(uname -m)" = "x86_64" ]; then
      wget $exa_repo
      mkdir tmp && unzip -d tmp $(basename $exa_repo) && sudo mv tmp/bin/exa /usr/local/bin/exa && sudo cp tmp/completions/exa.zsh /usr/local/share/zsh/site-functions/exa.zsh
      rm -r tmp
      rm -r $(basename $exa_repo)
   else  
      echo "exa with repo $exa_repo not installed. Please install manually." >> $ERRLOG_FILE
   fi
fi

if [ ! -f ~/.flux-capacitor/logs/LATEST.loga ]; then rm $(dirname $log_file)/LATEST.log ; fi
ln -s $log_file $(dirname $log_file)/LATEST.log 


# spd-say -p 10 -l ES "¡De super puta madre socio!" 