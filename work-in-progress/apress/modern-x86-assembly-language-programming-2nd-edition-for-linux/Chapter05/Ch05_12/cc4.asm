;name        : cc4.asm
;description : Calling convention demo
;source      : Modern X86 Assembly Language Programming 2nd Edition
;build       : mkdir build && cd build && qmake .. && make
;use         : extern "C" bool Cc4_(const double* ht, const double* wt, int n, double* bsa1, double* bsa2, double* bsa3)
;              calculates : calculates the estimation of the human body surface area using
;              some well known formulas.
;              bsa1 = 0.007184 * ht^0.725 * wt^0.425    (Dubois and Dubois)
;              bsa2 = 0.0235 * ht^0.42246 * wt^0.51546  (Gehan and George)
;              bsa3 = sqrt(ht * wt / 3600)              (Mosteller)
;note        : 1: This is NOT a leaf routine.
;              2: Due to the nature of the pow() function, I've wrapped this function in a separate
;                 routine (power). pow() changes almost all register values, the one I found stable is
;                 r15 and even then we need to be cousious.

bits 64

extern pow
extern sqrt
global Cc4_

section .rodata

    r8_0p007184 : dq 0.007184
    r8_0p725    : dq 0.725
    r8_0p425    : dq 0.425
    r8_0p0235   : dq 0.0235
    r8_0p42246  : dq 0.42246
    r8_0p51456  : dq 0.51456
    r8_60p0     : dq 60.0

section .text

Cc4_:
; in : rdi = ht ptr
;      rsi = wt ptr
;      edx = n
;      rcx = bsa1 ptr
;      r8 = bsa2  ptr
;      r9 = bsa3 ptr
; out : rax = return code
;       bsa1, bsa2, bsa3 : human body surface areas

    xor     rax,rax
    test    edx,edx
    jle     done
    xor     rbx,rbx

loop1:

; Calculate bsa1 = 0.007184 * ht^0.725 * wt^0.425

    vmovsd  xmm0,qword[rdi+rbx]         ;xmm0 = ht
    vmovsd  xmm1,qword[r8_0p725]        ;xmm1 = 0.725
    call    power
    vmovsd  xmm15,xmm6,xmm0             ;xmm15 = ht^0.725
    vmovsd  xmm0,qword[rsi+rbx]         ;xmm0 = wt
    vmovsd  xmm1,qword[r8_0p425]        ;xmm1 = 0.425
    call    power
    vmulsd  xmm0,xmm15,xmm0             ;xmm15 = wt^0.425
    vmovsd  xmm1,qword[r8_0p007184]     ;xmm1 = 0.007184
    vmulsd  xmm0,xmm0,xmm1              ;xmm0 = bsa1 = 0.007184 * ht^0.725 * wt^0.425
    vmovsd  qword[rcx+rbx],xmm0         ;store bsa1[i]

; Calculate bsa2 = 0.0235 * ht^0.42246 * wt^0.51546

    vmovsd  xmm0,qword[rdi+rbx]         ;xmm0 = ht
    vmovsd  xmm1,qword[r8_0p42246]      ;xmm1 = 0.42246
    call    power
    vmovsd  xmm15,xmm0,xmm0             ;xmm15 = ht^0.42246
    vmovsd  xmm0,qword[rsi+rbx]         ;xmm0 = wt
    vmovsd  xmm1,qword[r8_0p51456]      ;xmm1 = 0.51456
    call    power
    vmulsd  xmm0,xmm15,xmm0             ;xmm15 = wt^0.51456
    vmovsd  xmm1,qword[r8_0p0235]       ;xmm1 = 0.0235
    vmulsd  xmm0,xmm0,xmm1              ;xmm0 = 0.0235 * ht^0.42246 * wt^0.51546
    vmovsd  qword[r8+rbx],xmm0          ;store bsa2[i]

; Calculate bsa3 = sqrt(ht * wt / 3600)
; note: this formula is changed to bsa3 = sqrt(ht * wt) / 60

    vmovsd  xmm0,qword[rdi+rbx]         ;xmm0 = ht
    vmovsd  xmm1,qword[rsi+rbx]         ;xmm1 = wt
    vmovsd  xmm2,qword[r8_60p0]         ;xmm2 = 60.0
    vmulsd  xmm0,xmm0,xmm1              ;xmm0 = ht * wt
    vsqrtsd xmm0,xmm0,xmm0              ;xmm0 = sprt(ht * wt)
    vdivsd  xmm0,xmm0,xmm2              ;xmm0 = sqrt(ht * wt) / 60
    vmovsd  qword[r9+rbx],xmm0          ;store bsa3[i]

    add     rbx,8                       ;update array offset
    dec     edx                         ;n = n - 1
    jnz     loop1
done:
    ret

power:
    ; Wrapper for the pow function of g++.
    ; This functions changes a lot of registers.
    ; takes xmm0 and xmm1 and returns xmm0^xmm1 in xmm0
    push    rbp
    mov     rbp,rsp
    push    rdi
    push    rsi
    push    rbx
    push    rcx
    push    rdx
    push    r8
    push    r9
    call    pow
    pop     r9
    pop     r8
    pop     rdx
    pop     rcx
    pop     rbx
    pop     rsi
    pop     rdi
    mov     rsp,rbp
    pop     rbp
    ret
