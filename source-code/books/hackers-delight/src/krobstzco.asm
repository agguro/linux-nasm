; krobstzco.asm
; keep rightmost one bit, set trailing zero bits and clear other bits

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

      mov     rax, 0x0000000000045210
      call    printBinary
      call    krobstzco
      call    printBinary

      xor     rdi, rdi
      mov     rax, SYS_EXIT
      syscall

krobstzco:                              ; keep rightmost one bit, set trailing zero bits and clear other bits
      mov     rbx, rax
      dec     rbx
      xor     rax, rbx
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