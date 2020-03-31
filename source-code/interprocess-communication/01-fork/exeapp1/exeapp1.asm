; Name:         exeapp1.asm
;
; Build:        nasm "-felf64" exeapp4.asm -l exeapp4.lst -o exeapp4.o
;               ld -s -melf_x86_64 -o exeapp4 exeapp4.o
;
; Description:  First demonstration of four examples on how to execute a program or shell script from within an
;               assembler program. Assumed is that the 'hello' program is present, that you
;               know the path to it and the hello program must be EXECUTABLE!! chmod +x hello.
;               If everything behaves, the child exits after the execution of the child process (the hello application)
;               make sure that hello is executable or no messages will be displayed at all.

bits 64

[list -]
        %include "unistd.inc"
[list +]

section .data
        
     filename:      db   "hello",0          ; full path! 
     .length:       equ  $-filename
     ; argument pointer list to pass to the application to be executed, terminated by NULL
     argvPtr:       dq   filename           ; this is not a must but some programs (nasm for example) requires it.
                                            ; remark this line and change hello in /usr/bin/nasm for a demonstration.
                    dq   0   
     envPtr:        dq   0                  ; pointer to environment parameters
     forkerror:     db   "fork error", 10
     .length:       equ  $-forkerror
     execveerror:   db   "return not expected -> execve error for command: "
     .length:       equ  $-execveerror
    
section .text
     global _start

_start:

     syscall   fork
     and       rax, rax
     js        Error.Fork
     jnz       ParentProcess
     
ChildProcess:
       
     syscall   execve, filename, argvPtr, envPtr
     
ParentProcess:
     ; wait for child to terminate
     syscall   wait4, 0, 0, 0, 0
Exit:
     xor       rdi, rdi
     syscall   exit
     
Error.Fork:
     mov       rsi, forkerror
     mov       rdx, forkerror.length
     call      Write
     jmp       Exit
     
Error.Execve:
     mov       rsi, execveerror
     mov       rdx, execveerror.length
     call      Write
     mov       rsi, filename
     mov       rdx, filename.length
     mov       byte[rsi+rdx-1], 10     ; change trailing zero into EOL
     call      Write
     jmp       Exit
     
Write:     
     syscall   write, stdout
     ret
