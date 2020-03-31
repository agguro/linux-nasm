;name:         nibble2bcd.asm
;
;build:        nasm -felf64 nibble2bcd.asm -l nibble2bcd.lst -o nibble2bcd.o
;              ld -s -melf_x86_64 -o nibble2bcd nibble2bcd.o 
;
;description:  Branch free nibble to bcd convertion
;              The routine converts a nibble in bits 3..0 in RDI to
;              its bcd equivalent.  The reason for this routine is not to
;              convert a single nibble, for that a simple compare and add if bigger than 9
;              is enough and shorter and faster.  The raison why this routine
;              exists is to convert more nibbles simultainiously in e.g. xmm where 16 nibbles
;              can be converted at once.

bits 64
align 16

[list -]
     %include "unistd.inc"
[list +]

section .data
    
     msg:       db  "This program must be viewed in a debugger.", 10
     .length:   equ     $-msg
     
section .text
global _start
     
_start:
    ; remember to store the decimal as hexadecimal number
    mov       rdi,9
    call      nibble2bcd
    syscall   write, stdout, msg, msg.length
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
