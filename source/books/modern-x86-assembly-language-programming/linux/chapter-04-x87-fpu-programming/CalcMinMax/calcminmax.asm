; Name:     calcminmax.asm
;
; Source:   Modern x86 Assembly Language Programming p.116

bits 32
global  CalcMinMax_

section .data

r4_MinFloat dq 0xff7fffff                ;smallest float number
r4_MaxFloat dq 0x7f7fffff                ;largest float number

section .text

; extern "C" bool CalcMinMax_(const float* a, int n, float* min, float* max);
;
; Description:  The following function calculates the min and max values
;               of a single-precision floating-point array.
;
; Returns:      0 = invalid 'n'
;               1 = valid 'n'

%define a   [ebp+8]
%define n   [ebp+12]
%define min [ebp+16]
%define max [ebp+20]

CalcMinMax_:
    push    ebp
    mov     ebp,esp
; Load argument values and make sure 'n' is valid.
    xor     eax,eax                     ;set error return code
    mov     edx,a                       ;edx = 'a'
    mov     ecx,n                       ;ecx = 'n'
    test    ecx,ecx
    jle     .done                       ;jump if 'n' <= 0
    fld     qword[r4_MinFloat]          ;initial max_a value
    fld     qword[r4_MaxFloat]          ;initial min_a value
; Find min and max of input array
.l1:
    fld     dword[edx]                  ;load *a
    fld     st0                         ;duplicate *a on stack
    fcomi   st0,st2                     ;compare *a with min
    fcmovnb st0,st2                     ;ST(0) equals smaller val
    fstp    st2                         ;save new min value
    fcomi   st0,st2                     ;compare *a with max_a
    fcmovb  st0,st2                     ;st(0) equals larger val
    fstp    st2                         ;save new max value
    add     edx,4                       ;point to next a[i]
    dec     ecx
    jnz     .l1                         ;repeat loop until finished
; Save results
    mov     eax,min
    fstp    dword[eax]                  ;save final min
    mov     eax,max    
    fstp    dword[eax]                  ;save final max
    mov     eax,1                       ;set success return code
.done:
    pop     ebp
    ret
