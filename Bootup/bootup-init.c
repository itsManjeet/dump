#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/reboot.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <signal.h>

int bootup_reboot(int code);
void rescue_shell();

int main(int argc, char* argv[]) {
    
    /* Check SuperUser */
    if (geteuid() != 0) {
        fprintf(stderr,"should be executed with root permissions");
        return 1;
    }

    /* Check if required file exist */
    char* files[] = { "/lib/bootup/stages/stage1" , 
                      "/lib/bootup/stages/stage2" ,
                      "/lib/bootup/stages/stage_halt" , 
                      "/lib/bootup/stages/stage_reboot" , 
                      "/lib/bootup/stages/stage_poweroff" };

    for(int i=0;i<5;i++) {
        if (access(files[i],F_OK) == -1) {
            /* Essentail files missing */
            fprintf(stderr,"%s file is missing",file[i]);
            fprintf(stderr,"unable to procced boot\ndropping to rescue shell");
            rescue_shell();
        }
    }

    pid_t pid = fork();

    if (pid == 0) {
        fprintf(stdout,"starting stage 1");
        system(files[0]);
        fprintf(stdout,"stage 1 complete\nstarting stage 2");
        system(files[1]);
    }
        
}

int bootup_reboot(int code) {
    return (reboot(code,(char *)0));
}

void rescue_shell() {
    fprintf(stderr,"== Rescue Shell ====================== ");
    system("/bin/sh");
    fprintf(stdout,"rebooting system");
    sync();
    bootup_reboot(RB_AUTOBOOT);
}