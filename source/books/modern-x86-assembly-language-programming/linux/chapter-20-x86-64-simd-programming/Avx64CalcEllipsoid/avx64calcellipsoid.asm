; Name:     avx64calcellipsoid.asm
; Source:   Modern x86 Assembly Language Programming p.540

bits 64
extern pow
extern  _GLOBAL_OFFSET_TABLE_
global Avx64CalcEllipsoid_:function

section .bss
align 16
    ;reserved memory to store values of used xmm registers
    xmm:    resq    16

section .rodata
    r8_1p0      dq 1.0
    r8_3p0      dq 3.0
    r8_4p0      dq 4.0
    r8_pi       dq 3.14159265358979323846
    r8_1p6075   dq 1.6075

section .text

; extern "C" bool Avx64CalcEllipsoid_(const double* a, const double* b, const double* c, int n, double* sa, double* vol);
; Description:  The following function calculates the surface area
;               and volume of an ellipsoid
; Requires:     x86-64, AVX

Avx64CalcEllipsoid_:
    ;get GOT and store in rbx
    push    rbp
    mov     rbp,rsp
    push    rbx
    call    .get_GOT
.get_GOT:
    pop     rbx
    add     rbx,_GLOBAL_OFFSET_TABLE_+$$-.get_GOT wrt ..gotpc
    ; rdi = a
    ; rsi = b
    ; rdx = c
    ; rcx = n
    ; r8 = sa2
    ; r9 = vol2
    ;calculate repeated values, in fact we could calculate the results
    ;and store those in memory

    ;calculate xmm9 = 4*pi
    mov rax,r8_pi wrt ..gotoff          ;get pi
    vmovsd xmm0,[rbx + rax]
    mov rax,r8_4p0 wrt ..gotoff         ;get 4.0
    vmulsd xmm9,xmm0,[rbx + rax]

    ;xmm8 = 3
    mov rax,r8_3p0 wrt ..gotoff         ;get 3.0
    vmovsd xmm8,[rbx + rax]

    ;calculate xmm7 = 4*PI/3
    vdivsd xmm7,xmm9,xmm8

    ;xmm6 = p
    mov rax,r8_1p6075 wrt ..gotoff      ;get p
    vmovsd xmm6,[rbx + rax]

    ;calculate xmm5 = 1/p
    mov rax,r8_1p0 wrt ..gotoff         ;get 1.0
    vmovsd xmm0,[rbx + rax]
    vdivsd xmm5,xmm0,xmm6

.repeat:
    vmovsd  xmm0,[rdi]
    vmovsd  xmm1,[rsi]
    vmovsd  xmm2,[rdx]
    call    calcEllipsoidVolume
    vmovsd  [r9],xmm0
    vmovsd  xmm0,[rdi]
    vmovsd  xmm1,[rsi]
    vmovsd  xmm2,[rdx]
    call    calcEllipsoidSurface
    vmovsd  [r8],xmm0
    add     rdi,8
    add     rsi,8
    add     rdx,8
    add     r8,8
    add     r9,8
    loopnz  .repeat
.done:
    mov     rbx,[rbp-8]
    mov     rsp,rbp
    pop     rbp
    ret

calcEllipsoidVolume:
; Calculate the ellipsoid's volume
; in: xmm0 = a, xmm1 = b, xmm2 = c, xmm7 = 4pi/3
; out: xmm0 = volume
; all register values are destroyed
    vmulsd  xmm2,xmm1,xmm2          ;xmm2 = b * c
    vmulsd  xmm0,xmm0,xmm7          ;xmm0 = a * 4 * pi / 3
    vmulsd  xmm0,xmm0,xmm2          ;xmm0 = a * b * c * 4 * pi / 3
    ret

