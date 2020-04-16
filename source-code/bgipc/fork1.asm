; Name:
;    fork1.asm
;
; Build:
;    nasm "-felf64" fork1.asm -l fork1.lst -o fork1.o
;    ld -s -melf_x86_64 -o fork1 fork1.o
;
; Description:
;    Beej's Guide to IPC fork1 example.
;
; Source:
;    Beej's guide to IPC
;    http://beej.us/guide/bgipc/output/html/multipage/fork.html
;
; August 24, 2014 : assembler 64 bits version
; March 2020 :todo: review the code to work with ABI
;                   make use of syscall writev

bits 64

[list -]
    %include "unistd.inc"
    %include "sys/wait.inc"
[list +]

section .bss

    rv:         resq    1
    buffer:     resb    3
    .length:    equ     $-buffer    
    dummy:      resb    1               ; to flush STDIN
    status:     resq    1
    pid:        resq    1               ; this is not shared, in each process
                                        ; it is a different address

section .data
       
    ; the messages for the child
msgChild:
    .1:            db     " CHILD: This is the child process!", 10
    .2:            db     " CHILD: My PID is "
    .pid:          times  21 db 0
    .3:            db     " CHILD: My parent's PID is "
    .parentpid:    times  21 db 0
    .4:            db     " CHILD: Enter my exit status "
                   db     "(make it small 0-255): "
    .5:            db     " CHILD: I'm outta here!", 10
    .end:          equ    $
    .1.length:     equ    msgChild.2-msgChild.1
    .2.length:     equ    msgChild.pid-msgChild.2
    .3.length:     equ    msgChild.parentpid-msgChild.3
    .4.length:     equ    msgChild.5-msgChild.4
    .5.length:     equ    msgChild.end-msgChild.5
    ; the messages for the parent
msgParent:
    .1:            db     "PARENT: This is the parent process!", 10
    .2:            db     "PARENT: My PID is "
    .pid:          times  21 db 0
    .3:            db     "PARENT: My child's PID is "
    .childpid:     times  21 db 0
    .4:            db     "PARENT: I'm now waiting for my child to exit()"
                   db     "...",10
    .5:            db     "PARENT: My child's exit status is: "
    .status:       times  4 db 0
    .6:            db     "PARENT: I'm outta here!", 10
    .end:          equ    $
    .1.length:     equ    msgParent.2-msgParent.1
    .2.length:     equ    msgParent.pid-msgParent.2
    .3.length:     equ    msgParent.childpid-msgParent.3
    .4.length:     equ    msgParent.5-msgParent.4
    .5.length:     equ    msgParent.status-msgParent.5
    .6.length:     equ    msgParent.end-msgParent.6
    ; error messages
msgError:
    .fork:          db    "Fork error", 10
    .fork.length:   equ   $-msgError.fork
    .wait:          db    "Wait4 error", 10
    .wait.length:   equ   $-msgError.wait
    
section .text
    global  _start

_start:
    syscall fork
    and     rax, rax        ; rax contains the PID
                            ; if zero = child
                            ; if non-zero = child pid for parent process
    js      Error.Fork      ; if negative then there was an error
    jnz     Parent          ; childs pid returned, go to parent

; The child process
Child:
    ; get own pid
    syscall getpid
    mov     qword[pid], rax
    ; get parents pid
    syscall getppid
    mov     r12, rax        ; save parents pid in R12
    ; -- printf(" CHILD: This is the child process!\n");
    syscall write, stdout, msgChild.1, msgChild.1.length
    ; -- printf(" CHILD: My PID is %d\n", getpid());
    mov     rax, qword[pid]
    call    Hex2Dec
    mov     rdi, msgChild.pid
    call    StoreDecimal
    mov     byte[rdi], 10
    add     rdx, msgChild.2.length
    syscall write, stdout, msgChild.2, rdx
    ; -- printf(" CHILD: My parent's PID is %d\n", getppid());
    mov     rax, r12
    call    Hex2Dec
    mov     rdi, msgChild.parentpid
    call    StoreDecimal
    mov     byte [rdi], 10
    add     rdx, msgChild.3.length
    syscall write, stdout, msgChild.3, rdx
    ; -- printf(" CHILD: Enter my exit status (make it small): ");
    syscall write, stdout, msgChild.4, msgChild.4.length

    ; -- scanf(" %d", &rv);
    syscall read, stdin, buffer, buffer.length
    ; parse status code
    ; keep first three characters and flush rest of characters in buffer
    cmp     rax, buffer.length
    jl      .less               ; less than 2 characters + EOL entered
    cmp     byte[buffer+buffer.length-1], 10  
    je      .equal              ; 2 characters + EOL entered
