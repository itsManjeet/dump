#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/reboot.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <signal.h>

int bootup_reboot(int code);
void rescue_shell();

int main(int argc, char* argv[]) {
    int a;
    /* Check SuperUser */
    if (geteuid() != 0) {
        fprintf(stderr,"should be executed with root permissions\n");
        return 1;
    }

    /* Check if required file exist */
    char* files[] = { "/lib/bootup/stage1" , 
                      "/lib/bootup/stage2" ,
                      "/lib/bootup/stage_halt" , 
                      "/lib/bootup/stage_reboot" , 
                      "/lib/bootup/stage_poweroff" };

    for(int i=0;i<5;i++) {
        if (access(files[i],F_OK) == -1) {
            /* Essentail files missing */
            fprintf(stderr,"%s file is missing\n",files[i]);
            fprintf(stderr,"unable to procced boot\ndropping to rescue shell\n");
            rescue_shell();
        }
    }
    fprintf(stdout,"starting stage 1\n");
    system(files[0]);
    scanf("%d",&a);
    fprintf(stdout,"stage 1 complete\nstarting stage 2\n");
    system(files[1]);        
}

int bootup_reboot(int code) {
    return (reboot(code));
}

void rescue_shell() {
    fprintf(stderr,"== Rescue Shell ====================== \n");
    system("/bin/sh");
    fprintf(stdout,"rebooting system...\n");
    sync();
    bootup_reboot(RB_AUTOBOOT);
}