calcEllipsoidSurface:
; Calculate the ellipsoid's surface area
; 4*PI*[(a^p.b^p + a^p.c^p + b^p.c^p)/3]^(1/p)
; in: xmm0 = a, xmm1 = b, xmm2 = c
; out: xmm0 = volume
    push    rdi
    push    rsi
    push    rdx
    push    r8
    push    r9
    push    rcx
    push    rbp
    mov     rbp,rsp
    sub     rsp,8

    vmovsd  xmm3,xmm0          ;save xmm3
    vmovsd  xmm4,xmm1          ;save xmm4
    ;xmm2 = c,xmm3 = a,xmm4 = b

    ;calculate xmm3 = a^p
    vmovsd  xmm0,xmm3
    vmovsd  xmm1,xmm6
    call    SaveXmmRegisters
    call    pow wrt ..plt
    vmovq  rax,xmm0
    call    RestoreXmmRegisters
    vmovq xmm3,rax            ;xmm3=a^p

    ;calculate xmm4 = b^p
    vmovsd xmm0,xmm4
    vmovsd  xmm1,xmm6
    call    SaveXmmRegisters
    call    pow wrt ..plt
    vmovq  rax,xmm0
    call    RestoreXmmRegisters
    vmovq xmm4,rax           ;xmm4=b^p

    ;calculate xmm2 = c^p
    vmovsd xmm0,xmm2
    vmovsd  xmm1,xmm6
    call    SaveXmmRegisters
    call    pow wrt ..plt
    vmovq  rax,xmm0
    call    RestoreXmmRegisters
    vmovq xmm2,rax           ;xmm2=c^p

    ;calculate xmm3 = a^p . b^p, xmm4 = b^p . c^p and xmm2 = c^p . a^p
    vmovsd xmm0,xmm3                ;save a^p
    vmulsd xmm3,xmm4                ;a^p.b^p
    vmulsd xmm4,xmm2                ;b^p.c^p
    vmulsd xmm2,xmm0                ;c^p.a^p
    ;calculate xmm0 = a^p.b^p + b^p.c^p + c^p.a^p
    vmovsd  xmm0,xmm2
    vaddsd  xmm0,xmm3               ;a^p.b^p + b^p.c^p
    vaddsd  xmm0,xmm4               ;a^p.b^p + b^p.c^p + c^p.a^p

    ;calculate xmm0 = (a^p.b^p + b^p.c^p + c^p.a^p)/3
    vdivsd  xmm0,xmm0,xmm8
    ;calculate xmm0 = ((a^p.b^p + b^p.c^p + c^p.a^p)/3)^(1/p)
    vmovsd  xmm1,xmm5
    call    SaveXmmRegisters
    call    pow wrt ..plt
    vmovq  rax,xmm0
    call    RestoreXmmRegisters
    vmovq  xmm0,rax

    ;calculate xmm0 = 4pi.((a^p.b^p + b^p.c^p + c^p.a^p)/3)^(1/p)
    vmulsd  xmm0,xmm9

.done:
    add     rsp,8
    mov     rsp,rbp
    pop     rbp
    pop     rcx
    pop     r9
    pop     r8
    pop     rdx
    pop     rsi
    pop     rdi
    ret

SaveXmmRegisters:
    push    rax
    push    rbx
    mov     rax,xmm wrt ..gotoff
    add     rax,rbx
    vmovdqa [rax+16*0],xmm0
    vmovdqa [rax+16*1],xmm1
    vmovdqa [rax+16*2],xmm2
    vmovdqa [rax+16*3],xmm3
    vmovdqa [rax+16*4],xmm4
    vmovdqa [rax+16*11],xmm5
    vmovdqa [rax+16*12],xmm6
    vmovdqa [rax+16*13],xmm7
    vmovdqa [rax+16*14],xmm8
    vmovdqa [rax+16*15],xmm9
    pop     rbx
    pop     rax
    ret

RestoreXmmRegisters:
    push    rax
    push    rbx
    mov     rax,xmm wrt ..gotoff
    add     rax,rbx
    vmovdqa xmm0,[rax+16*0]
    vmovdqa xmm1,[rax+16*1]
    vmovdqa xmm2,[rax+16*2]
    vmovdqa xmm3,[rax+16*3]
    vmovdqa xmm4,[rax+16*4]
    vmovdqa xmm5,[rax+16*11]
    vmovdqa xmm6,[rax+16*12]
    vmovdqa xmm7,[rax+16*13]
    vmovdqa xmm8,[rax+16*14]
    vmovdqa xmm9,[rax+16*15]
    pop     rbx
    pop     rax
    ret
