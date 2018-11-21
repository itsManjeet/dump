#!/bin/sh

name=$(echo $3)
group=$(echo $4)
for i in /core/Recipie/* ; do
    if [ -d $i/$name ] ; then
        echo "i already know how to cook $name"
        exit 1
    fi
done

mkdir -p /core/Recipie/$group/$name

cat > /core/Recipie/$group/$name/recipie << "EOF"
# Desc : 
# URL : 


name=
ver=
release=1
source=
depends=

cook() {
    cd $name-$ver
    
    ./configure --prefix=/core  \
                --bindir=/core/bin \
                --datarootdir=/core/share \
                --docdir=/core/share/doc/$name-$ver \
                --sbindir=/core/bin \
                --libexecdir=/core/libexec \
                --sysconfdir=/core/conf \
                --sharedstatedir=/core/com \
                --localestatedir=/core/var \
                --libdir=/core/lib \
                --includedir=/core/include \
                --oldincludedir=/core/include \
                --datadir=/core/share
    
    make -j8
    make DESTDIR=$PKG install
    
}


EOF

