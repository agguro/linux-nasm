; snoob.asm
; Next higher number with same number of 1-bits
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

      mov       rax, 0x000001000F000000
      call      printBinary
      call      snoob
      call      printBinary

      xor       rdi, rdi
      mov       rax, SYS_EXIT
      syscall

snoob:                              ; next higher number with same number of 1-bits
      xor       rdx, rdx
      mov       rbx, rax
      neg       rbx
      and       rbx, rax
      mov       rcx, rax
      add       rcx, rbx
      xor       rax, rcx
      shr       rax, 2
      idiv      rbx
      or        rcx, rax
      mov       rax, rcx
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
