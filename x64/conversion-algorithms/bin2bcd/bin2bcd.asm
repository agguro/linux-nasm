; bin2bcd.asm
;
; Description:  Convert binary to packed bcd
; There is no output, so you have to run it in a debugger.
;
; The procedure is three times optimized.
; Normally we should calculate the BDC number of x on all 64 bits.  Checking each nibble in the result
; leads us to 64 bits * 16 nibbles = 1024 iterations.  It's ok for large numbers but for the lesserit's a
; bit too much.
;
; First optimization step:
; count the leading zeros in x and decrement the amount of shifts.  This lead us to 64 - nlz(x).
; Subtracting the first two shifts who doesn't require an nibble check and a check if the first three
; nibbles exceed the value 5 gives at most 64 - nlz(x) - 2 and 64 - nlz(x) - 3 iterations.
;
; Second optimization step:
; Instead of iterating through all 16 nibbles of x, I use the bits already shifted divided by 4 and
; incremented by the remainder, which will be in the carryflag.
;
; Third optimization step:
; If the number to convert is less than 10 then the procedure returns RDI in RAX because no convertion
; is needed.
;
; Source: nlz() Hacker's Delight - second edition (number of leading zeros
; No output on screen, you need a debugger

bits 64
align 16

[list -]
     %include "unistd.inc"
[list +]

section .data

section .text
     global _start
     
_start:

    mov       rdi, 0x002386f26fc0ffff         ; should give 9999999999999999
    call      Bin2bcd
    mov       rdi, 0
    mov       rax, SYS_EXIT
    syscall

;*********************************************************************************************************
; Bin2bcd       converts binary number in RDI to BCD in RAX
; in  : RDI : binary number to convert
; out : RAX : BCD equivalent
; Used registers must be saved by caller
;*********************************************************************************************************
Bin2bcd:
    
    cmp       rdi, 9                          ; number higher than 9?
    ja        .start                          ; positive numbers! use ja and not jg!
    mov       rax, rdi                        ; lower than 10 so just copy into RAX
    ret
.start:    
    ; calculate of how many significant bits RDI exists
    mov       r8, 64                          ; 64 bits in one QWORD
    call      NLZ                             ; number of leading zero's in rcx
    sub       r8, rcx                         ; subtract number of leading zeros of r8
    mov       rdx, rdi
    ; position left most one bit in left most position of RDX
    shl       rdx, cl                     
    xor       rax, rax                        ; zero out help register
    clc
    ; read first 3 bits in in rax
    rcl       rdx, 1
    rcl       rax, 1
    rcl       rdx, 1
    rcl       rax, 1
    rcl       rdx, 1
    rcl       rax, 1
    dec       r8                              ; adjust counter
    dec       r8
    dec       r8
    ; check if value in rdx is 5 or more, otherwise skip test
    cmp       rax, 5
    jge       .check
.nextbit:    
    rcl       rdx, 1
    rcl       rax, 1
    dec       r8
    and       r8, r8
    jz        .done
.check:      
    call      .checknibbles
    and       r8, r8
    jnz       .nextbit
.done:  
    ret
.checknibbles:
    mov       r9, 64                          ; total number of bits
    sub       r9, r8                          ; number of bits already shifted
    dec       r9                              ; nibbles -1
    shr       r9, 2                           ; divide by 4
    inc       r9                              ; quotient plus 1 = number of nibbles
    mov       r10, 16                         ; total amount of nibbles in 64 bits
    sub       r10, r9                         ; nibbles we don't check
    ; check if nibbles of rdx are > 4, if so add 3 to that nibble
.repeat:
    mov       bl, al
    and       bl, 0xF
    cmp       bl, 5
    jl        .nextnibble
    add       rax, 3
.nextnibble:
    ror       rax, 4
    dec       r9
    and       r9, r9
    jnz       .repeat
    jmp       .restore
.rotate:
    ror         rax, 4
    dec         r10
.restore:    
    and         r10, r10
    jnz         .rotate
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