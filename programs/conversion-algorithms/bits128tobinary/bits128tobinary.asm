; Name:         bits128tobinary
; Build:        nasm -felf64 -o bits128tobinary.o bits128tobinary.asm
; Description:  Convert a 128 bit unsigned integer in RDX:RAX to binary ASCII.
;               IN  : RDX:RAX is number to convert
;                     RDI : pointer to a 128 bytes long buffer
;               OUT : RDI contains a pointer the converted bits in ASCII notation
;
; To-do:        Check number of leading zeros in case RDX is zero.
;               In case RDX is zero, check number of leading zeros for RAX

bits 64

[list -]
     %include "unistd.inc"
[list +]

section .bss
     buffer:   resb   128
     eol:      resb   1
    
section .data

section .text
     global _start
_start:        
     mov       rax, 0xFFFFFFFEFFFFFFFF
     mov       rdx, 0xF0FFFFFFE
     mov       rdi, buffer
     call      Bits128ToBinary
     mov       BYTE[eol], 0x0A
     mov       rsi, rdi
     mov       rdx, 128+1
     mov       rdi, STDOUT
     mov       rax, SYS_WRITE
     syscall
     xor       rdi, rdi
     mov       rax, SYS_EXIT
     syscall
    
Bits128ToBinary:
     push      rax
     push      rdx
     push      rcx
     push      rdi
     push      r8
     pushfq
     ; prepare help registers
     mov       rcx, 128                      ; 128 times to rotate
     mov       r8, rax                       ; store lowest bits in R8
     .repeat:
     xor       rax, rax
     rcl       r8, 1                         ; shift bit into RAX
     rcl       rdx, 1
     rcl       rax, 1
     add       al, "0"                       ; make ASCII
     stosb                                   ; store in buffer
     loop      .repeat  
     popfq
     pop       r8
     pop       rdi
     pop       rcx
     pop       rdx
     pop       rax
     ret    