.flush:                         ; too many characters, flush
    syscall read, stdin, dummy, 1
    cmp     byte[rsi], 10
    jne     .flush
.equal:
    mov     rax, buffer.length
.less:   
    mov     byte[buffer+rax-1], 0
    ; convert status code to hexadecimal and store in rv
    mov     rsi, buffer
    xor     rax, rax
    cld
    xor     rdx, rdx                           ; result exit status
.repeat:
    lodsb
    and     al, al
    jz      .done
    mov     dh, dl                             ; dh = dh * 10
    shl     dh, 3
    shl     dl, 1
    add     dl, dh
    xor     dh, dh
    and     al, 0x0F                           ; un-ascii
    add     rdx, rax
    jmp     .repeat
.done:
    mov     qword[rv], rdx
    ; -- printf(" CHILD: I'm outta here!\n");
    syscall write, stdout ,msgChild.5, msgChild.5.length
     
    ; -- exit(rv);
    syscall exit, qword[rv]
        
; The parent process
Parent:
    ; save childs pid returned from fork
    mov     r12, rax                           ; childs pid
    ; now get own pid
    syscall getpid
    mov     qword[pid], rax
    ; -- printf("PARENT: This is the parent process!\n");
    syscall write, stdout, msgParent.1, msgParent.1.length
    ; -- printf("PARENT: My PID is %d\n", getpid());
    mov     rax, qword[pid]
    call    Hex2Dec
    mov     rdi, msgParent.pid
    call    StoreDecimal
    mov     byte[rdi], 10
    add     rdx, msgParent.2.length
    syscall write, stdout, msgParent.2, rdx
    ; -- printf("PARENT: My child's PID is %d\n", pid);
    mov     rax, r12
    call    Hex2Dec
    mov     rdi, msgParent.childpid
    call    StoreDecimal
    mov     byte[rdi], 10
    add     rdx, msgParent.3.length
    syscall write, stdout, msgParent.3, rdx
    ; -- printf("PARENT: I'm now waiting for my child to exit()...\n");
    syscall write, stdout, msgParent.4, msgParent.4.length
    ; wait for child to terminate
    syscall wait4, r12, status, 0, 0
    and     rax, rax
    js      Error.Wait
    ; -- printf("PARENT: My child's exit status is: %d\n", WEXITSTATUS(rv));
    mov     rax, qword[status]
    and     rax, 0xFF00
    shr     rax, 8
    ; save exit status. check n terminal with $?
    push    rax                                 
    call    Hex2Dec
    mov     rdi, msgParent.status
    call    StoreDecimal
    mov     byte[rdi], 10                      ; length + 1
    add     rdx, msgParent.5.length                                               
    syscall write, stdout, msgParent.5, rdx
    ; -- printf("PARENT: I'm outta here!\n");
    syscall write, stdout, msgParent.6, msgParent.6.length
    pop     rdi
    jmp     Exit
    
Error:
.Fork:
    mov     rdx, msgError.fork.length
    mov     rsi, msgError.fork
    jmp     Error.Write
.Wait:
    mov     rdx, msgError.wait.length
    mov     rsi, msgError.wait
.Write:
    syscall write, stdout
    xor     rdi, rdi
Exit:
    syscall exit, rdi

Hex2Dec:
    ; r10:r9:r8 = decimal(rax)
    xor     r10, r10                ; R10:R9:R8 hold the decimal value of RAX
    xor     r9, r9                  
    xor     r8, r8
    mov     rbx, 10                 ; base 10 for decimal
    clc
.repeat:        
    xor     rdx, rdx                ; clear remainder register
    idiv    rbx
    or      dl, "0"
    mov     rcx, 8
.shift:        
    rcr     dl, 1                   ; rotate ASCII decimal in R10:R9:R8
    rcr     r10, 1
    rcr     r9, 1
    rcr     r8, 1
    dec     rcx
    and     rcx, rcx
    jnz     .shift
    and     rax, rax                ; if quotient is zero, nothing to be done
    jnz     .repeat                 ; if not repeat procedure
    ret

StoreDecimal:
    ; RDI = pointer to buffer
    ; R10:R9:R8 = decimal value in ASCII
    ; return:
    ; RDX = length of decimal number
    ; RDI = offset to byte right after the stored integer
    clc
    xor     rdx,rdx
.repeat:
    inc     rdx
    mov     rcx,8
.shift:      
    rcl     r8,1
    rcl     r9,1
    rcl     r10,1
    rcl     rax,1
    dec     rcx
    and     rcx,rcx
    jnz     .shift
    and     al,al
    jz      .done
    stosb
    jmp     .repeat
.done:        
    ret
