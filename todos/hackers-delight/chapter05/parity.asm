; parity.asm
; calculate parity bit
;
; Source: Hacker's Delight - 5.2
 
[list -]
      %include "syscalls.inc"
      %include "termio.inc"
[list +]
 
bits 64
 
section .bss
      buffer: resb 1
 
section .data
      message:       db " has parity bit .",0x0A
      .length:       equ $-message
 
section .text
global _start
 
_start:
 
      mov     rax, 12364
      call    printBinary
      call    parity
      push    rax
      mov     rsi, message
      mov     rdx, 16
      call    print
      pop     rax
      call    printDecimal
      mov     rsi, message
      add     rsi, 16
      mov     rdx, message.length
      sub     rdx, 16
      call    print
      xor     rdi, rdi
      mov     rax, SYS_EXIT
      syscall
 
parity:                                            ; calculate parity bit 0 = even, 1 is odd
      mov       rcx, 32
repeat:      
      mov       rbx, rax
      shr       rbx, cl
      xor       rax, rbx
      shr       rcx, 1
      cmp       rcx, 0
      jne       repeat
      and       rax, 1                             ; rightmost bit is parity bit
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