find_dep() {
get=1
PORTLOC=/usr/port/
BUILDSCRIPT="spkgbuild"
CACHEDEP=/var/cache/deptmp
INSTALLED=/var/cache/installed
for i in $PORTLOC/* ; do
	if (( $get==0 )) ; then
		break
	fi
	for j in $i/* ; do
		PKGNAME=$(echo $j | rev | cut -d "/" -f1 | rev)
		if [[ $PKGNAME == $1 ]] ; then
			Depends=$(cat $j/spkgbuild | grep depends | cut -d ':' -f2)
			IFS=' ' read -r -a depends <<< "$Depends"
			get=0
			break
		fi
	done
done
if (( $get == 1 )) ; then
	echo "BUG"
fi

}

write_dep() {
for dep in ${depends[@]} ; do
	grep -Fxq $dep $CACHEDEP
	if [[ $? == 0 ]] ; then
		continue
	fi
	grep -Fxq $dep $INSTALLED
	if [[ $? == 0 ]] ; then
		continue
	fi
	echo "$dep" >> $CACHEDEP
	find_dep $dep
	write_dep
done
}
rm installed tmpdep
touch tmpdep
echo "getting dependencies"
for installed in /var/lib/packages/Packages/* ; do
		INSNAME=$(echo $installed | rev | cut -d '/' -f1 | rev)
		echo $INSNAME >> $INSTALLED
done
find_dep $1
write_dep
echo "== Package dependencies =========================================="
column $CACHEDEP
echo "================================================================"
COUNT=$(wc -l $CACHEDEP | cut -d ' ' -f1)
echo "Total ${COUNT} Packages are needed"
