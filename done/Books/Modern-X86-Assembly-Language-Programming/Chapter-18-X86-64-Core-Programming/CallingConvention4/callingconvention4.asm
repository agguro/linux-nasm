; Name:     callingconvention4.asm
;
; Build:    g++ -c main.cpp -o main.o
;           nasm -f elf64 -o callingconvention4.o callingconvention4.asm
;           g++ -o callingconvention4 callingconvention4.o main.o
;
; Source:   Modern x86 Assembly Language Programming p.540

bits 64
align 16

extern pow

global Cc4

section .data
; Floating-point constants for BSA equations

r8_0p007184:    dq 0.007184
r8_0p725:       dq 0.725
r8_0p425:       dq 0.425
r8_0p0235:      dq 0.0235
r8_0p42246:     dq 0.42246
r8_0p51456:     dq 0.51456
r8_60p0:        dq 60.0

section .text

; extern "C" bool Cc4(const double* ht, const double* wt, int n, double* bsa1, double* bsa2, double* bsa3);
;

Cc4:
; Registers: rdi    ht
;            rsi    wt
;            rdx    n
;            rcx    bsa1
;            r8     bsa2
;            r9     bsa3

    push    rbp
    mov     rbp,rsp
    sub     rsp,8                           ;align stack
    push    r12                             ;save non-volatile register
    push    r13
    push    r14
    push    r15
    push    rbx

; Initialize registers unchanged by pow function
    xor     eax,eax                         ;assume error
    test    edx,edx                         ;is n <= 0?
    jle     .done                           ;jump if n <= 0
    xor     r10,r10                         ;array element offset
    mov     r11,rdi                         ;height
    mov     r12,rsi                         ;width
    mov     r13,rcx                         ;bsa1
    mov     r14,r8                          ;bsa2
    mov     r15,r9                          ;bsa3
    ;warning! register r9 is changed by pow function
    mov     r9,rdx                              ;n

; Registers: r9     n
;            r10    array element offset
;            r11    ht
;            r12    wt
;            r13    bsa1
;            r14    bsa2
;            r15    bsa3

; Calculate bsa1 = 0.007184 * pow(ht, 0.725) * pow(wt, 0.425);
.l1:
    push    r9                              ;R9 is affected by the pow function
    ;xmm0 = 0.007184
    movsd   xmm0,[r8_0p007184]
    movsd   [r13+r10],xmm0

    ;xmm0 = 0.007184 * pow(ht, 0.725)
    movsd   xmm0,[r11+r10]                  ;xmm0 = height
    movsd   xmm1,[r8_0p725]
    call    pow
    movsd   xmm1,[r13+r10]
    mulsd   xmm0,xmm1
    movsd   [r13+r10],xmm0

    ;xmm0 = 0.007184 * pow(ht, 0.725) * pow(wt, 0.425)
    movsd   xmm0,qword[r12+r10]
    movsd   xmm1,qword[r8_0p425]
    call    pow
    movsd   xmm1,[r13+r10]
    mulsd   xmm0,xmm1
    movsd   [r13+r10],xmm0

; Calculate bsa2 = 0.0235 * pow(ht, 0.42246) * pow(wt, 0.51456)

    ;xmm0 = 0.0235
    movsd   xmm0,[r8_0p0235]
    movsd   [r14+r10],xmm0
    
    ;xmm0 = 0.0235 * pow(ht, 0.42246)
    movsd   xmm0,[r11+r10]                  ;xmm0 = height
    movsd   xmm1,[r8_0p42246]
    call    pow
    movsd   xmm1,[r14+r10]
    mulsd   xmm0,xmm1
    movsd   [r14+r10],xmm0

    ;xmm0 = 0.0235 * pow(ht, 0.42246) * pow(wt, 0.51456)
    movsd   xmm0,qword[r12+r10]
    movsd   xmm1,qword[r8_0p51456]

    call    pow
    movsd   xmm1,[r14+r10]
    mulsd   xmm0,xmm1
    movsd   [r14+r10],xmm0
        
; Calculate bsa3 = sqrt(ht * wt) / 60.0;
    movq    xmm0,[r11+r10]
    movq    xmm1,[r12+r10]
    mulsd   xmm0,xmm1
    sqrtsd  xmm0,xmm0
    divsd   xmm0,[r8_60p0]                  ;xmm0 = bsa3

    movsd   [r15+r10],xmm0                  ;save bsa3 result

    add     r10,8                           ;update array offset
    pop     r9
    dec     r9                              ;n = n - 1
    jnz     .l1
    mov     eax,1                           ;set success return code

.done:
    pop     rbx
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    mov     rsp,rbp
    pop     rbp
    ret
