; Name:     convertcoordinates.asm
;
; Source:   Modern x86 Assembly Language Programming p.120

bits 32
global RectToPolar_
global PolarToRect_

section .data

    DegToRad:    dq    0.01745329252
    RadToDeg:    dq    57.2957795131

section .text

; extern "C" void RectToPolar_(double x, double y, double* r, double* a);
;
; Description:  This function converts a rectangular coordinate to a
;               to polar coordinate.

%define x   qword[ebp+8]    ; value
%define y   qword[ebp+16]   ; value
%define r   [ebp+24]        ; pointer
%define a   [ebp+28]        ; pointer
    
RectToPolar_:
    push    ebp
    mov     ebp,esp
    ; Calculate the angle.  Note that fpatan computes atan2(ST(1) / ST(0))
    fld     y                   ;load y
    fld     x                   ;load x
    fpatan                      ;calc atan2 (y / x)
    fmul    qword[RadToDeg]     ;convert angle to degrees
    mov     eax,a
    fstp    qword [eax]         ;save angle
; Calculate the radius
    fld     x                   ;load x
    fmul    st0,st0             ;x * x
    fld     y                   ;load y
    fmul    st0,st0             ;y * y
    faddp                       ;x * x + y * y
    fsqrt                       ;sqrt(x * x + y * y)
    mov     eax,r
    fstp    qword [eax]         ;save radius
    pop     ebp
    ret

; extern "C" void PolarToRect_(double r, double a, double* x, double* y);
;
; Description:  The following function converts a polar coordinate
;               to a rectangular coordinate.

%define r   qword[ebp+8]    ; value
%define a   qword[ebp+16]   ; value
%define x   [ebp+24]        ; pointer
%define y   [ebp+28]        ; pointer

PolarToRect_:
    push    ebp
    mov     ebp,esp
    ; Calculate sin(a) and cos(a).
    ; Following execution of fsincos, ST(0) = cos(a) and ST(1) = sin(a)
    fld     a                   ;load angle in degrees
    fmul    qword[DegToRad]     ;convert angle to radians
    fsincos                     ;calc sin(ST(0)) and cos(ST(0))
    fmul    r                   ;x = r * cos(a)
    mov     eax,x
    fstp    qword[eax]          ;save x
    fmul    r                   ;y = r * sin(a)
    mov     eax,y
    fstp    qword [eax]         ;save y
    pop     ebp
    ret
