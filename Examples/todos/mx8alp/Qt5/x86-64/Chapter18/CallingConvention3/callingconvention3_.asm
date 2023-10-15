; Name:     callingconvention3.asm
;
; Source:   Modern x86 Assembly Language Programming p.533

global Cc3_

bits 64

section .data
    r8_3p0:      dq 3.0
    r8_pi:       dq 3.14159265358979323846

section .text

; extern "C" bool Cc3_(const double* r, const double* h, int n, double* sa_cone, double* vol_cone);

Cc3_:
; Registers: rdi    r
;            rsi    h
;            rdx    n
;            rcx    sa_cone
;            r8     vol_cone

; Initialize the processing loop variables.
    xor     rax,rax             ;set error code
    movsxd  rdx,edx             ;rdx = n
    test    rdx,rdx             ;is n <= 0?
    jle     .done               ;jump if n <= 0

    xor     r9,r9               ;r9 = array element offset
    movsd   xmm4,[r8_pi]        ;xmm4 = pi
    movsd   xmm5,[r8_3p0]       ;xmm5 = 3.0

; Calculate cone surface areas and volumes
; sa = pi * r * (r + sqrt(r * r + h * h))
; vol = pi * r * r * h / 3
.l1:
    movsd   xmm0,[rdi+r9]       ;xmm0 = r
    movsd   xmm1,[rsi+r9]       ;xmm1 = h
    movsd   xmm2,xmm0           ;xmm2 = r
    movsd   xmm3,xmm1           ;xmm3 = h

    mulsd   xmm0,xmm0           ;xmm0 = r * r
    mulsd   xmm1,xmm1           ;xmm1 = h * h
    addsd   xmm0,xmm1           ;xmm0 = r * r + h * h

    sqrtsd  xmm0,xmm0           ;xmm0 = sqrt(r * r + h * h)
    addsd   xmm0,xmm2           ;xmm0 = r + sqrt(r * r + h * h)
    mulsd   xmm0,xmm2           ;xmm0 = r * (r + sqrt(r * r + h * h))
    mulsd   xmm0,xmm4           ;xmm0 = pi * r * (r + sqrt(r * r + h * h))

    mulsd   xmm2,xmm2           ;xmm2 = r * r
    mulsd   xmm3,xmm4           ;xmm3 = h * pi
    mulsd   xmm3,xmm2           ;xmm3 = pi * r * r * h
    divsd   xmm3,xmm5           ;xmm3 = pi * r * r * h / 3

    movsd   [rcx+r9],xmm0       ;save surface area
    movsd   [r8+r9],xmm3        ;save volume

    add r9,8                    ;set r9 to next element

    dec rdx                     ;update counter
    jnz .l1                     ;repeat until done
    mov eax,1                   ;set success return code
.done:
    ret
