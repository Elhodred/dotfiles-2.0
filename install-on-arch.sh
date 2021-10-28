#!/bin/env bash
set -e

echo "Welcome!" && sleep 2

#Default vars
HELPER="paru"

# does full system update
echo "Doing a system update, cause stuff may break if it's not the latest version..."
sudo pacman --noconfirm -Syu

echo "###########################################################################"
echo "Will do stuff, get ready"
echo "###########################################################################"

# install base-devel if not installed
sudo pacman -S --noconfirm --needed base-devel wget git

# choose video driver
echo "1) xf86-video-intel 	2) xf86-video-amdgpu 3) nvidia 4) nvidia-340xx 5) Skip"
read -r -p "Choose you video card driver(default 1)(will not re-install): " vid

AURDRI=""
case $vid in 
[1])
	DRI='xf86-video-intel'
	;;

[2])
	DRI='xf86-video-amdgpu'
	;;

[3])
    	DRI='nvidia nvidia-settings nvidia-utils'
    	;;

[4])
	DRI=""
	AURDRI="nvidia-340xx"
	;;

[5])
	DRI=""
	;;
[*])
	DRI='xf86-video-intel'
	;;
esac

# install xorg if not installed
sudo pacman -S --noconfirm --needed rofi feh xorg xorg-xinit xorg-xinput $DRI xmonad lightdm lightdm-gtk-greeter gtk2 libnotify mpv cronie tint2 acpi acpilight accountsservice alsa-utils alsa-plugins jq youtube-dl fzf

# install fonts
mkdir -p ~/.local/share/fonts
mkdir -p ~/.srcs

