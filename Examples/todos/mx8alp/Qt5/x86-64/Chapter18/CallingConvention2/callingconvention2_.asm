; Name:     callingconvention2_.asm
;
; Source:   Modern x86 Assembly Language Programming p.528
;           Without the crazy stuff

global Cc2_

bits 64

%include "got.inc"

section .text

; extern "C" void Cc2_(const Int64* a, const Int64* b, Int32 n, Int64* sum_a, Int64* sum_b, Int64* prod_a, Int64* prod_b);
;
; Description:  The following function illustrates how to initialize and
;               use a stack frame pointer.  It also demonstrates use
;               of several non-volatile general purpose registers.

PROCEDURE Cc2_
	;stack :
	;stack : prod_b						[rsp+64]
	;stack : return address to main		[rsp+56]
	;stack : r12 .GOT					[rsp+48]
	;stack : r13 .GOT					[rsp+40]
	;stack : r14 .GOT					[rsp+32]
	;stack : r15 .GOT					[rsp+24]
	;stack : rbx .GOT					[rsp+16]
	;stack : rbp .GOT					[rsp+8]
	;stack : rbx .GOT					[rsp]
	;registers:
	;rdi = a, rsi = b, edx = n, rcx = sum_a, r8 = sum_b, r9 = prod_a
	mov		r14,qword[rsp+64]			;memory address prod_b
    ; Perform required initializations for processing loop
    test    edx,edx                         ;is n <= 0?
	jg		.start                              ;jump if n > 0
	xor		rax,rax							;rax = false
	jmp		.done
.start:
	;Initialize registers, don't use rbx unless you save and restore it
	xor     r15,r15                         ;r15 = current element offset
    xor     r10,r10                         ;r10 = sum_a
    xor     r11,r11                         ;r11 = sum_b
    mov     r12,1                           ;r12 = prod_a
    mov     r13,1                           ;r13 = prod_b
    ; Compute the array sums and products
.repeat:
	mov     rax,[rdi+r15]                   ;rax = a[i]
    add     r10,rax                         ;update sum_a
    imul    r12,rax                         ;update prod_a
	mov     rax,[rsi+r15]                   ;rax = b[i]
    add     r11,rax                         ;update sum_b
    imul    r13,rax                         ;update prod_b
	add     r15,8                           ;set ebx to next element
    dec     edx                             ;adjust count
	jnz     .repeat                         ;repeat until done
	mov     [rcx],r10                       ;sum_a
	mov     [r8],r11                        ;sum_b
	mov     [r9],r12
	mov     [r14],r13                       ;prod_b
    mov     eax,1                           ;set return code to true
.done:
ENDP Cc2_
