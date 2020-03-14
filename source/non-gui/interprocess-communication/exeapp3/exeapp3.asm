; Name:         exeapp3.asm
;
; Build:        nasm "-felf64" exeapp3.asm -l exeapp3.lst -o exeapp3.o
;               ld -s -melf_x86_64 -o exeapp3 exeapp3.o
;
; Description:  Demonstration on how to execute a bash script from a program and the environment parameters.
;               be sure that the script is set executable with chmod +x
;               We set an environment parameter TESTVAR to a value and read it out with the script test.sh.
;               Running the script directly doesn't display the TESTVAR value. (unless someone has defined it already)

bits 64

[list -]
        %include "unistd.inc"
[list +]

section .data
     filename:      db   "test.sh",0             ; full path!
     .length:       equ  $-filename
     
     ;... put more arguments here

     envp1:         db   "TESTVAR=123456",0
     
     
     argvPtr:       dq   filename
                    ; more pointers to arguments here
                    dq      0                               ; terminate the list of pointers with NULL

     envPtr:        dq   envp1
                    dq   0
        
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
     syscall   exit, 0
     
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
