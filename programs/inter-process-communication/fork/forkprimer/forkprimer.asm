; fork.asm
;
; Source : Beejs guide to IPC - http://beej.us/guide/bgipc/output/html/multipage/fork.html
;
; August 24, 2014 : assembler 64 bits version
;
; Description:
; A demonstration on fork syscall based on an example from Beej's Guide to IPC.
; At the end the user needs to enter an exit status. The program accepts no more than 3
; characters. An exit status is a number in [0 .. 255]. Any other value will be converted
; with his ASCII equivalent from hexadecimal to decimal and displayed. The result of the exit state
; will differ from the one entered if the user didn't entered a value between 0 and 255 both included.
;
; Disclaimer:
; GNU GENERAL PUBLIC LICENSE 3 

BITS 64
ALIGN 16

[list -]
     %include "unistd.inc"
     %include "sys/wait.inc"
[list +]

section .bss
     rv:            resq    1
     buffer:        resb    4
     .length:       equ     $-buffer    
     dummy:         resb    1               ; to flush STDIN
     status:        resq    1
     pid:           resq    1               ; this is not shared, in each process it is a different address
    
section .data
       
     ; the messages for the child
     msgChild:
     .1:            db    " CHILD: This is the child process!", 10
     .2:            db    " CHILD: My PID is "
     .pid:          times 21 db 0
     .3:            db    " CHILD: My parent's PID is "
     .parentpid:    times 21 db 0
     .4:            db    " CHILD: Enter my exit status (make it small 0-255): "
     .5:            db    " CHILD: I'm outta here!", 10
     .end:          equ   $

     .1.length:     equ   msgChild.2-msgChild.1
     .2.length:     equ   msgChild.pid-msgChild.2
     .3.length:     equ   msgChild.parentpid-msgChild.3
     .4.length:     equ   msgChild.5-msgChild.4
     .5.length:     equ   msgChild.end-msgChild.5

     ; the messages for the parent
     msgParent:
     .1:            db    "PARENT: This is the parent process!", 10
     .2:            db    "PARENT: My PID is "
     .pid:          times 21 db 0
     .3:            db    "PARENT: My child's PID is "
     .childpid:     times 21 db 0
     .4:            db    "PARENT: I'm now waiting for my child to exit()...", 10
     .5:            db    "PARENT: My child's exit status is: "
     .status:       times 4 db 0
     .6:            db    "PARENT: I'm outta here!", 10
     .end:          equ   $

     .1.length:     equ   msgParent.2-msgParent.1
     .2.length:     equ   msgParent.pid-msgParent.2
     .3.length:     equ   msgParent.childpid-msgParent.3
     .4.length:     equ   msgParent.5-msgParent.4
     .5.length:     equ   msgParent.status-msgParent.5
     .6.length:     equ   msgParent.end-msgParent.6

    ; error messages
    msgError:
    .fork:          db    "Fork error", 10
    .fork.length:   equ  $-msgError.fork
    .wait:          db    "Wait4 error", 10
    .wait.length:   equ  $-msgError.wait
    
section .text
     global  _start

_start:
     mov         rax, SYS_fork
     syscall
     and         rax, rax                        ; rax contains the PID
                                                 ; if zero = child
                                                 ; if non-zero = child pid for parent process
     js          Error.Fork                      ; if negative then there was an error
     jnz         Parent                          ; childs pid returned, go to parent

; The child process
Child:
     ; get own pid
     mov         rax, SYS_getpid
     syscall
     mov         QWORD[pid], rax
     ; get parents pid
     mov         rax, SYS_getppid
     syscall
     mov         r12, rax                                ; save parents pid in R12

     ; -- printf(" CHILD: This is the child process!\n");
     mov         rsi, msgChild.1
     mov         rdx, msgChild.1.length
     mov         rdi, stdout
     mov         rax, SYS_write
     syscall

     ; -- printf(" CHILD: My PID is %d\n", getpid());
     mov         rax, QWORD[pid]
     call        Hex2Dec
     mov         rdi, msgChild.pid
     call        StoreDecimal
     mov         BYTE[rdi], 10
     add         rdx, msgChild.2.length
     mov         rsi, msgChild.2
     mov         rdi, stdout
     mov         rax, SYS_write
     syscall

     ; -- printf(" CHILD: My parent's PID is %d\n", getppid());
     mov         rax, r12                     ;QWORD[child.parent]
     call        Hex2Dec
     mov         rdi, msgChild.parentpid
     call        StoreDecimal
     mov         BYTE[rdi], 10
     add         rdx, msgChild.3.length
     mov         rsi, msgChild.3
     mov         rdi, stdout
     mov         rax, SYS_write
     syscall

     ; -- printf(" CHILD: Enter my exit status (make it small): ");
     mov         rsi, msgChild.4
     mov         rdx, msgChild.4.length
     mov         rdi, stdout
     mov         rax, SYS_write
     syscall

     ; -- scanf(" %d", &rv);
     mov         rsi, buffer
     mov         rdx, buffer.length                      ; since rv can be between 0 and 255, 3 bytes must be enough
     mov         rdi, stdin
     mov         rax, SYS_read
     syscall

     ; parse status code
     ; keep first three characters and flush rest of characters in buffer
     cmp         rax, buffer.length
     jl          .less                                   ; less than 3 characters + EOL entered
     cmp         BYTE[buffer+buffer.length-1], 10
     je          .equal                                  ; 3 characters + EOL entered
