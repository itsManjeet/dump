#!/core/bin/sh

echo_fail() {
    echo -e "\e[1;31m"$@ "\e[0m"
}
echo_pass() {
    echo -e "\e[1;32m... "$@ "\e[0m"
}
echo_process() {
    echo -e "\e[1;37m... "$@ "\e[0m"
}
echo_notice() {
    echo -e "\e[1;35m... "$@ "\e[0m"
}

PKGNAME=$(echo $1 )
recipie_addr=""

srcode="/dmp/kitchen/src/"
bldir="/dmp/kitchen/build/"
pkgs="/dmp/kitchen/pkg/"
installed="/var/lib/pkgs/"

checkinstall() {

    if [ -d $installed/$PKGNAME ] ; then
        echo_notice "Package is already installed"
        exit 0
    fi

}

checkRecipie() {
    x=1
    for i in /core/Recipie/* ; do
        if [[ $x == 0 ]] ; then
            break;
        fi
        
        for j in $i/* ; do
            tmpname=$(echo $j | rev | cut -d '/' -f1 | rev )
            if [ $1 == $tmpname ] ; then
                recipie_addr=$(echo $j)
                x=0;
                break;
            fi
        done
    done
}


checkdep() {
    echo ${depends[@]}
    for dep in ${depends[@]} ; do
        #nishu cook $dep
        if [ $? != 0 ] ; then
            echo_fail "cooking failed"
            exit 2
        fi
    done

}
downloadsource() {
    tarfile=$(echo $source | rev | cut -d '/' -f1 | rev )
    ls $srcode | grep -Fq $tarfile
    if [ $? == 1 ] ; then
        echo_process "downloading source codes"
        wget $source -P $srcode
        return $?
    fi
    
    echo_notice "source found in cache"
    return 0

}

precomiple() {
    tarfile=$(echo $source | rev | cut -d '/' -f1 | rev )
    if [ -d $bldir/$name-$ver ] ; then
        echo_process "cleaning previous build"
        rm -rf $bldir/$name-$ver
    fi
    
    if [ -d $pkgs/$name-$ver ] ; then
        echo_process "cleaning previous build"
        rm -rf $pkgs/$name-$ver
    fi 
    #echo $tarfile
    tar -xaf "$srcode/$tarfile" -C $bldir
    if [ $? != 0 ] ;then
        echo_fail "Error while extracting tar file"
        exit $?
    fi
    PKG="$pkgs/$name-$ver"
    SRC="$recipie_addr"

}

createpkg() {
    cd $PKG
    mkdir -pv info
    echo "Name : $name" > info/info
    echo "Version : $ver" >> info/info
    echo "depends : ${depends[@]}" >> info/info
    echo "Size : $(du -hs | cut -f1)" >> info/info
    echo "date : $(date)" >> info/info
    if [ -d core ] ; then
        find core -type f > info/files
        for i in $(find . -type f ) ; do
            sha512sum $i >> info/sign
        done
    fi
    
    if [ -d pkgs ] ; then
        mv pkgs/.struct/* pkgs/
        rmdir pkgs/.struct
        find pkgs -type f > info/files
        for i in $(find pkgs -type f ) ; do
            sha512sum $i >> info/sign
        done
    fi
    cp -rv $SRC/* info/
    
    tar -caf ../$name-$ver-x86_64.pkgs.tar.xz *
}

## == Main Function ============================================================================
#  CheckInstall
#  checkRecipie
#  checkdep
#  downloadsource
#  precomiple
#  cook
#  createpkg
#  installpkg


checkinstall $PKGNAME

checkRecipie $PKGNAME

if [[ $x == 1 ]] ; then
    echo_fail "No Recipie for this package $PKGNAME"
    exit 1
fi
echo_pass "Recipie found for $PKGNAME"

source "$recipie_addr/recipie"

checkdep 

downloadsource

precomiple

cd $bldir
cook

createpkg
ans="n"
echo_notice "do you want to install pkg [ y n ]"
read ans
if [[ $ans == 'y' ]] ; then
    nishu install ../$name-$ver-x86_64.pkgs.tar.xz
else
    echo_notice "Package not installed"
fi