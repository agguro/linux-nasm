; Name:     avxscalarfloatingpointspherical.asm
;
; Build:    g++ -c -m32 main.cpp -o main.o
;           nasm -f elf32 -o avxscalarfloatingpointspherical.o avxscalarfloatingpointspherical.asm
;           g++ -m32 -o avxscalarfloatingpointspherical avxscalarfloatingpointspherical.o main.o
;
; Source:   Modern x86 Assembly Language Programming p. 368

extern DegToRad
extern RadToDeg
extern sin
extern cos
extern acos
extern atan2

global RectToSpherical
global SphericalToRect

section .data
align 16
    Epsilon:    dq 1.0e-15
    r8_0p0:     dq 0.0
    r8_90p0:    dq 90.0

section .text  

; extern "C" bool RectToSpherical(const double r_coord[3], double s_coord[3]);
;
; Description:  The following function performs rectangular to
;               spherical coordinate conversion.
;
; Requires: AVX

%define r_coord [ebp+8]
%define s_coord [ebp+12]

RectToSpherical:
    push    ebp
    mov     ebp,esp
    push    esi
    push    edi
    sub     esp,16              ;space for acos & atan2 args

; Load argument values
    mov     esi,r_coord         ;esi = ptr to r_coord
    mov     edi,s_coord         ;edi = ptr to s_coord
    vmovsd  xmm0,[esi]          ;xmm0 = x coord
    vmovsd  xmm1,[esi+8]        ;xmm1 = y coord
    vmovsd  xmm2,[esi+16]       ;xmm2 = z coord

; Compute r = sqrt(x * x + y * y + z * z)
    vmulsd  xmm3,xmm0,xmm0      ;xmm3 = x * x
    vmulsd  xmm4,xmm1,xmm1      ;xmm4 = y * y
    vmulsd  xmm5,xmm2,xmm2      ;xmm5 = z * z
    vaddsd  xmm6,xmm3,xmm4
    vaddsd  xmm6,xmm6,xmm5
    vsqrtsd xmm7,xmm7,xmm6      ;xmm7 = r

; Compute phi = acos(z / r)
    vcomisd xmm7,[Epsilon]
    jae     .lb1                ;jump if r >= epsilon
    vmovsd  xmm4,[r8_0p0]       ;round r to 0.0
    vmovsd  [edi],xmm4          ;save r
    vmovsd  xmm4,[r8_90p0]      ;phi = 90.0 degrees
    vmovsd  [edi+16],xmm4       ;save phi
    jmp     .lb2

.lb1:
    vmovsd  [edi],xmm7          ;save r
    vdivsd  xmm4,xmm2,xmm7      ;xmm4 = z / r
    vmovsd  [esp],xmm4          ;save on stack
    call    acos                ;be carefull if ecx must remain intact
    fmul    qword[RadToDeg]     ;convert phi to degrees
    fstp    qword[edi+16]       ;save phi

; Compute theta = atan2(y, x)
.lb2:
    vmovsd  xmm0,[esi]          ;xmm0 = x
    vmovsd  xmm1,[esi+8]        ;xmm1 = y
    vmovsd  [esp+8],xmm0
    vmovsd  [esp],xmm1
    call    atan2               ;be carefull if ecx must remain intact
    fmul    qword[RadToDeg]     ;convert theta to degrees
    fstp    qword[edi+8]        ;save theta

    add     esp,16
    pop     edi
    pop     esi
    pop     ebp
    ret

; extern "C" bool SphericalToRect(const double s_coord[3], double r_coord[3]);
;
; Description:  The following function performs spherical to
;               rectangular coordinate conversion.
;
; Requires: AVX
;
; Local stack variables
;   ebp-8     sin(theta)
;   ebp-16    cos(theta)
;   ebp-24    sin(phi)
;   ebp-32    cos(phi)

%define s_coord     [ebp+8]
%define r_coord     [ebp+12]
%define sin_theta   [ebp-8]
%define cos_theta   [ebp-16]
%define sin_phi     [ebp-24]
%define cos_phi     [ebp-32]

SphericalToRect:
    push    ebp
    mov     ebp,esp
    sub     esp,32                  ;local variable space
    push    esi
    push    edi
    sub     esp,8                   ;space for sin & cos argument

; Load argument values
    mov     esi,s_coord             ;esi = ptr to s_coord
    mov     edi,r_coord             ;edi = ptr to r_coord

; Compute sin(theta) and cos(theta)
    vmovsd  xmm0,[esi+8]            ;xmm0 = theta
    vmulsd  xmm1,xmm0,[DegToRad]    ;xmm1 = theta in radians
    vmovsd  cos_theta,xmm1          ;save theta for later use
    vmovsd  [esp],xmm1
    call    sin
    fstp    qword sin_theta         ;save sin(theta)
    vmovsd  xmm1,cos_theta          ;xmm1 = theta in radians
    vmovsd  [esp],xmm1
    call    cos
    fstp    qword cos_theta         ;save cos(theta)

; Compute sin(phi) and cos(phi)
    vmovsd  xmm0,[esi+16]           ;xmm0 = phi
    vmulsd  xmm1,xmm0,[DegToRad]    ;xmm1 = phi in radians
    vmovsd  cos_phi,xmm1            ;save phi for later use
    vmovsd  [esp],xmm1
    call    sin
    fstp    qword sin_phi           ;save sin(phi)
    vmovsd  xmm1, cos_phi           ;xmm1 = phi in radians
    vmovsd  [esp],xmm1
    call    cos
    fstp    qword cos_phi           ;save cos(phi)

; Compute x = r * sin(phi) * cos(theta)
    vmovsd  xmm0,[esi]              ;xmm0 = r
    vmulsd  xmm1,xmm0,sin_phi       ;xmm1 = r * sin(phi)
    vmulsd  xmm2,xmm1,cos_theta     ;xmm2 = r*sin(phi)*cos(theta)
    vmovsd  [edi],xmm2              ;save x

; Compute y = r * sin(phi) * sin(theta)
    vmulsd  xmm2,xmm1,sin_theta     ;xmm2 = r*sin(phi)*sin(theta)
    vmovsd  [edi+8],xmm2            ;save y

; Compute z = r * cos(phi)
    vmulsd  xmm1,xmm0,cos_phi       ;xmm1 = r * cos(phi)
    vmovsd  [edi+16],xmm1           ;save z

    add     esp,8
    pop     edi
    pop     esi
    mov     esp,ebp
    pop     ebp
    ret
