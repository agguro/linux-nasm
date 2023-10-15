; Name:     calcsphereareavolume.asm
;
; Build:    g++ -c -m32 main.cpp -o main.o
;           nasm -f elf32 -o calcsphereareavolume.o calcsphereareavolume.asm
;           g++ -m32 -o calcsphereareavolume calcsphereareavolume.o main.o
;
; Source:   Modern x86 Assembly Language Programming p.108

global CalcSphereAreaVolume

section .data

    r8_4p0:    dq    4.0
    r8_3p0:    dq    3.0

section .text

; extern "C" bool CalcSphereAreaVolume(double r, double* sa, double* v);
;
; Description:  This function calculates the surface area and volume
;               of a sphere.
;
; Returns:      0 = invalid radius
;               1 = valid radius

%define r   qword[ebp+8]        ; value
%define sa  [ebp+16]            ; pointer
%define v   [ebp+20]            ; pointer

CalcSphereAreaVolume:
    push    ebp
    mov     ebp,esp
    ; Make sure radius is valid
    xor     eax,eax            ;set error return code
    fld     r                ;ST(0) = r
    fldz                    ;ST(0) = 0.0, ST(1) = r
    fcomip  st0,st1            ;compare 0.0 to r
    fstp    st0                ;remove r from stack
    jp      .done            ;jump if unordered operands
    ja      .done            ;jump if r < 0.0
    ; Calculate sphere surface area
    fld     r                ;ST(0) = r
    fld     st0                ;ST(0) = r, ST(1) = r
    fmul    st0,st0            ;ST(0) = r * r, ST(1) = r
    fldpi                    ;ST(0) = pi
    fmul    qword[r8_4p0]    ;ST(0) = 4 * pi
    fmulp                    ;ST(0) = 4 * pi * r * r
    mov     edx,sa
    fst     qword [edx]        ;save surface area
    ; Calculate sphere volume
    fmulp                    ;ST(0) = pi * 4 * r * r * r
    fdiv    qword[r8_3p0]    ;ST(0) = pi * 4 * r * r * r / 3
    mov     edx,v
    fstp    qword [edx]        ;save volume
    mov     eax,1            ;set success return code
.done:
    pop     ebp
    ret
