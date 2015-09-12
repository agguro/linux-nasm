[list -]
%ifndef _ASM_UNISTD_INC_
%define _ASM_UNISTD_INC_

%if __BITS__ == 32
   %warning "using 32 bits syscalls"
   %include "unistd32.inc"
%elif __BITS__ == 64
   %warning "using 64 bits syscalls"
   %include "unistd64.inc"
%endif
     %define stdin   0
     %define stdout  1
     %define stderr  2
     %define STDIN   0             ; just in case someone likes the uppercase version
     %define STDOUT  1             ; just in case someone likes the uppercase version
     %define STDERR  2             ; just in case someone likes the uppercase version
     %define true    1
     %define false   0
     %define TRUE    1
     %define FALSE   0
%endif
[list +]