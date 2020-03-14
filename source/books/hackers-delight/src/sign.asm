; sign.asm
; sign function
; case RAX < 0 result is -1 (two's complement)
;      RAX = O result is  0
;      RAX > 1 result is  1
;
; Source: Hacker's Delight

[list -]
      %include "syscalls.inc"
      %include "termio.inc"
[list +]
 
bits 64
 
section .bss
      buffer: resb 1
 
section .data
 
section .text
      global _start
 
_start:
 
      
      mov       rax, -109                        ; rax = -109
      call      printBinary
      call      sign
      call      printBinary
 
      xor       rdi, rdi
      mov       rax, SYS_EXIT
      syscall
 
sign:                                            ; determine sign of RAX
 
      mov       rbx, rax
      shr       rax, 63
      neg       rax
      neg       rbx
      shr       rbx, 63
      or        rax, rbx
      ret
 
printBinary:
      push      rax
      mov       rcx, 64                 ; 64 bits to display
      clc                               ; clear carry flag
.repeat:
      rcl       rax, 1                  ; start with leftmost bit
      adc       BYTE[buffer],0x30       ; make it ASCII
      push      rcx
      push      rax
      call      printBuffer
      pop       rax
      pop       rcx
      loop      .repeat
      mov       BYTE[buffer],0x0A
      call      printBuffer
      pop       rax
      ret
 
printBuffer:
      mov       rax, SYS_WRITE
      mov       rdi, STDOUT
      mov       rsi, buffer
      mov       rdx, 1
      syscall
      and       BYTE[buffer],0          ; clear buffer
      ret
