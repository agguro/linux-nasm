;name        : calcarrayvalues.asm
;description : Calculates  y[i] = x[i] * a + b
;source      : Modern X86 Assembly Language Programming 2nd Edition
;build       : mkdir build && cd build && qmake .. && make
;use         : extern "C" long long CalcArrayValues_(long long* y, const int* x, int a, short b, int n);
;              returns: Sum of the elements in array y.

bits 64

global CalcArrayValues_

section .text

CalcArrayValues_:
; in : rdi = y ptr
;      rsi = x ptr
;      edx = a
;      cx  = b
;      r8d = n
; out : y[i] = x[i] * a + b

; Initialize sum to zero and make sure 'n' is valid
    xor     rax,rax                 ;sum = 0
    mov     r11d,r8d                ;r11d = n
    cmp     r11d,0
    jle     InvalidCount            ;jump if n <= 0

; Load expression constants and array index
    movsxd  r8,edx                  ;r8 = a (sign extended)
    movsx   r9,cx                   ;r9 = b (sign extended)
    xor     edx,edx                 ;edx = array index i

; Repeat until done
.repeat:
    movsxd  rcx,dword [rsi+rdx*4]   ;rcx = x[i] (sign extended)
    imul    rcx,r8                  ;rcx = x[i] * a
    add     rcx,r9                  ;rcx = x[i] * a + b
    mov     qword [rdi+rdx*8],rcx   ;y[i] = rcx

    add     rax,rcx                 ;update running sum

    inc     edx                     ;edx = i + i
    cmp     edx,r11d                ;is i >= n?
    jl      .repeat                 ;jump if i < n

InvalidCount:

    ret