.flush:                                                 ; to many characters entered, we need to flush
     mov         rdi, stdin
     mov         rsi, dummy
     mov         rdx, 1
     mov         rax, SYS_read
     syscall
     cmp         BYTE[rsi], 10
     jne         .flush
.equal:
     mov         rax, buffer.length
.less:   
     mov         BYTE[buffer+rax-1], 0
     ; convert status code to hexadecimal and store in rv
     mov         rsi, buffer
     xor         rax, rax
     cld
     xor         rdx, rdx                ; result exit status
.repeat:
     lodsb
     and         al, al
     jz          .done
     mov         dh, dl                  ; dh = dh * 10
     shl         dh, 3
     shl         dl, 1
     add         dl, dh
     xor         dh, dh
     and         al, 0x0F                ; un-ascii
     add         rdx, rax
     jmp         .repeat
.done:
     mov         QWORD[rv], rdx

     ; -- printf(" CHILD: I'm outta here!\n");
     mov         rsi, msgChild.5
     mov         rdx, msgChild.5.length
     mov         rdi, stdout
     mov         rax, SYS_write
     syscall       
     
     ; -- exit(rv);
     mov         rdi, QWORD[rv]
     mov         rax, SYS_exit
     syscall
        
; The parent process
Parent:
     ; save childs pid returned from fork
     mov         r12, rax                                ; childs pid
     ; now get own pid
     mov         rax, SYS_getpid
     syscall
     mov         QWORD[pid], rax

     ; -- printf("PARENT: This is the parent process!\n");
     mov         rsi, msgParent.1
     mov         rdx, msgParent.1.length
     mov         rdi, stdout
     mov         rax, SYS_write
     syscall

     ; -- printf("PARENT: My PID is %d\n", getpid());
     mov         rax, QWORD[pid]
     call        Hex2Dec
     mov         rdi, msgParent.pid
     call        StoreDecimal
     mov         BYTE[rdi], 10
     add         rdx, msgParent.2.length
     mov         rsi, msgParent.2
     mov         rdi, stdout
     mov         rax, SYS_write
     syscall

     ; -- printf("PARENT: My child's PID is %d\n", pid);
     mov         rax, r12
     call        Hex2Dec
     mov         rdi, msgParent.childpid
     call        StoreDecimal
     mov         BYTE[rdi], 10
     add         rdx, msgParent.3.length
     mov         rsi, msgParent.3
     mov         rdi, stdout
     mov         rax, SYS_write
     syscall

     ; -- printf("PARENT: I'm now waiting for my child to exit()...\n");
     mov         rsi, msgParent.4
     mov         rdx, msgParent.4.length
     mov         rdi, stdout
     mov         rax, SYS_write
     syscall

     ; wait for child to terminate
     mov         rcx, 0
     mov         rdx, 0
     mov         rsi, status                        
     mov         rdi, r12
     mov         rax, SYS_wait4                      ; wait for child to terminate
     syscall
     and         rax, rax
     js          Error.Wait
     
     ; -- printf("PARENT: My child's exit status is: %d\n", WEXITSTATUS(rv));
     ; we can access rv only through the status returned by wait4 syscall in RSI
     WEXITSTATUS rax, QWORD[status]
     call        Hex2Dec
     mov         rdi, msgParent.status
     call        StoreDecimal
     mov         BYTE[rdi], 10                                ; length + 1
     add         rdx, msgParent.5.length
     mov         rsi, msgParent.5
     mov         rdi, stdout
     mov         rax, SYS_write
     syscall

     ; -- printf("PARENT: I'm outta here!\n");
     mov         rsi, msgParent.6
     mov         rdx, msgParent.6.length
     mov         rdi, stdout
     mov         rax, SYS_write
     syscall
     jmp         Exit

Error:
.Fork:
     mov         rdx, msgError.fork.length
     mov         rsi, msgError.fork
     jmp         Error.Write
.Wait:
     mov         rdx, msgError.wait.length
     mov         rsi, msgError.wait
.Write:
     mov         rdi, stdout
     mov         rax, SYS_write
     syscall

Exit:
     xor         rdx, rdx
     mov         rax, SYS_exit
     syscall

Hex2Dec:
     ; r10:r9:r8 = decimal(rax)
     xor         r10, r10                ; R10:R9:R8 will hold the decimal value of RAX
     xor         r9, r9                  
     xor         r8, r8
     mov         rbx, 10                 ; base 10 for decimal
     clc
.repeat:        
     xor         rdx, rdx                ; clear remainder register
     idiv        rbx
     or          dl, "0"
     mov         rcx, 8
.shift:        
     rcr         dl, 1                   ; rotate ASCII decimal in R10:R9:R8
     rcr         r10, 1
     rcr         r9, 1
     rcr         r8, 1
     dec         rcx
     and         rcx, rcx
     jnz         .shift
     and         rax, rax                ; if quotient is zero, nothing to be done anymore
     jnz         .repeat                 ; if not repeat procedure
     ret

StoreDecimal:
     ; RDI = pointer to buffer
     ; R10:R9:R8 = decimal value in ASCII
     ; return:
     ; RDX = length of decimal number
     ; RDI = offset to byte right after the stored integer
     
     clc
     xor         rdx, rdx
.repeat:
     inc         rdx
     mov         rcx, 8
.shift:        
     rcl         r8, 1
     rcl         r9, 1
     rcl         r10, 1
     rcl         rax, 1
     dec         rcx
     and         rcx, rcx
     jnz         .shift
     and         al, al
     jz          .done
     stosb
     jmp         .repeat
.done:        
     ret        