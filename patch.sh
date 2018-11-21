#!/System/bin/sh

for i in $(find $1 -type f) ; do
    echo "....Patching $i"
    nishu replace "/bin" with "/System/exec" in $i
    nishu replace "/sbin" with "/System/exec" in $i
    nishu replace "/lib" with "/System/libraries" in $i
    nishu replace "/lib64" with "/System/libraries" in $i
    nishu replace "/proc" with "/System/kernel/processes" in $i
    nishu replace "/dev" with "/System/kernel/devices" in $i
    nishu replace "/sys" with "/System/kernel/sysinfo" in $i
    nishu replace "/var" with "/System/dump" in $i
    nishu replace "/run" with "/System/dump/caches" in $i
    nishu replace "/tmp" with "/System/dump/temp" in $i
    nishu replace "/etc" with "/System/configs" in $i    
done
