; Name:     callingconvention2.asm
;
; Remark:   G++ also has non-volatile registers, so this example is converted too.
;           In fact I expanded it with useless but interesting issues on stack-
;           operations.  Keep in mind that this program is to illustrate how
;           to deal with stacks.
;
; Source:   Modern x86 Assembly Language Programming p.528

bits 64
global Cc2_
section .text

; extern "C" void Cc2_(const Int64* a, const Int64* b, Int32 n, Int64* sum_a, Int64* sum_b, Int64* prod_a, Int64* prod_b);
;
; Description:  The following function illustrates how to initialize and
;               use a stack frame pointer.  It also demonstrates use
;               of several non-volatile general purpose registers.

; Named expressions for constant values.
;
; NUM_PUSHREG   = number of prolog non-volatile register pushes
; STK_LOCAL1    = size in bytes of STK_LOCAL1 area
; STK_LOCAL2    = size in bytes of STK_LOCAL2 area
; STK_PAD       = extra bytes (0 or 8) needed to 16-byte align RSP
; STK_TOTAL     = total size in bytes of local stack
; RBP_RA        = number of bytes between RBP and ret addr on stack
; LOCAL1        = start LocalVars1 space on stack
; LOCAL2        = start LocalVars2 space on stack
; ARGS          = start arguments space on stack

NUM_PUSHREG: equ 6
;space for LocalVar1A, LocalVar1B, LocalVar1C and LocalVar1D, 64 bits
STK_LOCAL1:  equ 4
;space for arguments on stack, 64 bits
STK_ARG:     equ 7
;space for LocalVar2A/B and LocalVar2C/D, 128 bits
STK_LOCAL2:  equ 2
STK_PAD:     equ ((NUM_PUSHREG + STK_ARG + STK_LOCAL1 + STK_LOCAL2*2) & 1) ^ 1
STK_TOTAL:   equ (STK_LOCAL1 + STK_LOCAL2*2 + STK_ARG + STK_PAD) * 8
RBP_RA:      equ (NUM_PUSHREG + STK_LOCAL1 + STK_ARG + STK_PAD) * 8
;start LocalVars2
%define LOCAL2 rbp-STK_LOCAL2*2*8
;start LocalVars1
%define LOCAL1 rbp
;start Arguments
%define ARGS   rbp+STK_LOCAL1*8

Cc2_:
    ; Registers: rdi    a
    ;            rsi    b
    ;            rdx    n
    ;            rcx    sum_a
    ;            r8     sum_b
    ;            r9     prod_a
    ;            stack  prod_b
    ; Save non-volatile registers on the stack
    ; in GCC these are different from VC++
    push    rbp
    push    rbx
    push    r12
    push    r13
    push    r14
    push    r15
    ; Allocate local stack space and set frame pointer
    sub     rsp,STK_TOTAL                   ;allocate local stack space
    lea     rbp,[rsp+STK_LOCAL2*2*8]        ;set frame pointer
    ; Initialize local variables on the stack (demonstration only)
    ; 128 bit values
    pxor    xmm5,xmm5
    movdqa  [LOCAL2],xmm5                   ;save xmm5 to LocalVar2A/2B
    movdqa  [LOCAL2+16],xmm5                ;save xmm5 to LocalVar2C/2D
    ; 64 bit values
    mov     qword[LOCAL1],0aah              ;save 0xaa to LocalVar1A
    mov     qword[LOCAL1+8],0bbh            ;save 0xbb to LocalVar1B
    mov     qword[LOCAL1+16],0cch           ;save 0xcc to LocalVar1C
    mov     qword[LOCAL1+24],0ddh           ;save 0xdd to LocalVar1D
    ; Save argument values, just to do crazy things
    mov     qword[ARGS],rdi                 ;a
    mov     qword[ARGS+8],rsi               ;b
    movsx   rdx,edx
    mov     qword[ARGS+16],rdx              ;n
    mov     qword[ARGS+24],rcx              ;sum_a
    mov     qword[ARGS+32],r8               ;sum_b
    mov     qword[ARGS+40],r9               ;prod_a
    mov     rax,[rbp+RBP_RA+8]
    mov     qword[ARGS+48],rax              ;prod_b
    ; Perform required initializations for processing loop
    test    edx,edx                         ;is n <= 0?
    jle .error                              ;jump if n <= 0
    ;Initialize registers
    xor     rbx,rbx                         ;rbx = current element offset
    xor     r10,r10                         ;r10 = sum_a
    xor     r11,r11                         ;r11 = sum_b
    mov     r12,1                           ;r12 = prod_a
    mov     r13,1                           ;r13 = prod_b
    ; Compute the array sums and products
.l1:
    mov     rax,[rdi+rbx]                   ;rax = a[i]
    add     r10,rax                         ;update sum_a
    imul    r12,rax                         ;update prod_a
    mov     rax,[rsi+rbx]                   ;rax = b[i]
    add     r11,rax                         ;update sum_b
    imul    r13,rax                         ;update prod_b
    add     rbx,8                           ;set ebx to next element
    dec     edx                             ;adjust count
    jnz     .l1                             ;repeat until done
    ;more crazy stuff
    mov     qword[ARGS+24],r10              ;sum_a
    mov     qword[ARGS+32],r11              ;sum_b
    mov     qword[ARGS+40],r12              ;prod_a
    mov     qword[ARGS+48],r13              ;prod_b
    ; Save the final results
    mov     rax,qword[ARGS+24]
    mov     [rcx],rax                       ;sum_a
    mov     rax,qword[ARGS+32]
    mov     [r8],rax                        ;sum_b
    mov     rax,qword[ARGS+40]              ;prod_a
    mov     [r9],rax
    mov     rax,qword[rbp+RBP_RA+8]
    mov     rbx,qword[ARGS+48]
    mov     [rax],rbx                       ;prod_b
    mov     eax,1                           ;set return code to true
.done:
    ; Function epilog
    lea     rsp,[rbp+(STK_LOCAL1+STK_ARG+STK_PAD)*8]    ;restore rsp
    pop     r15
    pop     r14
    pop     r13                             ;restore NV registers
    pop     r12
    pop     rbx
    pop     rbp
    ret
.error:
    xor     eax,eax                         ;set return code to false
    jmp     .done
