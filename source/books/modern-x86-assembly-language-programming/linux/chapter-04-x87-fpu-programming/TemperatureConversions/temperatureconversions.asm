; Name:     temperatureconversions.asm
;
; Source:   Modern x86 Assembly Language Programming p.104

bits 32
global FtoC_
global CtoF_

section .data

    r8_SfFtoC:    dq    0.5555555556    ; 5 / 9
    r8_SfCtoF:    dq    1.8                ; 9 / 5
    i4_32:        dw    32

section .text

; extern "C" double FtoC_(double f);
;
; Description:  Converts a temperature from Fahrenheit to Celsius.
;
; Returns:      Temperature in Celsius.

%define    f    [ebp+8]

FtoC_:
    push    ebp
    mov     ebp,esp
    fld     qword [r8_SfFtoC]       ;load 5/9
    fld     qword f                 ;load 'f'
    fild    dword [i4_32]           ;load 32
    fsubp                           ;ST(0) = f - 32
    fmulp                           ;ST(0) = (f - 32) * 5/9
    pop     ebp
    ret

; extern "C" double CtoF_(double c)
;
; Description:  Converts a temperature from Celsius to Fahrenheit.
;
; Returns:      Temperature in Fahrenheit.

%define    c    [ebp+8]

CtoF_:
    push    ebp
    mov     ebp,esp
    fld     qword c                 ;load 'c'
    fmul    qword [r8_SfCtoF]       ;ST(0) = c * 9/5
    fiadd   dword [i4_32]           ;ST(0) = c * 9/5 + 32
    pop     ebp
    ret
