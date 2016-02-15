; Name  : bits128todecimal
; Build : nasm -felf64 -o bits128todecimal.o bits128todecimal.asm
; Convert an 128 bit unsigned integer in RDX:RAX to decimal in a buffer pointed by RDI. The
; the buffer must be large enougd to store the converted decimal.
; IN  : RDX:RAX : is number to convert
;       RDI     : pointer to a 39 bytes long buffer
; OUT : RSI     : pointer to a 39 bytes long buffer with converted number as ASCII decimal.
;
; To-do : optimize if RDX should be all zeros (32 bits numbers)
;         check number of leading zeros for lower bits conversions

bits 64

[list -]
     %include "unistd.inc"
[list +]

section .bss
     buffer:  resb   39
     eol:     resb   1
    
section .data 
    
section .text
     global _start
_start:

     mov       rax, 0xFFFFFFFFFFFFFFFF
     mov       rdx, 0xFFFFFFFFFFFFFFFF
     mov       rdi, buffer
     call      Bits128ToDecimal
     mov       BYTE[eol], 0x0A
     mov       rsi, buffer
     mov       rdx, 39+1
     mov       rcx, 39
.repeat:
     lodsb
     cmp       al, "0"
     jne       .write
     dec       rdx
     loop      .repeat
.write:
     dec       rsi
     mov       rdi, STDOUT
     mov       rax, SYS_WRITE
     syscall
     xor       rdi, rdi
     mov       rax, SYS_EXIT
     syscall

Bits128ToDecimal:
     push      rax
     push      rbx
     push      rcx
     push      rdx
     push      rdi
     push      r8
     push      r9
     push      r10
     push      r11
     pushfq
          
     clc
     mov       rcx, 32
     xor       r9, r9
     xor       r11, r11
.nextbit:    
     rcl       rax, 1
     rcl       r9, 1
     rcl       rdx, 1
     rcl       r11, 1
     loop      .nextbit
     shr       rax, 32
     mov       r8, rax
     shr       rdx, 32
     mov       r10, rdx
     std                                     ; store backwards
     add       rdi, 38                         ; end of buffer
     mov       rcx, 39                         ; 39 digits to calculate
     mov       rbx, 10                         ; base 10        
.repeat:    
     mov       rax, r11
     xor       rdx, rdx                        ; prepare division
     idiv      rbx
     shl       rdx, 32    
     mov       r11, rax
     or        r10, rdx
     mov       rax, r10
     xor       rdx, rdx                        ; prepare division
     idiv      rbx
     shl       rdx, 32    
     mov       r10, rax
     or        r9, rdx
     mov       rax, r9
     xor       rdx, rdx                        ; prepare division    
     idiv      rbx
     shl       rdx, 32
     mov       r9, rax
     or        r8, rdx
     mov       rax, r8
     xor       rdx, rdx
     idiv      rbx
     mov       r8, rax
     mov       rax, rdx
     or        rax, 0x30
     stosb
     loop      .repeat   
.stop:
     popfq
     pop       r11
     pop       r10
     pop       r9
     pop       r8
     pop       rdi
     pop       rdx
     pop       rcx
     pop       rbx
     pop       rax
     ret