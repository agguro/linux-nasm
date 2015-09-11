; Name  : bits128tohexadecimal
; Build : nasm -felf64 -o bits128tohexadecimal.o bits128tohexadecimal.asm
; Converts the value in RDX:RAX as an 128 bits hexadecimal ASCII value in a buffer pointed by
; RDI.  The buffer must be at least 32 bytes long.
; IN  : RDX:RAX : value to convert
;       RDI     : pointer to a 32 bytes long buffer
; OUT : RSI     : points to the first character in the buffer. RDX contains the number of
;                 digits.
;
; To-do : optimize if RDX should be all zeros (32 bits numbers)
;         check number of leading zeros for lower bits conversions

bits 64

[list -]
     %include "unistd.inc"
[list +]

section .bss
     buffer:   resb   32
     eol:      resb   1
    
section .data

section .text
     global _start
_start:        
     mov       rax, 0xFFFFFFFFFFFFFFF1
     mov       rdx, 0x1000FFFFFFFFFFFF
     mov       rdi, buffer
     call      Bits128ToHexadecimal
     mov       BYTE[eol], 0x0A
     mov       rsi, buffer
     mov       rdx, 32+1
     mov       rcx, 32
     .repeat:
     lodsb
     cmp       al, "0"
     jne       .write
     dec       rdx
     loop      .repeat
     .write:
     dec       rsi
     mov       rdi, STDOUT
     mov       rax, SYS_WRITE
     syscall
     xor       rdi, rdi
     mov       rax, SYS_EXIT
     syscall   
     
Bits128ToHexadecimal:
     push      rax
     push      rbx
     push      rcx
     push      rdx
     push      rdi
     pushfq
     ; prepare help registers
     mov       rcx, 32                         ; max 32 hexadecimals in 128 bits
     mov       rbx, rax                        ; store lowest bits in RBX
.repeat:
     push      rcx
     pushfq
     mov       rcx, 4
     xor       rax, rax
     popfq
.nextBit:    
     rcl       rbx, 1                          ; shift bit into RAX
     rcl       rdx, 1
     rcl       rax, 1
     loop      .nextBit
     or        al, "0"                         ; make ASCII
     cmp       al, "9"
     jle       .store
     add       al, 7                           ; hexdigit is a letter
.store:    
     stosb
     pop       rcx
     loop      .repeat
     popfq
     pop       rdi
     pop       rdx
     pop       rcx
     pop       rbx
     pop       rax
     ret