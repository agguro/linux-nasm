;name: 3valcomp.asm
;description:  Threevalued compare function
;
; case rdi < rsi result is rax=-1 (two's complement)
;      rdi = rsi result is rax= 0
;      rdi > rsi result is rax= 1
;
;source: Hacker's Delight 

[list -]
      %include "unistd64.inc"
[list +]
 
bits 64
 
section .bss
      buffer: resb 1
 
section .data
 
section .text
      global _start
 
_start:
 
      mov       rax, 2015
      mov       rbx, 1028
      call      printBinary                     ; print RAX
      xchg      rax, rbx
      call      printBinary                     ; print RBX
      xchg      rax, rbx
      call      ThreeValuedCompare
      call      printBinary
 
      xor       rdi, rdi
      mov       rax, SYS_EXIT
      syscall
 
threeValuedCompare:
;compare rdi against rsi return result in rax
;rax = 0 when rdi = rsi
;rax = -1 when rdi < rsi
;rax = 1 when rdi > rsi

      sub       rax, rbx
      ; from here the sign function
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
