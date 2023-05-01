;project:		smartschool.asm
;name:		dwordbin2hexascii.asm
;date:		17 aug 2020
;
;description:	converts a 32 bit binary (or hexadecimal) in hexadecimal ascii in rax
;
;to do:		64 bit convertion

bits 64

global dwordbin2hexascii

section .text

dwordbin2hexascii:

	push		rbx
	push		rcx
	push		rdx
	mov		eax,edi
	mov		edx,edi
	shl		rdx,16
	or		rax,rdx
	mov		rcx,0x0000FFFF0000FFFF
	and		rax,rcx
	mov		rdx,rax
	shl		rdx,8
	or		rax,rdx
	mov		rcx,0x00FF00FF00FF00FF
	and		rax,rcx
	mov		rdx,rax
	shl		rdx,4
	or		rax,rdx
	mov		rcx,0x0F0F0F0F0F0F0F0F
	and		rax,rcx
	mov		rbx,0x0606060606060606
	shl		rcx,4
	add		rax,rbx
	and		rcx,rax
	sub		rax,rbx
	shr		rcx,1
	sub		rax,rcx
	shr		rcx,3
	sub		rax,rcx
	shr		rbx,1
	add		rbx,rcx
	shl		rbx,4
	or		rax,rbx
	pop		rdx
	pop		rcx
	pop		rbx
	ret