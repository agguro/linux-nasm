; nlz.asm
; count leading zeros, binary search
;
; Source: Hacker's Delight - 5.3
 
[list -]
      %include "syscalls.inc"
      %include "termio.inc"
[list +]
 
bits 64
 
section .bss
      buffer: resb 1
 
section .data
      message:       db " has leading zero bits.",0x0A
      .length:       equ $-message
 
section .text
global _start
 
_start:
 
      mov     rax, 1000
      call    printBinary
      call    nlz
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
 
nlz:                                            ; number of leading zero's
      and       rax, rax
      jz        @done
      xor       rbx, rbx                        ; storage for number of zero bits
 
      mov       rcx, 0xFFFFFFFF00000000
      test      rax, rcx
      jnz       @1
      add       rbx, 32
      shl       rax, 32
@1:
      shl       rcx, 16
      test      rax, rcx
      jnz       @2
      add       rbx, 16
      shl       rax, 16
@2:
      shl       rcx, 8
      test      rax, rcx
      jnz       @3
      add       rbx, 8
      shl       rax, 8
@3:
      shl       rcx, 4
      test      rax, rcx
      jnz       @4
      add       rbx, 4
      shl       rax, 4
@4:
      shl       rcx, 2
      test      rax, rcx
      jnz       @5
      add       rbx, 2
      shl       rax, 2
@5:
      shl       rcx, 1
      test      rax, rcx
      jnz       @6
      add       rbx, 1
@6:
      mov       rax, rbx                ; result in rax
@done:      
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