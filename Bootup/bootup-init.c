#include <stdio.h>
#include <string.h>
#include <unistd.h>

int main(int argc, char* argv[]) {
    
    // Check SuperUser
    if (geteuid() != 0) {
        fprintf(stderr,"should be executed with root permissions");
        exit(1);
    }

    
}