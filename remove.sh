#!/bin/sh
PKG=$(echo $2 )
echo -e "\033[1;36m... Checking $PKG\033[0m"
if [ -d /var/lib/pkgs/$PKG ] ; then
	
        if [ -d /core/pkgs/$PKG ] ; then
		if [ -e /var/lib/pkgs/$PKG/*/remove.sh ]; then
			echo -e "\033[1;35m... pre system config \033[0m"
			sh /var/lib/pkgs/$PKG/*/remove.sh
		fi
                echo -e "\033[1;34m... I got it its a system package \033[0m"
		rm -rf /core/pkgs/$PKG
                echo -e "\033[1;34m... Cleaning broken links\033[0m"
                find -L /core/ -maxdepth 5 -type l -delete -not -path "/core/pkgs"
	elif [ -d /pkgs/$PKG ] ; then
		if [ -e /var/lib/pkgs/$PKG/*/remove.sh ]; then
			echo -e "\033[1;35m... pre system config \033[0m"
			sh /var/lib/pkgs/$PKG/*/remove.sh
		fi
		echo -e "\033[1;34m... I got it its a user package \033[0m"
		rm -rf /pkgs/$PKG
		echo -e "\033[1;34m... Cleaning broken links\033[0m"
                find -L /pkgs/.struct/ -maxdepth 5 -type l -delete
        fi
        find -L /core/share/applications/ -maxdepth 2 -type l -delete
	rm -rf /var/lib/pkgs/$PKG
	echo -e "\033[1;32m... I Done it \033[0m"
else
	echo -e "\033[1;31mI never cooked $PKG in your system\033[0m"

fi
	
