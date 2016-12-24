; Name:         sleep.asm
;
; Build:        nasm "-felf64" sleep.asm -l sleep.lst -o sleep.o
;               ld -s -melf_x86_64 -o sleep sleep.o 
;
; Description:  running the program will delay for 5 seconds
;               This program can be extended with the use of a signal to prematurely interrupt the
;               nanosleep syscall. (in case you should set it to sleep for several hours, and by passing
;               the 'sleeping' time as an argument. (see linux sleep command).
; Remark:
; When you should decide to use this frequently with large intervals then you have to adjust your OS time.

bits 64

[list -]
     %include "unistd.inc"
     %include "sys/time.inc"
[list +]

     %define SECONDS         5
     %define NANOSECONDS     0

section .bss
    
section .data

     msgSleeping:   db   'sleeping for 5 seconds...', 10
     .length:       equ  $-msgSleeping
     msgAwake:      db   'back up and running.', 10
     .length:       equ  $-msgAwake
    
     TIMESPEC timer

section .text
     global _start
    
_start:
     mov       qword [timer.tv_sec], SECONDS
     mov       qword [timer.tv_nsec], NANOSECONDS
     syscall   write, stdout, msgSleeping, msgSleeping.length
     syscall   nanosleep, qword timer, 0
     syscall   write, stdout, msgAwake, msgAwake.length
     syscall   exit, 0
