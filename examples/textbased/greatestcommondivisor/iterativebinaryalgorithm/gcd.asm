; Name: greatestcommondivisor
;
; Description: calculates the gcd of two positive numbers in rdi and rsi.
;              result is returned in rax. The algorithm is found at
;              https://en.wikipedia.org/wiki/Binary_GCD_algorithm.
;
; Build: nasm -elf64 greatestcommondivisor.asm

global GreatestCommonDivisor

bits 64

section .text

GreatestCommonDivisor:
    push    rbx
    mov     rax,rdi                 ;rax=u
    mov     rbx,rsi                 ;rbx=v
    ;make rdi and rsi positive if not
    and     rax,rax
    jns     .uispositive
    neg     rax
.uispositive:
    and     rbx,rbx
    jns     .vispositive
    neg     rbx
.vispositive:
    ;gcd(0,v)=v, gcd(u,0)=u,gcd(0,0)=0
    ;if v==0 return u
    and     rbx,rbx
    jz      .returnu
    ;if u==0 return v
    and     rax,rax
    jz      .returnv
    ;save used registers except rax = result
    ;remember rbx is already saved on stack
    push    rcx
    push    rdx
    push    r8
    push    r9
    ;initialize registers
    mov     r8,rax                  ;save u
    mov     r9,rbx                  ;save v
    xor     rcx,rcx                 ;shift=0
    mov     rdx,1                   ;help register containing 1
    ;left shift := lg k, where k is greatest power of 2 dividing both u and v
.l1:
    ;for(shift=0;((u|v)&1)==0;shift++)
    mov     rax,r8                  ;rax=u
    mov     rbx,r9                  ;rbx=v
    or      rax,rbx                 ;u | v
    and     rax,rdx                 ;(u | v) & 1
    jnz     .l2                     ;(u | v) & 1 == 0 ?
    shr     r8,1                    ;yes, right shift u
    shr     r9,1                    ;     right shift v
    inc     rcx                     ;increment shift
    jmp     .l1

.l2:
    ;while (u & 1) == 0
    mov     rax,r8                  ;rax=u
    and     rax,rdx                 ;u & 1
    jnz     .l3                     ; (u & 1) == 0
    shr     r8,1                    ; yes, right shift u
    jmp     .l2
.l3:
    ;u is always odd
    ;remove all factors of two in v
    ;while ((v & 1) == 0)
    mov     rax,r9                  ;rax=v
    and     rax,rdx                 ;v & 1
    jnz     .l4                     ;(v & 1) == 0
    shr     r9,1                    ;yes right shift r9
    jmp     .l3
.l4:
    ;u and v are odd, swap if necessary so u <= u
    mov     rax,r8                  ;rax=u
    mov     rbx,r9                  ;rbx=v
    cmp     rax,rbx                 ;u <= v
    jle     .l5                     ;yes, skip swapping
    xor     rax,rbx                 ;swap u and v
    xor     rbx,rax
    xor     rax,rbx
.l5:
    ;v = v - u
    sub     rbx,rax
    mov     r8,rax                  ;store values
    mov     r9,rbx
    and     rbx,rbx                 ;v != 0
    jnz     .l3
    ;gcd = u << shift
    mov     rax,r8
    shl     rax,cl                  ;return gcd
    pop     r9
    pop     r8
    pop     rdx
    pop     rcx
    pop     rbx
    ret
.returnv:
    mov     rax,rbx
.returnu:
    pop     rbx
    ret
