; ntz.asm
; count trailing zeros, binary search
;
; Source: Hacker's Delight - 5.4

[list -]
      %include "syscalls.inc"
      %include "termio.inc"
[list +]

bits 64

section .bss
      buffer: resb 1
      
section .data
      message:       db " has trailing zero bits.",0x0A
      .length:       equ $-message
      
section .text
global _start

_start:

      mov     rax, 1024
      call    printBinary
      call    ntz
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

ntz:                                            ; number of trailing zeros
      mov       rbx, 64
      test      rax, rax
      jz        @done
      mov       rbx, 1
      mov       rcx, 0xFFFFFFFFFFFFFFFF
      test      rax, rcx
      jnz       @1
      add       rbx, 32
      shr       rax, 32
@1:
      shr       rcx, 32
      test      rax, rcx
      jnz       @2
      add       rbx, 32
      shr       rax, 32      
@2:
      shr       rcx, 16
      test      rax, rcx
      jnz       @3
      add       rbx, 16
      shr       rax, 16     
@3:
      shr       rcx, 8
      test      rax, rcx
      jnz       @4
      add       rbx, 8
      shr       rax, 8     
@4:
      shr       rcx, 4
      test      rax, rcx
      jnz       @5
      add       rbx, 4
      shr       rax, 4      
@5:
      shr       rcx, 2
      test      rax, rcx
      jnz       @6
      add       rbx, 2
      shr       rax, 2      
@6:
      and       rax, 1
      sub       rbx, rax
@done:
      mov       rax, rbx                ; result in rax
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
