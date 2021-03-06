#!/bin/bash

##############################################################################
### Archlinux boot/efi bspwm kurulumu ########################################
##############################################################################
Bold=$(tput bold)
Sgr0=$(tput sgr0)
Black=$(tput setaf 0)
Red=$(tput setaf 1)
Green=$(tput setaf 2)
Yellow=$(tput setaf 3)
Blue=$(tput setaf 4)
Magenta=$(tput setaf 5)
Cyan=$(tput setaf 6)
White=$(tput setaf 7)
##############################################################################
clear
YesOrNo() {
        while :
        do
                read -p "${Green}Aynalari guncellemek istiyor musunuz? (y/n?): " answer
                case "${answer}" in
                    [yY]|[yY][eE]) exit 0 ;;
                    [nN]|[nN][hH]) exit 1 ;;
                esac
        done
}
if $( YesOrNo ); then

echo "${Bold}${White}-------------------------------------------------${Sgr0}"
echo "${Yellow}Aynalar guncelleniyor ${Sgr0}"
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
reflector --verbose --latest 10 --sort rate --save /etc/pacman.d/mirrorlist
cat /etc/pacman.d/mirrorlist
else
pacman-key --populate archlinux
fi

echo ""
echo "##############################################################################"
##############################################################################
YesOrNo() {
        while :
        do
                read -p "${Green}Disk bolumleme yapilacak mi? (y/n?): " answer
                case "${answer}" in
                    [yY]|[yY][eE]) exit 0 ;;
                    [nN]|[nN][hH]) exit 1 ;;
                esac
        done
}
if $( YesOrNo ); then
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
echo "${Yellow}Disk bolumlemesi icin cfdisk komutu calistiriliyor ${Sgr0}"
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
cfdisk
else
echo "${Bold}${Red}Disk bicimlendirme adimina geciliyor${Sgr0}"
fi
echo ""
echo "##############################################################################"
##############################################################################
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
echo "${Yellow}EFI yuklemesi yapilacak partisyonu secin (Ornek: sdaX , vdaX) ${Sgr0}"
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
read efipart
mkfs.fat -F32 /dev/$efipart
echo ""
echo "##############################################################################"
##############################################################################
YesOrNo() {
        while :
        do
                read -p "${Green}Takas bolumu kullanilacak mi? (y/n?): ${Sgr0}" answer
                case "${answer}" in
                    [yY]|[yY][eE]) exit 0 ;;
                    [nN]|[nN][hH]) exit 1 ;;
                esac
        done
}
if $( YesOrNo ); then
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
echo "${Yellow}Swap icin partisyon secin (Ornek: sdaX , vdaX) ${Sgr0}"
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
read swappart
mkswap /dev/$swappart
swapon /dev/$swappart
else
echo "${Bold}${Red}Swap partisyonu atlaniyor${Sgr0}"
fi
echo ""
echo "##############################################################################"
##############################################################################
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
echo "${Yellow}ROOT yuklemesi yapilacak partisyonu secin (Ornek: sdaX , vdaX) ${Sgr0}"
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
read rootpart
mkfs.ext4 /dev/$rootpart
echo ""
echo "##############################################################################"
##############################################################################
YesOrNo() {
        while :
        do
                read -p "${Green}HOME bolumu kullanilacak mi? (y/n?): ${Sgr0}" answer
                case "${answer}" in
                    [yY]|[yY][eE]) exit 0 ;;
                    [nN]|[nN][hH]) exit 1 ;;
                esac
        done
}
if $( YesOrNo ); then
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
echo "${Yellow}Home yuklemesi yapilacak partisyonu secin (Ornek: sdaX , vdaX) ${Sgr0}"
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
read homepart
mkfs.ext4 /dev/$homepart
else
echo "${Bold}${Red}Home partisyonu atlaniyor${Sgr0}"
fi
echo ""
echo "##############################################################################"
##############################################################################
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
echo "${Yellow}Root montaji yapiliyor${Sgr0}"
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
mount /dev/$rootpart /mnt
echo ""
echo "##############################################################################"
##############################################################################
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
echo "${Yellow}Dosyalar olusturuluyor${Sgr0}"
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
mkdir -p /mnt/boot/efi
mkdir -p /mnt/home
echo ""
echo "##############################################################################"
##############################################################################
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
echo "${Yellow}Montaj islemleri yapiliyor ${Sgr0}"
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
mount /dev/$efipart /mnt/boot/efi
file="/mnt/home"
if [ -e $file ]; then
mount /dev/$homepart /mnt/home
fi
mkdir -p /mnt/ikikarinca
mount -o defaults,noatime,discard=async,ssd /dev/sda5 /mnt/ikikarinca
cp -R /root/arch/ /mnt/home/
echo ""
echo "${Bold}${Red}ikikarinca montaji /// !!!! ${Sgr0}"
sleep 2
echo ""
echo "##############################################################################"
##############################################################################
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
echo "${Yellow}Temel paket yuklemeleri yapiliyor ${Sgr0}"
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
pacstrap -i /mnt base linux linux-headers linux-firmware nano wget networkmanager base-devel xorg-drivers linux-tools archlinux-tools sddm git curl grub mtools dosfstools efibootmgr os-prober --noconfirm
echo ""
echo "##############################################################################"
##############################################################################
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
echo "${Yellow}fstab dosyasi yaziliyor--------------------------------${Sgr0}"
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
genfstab -U /mnt >> /mnt/etc/fstab  
cat /mnt/etc/fstab
echo ""
echo "##############################################################################"
##############################################################################
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
echo "${Yellow}Donanim saati ayarlaniyor ${Sgr0}"
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
timedatectl set-ntp true
echo ""
echo "##############################################################################"
##############################################################################
##############################################################################
##############################################################################
echo "${Bold}${Yellow}-------------------------------------------------${Sgr0}"
echo "${Bold}${Yellow}-------------------------------------------------${Sgr0}"
echo "${Bold}${Yellow}-------------------------------------------------${Sgr0}"
echo "${Yellow}CHROOT islemlerine geciliyor ${Sgr0}"
echo "${Bold}${Yellow}-------------------------------------------------${Sgr0}"
echo "${Bold}${Yellow}-------------------------------------------------${Sgr0}"
echo "${Bold}${Yellow}-------------------------------------------------${Sgr0}"
echo ""
sleep 3
##############################################################################
##############################################################################
##############################################################################
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
echo "${Yellow}Yerel zaman bolgesi ayarlaniyor ${Sgr0}"
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
arch-chroot /mnt /bin/bash -c "ln -sf /usr/share/zoneinfo/$(curl https://ipapi.co/timezone) /etc/localtime"
arch-chroot /mnt /bin/bash -c "timedatectl set-timezone $(curl https://ipapi.co/timezone)"
arch-chroot /mnt /bin/bash -c "hwclock --systohc"
echo ""
echo "##############################################################################"
##############################################################################
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
echo "${Yellow}Sistem dilini girin (Ornek : en_US , tr_TR) ${Sgr0}"
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
read lang
echo "$lang.UTF-8 UTF-8" > /mnt/etc/locale.gen
arch-chroot /mnt /bin/bash -c "locale-gen" 
echo "LANG=$lang.UTF-8" > /mnt/etc/locale.conf
echo ""
echo "##############################################################################"
##############################################################################
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
echo "${Yellow} Klavye dilini girin (Ornek : us , trq) ${Sgr0}"
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
read keymap
echo "KEYMAP=$keymap" > /mnt/etc/vconsole.conf
echo ""
echo "##############################################################################"
##############################################################################
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
echo "${Yellow}Ana makine adini girin ${Sgr0}"
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
read hostname
echo "$hostname" > /mnt/etc/hostname
echo "# <ip-address> <hostname.domain.org> <hostname>" >> /mnt/etc/hosts
echo "127.0.0.1 localhost" >> /mnt/etc/hosts
echo "::1 localhost" >> /mnt/etc/hosts
echo "127.0.1.1 $hostname.localdomain $hostname" >> /mnt/etc/hosts
echo "Hostname: $(cat /mnt/etc/hostname)"
echo "Hosts: $(cat /mnt/etc/hosts)"
echo ""
echo "##############################################################################"
##############################################################################
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
echo "${Yellow}Yeni kullanici olusturun ${Sgr0}"
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
read user
arch-chroot /mnt /bin/bash -c "useradd -mG wheel $user"
echo ""
echo "##############################################################################"
##############################################################################
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
echo "${Yellow}$user kullanicisi icin parola belirleyin ${Sgr0}"
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
read userpasswd
arch-chroot /mnt /bin/bash -c "(echo $userpasswd ; echo $userpasswd) | passwd $user"
arch-chroot /mnt /bin/bash -c "(echo $userpasswd ; echo $userpasswd) | passwd root"
echo "
$user ALL=(ALL:ALL) ALL" >> /mnt/etc/sudoers.d/10-$user
echo "
%wheel ALL=(ALL:ALL) ALL" >> /mnt/etc/sudoers
echo ""
echo "##############################################################################"
##############################################################################

