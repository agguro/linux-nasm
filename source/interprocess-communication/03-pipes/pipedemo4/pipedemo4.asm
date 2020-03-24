; Name          : pipedemo4.asm
;
; Build         : nasm -felf64 pipedemo4.asm -l pipedemo4.lst -o pipedemo4.o
;                 ld -s -melf_x86_64 -o pipedemo4 pipedemo4.o
;
; Description   : A demonstration on pipes based on an example from Beej's Guide to IPC
;                 Here the program opens the write end of the pipe, writes data in it
;                 and retrieve it through the read end of the pipe.  The buffer must be large
;                 enough, a to small buffer leads to loss of data because not all data will be
;                 read from the pipe.
;
; Source        : Beejs guide to IPC - http://beej.us/guide/bgipc/output/html/multipage/pipes.html
;
; August 24, 2014 : assembler 64 bits version
 
bits 64
 
[list -]
    %include "unistd.inc"
[list +]

    %define         DATA    "this is the test sentence"
        
section .bss
    ; pdfs
    pdfs:
    .read:          resd    1       ; read end
    .write:         resd    1       ; write end
 
section .data

    msg1:           db      "writing to file descriptor #"
    .length:        equ     $-msg1
    
    .pdf1:          times   10 db 0                            ; max size of DWORD
                    db      0
    
    msg2:           db      "reading from file descriptor #"
    .length:        equ     $-msg2
  
    .pdf0:          times   10 db 0                            ; max size of DWORD
                    db      0

    data:           db      DATA
    .length:        equ     $-data
  
    msg3:           db      "read ", 0x22                      ; ASCII for "
    .buffer:        times   data.length db 0                   ; reserving length of data bytes
                    db      0x22, 10
    .length:        equ     $-msg3
  
    pipeerror:      db      "pipe call error"
    .length:        equ     $-pipeerror
 
section .text
    global _start

_start:
    
    ; create pipe, pdfs is an array to the READ and WRITE ends of the pipe
    syscall     pipe, pdfs
    jns         startpipe                                       ; if RAX < 0 then error
    syscall     write, stdout, pipeerror, pipeerror.length
    jmp         Exit
      
startpipe:
    ; prepare messages to be displayed with one syscall
    xor         rax, rax
    mov         eax, dword[pdfs.read]
    call        Hex2Dec
    mov         rdi, msg2.pdf0
    call        StoreDecimal
    add         rdx, msg2.length
    mov         byte[rdi], 10                                   ; EOL behind the decimal
    inc         rdx                                             ; adjust length of decimal
    mov         r14, rdx                                        ; R14 is length of msg2
    xor         rax, rax
    mov         eax, dword[pdfs.write]
    call        Hex2Dec
    mov         rdi, msg1.pdf1
    call        StoreDecimal
    add         rdx, msg1.length
    mov         byte[rdi], 10                                   ; EOL behind the decimal
    inc         rdx                                             ; adjust length of decimal
    mov         r15, rdx                                        ; R15 is length of msg1
    ; write message msg1
    syscall     write, stdout, msg1, r15    
    ; write to the pipe
    mov         edi, dword[pdfs.write]
    syscall     write, rdi, data, data.length
    ; write message msg2
    syscall     write, stdout, msg2, r14
    ; read from pipe
    mov         edi, dword[pdfs.read]
    syscall     read, rdi, msg3.buffer, data.length
    ; write output with buffer to STDOUT
    syscall     write, stdout, msg3, msg3.length
Exit:      
    syscall     exit, 0
      
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
    dec         rdx
    ret
