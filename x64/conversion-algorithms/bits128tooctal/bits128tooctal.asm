; Name:         bits128tooctal
; Build:        nasm -felf64 -o bits128tooctal.o bits128tooctal.asm
; Description:  Convert a 128 bit unsigned integer in RDX:RAX to octal ASCII.
;               IN  : RDX:RAX is number to convert
;                     RDI : pointer to a 43 bytes long buffer
;               OUT : RDI contains the converted octal in ASCII notation
;
; To-do : optimize if RDX should be all zeros (32 bits numbers)
;         check number of leading zeros for lower bits conversions

bits 64

[list -]
     %include "unistd.inc"
[list +]

section .bss
     buffer:   resb   43
     eol:      resb   1
    
section .data

section .text
     global _start
_start:        
     mov       rax, 0xFFFFFFFFFFFFFFFF
     mov       rdx, 0xFFFFFFFFFFFFFFFF

     mov       rdi, buffer
     call      Bits128ToOctal
     mov       BYTE[eol], 0x0A
     mov       rsi, buffer
     mov       rdx, 43+1
     mov       rcx, 43
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

Bits128ToOctal:
     push      rax
     push      rcx
     push      rdx
     push      rdi
     push      r8
     pushfq
     ; prepare help registers

     clc
     cld
     mov       r8, rax                 ; lowest 64 bits in R8    
     mov       rcx, 43                 ; 43 octals to do, first octal takes first two bits
.repeat:
     xor       al, al          
     cmp       rcx, 42                 ; first two done
     jg        .skip                   ; no, do them first
     rcl       r8, 1
     rcl       rdx, 1
     rcl       al, 1
.skip:    
     rcl       r8, 1
     rcl       rdx, 1
     rcl       al, 1
     rcl       r8, 1
     rcl       rdx, 1
     rcl       al, 1
     add       al,"0"                  ; make ASCII
     stosb
     loop      .repeat

     popfq
     pop       r8
     pop       rdi
     pop       rdx
     pop       rcx
     pop       rax
     ret