cp -r ./fonts/* ~/.local/share/fonts/
fc-cache -f
clear 

echo "We need an AUR helper. It is essential. 1) paru       2) yay"
read -r -p "What is the AUR helper of your choice? (Default is paru): " num

if [ $num -eq 2 ]
then
    HELPER="yay"
fi

if ! command -v $HELPER &> /dev/null
then
    echo "It seems that you don't have $HELPER installed, I'll install that for you before continuing."
	git clone https://aur.archlinux.org/$HELPER.git ~/.srcs/$HELPER
	(cd ~/.srcs/$HELPER/ && makepkg -si )
fi

$HELPER -S picom-jonaburg-git\
	   candy-icons-git   \
	   wmctrl            \
	   alacritty         \
	   playerctl         \
	   brightnessctl     \
	   dunst             \
	   xmonad-contrib    \
	   xclip             \
	   maim              \
	   rofi-greenclip    \
	   xautolock         \
	   $AURDRI           \
	   betterlockscreen  \
	   play-with-mpv-git \
	   ytfzf

#install custom picom config file 
if [ ! -d ~/.config]; then
    mkdir -p ~/.config/
fi

    #ROFI
    if [ -e ~/.config/rofi ]; then
        echo "Rofi configs detected, backing up..."
	if [-d ~/.config/rofi.old ]; then
	    rm -rf ~/.config/rofi.old;
	fi
        mkdir ~/.config/rofi.old && mv ~/.config/rofi/* ~/.config/rofi.old/;
    fi
    echo "Installing rofi configs..."
    ln -sf ./config/rofi/ ~/.config/rofi
    sleep 5

    #EWW
    echo "1)1366 x 768       2)1920 x 1080"
    read -r -p "Choose your screen resolution: " res
    case $res in 
    [1])
	EWW_DIR='config/eww-1366'
	;;
    [2])
	EWW_DIR='config/eww-1920'
	;;
    [*])
	EWW_DIR='config/eww-1366'
	;;
    esac
    if [ -e ~/.config/eww ]; then
        echo "Eww configs detected, backing up..."
    	if [ -d ~/.config/eww.old ]; then
	    rm -rf ~/.config/eww.old;
	fi
        mkdir ~/.config/eww.old && mv ~/.config/eww/* ~/.config/eww.old/;
    fi
    echo "Installing eww configs..."
    ln -sf ./$EWW_DIR/ ~/.config/eww
    ln -sf ./eww-scripts/ ~/.config/eww/scripts

    #PICOM
    if [ -e ~/.config/picom.conf ]; then
        echo "Picom configs detected, backing up..."
        cp -L ~/.config/picom.conf ~/.config/picom.conf.old;
    fi
    echo "Installing picom configs..."
    ln -sf ./config/picom.conf ~/.config/picom.conf

    #ALACRITTY
    if [ -e ~/.config/alacritty.yml ]; then
        echo "Alacritty configs detected, backing up..."
        cp -L ~/.config/alacritty.yml ~/.config/alacritty.yml.old;
    fi
    echo "Installing alacritty configs..."
    ln -sf ./config/alacritty.yml ~/.config/alacritty.yml
  
    #DUNST
    if [ -e ~/.config/dunst ]; then
        echo "Dunst configs detected, backing up..."
    	if [ -d ~/.config/dunst.old ]; then
	    rm -rf ~/.config/dunst.old;
	fi
        mkdir ~/.config/dunst.old && mv ~/.config/dunst/* ~/.config/dunst.old/
    fi
    echo "Installing dunst configs..."
    ln -sf ./config/dunst/ ~/.config/dunst

    if [ ! -d ~/wallpapers ]; then
        echo "Creating ~/wallpapers..."
        mkdir ~/wallpapers;
    fi
    echo "Installing wallpapers..."
    cp -r ./wallpapers/* ~/wallpapers/

    if [ -e ~/.config/tint2 ]; then
        echo "Tint2 configs detected, backing up..."
    	if [ -d ~/.config/tint2.old ]; then
	    rm -rf ~/.config/tint.old;
	fi
        mkdir ~/.config/tint2.old && mv ~/.config/tint2/* ~/.config/tint2.old/;
    fi
    echo "Installing tint2 configs..."
    ln -sf ./config/tint2/ ~/.config/tint2

    if [ -e ~/.xmonad ]; then
        echo "XMonad configs detected, backing up..."
    	if [ -d ~/.xmonad.old ]; then
	    rm -rf ~.xmonad.old;
	fi
        mkdir ~/.xmonad.old && mv ~/.xmonad/* ~/.xmonad.old/
    fi
    echo "Installing xmonad configs..."
    ln -sf ./xmonad/* ~/.xmonad;

    if [ -e ~/bin ]; then
        echo "~/bin detected, backing up..."
    	if [ -d ~/bin.old ]; then
	    rm -rf ~/bin.old
	fi
        mkdir ~/bin.old && mv ~/bin/* ~/bin.old/
        ln -sf ./bin/ ~/bin;
	clear
    else
        echo "Installing bin scripts..."
        ln -sf ./bin/ ~/bin/;
	clear
        SHELLNAME=$(echo $SHELL | grep -o '[^/]*$')
        case $SHELLNAME in
            bash)
                if [[ ":$PATH:" == *":$HOME/bin:"* ]]; then
                    echo "Looks like $HOME/bin is not on your PATH, adding it now."
                    echo "export PATH=\$PATH:\$HOME/bin" >> $HOME/.bashrc
                else
                    echo "$HOME/bin is already in your PATH. Proceeding."
                fi
                ;;

            zsh)
                if [[ ":$PATH:" == *":$HOME/bin:"* ]]; then
                    echo "Looks like $HOME/bin is not on your PATH, adding it now."
                    echo "export PATH=\$PATH:\$HOME/bin" >> $HOME/.zshrc
                else
                    echo "$HOME/bin is already in your PATH. Proceeding."
                fi
                ;;

            fish)
                echo "I see you use fish. shahab96 likes your choice."
                fish -c fish_add_path -P $HOME/bin
                ;;

            *)
                echo "Please add: export PATH='\$PATH:$HOME/bin' to your .bashrc or whatever shell you use."
                echo "If you know how to add stuff to shells other than bash, zsh and fish please help out here!"
        esac
    fi
    

# done 
echo "PLEASE MAKE .xinitrc TO LAUNCH, or just use your Display Manager (ie. lightdm or sddm, etc.)" | tee ~/Note.txt
printf "\n" >> ~/Note.txt
echo "For startpage, copy the startpage directory into wherever you want, and set it as new tab in firefox settings." | tee -a ~/Note.txt
echo "For more info on startpage (Which is a fork of Prismatic Night), visit https://github.com/dbuxy218/Prismatic-Night#Firefoxtheme" | tee -a ~/Note.txt
echo "ALL DONE! Reboot for all changes to take place!" | tee -a ~/Note.txt
echo "Open issues on github or ask me on discord or whatever if you face issues." | tee -a ~/Note.txt
echo "Install Museo Sans as well. Frome Adobe I believe." | tee -a ~/Note.txt
echo "If the bar doesn't work, use tint2conf and set stuff up, if you're hopelessly lost, open an issue." | tee -a ~/Note.txt
echo "These instructions have been saved to ~/Note.txt. Make sure to go through them."
echo "For instructions regarding usage on VirtualMachines, please refer to the VM folder of the repo." | tee -a ~/Note.txt
sleep 5
xmonad --recompile
