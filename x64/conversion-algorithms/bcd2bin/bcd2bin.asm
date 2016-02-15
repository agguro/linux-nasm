; bcd2bin.asm
;
; Description:  Convert "packed bcd" to "binary"
;
; The procedure is optimized three times.
; Instead of just loop through 64 bits and whilest checking all 16 nibbles, which gives us
; 64 * 16 = 1024 loops, I use the number of leading bits to reduce the iterations through the bit
; rotations and to reduce the number of nibble checks.

; Optimization 1:
; This way the number of bits to convert, is reduced from 64 to 64 - nlz(x).
; Taking in account that the first bit shift, which is always performed without check, gives us:
; n bits to loop through : 64 - nlz(x) - 1.

; Optimization 2:
; The nibbles to check if they exceed the value of 4 is normally 16. (16 nibbles * 4 bits per 
; nibble = 64 bits).  By dividing the number of leading zeros by 4, we have a value for the nibbles we
; can skip safely in the check.
; Gives us: nibbles to check : 16 - nlz(x)\4

; Optimization 3:
; The most obvious but often forgotten optimization is to check if a given number is lower than 10.  If so
; the result is already in RDI and we just copy RDI to RAX, which returns the result.
;
; Source : nlz() : Hacker's Delight - seconbd edition (number of leading zeros.
; This program must be run in a debugger (no output)

bits 64
align 16

[list -]
     %include "unistd.inc"
[list +]

section .data

section .text
     global _start
_start:

    ; remember to store the decimal as hexadecimal number
    mov       rdi, 0x9999999999999999
    call      Bcd2bin
    mov       rdi, 0
    mov       rax, SYS_EXIT
    syscall

;*********************************************************************************************************
; Bcd2bin:      convert number in RDI to BCD in RAX
; in : binary number in RDI
; out : BCD equivalent in RAX
; Used registers must be saved by caller
;*********************************************************************************************************
Bcd2bin:
    
    ; calculate of how many significant bits RDI exists
    ; check if RDI is less than 10, if so the quickest way to convert is doing nothing
    cmp       rdi, 9
    ; if bigger than 9 convert, otherwise
    ja        .start                          ; positive numbers!! use ja and not jg
    mov       rax, rdi                        ; put RDI in RAX and exit
    ret
.start:    
    mov       r8, 64                          ; 64 bits in one QWORD
    call      NLZ                             ; number of leading zero's in RAX
    mov       rcx, rax                        ; and in RCX
    sub       r8, rcx                         ; subtract number of leading zeros of r8
    mov       rdx, rcx                        ; number of leading zeros in rdx
    shr       rdx, 2                          ; divided by 4 gives number of nibbles we can skip in
    mov       r10, rdx                        ; store in r10
    mov       rax, rdi
    xor       rdx, rdx
    ; shift right most bit in RAX
    clc
.nextbit:     
    rcr       rax, 1
    rcr       rdx, 1
    dec       r8
    call      .check
    cmp       r8, 2                           ; two bits left to do?
    jne       .nextbit
    rcr       rax, 1                          ; shift last two bits in RDX
    rcr       rdx, 1
    rcr       rax, 1
    rcr       rdx, 1
    shr       rdx, cl                         ; shift remaining places to the right
    mov       rax, rdx
    ret
; this subroutine if of very less use independently.    
.check:    
    ; check if nibbles of rdx are > 4, if so add 3 to that nibble
    mov       r9, 16                          ; 16 nibbles in 64 bits
    sub       r9, r10                         ; subtract nibbles to skip
.repeat:
    mov       bl, al
    and       bl, 0xF
    cmp       bl, 5
    jl        .nextnibble
    sub       rax, 3
.nextnibble:
    ror       rax, 4
    dec       r9
    and       r9, r9
    jnz       .repeat
    jmp       .restore
.rotate:
    ror       rax, 4
    dec       r10
.restore:    
    and       r10, r10
    jnz       .rotate
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