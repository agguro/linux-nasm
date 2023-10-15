; Name:     callingconvention1_.asm
;
; Source:   Modern x86 Assembly Language Programming p.524
;
; extern "C" Int64 Cc1_(Int8 a, Int16 b, Int32 c, Int64 d, Int8 e, Int16 f, Int32 g, Int64 h);

global Cc1_

bits 64
;we don't have to make position independent code, because we don't have a .data section
;but we can need it in the future, therefor this example

%include "got.inc"

section .text

%define RETURNADDR  8       ; size of return address on the stack
%define REG_GOT     7*8		; size of registers pushed on stack in prologue

PROCEDURE Cc1_
	;stack :
	;stack : value of h					[rsp+72]
	;stack : value of g					[rsp+64]
	;stack : return address to main		[rsp+56]
	;stack : r12 .GOT					[rsp+48]
	;stack : r13 .GOT					[rsp+40]
	;stack : r14 .GOT					[rsp+32]
	;stack : r15 .GOT					[rsp+24]
	;stack : rbx .GOT					[rsp+16]
	;stack : rbp .GOT					[rsp+8]
	;stack : rbx .GOT					[rsp]
	;registers:
	;dil = a, si = b, edx = c, rcx = d, r8b = e, r9w = f
	;we can make use of r10 and r11
	mov		r11,qword[rsp+RETURNADDR+REG_GOT+8]		;h in r11
	mov		r10,qword[rsp+RETURNADDR+REG_GOT]       ;g in r10
	movsx	r10,r10d								;sign extend r10
	;a is in rdi, b in rsi, c in rdx, d in rcx, e in r8 and f in r9
	movsx	r9,r9w
	movsx	r8,r8b
	movsx	rdx,edx
	movsx	rsi,si
	movsx	rdi,dil
	mov		rax,rdi
	add		rax,rsi
	add		rax,rdx
	add		rax,rcx
	add		rax,r8
	add		rax,r9
	add		rax,r10
	add		rax,r11
ENDP Cc1_
