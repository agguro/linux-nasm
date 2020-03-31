; signext.asm
; sign extension
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
 
      mov       rax, 0x000F000000000000         ; set RAX to a value, these bits will be ignored
      mov       ax, -109                        ; ax = -109, bit 16 = sign bit
      call      printBinary
      call      signExt
      call      printBinary
 
      xor       rdi, rdi
      mov       rax, SYS_EXIT
      syscall
 
signExt:                              ; sign extension
 
      add       rax, 0x0000000000000080
      and       rax, 0x00000000000000FF
      sub       rax, 0x0000000000000080
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
