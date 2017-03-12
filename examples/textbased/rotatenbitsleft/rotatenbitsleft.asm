; Name:         rotatenbitsleft.asm
;
; Build:        nasm -felf64 rotatenbitsleft.asm -l rotatenbitsleft.lst -o rotatenbitsleft.o
;               ld -s -melf_x86_64 -o rotatenbitsleft rotatenbitsleft.o 
;
; Description:  Rotate databits (consisting of n bits in a 64 register) left by 1
;
; Source:       nlz() : Hacker's Delight - second edition (number of leading zeros.)
;
; Remark:
; Although not of great importance this routine can be used in at least one application namely the
; Josephus problem.  The problem is when an n number of persons standing in a circle and starting by one
; killing his neighbour on the left (or on the right) and repeating this untill the last man stands.
; On what position need one to stand to left over (alive).
; The solution I found comes from https://www.youtube.com/watch?v=uCsD3ZGzMgE [Numberphile]
;
; The number of persons is stored in RDI (10 in this program)
; initial     : 1 2 3 4 5 6 7 8 9 10
; first pass  : 1   3   5   7   9
; second pass : 1       5       9
; third pass  :         5
; turns out that you need to be on the fifth place to survive.
;
; Numberphile discovered that when you write 10 binary 1010b and rotate this value
; one position to the left, we have 0101b which is 5 decimal and which is equal to the
; surviving position.
;
; The number of leading zero routine deals with the extra bits in a 64 bits register.  We cannot simple
; rotate the value of the number of contestants so I came up with this solution.
; starting with 42 in 64 bits : 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0001 0101
; - calculate number of leading zeros
; gives 59 (59 and 5 bits of the value 42 gives 64 bits in a 64 bit register)
; - rotate (or shift) the value 10101 left by the amount of leading zeros
; gives 1010 1000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
; - rotate the MSB of the 64 bit register in the carryflag
; gives carry = 1 and value 0101 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
; - rotate right the value by the number of leading zeros incremented once for the rotated carry bit
; gives carry = 1 and value 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0101
; - rotate carry in least significant position of the value
; gives 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 1011
;
; which means that the on e standing on the 19th place will survive.

bits 64
align 16

[list -]
     %include "unistd.inc"
[list +]

section .data
    
     msg:       db      "This program must be viewed in a debugger.", 10
     .length:   equ     $-msg
     
section .text
     global _start
     
_start:

    mov       rdi, 10
    call      Rotatenbitsleft
    syscall   write, stdout, msg, msg.length
    syscall   exit, 0

;*********************************************************************************************************
; RotateNbits: rotate msbit in a bitword to the least significant position ignoring leading zeros
; in : decimal number in RDI
; out : most significant bit of value in RDI becomes least significant bit.
;       result in RAX
; Used registers must be saved by caller
;*********************************************************************************************************
Rotatenbitsleft:   
    call      NLZ                       ; get the number of leading zeros, these must be skipped
    mov       rcx, rax                  ; value of leading zero bits in RCX for rotation count
    mov       rax, rdi                  ; value in rax
    rol       rax, cl                   ; move all bits until most significant bit is in position 63 in RAX
    rcl       rax, 1                    ; move most signifant bit in carry flag
    inc       rcx                       ; add one to shift count (one bit is moved into carry)
    pushfq                              ; store flags (especially carry flag)
    ror       rax, cl                   ; shift all bits back in place
    popfq                               ; restore flags
    rcl       rax, 1                    ; move carry flag into position 0 of rax    
    ret
;*********************************************************************************************************
; count number of leading zero's
; source: Hackers Delight
; in : RDI : number to check
; out : RAX : number of leading zeros
;*********************************************************************************************************
NLZ:
    and       rdi, rdi
    jnz       .start
    mov       rax, 64
    ret
.start: 
    mov       rax, rdi
    xor       rbx, rbx                        ; storage for number of zero bits
    mov       rcx, 32
    mov       rdx, 0xFFFFFFFF00000000
.repeat:      
    test      rax, rdx
    jnz       .nozeros
    add       rbx, rcx
    shl       rax, cl
.nozeros:
    shr       rcx, 1
    shl       rdx, cl
    and       rcx, rcx
    jnz       .repeat
    mov       rax, rbx                        ; result in rax
    ret
