#include <stdio.h>
#include <stdlib.h>
#include <signal.h>

void signalHandler( int signum )
{
    printf ("Interrupt signal (%d)\n",signum);

    // cleanup and close up stuff here  
    // terminate program  

    exit(signum);  

}

int main ()
{
    // register signal SIGINT and signal handler  
    signal(SIGINT, signalHandler);  

    while(1){
       printf ("Going to sleep....\n");
       sleep(1);
    }

    return 0;
}