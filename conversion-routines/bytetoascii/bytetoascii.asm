;name: bytetoascii.asm
;
;description:
;	branch free conversion of a byte in dil to ASCII in AX
;	with use of BX and CX as auxiliary registers.
;
;build: nasm "-felf64" bytetoascii.asm -o bytetoascii.o
;	ld -s -melf_x86_64 bytetoascii.o -o bytetoascii

bits 64

%include "unistd.inc"

global _start

section .bss

section .data
	hexbyte:	db  0x9C
	output:		db  "0x"
	buffer:		dw  0
	crlf:		db  10
	length:		equ $-output

section .text

_start:
	mov		dil,byte[hexbyte]
	call	bytetoascii
	ror		ax,8			;reverse byte order
	mov		word[buffer],ax
	syscall	write,stdout,output,length
	syscall	exit,0

; in :  DIL has the byte to convert
; out : AX  has the converted byte
; values of BX and CX are destroyed.
bytetoascii:
	mov	al,dil
	shl	ax,4		;high nibble in AH
	shr	al,4		;low nibble back in AL
	mov	bx,0x0606	;constant 0x0606 in BX
	mov	cx,0xF0F0	;mask in CX
	add	ax,bx   	;AH=AH+6, AL=AL+6
	and	cx,ax		;get high nibbles from AH and AL in CX
	sub	ax,bx		;subtract 0x0606 from AH and AL
	shr	cx,1		;shift right CX once, gives 0 or 0x0808 in CX
	sub	ax,cx		;subtract CX from AX
	shr	cx,3		;shift right CX three times,, gives 0 or 0x0101 in CX
	sub	ax,cx		;subtract CX from AX
	shr	bx,1		;adjust BX, gives 0x0303
	add	bx,cx		;add CX to BX, gives 0x0303 or 0x0404
	shl	bx,4		;move bits in right position, gives 0x3030 or 0x4040
	or	ax,bx		;make AX ASCII
	ret
