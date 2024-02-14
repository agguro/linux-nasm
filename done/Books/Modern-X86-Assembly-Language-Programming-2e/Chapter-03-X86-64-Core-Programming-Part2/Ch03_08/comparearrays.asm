;name        : comparearrays.asm
;description : compare array x against array y
;source      : Modern X86 Assembly Language Programming 2nd Edition
;build       : mkdir build && cd build && qmake .. && make
;use         : extern "C" long long CompareArrays_(const int* x, const int* y, long long n)
;              returns: -1 =         Value of 'n' is invalid
;                        0 <= i < n  Index of first non-matching element
;                        n           All elements match

bits 64

global CompareArrays_

section .text

CompareArrays_:
; in : rdi = x ptr
;      rsi = y ptr
;      rdx = n
; out : rax = -1 : value of n is invalid
;           = 0 <= i < n : value of first non-matching element
;           = n : all elements match

; Load arguments and validate 'n'
    mov     rax,-1              ;rax = return code for invalid n
    test    rdx,rdx
    jle     .done               ;jump if n <= 0

; Compare the arrays for equality
    mov     rcx,rdx             ;rcx = n
    mov     rax,rdx             ;rax = n
    repe    cmpsd
    je      .done               ;arrays are equal

; Calculate index of first non-match
    sub     rax,rcx             ;rax = index of mismatch + 1
    dec     rax                 ;rax = index of mismatch

; Return
.done:
    ret
