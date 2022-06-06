#!/bin/bash

pacman-key --recv-key FBA220DFC880C036 --keyserver keyserver.ubuntu.com
pacman-key --lsign-key FBA220DFC880C036
pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
echo "
[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist" >> /mnt/etc/pacman.conf

cp -RT /home/arch/usr/ /usr/
bash /usr/share/arcolinux-spices/scripts/get-the-keys-and-repos.sh

bash /home/arch/strap.sh

pacman -Syu yay-bin

yay -S alacritty bspwm sxhkd feh polybar xorg-xsetroot xorg-xbacklight light pamixer picom-jonaburg-git dunst rofi flameshot ksuperkey nerd-fonts-jetbrains-mono polkit-gnome fm6000 network-manager-applet helix xfce4-power-manager betterlockscreen zsh zsh-autosuggestions zsh-syntax-highlighting oh-my-zsh-git catppuccin-gtk-theme papirus-icon-theme --needed --noconfirm

git clone https://github.com/theCode-Breaker/bspwm-dotfiles.git --depth 1
cd bspwm-dotfiles
cp -R .config/* ~/.config/
chmod -R +x ~/.config/bspwm
cp .zshrc ~
cp .zshrc-personal ~
mkdir ~/.local/bin
cp -R .local/bin/* ~/.local/bin
chmod -R +x ~/.local/bin
betterlockscreen -u ~/.config/bspwm/backgrounds/evening-sky.png
sudo systemctl enable betterlockscreen@$USER.service

rm -rf bspwm-dotfiles
