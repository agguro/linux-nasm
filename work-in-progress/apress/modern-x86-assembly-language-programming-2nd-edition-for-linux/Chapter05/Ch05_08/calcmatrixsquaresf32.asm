;name        : calcmatrixsquaresf32.asm
;description : Calculates y[i][j] = x[j][i] * x[j][i] + offset
;source      : Modern X86 Assembly Language Programming 2nd Edition
;build       : mkdir build && cd build && qmake .. && make
;use         : extern "C" void CalcMatrixSquaresF32_(float* y, const float* x, float offset, int nrows, int ncols)

bits 64

%define real4 dword

global CalcMatrixSquaresF32_
; in : rdi = y ptr
;      rsi = x ptr
;      xmm0 = offset
;      edx = nrows
;      ecx = ncols
; out : y[i][j] = x[j][i] * x[j][i] + offset

section .text

CalcMatrixSquaresF32_:

; Make sure nrows and ncols are valid
    test    edx,edx
    jle     InvalidCount            ;jump if nrows <= 0
    test    ecx,ecx
    jle     InvalidCount            ;jump if ncols <= 0

    movsxd  r9,edx                  ;r9 = nrows
    movsxd  r10,ecx                 ;r10 = ncols

; Initialize pointers to source and destination arrays
    xor     rcx,rcx                 ;rcx = i
    vmovss  xmm2,xmm0

; Perform the required calculations
Loop1:
    xor     rdx,rdx                 ;rdx = j

Loop2:
    mov     rax,rdx                 ;rax = j
    imul    rax,r10                 ;rax = j * ncols
    add     rax,rcx                 ;rax = j * ncols + i
    vmovss  xmm0,real4 [rsi+rax*4]  ;xmm0 = x[j][i]
    vmulss  xmm1,xmm0,xmm0          ;xmm1 = x[j][i] * x[j][i]
    vaddss  xmm3,xmm1,xmm2          ;xmm2 = x[j][i] * x[j][i] + offset

    mov     rax,rcx                 ;rax = i
    imul    rax,r10                 ;rax = i * ncols
    add     rax,rdx                 ;rax = i * ncols + j;
    vmovss  real4 [rdi+rax*4],xmm3  ;y[i][j] = x[j][i] * x[j][i] + offset

    inc     rdx                     ;j += 1
    cmp     rdx,r10
    jl      Loop2                   ;jump if j < ncols

    inc     rcx                     ;i += 1
    cmp     rcx,r9
    jl      Loop1                   ;jump if i < nrows

InvalidCount:
    ret
