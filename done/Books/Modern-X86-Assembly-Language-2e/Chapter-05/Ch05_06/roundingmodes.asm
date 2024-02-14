;name        : roundingmodes.asm
;description : MXCSR.RC rounding mode example
;source      : Modern X86 Assembly Language Programming 2nd Edition
;build       : mkdir build && cd build && qmake .. && make
;use         : extern "C" RoundingMode GetMxcsrRoundingMode_(void);
;                 Description: Obtains the current floating-point rounding
;                 mode from MXCSR.RC.
;              returns: Current MXCSR.RC rounding mode.
;              extern "C" void SetMxcsrRoundingMode_(RoundingMode rm);
;                 Description:  Updates the rounding mode value in MXCSR.RC.
;              extern "C" bool ConvertScalar_(Uval* des, const Uval* src, CvtOp cvt_op)
;                 Note: The linker option /LARGEADDRESSAWARE:NO from Windows isn't needed.

bits 64

global GetMxcsrRoundingMode_
global SetMxcsrRoundingMode_
global ConvertScalar_

MxcsrRcMask equ 9fffh                       ;bit pattern for MXCSR.RC
MxcsrRcShift equ 13                         ;shift count for MXCSR.RC

section .rodata

; The order of values in following table must match the enum CvtOp
; that's defined in the .cpp file.

%define SIZE_QWORD 8
%define real4 dword
%define real8 qword

align 8
CvtOpTable: equ $
    dq I32_F32, F32_I32, I32_F64, F64_I32, I64_F32
    dq F32_I64, I64_F64, F64_I64, F32_F64, F64_F32
CvtOpTableCount equ ($ - CvtOpTable) / SIZE_QWORD

section .text

GetMxcsrRoundingMode_:
; in : nothing
; out : rax = RoundingMode: Nearest = 0
;                           Down = 1
;                           Up = 2
;                           Truncate = 3
    push        rbp
    mov         rbp,rsp
    sub         rsp,8
    vstmxcsr    dword [rsp]          ;save mxcsr register
    mov         eax,[rsp]
    shr         eax,MxcsrRcShift     ;eax[1:0] = MXCSR.RC bits
    and         eax,3                ;masked out unwanted bits
    mov         rsp,rbp
    pop         rbp
    ret

SetMxcsrRoundingMode_:
; in : edi = rm (RoundingMode)
; out : nothing, roundingmode is set
    push        rbp
    mov         rbp,rsp
    sub         rsp,8
    and         edi,3                ;masked out unwanted bits
    shl         edi,MxcsrRcShift     ;ecx[14:13] = rm
    vstmxcsr    dword [rsp]          ;save current MXCSR
    mov         eax,[rsp]
    and         eax,MxcsrRcMask      ;masked out old MXCSR.RC bits
    or          eax,edi              ;insert new MXCSR.RC bits
    mov         [rsp],eax
    vldmxcsr    dword [rsp]          ;load updated MXCSR
    mov         rsp,rbp
    pop         rbp
    ret

ConvertScalar_:
; in : rdi = des ptr   rcx
;      rsi = src ptr   rdx
;      edx = cvt_op    r8d

; Make sure cvt_op is valid, then jump to target conversion code
        mov eax,edx                  ;eax = CvtOp
        cmp eax,CvtOpTableCount
        jae BadCvtOp                 ;jump if cvt_op is invalid
        jmp [CvtOpTable+rax*8]       ;jump to specified conversion

; Conversions between int32_t and float/double

I32_F32:
        mov eax,[rsi]                ;load integer value
        vcvtsi2ss xmm0,xmm0,eax      ;convert to float
        vmovss real4 [rdi],xmm0      ;save result
        mov eax,1
        ret

F32_I32:
        vmovss xmm0,real4 [rsi]      ;load float value
        vcvtss2si eax,xmm0           ;convert to integer
        mov [rdi],eax                ;save result
        mov eax,1
        ret

I32_F64:
        mov eax,[rsi]                ;load integer value
        vcvtsi2sd xmm0,xmm0,eax      ;convert to double
        vmovsd real8 [rdi],xmm0      ;save result
        mov eax,1
        ret

F64_I32:
        vmovsd xmm0,real8 [rsi]      ;load double value
        vcvtsd2si eax,xmm0           ;convert to integer
        mov [rdi],eax                ;save result
        mov eax,1
        ret

; Conversions between int64_t and float/double

I64_F32:
        mov rax,[rsi]                ;load integer value
        vcvtsi2ss xmm0,xmm0,rax      ;convert to float
        vmovss real4 [rdi],xmm0      ;save result
        mov eax,1
        ret

F32_I64:
        vmovss xmm0,real4 [rsi]      ;load float value
        vcvtss2si rax,xmm0           ;convert to integer
        mov [rdi],rax                ;save result
        mov eax,1
        ret

I64_F64:
        mov rax,[rsi]                ;load integer value
        vcvtsi2sd xmm0,xmm0,rax      ;convert to double
        vmovsd real8 [rdi],xmm0      ;save result
        mov eax,1
        ret

F64_I64:
        vmovsd xmm0,real8 [rsi]      ;load double value
        vcvtsd2si rax,xmm0           ;convert to integer
        mov [rdi],rax                ;save result
        mov eax,1
        ret

; Conversions between float and double

F32_F64:
        vmovss xmm0,real4 [rsi]      ;load float value
        vcvtss2sd xmm1,xmm1,xmm0     ;convert to double
        vmovsd real8 [rdi],xmm1      ;save result
        mov eax,1
        ret

F64_F32:
        vmovsd xmm0,real8 [rsi]      ;load double value
        vcvtsd2ss xmm1,xmm1,xmm0     ;convert to float
        vmovss real4 [rdi],xmm1      ;save result
        mov eax,1
        ret

BadCvtOp:
        xor eax,eax                  ;set error return code
        ret
