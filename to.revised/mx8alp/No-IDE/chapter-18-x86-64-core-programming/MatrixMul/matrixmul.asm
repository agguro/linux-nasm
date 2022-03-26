; Name:     matrixmul.asm
;
; Build:    g++ -c main.cpp -o main.o
;           nasm -f elf64 -o matrixmul.o matrixmul.asm
;           g++ -o matrixmul matrixmul.o main.o
;
; Source:   Modern x86 Assembly Language Programming p.546

; extern "C" double* MatrixMul(const double* m1, int nr1, int nc1, const double* m2, int nr2, int nc2);
;
; Description:  The following function computes the product of two
;               matrices.

global MatrixMul
extern malloc

section .text

MatrixMul:
;            GCC                Windows
; Registers: rdi    m1           rcx
;            rsi    nr1          rdx
;            rdx    nc1          r8
;            rcx    m2           r9
;            r8     nr2          stack
;            r9     nc2          stack

; Create stackframe
    push    rbp
    mov     rbp,rsp
    sub     rsp,8                   ;align stack
    push    r12                     ;save non-volatile register
    push    r13
    push    r14
    push    r15
    push    rbx

; assume error
    xor     rax,rax                 ;return NULL pointer when error
; Verify the matrix size values.
    movsxd  rsi,esi                 ;rsi = nr1
    test    rsi,rsi
    jle     .done                   ;jump if nr1 <= 0

    movsxd  rdx,edx                 ;rdx = nc1
    test    rdx,rdx
    jle     .done                   ;jump if nc1 <= 0

    movsxd  r8,r8d                  ;r8 = nr2
    test    r8,r8
    jle     .done                   ;jump if nr2 <= 0

    movsxd  r9,r9d                  ;r9 = nc2
    test    r9,r9
    jle     .done                   ;jump if nc2 <= 0

    cmp     rdx,r8
    jne     .done                   ;jump if nc1 != nr2

; Allocate storage
    ; save m1, m2, nc1 and nc2 on stack, these are altered by malloc()
    push    rdi
    push    rsi
    push    rcx
    push    rdx
    push    r9
    ;calculate number of bytes of memory to allocate
    mov     rdi,rsi                 ;rdi = nr1
    imul    rdi,r9                  ;rdi = nr1 * nc2
    shl     rdi,3                   ;rdi = nr1 * nc2 * size real8
    call    malloc
    mov     rbx,rax                 ;rbx = ptr to m3
    ;restore m1, m2, nc1 and nc2 from stack
    pop     r9
    pop     rdx
    pop     rcx
    pop     rsi
    pop     rdi

; Initialize row index i
    xor     r14,r14                 ;i = 0
; Initialize column index j
.lp1:
    xor     r15,r15                 ;j = 0
; Initialize sum and index k
.lp2:
    xorpd   xmm4,xmm4               ;sum = 0;
    xor     r10,r10                 ;k = 0;
; Calculate sum += m1[i * nc1 + k] * m2[k * nc2 + j]
.lp3:
    mov     rax,r14                 ;rax = i
    imul    rax,rdx                 ;rax = i * nc1
    add     rax,r10                 ;rax = i * nc1 + k
    movsd   xmm0,[rdi+rax*8]        ;xmm0 = m1[i * nc1 + k]
    mov     r11,r10                 ;r11 = k;
    imul    r11,r9                  ;r11 = k * nc2
    add     r11,r15                 ;r11 = k * nc2 + j
    movsd   xmm1,[rcx+r11*8]        ;xmm1 = m2[k * nc2 + j]
    mulsd   xmm0,xmm1               ;xmm0 = m1[i * nc1 + k] * m2[k * nc2 + j]
    addsd   xmm4,xmm0               ;update sum
    inc     r10                     ;k++
    cmp     r10,rdx
    jl      .lp3                    ;jump if k < nc1
; Save sum to m3[i * nc2 + j]
    mov     rax,r14                 ;rax = i
    imul    rax,r9                  ;rax = i * nc2
    add     rax,r15                 ;rax = i * nc2 + j
    movsd   qword[rbx+rax*8],xmm4   ;m3[i * nc2 + j] = sum
; Update loop counters and repeat until done
    inc     r15                     ;j++
    cmp     r9,r15
    jl      .lp2                    ;jump if j < nc2
    inc     r14                      ;i++
    cmp     r14,rsi
    jl      .lp1                    ;jump if i < nr1
    mov     rax,rbx                 ;rax = ptr to m3

.done:
    pop     rbx                     ;restore non-volatile registers
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    mov     rsp,rbp                 ;restore stack
    pop     rbp
    ret
