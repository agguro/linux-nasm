;name        : cc1.asm
;description : Calling convention demo
;source      : Modern X86 Assembly Language Programming 2nd Edition
;build       : mkdir build && cd build && qmake .. && make
;use         : extern "C" Int64 Cc1_(int8_t a, int16_t b, int32_t c, int64_t d, int8_t e, int16_t f, int32_t g, int64_t h);
;              calculates the sum = a+b+c+d+e+f+g+h using the Red Zone.
;note        : this example is very different because of Linux.
;              Linux knows about a Red Zone which Windows doesn't use.
;about       : Red Zone : https://eli.thegreenplace.net/2011/09/06/stack-frame-layout-on-x86-64/
;              Leaf Functions : https://en.wikipedia.org/wiki/Leaf_subroutine

bits 64

global Cc1_

section .text

Cc1_:
; in : dil : a
;      si : b
;      edx : c
;      rcx : d
;      r8b : e
;      r9w : f
;      dword [rsp+8] : g
;      qword [rsp+16] : h

; Get the values, rcx already has the 64 bit value of d
    movsx   rax,dil             ;rdi = a
    movsx   rsi,si              ;rsi = b
    add     rax,rsi             ;rdi = a + b

    movsxd  rdx,edx             ;rdx = c
    movsx   r8,r8b              ;r8 = e
    add     rdx,r8              ;rdx = c + e

    movsx   r9,r9w              ;r9 = f
    mov     r10d,dword [rsp+8]  ;r10d = g
    movsxd  r10,r10d            ;r10 = g
    add     r9,r10              ;r9 = f + g

    add     rcx,qword[rsp+16]   ;rcx = d + h

    add     rax,rdx             ;rdi = a + b + c + e
    add     r9,rcx              ;r9 = f + g + d + h

    add     rax,r9              ;rdi = a + b + c + d + e + f + g + h
    ; return sum to caller
    ret
