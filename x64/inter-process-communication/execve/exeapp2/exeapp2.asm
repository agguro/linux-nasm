; Name:         exeapp2.asm
; Build:        see makefile
; Run:          ./exeapp2
; Description:  Demonstration on how to execute a program / shell script from within an assembler program.
;               This example, as extension of exeapp1, shows how to pass arguments to the application being called.
;               Assumed is the presence of the program arguments.

BITS 64

[list -]
        %include "unistd.inc"
[list +]

section .data
        
     filename:      db   "arguments",0                   ; full path!
     .length:       equ  $-filename
     argv1:         db   "hello", 0                      ; a first argument to pass
     argv2:         db   "world", 0                      ; a second argument to pass
     ;... put more arguments here
               
     argvPtr:       dq   filename
                    dq   argv1
                    dq   argv2
                    ; more pointers to arguments here
     envPtr:        dq      0                            ; terminate the list of pointers with NULL
     ; envPtr is put at the end of the argv pointer list to safe some bytes
     
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
     
