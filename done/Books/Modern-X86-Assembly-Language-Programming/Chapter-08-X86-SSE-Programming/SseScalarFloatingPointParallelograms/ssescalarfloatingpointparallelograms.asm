; Name:     ssescalarfloatingpointspheres.asm
;
; Build:    g++ -c -m32 main.cpp -o main.o -std=c++11
;           nasm -f elf32 -o ssescalarfloatingpointparallelograms.o ssescalarfloatingpointparallelograms.asm
;           g++ -m32 -o ssescalarfloatingpointparallelograms ssescalarfloatingpointparallelograms.o main.o
;
; Source:   Modern x86 Assembly Language Programming p. 228
;
; Remark:   4 lines are added to this source code. Calling the sin and cos
;           functions from the math library changes the content of ecx.
;           We need to save ecx somewhere before calling sin or cos and restore
;           ecx back when sin or cos returns with the result.

global	SizeofPdataX86
global	SseSfpParallelograms

extern sin
extern cos
extern DegToRad

; This structure must agree with the structure that's defined
; in file SseScalarFloatingPointParallelograms.cpp.

struc PDATA
    .A:       resq 1
    .B:       resq 1
    .Alpha:   resq 1
    .Beta:    resq 1
    .H:       resq 1
    .Area:    resq 1
    .P:       resq 1
    .Q:       resq 1
    .BadVal:  resb 1
    .Pad:     resb 7
    .size:	equ $-PDATA
endstruc

section .data

; Constant values used by function
    r8_2p0:         dq 2.0
    r8_180p0:       dq 180.0
    r8_MinusOne:    dq -1.0
    SizeofPdataX86: dq PDATA.size

section .text

; extern "C" bool SseSfpParallelograms(PDATA* pdata, int n);
;
; Description:  The following function calculates area and length
;               values for parallelograms.
;
; Returns:      0   n <= 0
;               1   n > 0
;
; Local stack:  [ebp-8]     x87 FPU transfer location
;               [ebp-16]    Alpha in radians
;
; Requires SSE2

SseSfpParallelograms:

    %define pdata	[ebp+8]			; pointer
    %define n		dword[ebp+12]	; value 

    push    ebp
    mov     ebp,esp
    sub     esp,16                      ;allocate space for local vars
    push    ebx

; Load arguments and validate n
    xor     eax,eax                     ;set error code
    mov     ebx,pdata                   ;ebx = pdata
    mov     ecx,n                       ;ecx = n
    test    ecx,ecx
    jle     .done                       ;jump if n <= 0

    
; Initialize constant values
.loop1:  
    movsd   xmm6,qword[r8_180p0]        ;xmm6 = 180.0
    xorpd   xmm7,xmm7                   ;xmm7 = 0.0
    sub     esp,8                       ;space for sin/cos arg value
    
; Load and validate A and B
    movsd   xmm0,qword[ebx+PDATA.A]     ;xmm0 = A
    movsd   xmm1,qword[ebx+PDATA.B]     ;xmm0 = B
    comisd  xmm0,xmm7
    jp      .invalidValue
    jbe     .invalidValue               ;jump if A <= 0.0
    comisd  xmm1,xmm7
    jp      .invalidValue
    jbe     .invalidValue               ;jump if B <= 0.0
; Load and validate Alpha
    movsd   xmm2,qword[ebx+PDATA.Alpha]
    comisd  xmm2,xmm7
    jp      .invalidValue
    jbe     .invalidValue               ;jump if Alpha <= 0.0
    comisd  xmm2,xmm6
    jae     .invalidValue               ;jump if Alpha >= 180.0
; Compute Beta
    subsd   xmm6,xmm2                   ;Beta = 180.0 - Alpha
    movsd   qword[ebx+PDATA.Beta],xmm6  ;Save Beta
; Compute sin(Alpha)
    mulsd   xmm2,[DegToRad]             ;convert Alpha to radians
    movsd 	qword[ebp-16],xmm2          ;save value for later
    movsd 	qword[esp],xmm2             ;copy Alpha onto stack
; save ecx into the location for n
    mov 	n,ecx                       ;n = ecx
;    call 	sin
; restore ecx
    mov 	ecx,n                       ;ecx = n
    fstp 	qword[ebp-8]                ;save sin(Alpha)
; Compute parallelogram Height and Area
    movsd 	xmm0,qword[ebx+PDATA.A]     ;A
    mulsd 	xmm0, [ebp-8]               ;A * sin(Alpha)
    movsd 	qword[ebx+PDATA.H],xmm0     ;save height
    mulsd 	xmm0, [ebx+PDATA.B]         ;A * sin(Alpha) * B
    movsd 	qword[ebx+PDATA.Area],xmm0  ;save area
; Compute cos(Alpha)
    movsd 	xmm0,qword[ebp-16]          ;xmm0 = Alpha in radians
    movsd 	[esp],xmm0                  ;copy Alpha onto stack
; save ecx into the location for n
    mov 	n,ecx                       ;n = ecx
;    call 	cos
; restore ecx
    mov 	ecx,n                       ;ecx = n
    fstp 	qword[ebp-8]                ;save cos(Alpha)
; Compute 2.0 * A * B * cos(Alpha)
    movsd 	xmm0,qword[r8_2p0]
    movsd 	xmm1,qword[ebx+PDATA.A]
    movsd 	xmm2,qword[ebx+PDATA.B]
    mulsd 	xmm0,xmm1                   ;2 * A
    mulsd 	xmm0,xmm2                   ;2 * A * B
    mulsd 	xmm0,[ebp-8]                ;2 * A * B * cos(Alpha)
; Compute A * A + B * B
    movsd 	xmm3,xmm1
    movsd 	xmm4,xmm2
    mulsd 	xmm3,xmm3                   ;A * A
    mulsd 	xmm4,xmm4                   ;B * B
    addsd 	xmm3,xmm4                   ;A * A + B * B
    movsd 	xmm4,xmm3                   ;A * A + B * B
; Compute P and Q
    subsd 	xmm3,xmm0
    sqrtsd 	xmm3,xmm3                   ;xmm3 = P
    movsd 	qword[ebx+PDATA.P],xmm3
    addsd 	xmm4,xmm0
    sqrtsd 	xmm4,xmm4                   ;xmm4 = Q
    movsd 	qword[ebx+PDATA.Q],xmm4
    mov 	byte[ebx+PDATA.BadVal],0    ;set BadVal to false
.nextItem:
    add 	ebx,PDATA.size              ;ebx = next element in array
    
    ;next instruction gives an segmentation fault in the books source code.
    ;It must be excuted within the loop instead of outside the loop.
    
    add 	esp,8                       ;restore ESP before exiting the loop
                                        ;and before decrementing the loop counter
    dec 	ecx
    jnz 	.loop1                      ;repeat loop until done
    
.done:
    pop 	ebx
    mov 	esp,ebp
    pop 	ebp
    ret

; Set structure members to know values for display purposes
.invalidValue:
	movsd 	xmm0,[r8_MinusOne]
	movsd  	qword[ebx+PDATA.Beta],xmm0
	movsd  	qword[ebx+PDATA.H],xmm0
	movsd  	qword[ebx+PDATA.Area],xmm0
	movsd  	qword[ebx+PDATA.P],xmm0
	movsd  	qword[ebx+PDATA.Q],xmm0
	mov  	byte[ebx+PDATA.BadVal],1
	jmp 	.nextItem
