#include <unistd.h>

int main(){
execl("/usr/bin/xterm", "/usr/bin/xterm", "-e", "bash", "-c", "echo hello", (void*)NULL);
return 0;
}
