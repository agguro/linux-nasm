;name:
;	nibbles.asm
;
;description:
;	Set of conversion routines applying to nibbles.
;
;build:
;	nasm -felf64 nibbles.asm -l nibbles.lst -o nibbles.o
;	ld -s -melf_x86_64 -o nibbles nibbles.o 

bits 64

[list -]
     %include "unistd.inc"
[list +]

section .data
        
section .text
global _start
     
_start:

	syscall   exit, 0

;*********************************************************************************************************
; nibble2bcd:	convert number in RDI to BCD in RAX
; in : binary number in DIL
; out : BCD equivalent in RAX
; Used registers must be saved by caller
;*********************************************************************************************************
nibble2bcd:
	xor		rax,rax
	mov		al,dil
.unpacked:	
	add		al,6
	shl		ax,4
	shr 	al,4
	not		ah
	and 	ah,1
	shl 	ah,1
	sub 	al,ah
	shl 	ah,1
	sub 	al,ah
	shr 	ah,2
	not 	ah
	and 	ah,1
	ret
