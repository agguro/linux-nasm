;name:
;	nibbletoascii.asm
;
;description:
;	branch free conversion of a nible to ASCII using a single register
;	in this case ax.
;
;build:
;	nasm -felf64 nibbletoascii.asm -o nibbletoascii.o
;	ld -s -melf_x86_64 nibbletoascii.o -o nibbletoascii
;
;the algorithm:
;						ah			al
; ax:				0000 0000   0000 1111
; shl ax,4			0000 0000	1111 0000
;					0000 0000	0110 0000
; add ax,0x0060		0000 0001	0101 0000
; shr al,4			0000 0001	0000 0101
;					0000 0000	0000 0110
; sub al,6			0000 0001	1111 1111
;					0000 0001	0000 1111
; and al,0x0F		0000 0001	0000 1111
; sub al,ah			0000 0001	0000 1110
; shl ah,3			0000 1000	0000 1110
; sub al,ah			0000 1000	0000 0110
;					0001 1000
; add ah,0x18		0010 0000	0000 0110
; shl ah,1			0100 0000	0000 0110
; or al,ah			0100 0000	0100 0110
; and ax,0x00FF		0000 0000	0100 0110


bits 64

%include "unistd.inc"

global _start

section .bss
    
section .data
	hexnibble:	db  0xC
	output:		db  "0x0"
	buffer:		db  0
	crlf:		db  10
	length:		equ $-output
    
section .text

_start:
	mov		dil,byte[hexnibble]
	call	nibbletoascii
	mov		byte[buffer],al
	syscall	write,stdout,output,length
	syscall	exit,0
    
; in : DIL has the nibble to convert
; out : AL has the converted nibble
nibbletoascii:
	mov		al,dil
	and		al,0x0F		;only lower 4 bits counts
	shl		ax,4		;shift to most significant positions
	add		ax,0x0060	;add 0110 to nibble
	shr		al,4		;move back to least significant positions
	sub		al,6		;subtract 6 from nibble
	and		al,0x0F		;mask bits 7 to 4
	sub		al,ah		;subtract AH from AL
	shl		ah,3		;multiplicate AH by 8
	sub		al,ah		;subtract AH from AL
	add		ah,0x18		;add 2 to bits in AH
	shl		ah,1		;multiply AH by two
	or		al,ah		;make AL ASCII
	xor		ah,ah		;zero out bits from AH
	ret
