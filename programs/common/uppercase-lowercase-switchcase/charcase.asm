; name        : charcase.asm
; build       : see makefile
; description : convert a asciiz string pointed to by RDI, to uppercase
;             : this program can be improved using subroutines, I did not to improve readability

BITS 64
ALIGN 16

[list -]
     %include "unistd.inc"
[list +]

section .bss

section .data
    msg0:       db      "Start string", 10
    .length:    equ     $-msg0
    msg1:       db      "Inverting case", 10
    .length:    equ     $-msg1
    msg2:       db      "To uppercase", 10
    .length:    equ     $-msg2
    msg3:       db      "To lowercase", 10
    .length:    equ     $-msg3
    theText:    db      "AbCdEfGhIjKlMnOpQrStUvWxYz0123456789", 10, 0
    .length:    equ     $-theText
    
section .text

global _start
_start:

    ; start string
    mov         r8, msg0
    mov         r9, msg0.length
    call        Output
    
    ; switch case
    call        Character.SwitchCase
    mov         r8, msg1
    mov         r9, msg1.length
    call        Output
    
    ; to uppercase
    call        Character.ToUpperCase
    mov         r8, msg2
    mov         r9, msg2.length
    call        Output

    ; to lowercase
    call        Character.ToLowerCase
    mov         r8, msg3
    mov         r9, msg3.length
    call        Output
    
    ; and exit
    xor         rdi, rdi
    mov         rax, SYS_EXIT
    syscall

Output:
    mov         rsi, r8
    mov         rdx, r9
    call        Print
    mov         rsi, theText
    mov         rdx, theText.length
Print:
    mov         rdi, STDOUT
    mov         rax, SYS_WRITE
    syscall
    ret

; 3 separate routines, but they can be put together to save space if we use them all three in a single
; program
Character.ToUpperCase:
    mov         rsi, theText
    mov         rdi, theText    
    cld
.repeat:    
    lodsb
    and         al, al
    jz          .done
    cmp         al, "a"
    jb          .skip
    cmp         al, "z"
    ja          .skip
.change:
    and         al, 11011111b
.skip:
    stosb
    jmp         .repeat
.done:
    ret   

Character.ToLowerCase:
    mov         rsi, theText
    mov         rdi, theText
    cld
.repeat:    
    lodsb
    and         al, al
    jz          .done
    cmp         al, "A"
    jb          .skip
    cmp         al, "Z"
    ja          .skip
.change:
    or          al, 00100000b
.skip:
    stosb
    jmp         .repeat
.done:
    ret

Character.SwitchCase:
    mov         rsi, theText
    mov         rdi, theText
    cld
.repeat:    
    lodsb
    and         al, al
    jz          .done
    ; only alphanumerical characters can be switched
    cmp         al, "A"
    jb          .skip               ; we have to jump to stosb to adjust RDI too
    cmp         al, "Z"
    jbe         .change
    cmp         al, "a"
    jb          .skip
    cmp         al, "z"
    ja          .skip
.change:
    xor         al, 00100000b
.skip:
    stosb
    jmp         .repeat
.done:
    ret
