; pop.asm
; counting 1 bits
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
      message:       db " has one bits.",0x0A
      .length:       equ $-message
 
section .text
global _start
 
_start:
 
      mov     rax, 184467440737
      call    printBinary
      call    pop
      push    rax
      mov     rsi, message
      mov     rdx, 5
      call    print
      pop     rax
      call    printDecimal
      mov     rsi, message
      add     rsi, 4
      mov     rdx, message.length
      sub     rdx, 4
      call    print
      xor     rdi, rdi
      mov     rax, SYS_EXIT
      syscall
 
pop:                                            ; count 1 bits
      mov       rbx, rax
      mov       rcx, 0x5555555555555555
      and       rbx, rcx
      shr       rax, 1
      and       rax, rcx
      add       rax, rbx
      mov       rbx, rax
      mov       rcx, 0x3333333333333333
      and       rbx, rcx
      shr       rax, 2
      and       rax, rcx
      add       rax, rbx
      mov       rbx, rax
      mov       rcx, 0x0F0F0F0F0F0F0F0F
      and       rbx, rcx
      shr       rax, 4
      and       rax, rcx
      add       rax, rbx
      mov       rbx, rax
      mov       rcx, 0x00FF00FF00FF00FF
      and       rbx, rcx
      shr       rax, 8
      and       rax, rcx
      add       rax, rbx
      mov       rbx, rax
      mov       rcx, 0x0000FFFF0000FFFF
      and       rbx, rcx
      shr       rax, 16
      and       rax, rcx
      add       rax, rbx
      mov       rbx, rax
      mov       rcx, 0x00000000FFFFFFFF
      and       rbx, rcx
      shr       rax, 32
      and       rax, rcx
      add       rax, rbx
      ret
 
printDecimal:
      ; maximum 64 bits in a qword, so we divide first by 10
      push      rax
      xor       rdx, rdx
      mov       rbx, 10
      idiv      rbx
      cmp       rax, 0
      je        .last
      add       al, 0x30                ; make ascii
      mov       BYTE[buffer], al
      push      rdx
      call      printBuffer
      pop       rdx
.last:
      add       dl, 0x30                ; make ascii
      mov       BYTE[buffer], dl
      call      printBuffer
      pop       rax
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
      pop       rax
      ret
 
printBuffer:
      mov       rsi, buffer
      mov       rdx, 1
print:      
      mov       rax, SYS_WRITE
      mov       rdi, STDOUT
      syscall
      and       BYTE[buffer],0          ; clear buffer
      ret