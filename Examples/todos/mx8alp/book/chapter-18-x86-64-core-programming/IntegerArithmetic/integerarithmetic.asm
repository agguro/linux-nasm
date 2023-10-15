; Name:         integerarithmetic.asm
;
; Build:        g++ -c main.cpp -o main.o
;               nasm -f elf64 -o integerarithmetic.o integerarithmetic.asm
;               g++ -o integerarithmetic integerarithmetic.o main.o
;
; Description:  Demonstration of GCC with nasm calling convention on Linux
;               However we can program this example easier, I've followed the
;               Windows Visual Studio way to calculate the results.  Just to show
;               how different things can be.
;
; Source:       Modern x86 Assembly Language Programming p.504

bits 64

global IntegerAdd
global IntegerMul
global IntegerDiv

section .text

; extern "C" Int64 IntegerAdd(Int64 a, Int64 b, Int64 c, Int64 d, Int64 e, Int64 f)
;
; Description:  The following function demonstrates 64-bit integer
;               addition.

IntegerAdd:
    ; Calculate sum of argument values
    add     rdi,rsi          ;rdi = a + b
    add     rcx,rdx          ;rcx = c + d
    mov     rax,r8           ;rax = e
    add     rax,r9           ;rax = e + f
    add     rcx,rdi          ;rcx = a + b + c + d
    add     rax,rcx          ;rax = a + b + c + d + e + f
    ret

; extern "C" Int64 IntegerMul(Int8 a, Int16 b, Int32 c, Int64 d, Int8 e, Int16 f, Int32 g, Int64 h);
;
; Description:  The following function demonstrates 64-bit signed
;               integer multiplication.
; Remark:       Intel stores the negative byte and word values already signed extended in a
;               dword register meaning that we can sign extend a dword immediately. Anyway,
;               in this example we see the use of the 8bit value of di (dil) and r8 (r8b).
;               Users who have the books source code will notice that the stack is used
;               slightly different used than in Windows VC++.  That's because gcc in linux 
;               uses a different ABI.

IntegerMul:
    ; Calculate a * b
    movsx   rdi,dil                     ;dil = a, sign_extend(a) in rdi
    movsx   rsi,si                      ;si = b, sign_extend(b) in rsi
    imul    rdi,rsi                     ;rdi = a * b
    ;Calculate c * d                    ;rcx = d
    movsxd  rdx,edx                     ;edx = c, sign_extend(c) in rdx
    imul    rcx,rdx                     ;rcx = c * d
    ; Calculate e * f
    movsx   r8,r8b                      ;r8b = e, sign_extend(e) in r8
    movsx   r9,r9w                      ;r9w = f, sign_extend(f) in r9
    imul    r8,r9                       ;r8 = e * f
    ; Calculate g * h
    movsxd  rax,dword[rsp+8]            ;rax = sign_extend(g)
    imul    rax,[rsp+16]                ;rax = g * h
    ; Compute final result
    imul    rax,rdi                     ;rax = a * b * g * h
    imul    rax,rcx                     ;rax = a * b * c * d * g * h
    imul    rax,r8                      ;rax = a * b * c * d * e * f * g * h
    ;rax = final product
    ret

; extern "C" void IntegerDiv(Int64 a, Int64 b, Int64 quo_rem_ab[2], Int64 c, Int64 d, Int64 quo_rem_cd[2]);
;
; Description:  The following function demonstrates 64-bit signed
;               integer division.

IntegerDiv:
    mov     r10,rdx                     ;save pointer to quo_rem_ab[2]
    ; Additional we check for division by zero
    cmp     rsi,0
    je      .bzero
    ; Calculate a / b, save quotient and remainder
    mov     rax,rdi                     ;rax = a
    cqo                                 ;rdx:rax = sign_extend(a)
    idiv    rsi                         ;rax = quo a/b, rdx = rem a/b
    jmp     .l1
.bzero:
    mov     rax,-1                      ;both values -1
    mov     rdx,-1
.l1:    
    mov     qword[r10],rax              ;save quotient
    mov     qword[r10+8],rdx            ;save remainder
    ; Additional we check for division by zero
    cmp     r8,0
    je      .dzero
    ; Calculate c / d, save quotient and remainder
    mov     rax,rcx                     ;rax = c
    cqo                                 ;rdx:rax is sign_extend(c)
    idiv    r8                          ;rax = quo c/d, rdx = rem c/d
    jmp     .l2
.dzero:
    mov     rax,-1                      ;both values -1
    mov     rdx,-1
.l2:
    mov     qword[r9],rax               ;save quotient
    mov     qword[r9+8],rdx             ;save remainder
    ret
