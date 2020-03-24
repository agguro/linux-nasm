; torzbca.asm
; turn on rightmost zero bit, clear all other bits
; create a word with a single 1-bit at the position of the rightmost 0-bit

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

      mov     rax, 0x80000000000452FF
      call    printBinary
      call    torzbca
      call    printBinary

      xor     rdi, rdi
      mov     rax, SYS_EXIT
      syscall

torzbca:                                ; create a word with a single 1-bit at the position of the rightmost 0-bit
      mov     rbx, rax
      inc     rbx
      not     rax
      and     rax, rbx
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