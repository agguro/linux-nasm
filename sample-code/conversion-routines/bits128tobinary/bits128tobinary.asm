; Name:         bits128tobinary.asm
;
; Build:        nasm -felf64 -o bits128tobinary.o bits128tobinary.asm
;               d -s -melf_x86_64 -o bits128tobinary bits128tobinary.o 
;
; Description:  Convert a 128 bit unsigned integer in RDX:RAX to binary ASCII.
;               IN  : RDX:RAX is number to convert
;                     RDI : pointer to a 128 bytes long buffer
;               OUT : RDI contains a pointer the converted bits in ASCII notation
;
; To-do:        - Check number of leading zeros in case RDX is zero.
;                 In case RDX is zero, check number of leading zeros for RAX

bits 64

[list -]
     %include "unistd.inc"
[list +]

section .bss
     buffer:   resb   128
     eol:      resb   1
    
section .data

     msg:       db  "conversion to binary of 0x0123456789ABCDEF0123456789ABCDEF...", 10
     .length:   equ $-msg
     
section .text
     global _start
_start:        
     syscall    write, stdout, msg, msg.length
     mov        rax, 0x0123456789ABCDEF
     mov        rdx, 0x0123456789ABCDEF
     mov        rdi, buffer
     call       Bits128ToBinary
     mov        byte [eol], 0x0A
     syscall    write, stdout, rdi, 129     ; 128 + 1 byte for end of line
     syscall    exit, 0
     syscall
    
Bits128ToBinary:
     push       rax
     push       rdx
     push       rcx
     push       rdi
     push       r8
     pushfq
     ; prepare help registers
     mov        rcx, 128                      ; 128 times to rotate
     mov        r8, rax                       ; store lowest bits in R8
     .repeat:
     xor        rax, rax
     rcl        r8, 1                         ; shift bit into RAX
     rcl        rdx, 1
     rcl        rax, 1
     add        al, "0"                       ; make ASCII
     stosb                                    ; store in buffer
     loop       .repeat  
     popfq
     pop        r8
     pop        rdi
     pop        rcx
     pop        rdx
     pop        rax
     ret    
