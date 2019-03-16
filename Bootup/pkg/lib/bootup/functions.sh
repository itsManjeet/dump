#!/bin/sh

WHITE="\033[1;37m"
GREEN="\033[1;32m"
RED="\033[1;31m"
YELLOW="\033[1;33m"
NORMAL="\033[0m"

PATH=/bin:/sbin:/usr/bin:/usr/sbin

msg_done() {
    echo -e "${WHITE}[${GREEN} done ${WHITE}] : $@${NORMAL}"
}

msg_fail() {
    echo -e "${WHITE}[${RED} fail ${WHITE}] : $@${NORMAL}"
}

msg() {
    echo -e "${WHITE}$@${NORMAL}"
}

start_stage() {
    STAGE=${1}
    STAGE_NAME=$(echo $STAGE | rev | cut -d '/' -f1 | rev)
    source ${1}
    waitdep ${start_depends}
    start_stage
    if [[ ${?} != 0 ]] ; then
        msg_fail "${MSG}"
    else
        msg_done "${MSG}"
    done
    touch "/var/cache/bootup/done/${STAGE_NAME}"
    
}

waitdep() {
    DEP=${1}
    while [ ! -n ${DEP} ] ; do
        for dep in ${DEP[@]} ; do
            if [ -f "/var/cache/bootup/done/${dep}"] ; then
                DEP=("${DEP[@]/$dep}")
            fi
        done
    done
}