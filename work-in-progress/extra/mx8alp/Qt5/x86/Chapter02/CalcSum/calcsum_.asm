; extern "C" int CalcSum_(int a, int b, int c);
;
; Description:  This function demonstrates passing arguments between
;               a C++ function and an assembly language function in
;               Linux with g++ and nasm, 32 bits
;
; Returns:      a + b + c

;bits 32
global CalcSum_

section .data
	tb: dw 15

section .text

%define a    [ebp+8]
%define b    [ebp+12]
%define c    [ebp+16]

CalcSum_:
    push    ebp
    mov	    ebp,esp
    mov	    edx,a
    mov	    eax,b
    add	    eax,edx
    mov	    edx,c
    add	    eax,edx
	add		eax,dword[tb]
    pop	    ebp
    ret