mv /mnt/etc/pacman.d/ /mnt/etc/pacman.d.bak
cp -R /etc/pacman.d/ /mnt/etc/
mv /mnt/etc/pacman.conf /mnt/etc/pacman.conf.bak
cp /etc/pacman.conf /mnt/etc/

arch-chroot /mnt /bin/bash -c "pacman-key --recv-key FBA220DFC880C036 --keyserver keyserver.ubuntu.com"
arch-chroot /mnt /bin/bash -c "pacman-key --lsign-key FBA220DFC880C036"
arch-chroot /mnt /bin/bash -c "pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'"
echo "
[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist" >> /mnt/etc/pacman.conf
cp -RT usr/ /mnt/usr/
arch-chroot /mnt /bin/bash -c "bash /usr/share/arcolinux-spices/scripts/get-the-keys-and-repos.sh"
arch-chroot /mnt /bin/bash -c "bash /home/arch/strap.sh"
arch-chroot /mnt /bin/bash -c "pacman -Syu yay-bin"
echo ""
echo "##############################################################################"
##############################################################################
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
arch-chroot /mnt /bin/bash -c "yay -S ctlos"
arch-chroot /mnt /bin/bash -c "yay -S --needed - < /home/arch/bspwm-packages.txt"
#arch-chroot /mnt /bin/bash -c "yay -S --needed - < /home/arch/pkgs.txt"
#arch-chroot /mnt /bin/bash -c "yay -S - < /home/arch/ctlpkg.txt"
##############################################################################
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
arch-chroot /mnt /bin/bash -c "grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=$hostname"
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
arch-chroot /mnt /bin/bash -c "grub-mkconfig -o /boot/grub/grub.cfg"
##############################################################################
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
cp -R /mnt/etc/skel/ /mnt/etc/skel-ctlos/
rm -rf /mnt/etc/skel/
cp -R /etc/skel/ /mnt/etc/
cp -RT /usr/bin/ /mnt/usr/bin/
###arch-chroot /mnt /bin/bash -c "yay -S --needed arcolinux-bspwm-git"
cp -RT /mnt/etc/skel/ /mnt/home/$user/
cp /mnt/home/$user/.config/bspwm/bspwmrc /mnt/home/$user/.config/bspwm/bspwmrc.old
cp /mnt/usr/share/doc/bspwm/examples/bspwmrc /mnt/home/$user/.config/bspwm/
cp /mnt/home/$user/.config/sxhkd/sxhkdrc /mnt/home/$user/.config/sxhkd/sxhkdrc.old
cp /mnt/usr/share/doc/bspwm/examples/sxhkdrc /mnt/home/$user/.config/sxhkd/
arch-chroot /mnt /bin/bash -c "chown -R $user:$user /home/$user/"
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
##############################################################################
arch-chroot /mnt /bin/bash -c "bash /home/arch/pdinstall.sh"
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
arch-chroot /mnt /bin/bash -c "systemctl enable NetworkManager"
arch-chroot /mnt /bin/bash -c "systemctl enable sddm"
echo "${Bold}${White}-------------------------------------------------${Sgr0}"
##############################################################################
##############################################################################
##############################################################################
echo "${Bold}${Yellow}-------------------------------------------------${Sgr0}"
echo "${Bold}${Yellow}-------------------------------------------------${Sgr0}"
echo "${Bold}${Yellow}-------------------------------------------------${Sgr0}"
echo "${Yellow}Kurulum tamamlandi ${Sgr0}"
echo "${Bold}${Yellow}-------------------------------------------------${Sgr0}"
echo "${Bold}${Yellow}-------------------------------------------------${Sgr0}"
echo "${Bold}${Yellow}-------------------------------------------------${Sgr0}"
echo ""
sleep 3
##############################################################################
##############################################################################
##############################################################################
YesOrNo() {
        while :
        do
                read -p "${Green}Montajlari ayir ve sistemi yeniden baslat? (y/n?): ${Sgr0}" answer
                case "${answer}" in
                    [yY]|[yY][eE]) exit 0 ;;
                    [nN]|[nN][hH]) exit 1 ;;
                esac
        done
}
if $( YesOrNo ); then
umount -R /mnt
swapoff -a
reboot
else
echo "${Bold}${Red}Cikis yapacaginiz zaman montajlari ayirmayi unutmayin${Sgr0}"
fi
sleep 3
##############################################################################
##############################################################################
##############################################################################
