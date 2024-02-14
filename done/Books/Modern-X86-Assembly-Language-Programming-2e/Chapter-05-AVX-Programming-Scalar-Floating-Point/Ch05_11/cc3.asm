;name        : cc3.asm
;description : Calling convention demo
;source      : Modern X86 Assembly Language Programming 2nd Edition
;build       : mkdir build && cd build && qmake .. && make
;use         : extern "C" bool Cc3_(const double* r, const double* h, int n, double* sa_cone, double* vol_cone)
;              calculates : surface area and volume of an array of cones.
;              sa = pi * r * (r + sqrt(r * r + h * h))
;              vol = pi * r * r * h / 3

bits 64

global Cc3_

section .rodata

    r8_3p0: dq  3.0
    r8_pi:  dq  3.14159265358979323846

section .text

Cc3_:
;in : rdi = r ptr
;     rsi = h ptr
;     edx = n
;     rcx = sa_cone
;     r8 = vol_cone

    xor     eax,eax                 ;set error return code
    test    edx,edx                 ;is n > 0?
    jle     done                    ;jump if n > 0

    xor     r9,r9                   ;r9 = array element offset
    vmovsd  xmm4,qword [r8_pi]      ;xmm4 = pi
    vmovsd  xmm5,qword [r8_3p0]     ;xmm5 = 3.0

loop1:
    ; Calculate cone surface areas and volumes
    ; sa = pi * r * (r + sqrt(r * r + h * h))
    ; vol = pi * r * r * h / 3
    vmovsd  xmm0,qword [rdi+r9]     ;xmm0 = r
    vmovsd  xmm1,qword [rsi+r9]     ;xmm1 = h
    vmovsd  xmm2,xmm2,xmm0          ;xmm2 = r
    vmovsd  xmm3,xmm3,xmm1          ;xmm3 = h

    vmulsd  xmm0,xmm0,xmm0          ;xmm0 = r * r
    vmulsd  xmm1,xmm1,xmm1          ;xmm1 = h * h
    vaddsd  xmm0,xmm0,xmm1          ;xmm0 = r * r + h * h

    vsqrtsd xmm0,xmm0,xmm0          ;xmm0 = sqrt(r * r + h * h)
    vaddsd  xmm0,xmm0,xmm2          ;xmm0 = r + sqrt(r * r + h * h)
    vmulsd  xmm0,xmm0,xmm2          ;xmm0 = r * (r + sqrt(r * r + h * h))
    vmulsd  xmm0,xmm0,xmm4          ;xmm0 = pi * r * (r + sqrt(r * r + h * h))

    vmulsd  xmm2,xmm2,xmm2          ;xmm2 = r * r
    vmulsd  xmm3,xmm3,xmm4          ;xmm3 = h * pi
    vmulsd  xmm3,xmm3,xmm2          ;xmm3 = pi * r * r * h
    vdivsd  xmm3,xmm3,xmm5          ;xmm3 = pi * r * r * h / 3

    vmovsd  qword[rcx+r9],xmm0      ;save surface area
    vmovsd  qword[r8+r9],xmm3       ;save volume

    add     r9,8                    ;set rbx to next element
    dec     edx                     ;update counter
    jnz     loop1                   ;repeat until done

    mov     eax,1
done:

    ret
