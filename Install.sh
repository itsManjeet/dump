#!/core/bin/sh
echo_fail() {
    echo -e "\e[1;31m" $@ "\e[0m"
}
echo_pass() {
    echo -e "\e[1;32m" $@ "\e[0m"
}
echo_process() {
    echo -e "\e[1;37m" $@ "\e[0m"
}
echo_notice() {
    echo -e "\e[1;35m" $@ "\e[0m"
}

PkgName="$( echo $1)"
echo_process "... Checking Package"
tar -tf $PkgName >/dev/null
if [ $? != 0 ] ; then
    echo_fail "Package is corrupt"
    exit 1
fi
if [ -d /var/cache/pkgs/ ] ; then
    rm -rf /var/cache/pkgs
fi
mkdir -p /var/cache/pkgs/
tar -xaf $PkgName -C /var/cache/pkgs

cd /var/cache/pkgs
name=$(cat info/info | grep "Name" | cut -d ':' -f2- | cut -d ' ' -f2-)
ver=$(cat info/info | grep "Version" | cut -d ':' -f2- | cut -d ' ' -f2-)


if [ -d /var/lib/pkgs/$name/$ver ] ; then
    echo_notice "Package is already installed"
    exit 1
fi

mkdir -p /var/lib/pkgs/$name/$ver/
cp info/* /var/lib/pkgs/$name/$ver

if [ -e info/pre ] ; then
    echo_process "Pre configurations"
    sh info/pre
fi
if [ -d core ] ;then
    echo_process "installing system package"
    mkdir -p /core/pkgs/$name/$ver/
    mv * /core/pkgs/$name/$ver/
    lndir -silent /core/pkgs/$name/$ver/core /core
    if [ -s /core/pkgs/$name/$ver/info/*.desktop ] ; then
	echo_notice "Desktop file found"
        mv /core/pkgs/$name/$ver/info/*.desktop /core/pkgs/$name/$ver/
	ln -srv /core/pkgs/$name/$ver/*.desktop /core/share/applications
	chmod +x /core/pkgs/$name/$ver/*.desktop
   fi
else
    echo_process "installing user package"
    mkdir -p /pkgs/$name/$ver/
    mv * /pkgs/$name/$ver
    lndir -silent /pkgs/$name/$ver/pkgs/ /pkgs/.struct/
    if [ -s /pkgs/$name/$ver/info/*.desktop ] ; then
	echo_notice "Desktop file found"
        mv /pkgs/$name/$ver/info/*.desktop /pkgs/$name/$ver/
	ln -srv /pkgs/$name/$ver/*.desktop /core/share/applications
	chmod +x /pkgs/$name/$ver/*.desktop
   fi
fi


if [ -e /var/lib/pkgs/$name/$ver/post ] ; then
    echo_process "Post configurations"
    sh /var/lib/pkgs/$name/$ver/post
fi

rm -rf /var/cache/pkgs
echo_pass "Package installed"

echo_process "Updating database"
ldconfig

if [[ -x /bin/glib-compile-schemas ]] ; then
	glib-compile-schemas /usr/share/glib-2.0/schemas/
fi
if [[ -x /bin/update-desktop-database ]] ; then
	update-desktop-database
fi
if [[ -x /bin/update-mime-database ]] ; then
        export PKGSYSTEM_ENABLE_FSYNC=0
	update-mime-database /usr/share/mime
	unset PKGSYSTEM_ENABLE_FSYNC
fi
if [[ -x /bin/gtk-update-icon-cache ]] ; then
	for i in /usr/share/icons/ ; do
		gtk-update-icon-cache $i
	done
fi