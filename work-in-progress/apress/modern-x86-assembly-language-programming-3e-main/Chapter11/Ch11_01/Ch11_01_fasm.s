;------------------------------------------------------------------------------
; Ch11_01_fasm.s
;------------------------------------------------------------------------------

        %include "ModX86Asm3eNASM.inc"

;------------------------------------------------------------------------------
; ReducePD_M macro
;
; Description:  This macro sums the double-precision elements in register YmmSrc.
;               The result is saved in register XmmDes.
;
; Macro Parameters (use complete register names):
;   %1 = XmmDes     xmm destination register
;   %2 = YmmSrc     ymm source register
;   %3 = XmmSrc     xmm source register (must be same number as YmmSrc)
;   %4 = XmmTmp     xmm temp register (must be different than XmmDes and YmmSrc)
;------------------------------------------------------------------------------

%macro ReducePD_M 4
        vextractf128 %4,%2,1                ;extract two high-order F64 values
        vaddpd %1,%4,%3                     ;reduce to two F64 values
        vhaddpd %1,%1,%1                    ;reduce to one F64 value
%endmacro

;------------------------------------------------------------------------------
; void CalcLeastSquares_avx2(double* m, double* b, const double* x,
;   const double* y, size_t n, double epsilon);
;------------------------------------------------------------------------------

NSE     equ 8                               ;num_simd_elements

        section .text

        global CalcLeastSquares_avx2
CalcLeastSquares_avx2:

; Set m and b to zero (error values)
        xor eax,eax
        mov [rdi],rax                       ;m = 0.0
        mov [rsi],rax                       ;b = 0.0

; Validate arguments
        cmp r8,2                            ;n < 2?
        jl Done                             ;jump if yes

        test rdx,1fh
        jnz Done                            ;jump if x not 32b aligned
        test rcx,1fh
        jnz Done                            ;jump if y not 32b aligned

; Initialize
        vmovsd xmm11,xmm0                   ;xmm11 = epsilon

        vxorpd ymm12,ymm12,ymm12            ;packed sum_x = 0
        vxorpd ymm13,ymm13,ymm13            ;packed sum_y = 0
        vxorpd ymm14,ymm14,ymm14            ;packed sum_xx = 0
        vxorpd ymm15,ymm15,ymm15            ;packed sum_xy = 0
        mov r11,r8                          ;save copy of n for later

        mov rax,-8                          ;rax = array offset for Loop2
        cmp r8,NSE                          ;n >= NSE?
        jb Loop2                            ;jump if no
        mov rax,-NSE*8                      ;rax = array offset for Loop1

; Calculate sum vars using SIMD arithmetic
Loop1:  add rax,NSE*8                       ;update offset for current iteration
        vmovapd ymm0,[rdx+rax]              ;load x[i:i+3]
        vmovapd ymm1,[rcx+rax]              ;load y[i:i+3]
        vaddpd ymm12,ymm12,ymm0             ;update packed sum_x
        vaddpd ymm13,ymm13,ymm1             ;update packed sum_y
        vfmadd231pd ymm14,ymm0,ymm0         ;update packed sum_xx
        vfmadd231pd ymm15,ymm0,ymm1         ;update packed_sum_xy

        vmovapd ymm0,[rdx+rax+32]           ;load x[i+4:i+7]
        vmovapd ymm1,[rcx+rax+32]           ;load y[i+4:i+7]
        vaddpd ymm12,ymm12,ymm0             ;update packed sum_x
        vaddpd ymm13,ymm13,ymm1             ;update packed sum_y
        vfmadd231pd ymm14,ymm0,ymm0         ;update packed sum_xx
        vfmadd231pd ymm15,ymm0,ymm1         ;update packed_sum_xy

        sub r8,NSE                          ;n -= NSE
        cmp r8,NSE                          ;n >= NSE?
        jae Loop1                           ;jump if yes

; Reduce packed sum vars to scalars
        ReducePD_M xmm12,ymm12,xmm12,xmm0   ;xmm12 = sum_x
        ReducePD_M xmm13,ymm13,xmm13,xmm0   ;xmm13 = sum_y
        ReducePD_M xmm14,ymm14,xmm14,xmm0   ;xmm14 = sum_xx
        ReducePD_M xmm15,ymm15,xmm15,xmm0   ;xmm15 = sum_xy

        test r8,r8                          ;n == 0?
        jz CalcLS                           ;jump if yes

        add rax,NSE*8-8                     ;adjust array offset for Loop2

; Process any residual elements using scalar arithmetic
Loop2:  add rax,8                           ;update offset
        vmovsd xmm0,[rdx+rax]               ;load x[i]
        vmovsd xmm1,[rcx+rax]               ;load y[i]

        vaddsd xmm12,xmm12,xmm0             ;update sum_x
        vaddsd xmm13,xmm13,xmm1             ;update sum_y
        vfmadd231sd xmm14,xmm0,xmm0         ;update sum_xx
        vfmadd231sd xmm15,xmm0,xmm1         ;update sum_xy

        sub r8,1                            ;n -= 1
        jnz Loop2                           ;repeat until done

CalcLS: vcvtsi2sd xmm5,xmm5,r11             ;xmm5 = n
        vmulsd xmm0,xmm5,xmm14              ;xmm0 = n * sum_xx
        vmulsd xmm1,xmm12,xmm12             ;xmm1 = sum_x * sum_x
        vsubsd xmm0,xmm0,xmm1               ;xmm0 = denom

        mov rax,7fffffffffffffffh           ;rax = F64 abs mask
        vmovq xmm1,rax
        vandpd xmm4,xmm0,xmm1               ;xmm4 = fabs(denom)
        vcomisd xmm4,xmm11                  ;fabs(denom) < epsilon ?
        jb Done                             ;jump if yes 

; Compute and save slope
        vmulsd xmm0,xmm5,xmm15              ;n * sum_xy
        vmulsd xmm1,xmm12,xmm13             ;sum_x * sum_y
        vsubsd xmm2,xmm0,xmm1               ;n * sum_xy - sum_x * sum_y
        vdivsd xmm3,xmm2,xmm4               ;xmm3 = slope
        vmovsd [rdi],xmm3                   ;save slope

; Compute and save intercept
        vmulsd xmm0,xmm14,xmm13             ;sum_xx * sum_y
        vmulsd xmm1,xmm12,xmm15             ;sum_x * sum_xy
        vsubsd xmm2,xmm0,xmm1               ;sum_xx * sum_y - sum_x _ sum_xy
        vdivsd xmm3,xmm2,xmm4               ;xmm3 = intercept
        vmovsd [rsi],xmm3                   ;save intercept

Done:   vzeroupper
        ret
