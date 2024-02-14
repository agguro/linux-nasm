;name        : cc2.asm
;description : Calling convention demo
;source      : Modern X86 Assembly Language Programming 2nd Edition
;build       : mkdir build && cd build && qmake .. && make
;use         : extern "C" void Cc2_(const int64_t* a, const int64_t* b, int32_t n, int64_t* sum_a, int64_t* sum_b, int64_t* prod_a, int64_t* prod_b)
;              calculates : sum and product of all elements in array a and b respectively.
;note        : because of the different ABI for Linux this example is also different as the Windows equivalent.

bits 64

%define NUM_PUSHREGS 7

global Cc2_

section .text

Cc2_:
; in : rdi = a ptr
;      rsi = b ptr
;      edx = n
;      rcx = sum_a ptr
;      r8 = sum_b ptr
;      r9 = prod_a ptr
;      [rsp+8] = prod_b ptr
; out : sum_a = sum of all the elements of array a
;       sum_b = sum of all the elements of array b
;       prod_a = product of the all elements of array a
;       prod_b = product of the all elements of array b
;       rax = return code

%define PUSHREG 4

; Save non-volatile GP registers on the stack
    push    rbp
    push    rbx
    push    r12
    push    r13

; Perform required initializations for processing loop
    xor     rax,rax                     ;rc = 0 at start
    test    edx,edx                     ;is n <= 0?
    jle     Done                        ;jump if n <= 0

    xor     rbx,rbx                     ;rbx = current element offset
    xor     r10,r10                     ;r10 = sum_a
    xor     r11,r11                     ;r11 = sum_b
    mov     r12,1                       ;r12 = prod_a
    mov     r13,1                       ;r13 = prod_b

; Compute the array sums and products
.repeat:
    mov     rax,[rdi+rbx]               ;rax = a[i]
    add     r10,rax                     ;update sum_a
    imul    r12,rax                     ;update prod_a
    mov     rax,[rsi+rbx]               ;rax = b[i]
    add     r11,rax                     ;update sum_b
    imul    r13,rax                     ;update prod_b
    add     rbx,8                       ;set ebx to next element
    dec     edx                         ;adjust count
    jnz     .repeat                     ;repeat until done

; Save the final results
    mov     [rcx],r10                   ;save sum_a
    mov     [r8],r11                    ;save sum_b
    mov     [r9],r12                    ;save prod_a
    ;the displacement of 64 = 7 pushed registers + return address
    ;multiplied by 8 makes 64 bytes upwards the stack.
    mov     rax,[rsp+(PUSHREG+1)*8]     ;rax = ptr to prod_b
    mov     [rax],r13                   ;save sum_b
    mov     eax,1                       ;set return code to true

Done:
    ; Restore non-volatile registers to old their values
    pop     r13
    pop     r12
    pop     rbx
    pop     rbp
    ret
