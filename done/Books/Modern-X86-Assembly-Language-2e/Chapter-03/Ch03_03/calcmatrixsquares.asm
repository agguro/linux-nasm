;name        : calcmatrixsquares.asm
;description : Calculates y[i][j] = x[j][i] * x[j][i]
;              (mind the indexes switch)
;source      : Modern X86 Assembly Language Programming 2nd Edition
;build       : mkdir build && cd build && qmake .. && make
;use         : extern "C" void CalcMatrixSquares_(int* y, const int* x, int nrows, int ncols);

bits 64

global CalcMatrixSquares_

section .text

CalcMatrixSquares_:
; in : rdi = y ptr
;      rsi = x ptr
;      edx = nrows
;      ecx = ncols

; Make sure nrows and ncols are valid
    cmp     edx,0
    jle     InvalidCount                ;jump if nrows <= 0
    cmp     ecx,0
    jle     InvalidCount                ;jump if ncols <= 0

; Initialize pointers to source and destination arrays
    movsxd  r8,edx                      ;r8 = nrows sign extended
    movsxd  r9,ecx                      ;r9 = ncols sign extended
    xor     rcx,rcx                     ;rcx = i

; Perform the required calculations
Loop1:
    xor     rdx,rdx                     ;rdx = j
Loop2:
    mov     rax,rdx                     ;rax = j
    imul    rax,r9                      ;rax = j * ncols
    add     rax,rcx                     ;rax = j * ncols + i
    mov     r10d,dword [rsi+rax*4]      ;r10d = x[j][i]
    imul    r10d,r10d                   ;r10d = x[j][i] * x[j][i]

    mov     rax,rcx                     ;rax = i
    imul    rax,r9                      ;rax = i * ncols
    add     rax,rdx                     ;rax = i * ncols + j;
    mov     dword [rdi+rax*4],r10d      ;y[i][j] = r10d

    inc     rdx                         ;j += 1
    cmp     rdx,r9
    jl      Loop2                       ;jump if j < ncols

    inc     rcx                         ;i += 1
    cmp     rcx,r8
    jl      Loop1                       ;jump if i < nrows

InvalidCount:

    ret
