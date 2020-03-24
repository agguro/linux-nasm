; Name:     avxfma.asm
;
; Build:    g++ -c -m32 main.cpp -o main.o
;           nasm -f elf32 -o avxfma.o avxfma.asm
;           g++ -m32 -o avxfma avxfma.o main.o
;
; Source:   Modern x86 Assembly Language Programming p. 470

global AvxFmaSmooth5a
global AvxFmaSmooth5b
global AvxFmaSmooth5c

section .text

; void AvxFmaSmooth5a(float* y, const float*x, Uint32 n, const float* sm5_mask);
;
; Description:  The following function applies a weighted-average
;               smoothing transformation to the input array x using
;               scalar SPFP multiplication and addition.
;
; Requires:     AVX

%define y           [ebp+8]
%define x           [ebp+12]
%define n           [ebp+16]
%define sm5_mask    [ebp+20]

AvxFmaSmooth5a:
    push    ebp
    mov     ebp,esp
    push    esi
    push    edi

; Load argument values
    mov     edi,y                           ;edi = ptr to y
    mov     esi,x                           ;esi = ptr to x
    mov     ecx,n                           ;ecx = n
    mov     eax,sm5_mask                    ;eax = ptr to sm5_mask

    add     esi,8                           ;adjust pointers and
    add     edi,8                           ;counter to skip first 2
    sub     ecx,4                           ;and last 2 elements

align 16
; Apply smoothing operator to each element of x
.@1:
    vxorps  xmm6,xmm6,xmm6               ;x_total=0

; Compute x_total += x[i-2]*sm5_mask[0]
    vmovss  xmm0,dword [esi-8]
    vmulss  xmm1,xmm0,dword [eax]
    vaddss  xmm6,xmm6,xmm1

; Compute x_total += x[i-1]*sm5_mask[1]
    vmovss  xmm2,dword [esi-4]
    vmulss  xmm3,xmm2,dword [eax+4]
    vaddss  xmm6,xmm6,xmm3

; Compute x_total += x[i]*sm5_mask[2]
    vmovss  xmm0,dword [esi]
    vmulss  xmm1,xmm0,dword[eax+8]
    vaddss  xmm6,xmm6,xmm1

; Compute x_total += x[i+1]*sm5_mask[3]
    vmovss  xmm2,dword[esi+4]
    vmulss  xmm3,xmm2,dword[eax+12]
    vaddss  xmm6,xmm6,xmm3

; Compute x_total += x[i+2]*sm5_mask[4]
    vmovss  xmm0,dword[esi+8]
    vmulss  xmm1,xmm0,dword[eax+16]
    vaddss  xmm6,xmm6,xmm1

; Save x_total
    vmovss  dword[edi],xmm6

    add     esi,4
    add     edi,4
    sub     ecx,1
    jnz     .@1

    pop     edi
    pop     esi
    pop     ebp
    ret

; void AvxFmaSmooth5b(float* y, const float*x, Uint32 n, const float* sm5_mask);
;
; Description:  The following function applies a weighted-average
;               smoothing transformation to the input array x using
;               scalar SPFP fused-multiply-add operations.
;
; Requires:     AVX2, FMA

%define y           [ebp+8]
%define x           [ebp+12]
%define n           [ebp+16]
%define sm5_mask    [ebp+20]

AvxFmaSmooth5b:
    push    ebp
    mov     ebp,esp
    push    esi
    push    edi

; Load argument values
    mov     edi,y                           ;edi = ptr to y
    mov     esi,x                           ;esi = ptr to x
    mov     ecx,n                           ;ecx = n
    mov     eax,sm5_mask                    ;eax = ptr to sm5_mask

    add     esi,8                           ;adjust pointers and
    add     edi,8                           ;counter to skip first 2
    sub     ecx,4                           ;and last 2 elements

align 16
; Apply smoothing operator to each element of x
.@1:
    vxorps  xmm6,xmm6,xmm6               ;set x_total1 = 0
    vxorps  xmm7,xmm7,xmm7               ;set x_total2 = 0

; Compute x_total1 = x[i-2] * sm5_mask[0] + x_total1
    vmovss      xmm0,dword[esi-8]
    vfmadd231ss xmm6,xmm0,dword[eax]

; Compute x_total2 = x[i-1] * sm5_mask[1] + x_total2
    vmovss      xmm2,dword[esi-4]
    vfmadd231ss xmm7,xmm2,dword[eax+4]

; Compute x_total1 = x[i] * sm5_mask[2] + x_total1
    vmovss      xmm0,dword[esi]
    vfmadd231ss xmm6,xmm0,dword[eax+8]

; Compute x_total2 = x[i+1] * sm5_mask[3] + x_total2
    vmovss      xmm2,dword[esi+4]
    vfmadd231ss xmm7,xmm2,dword[eax+12]

; Compute x_total1 = x[i+2] * sm5_mask[4] + x_total1
    vmovss      xmm0,dword[esi+8]
    vfmadd231ss xmm6,xmm0,dword[eax+16]

; Compute final x_total and save result
    vaddss  xmm5,xmm6,xmm7
    vmovss  dword[edi],xmm5

    add     esi,4
    add     edi,4
    sub     ecx,1
    jnz     .@1

    pop     edi
    pop     esi
    pop     ebp
    ret

; void AvxFmaSmooth5c(float* y, const float*x, Uint32 n, const float* sm5_mask);
;
; Description:  The following function applies a weighted-average
;               smoothing transformation to the input array x using
;               scalar SPFP fused-multiply-add operations.
;
; Requires:     AVX2, FMA

%define y           [ebp+8]
%define x           [ebp+12]
%define n           [ebp+16]
%define sm5_mask    [ebp+20]

AvxFmaSmooth5c:
    push    ebp
    mov     ebp,esp
    push    esi
    push    edi

; Load argument values
    mov     edi,y                           ;edi = ptr to y
    mov     esi,x                           ;esi = ptr to x
    mov     ecx,n                           ;ecx = n
    mov     eax,sm5_mask                    ;eax = ptr to sm5_mask

    add     esi,8                           ;adjust pointers and
    add     edi,8                           ;counter to skip first 2
    sub     ecx,4                           ;and last 2 elements

align 16

; Apply smoothing operator to each element of x, save result to y
.@1:
    vxorps xmm6,xmm6,xmm6               ;set x_total = 0

; Compute x_total = x[i-2] * sm5_mask[0] + x_total
    vmovss      xmm0,dword[esi-8]
    vfmadd231ss xmm6,xmm0,dword[eax]

; Compute x_total = x[i-1] * sm5_mask[1] + x_total
    vmovss      xmm0,dword[esi-4]
    vfmadd231ss xmm6,xmm0,dword[eax+4]

; Compute x_total = x[i] * sm5_mask[2] + x_total
    vmovss      xmm0,dword[esi]
    vfmadd231ss xmm6,xmm0,dword[eax+8]

; Compute x_total = x[i+1] * sm5_mask[3] + x_total
    vmovss      xmm0,dword[esi+4]
    vfmadd231ss xmm6,xmm0,dword[eax+12]

; Compute x_total = x[i+2] * sm5_mask[4] + x_total
    vmovss      xmm0,dword[esi+8]
    vfmadd231ss xmm6,xmm0,dword[eax+16]

; Save result
    vmovss  dword[edi],xmm6

    add     esi,4
    add     edi,4
    sub     ecx,1
    jnz     .@1

    pop     edi
    pop     esi
    pop     ebp
    ret
