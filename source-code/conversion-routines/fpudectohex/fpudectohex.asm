;name:	fpudectohex.asm
;
;description:
;		Convert the inimum and maximum BCD value to hexadecimal.
;routines:
;		_start:			program start
;		hex2ascii:		branch free conversion of a 64 bit hexadecimal value in ASCII
;		print:			syscall write to show the output to stdout
;		swapNibbles:	reverts the order of the nibbles of a 64 bit hexadecimal value
;build:
;		nasm -felf64 fpudectohex.asm
;		ld -s -melf_x86_64 -o fpudectohex fpudectohex.o
;output:
;		-999999999999999999 = 0xF21F494C589C0001
;		 999999999999999999 = 0x0DE0B6B3A763FFFF

bits 64

%include "unistd.inc"
%define	 	EOL		10
%define		PLUS	"+"

global _start

section .bss
	;64 bit buffer to store the hexadecimal result
	hexbuffer:	resq	16

section .data
    decimal:
		;maximum positive BCD value that can be used
		;this value is 999999999999999999 and is stored in reversed order
		;least significant byte in lower memory address prefixed by the
		;sign byte either 0x00 for positive values or 0x80 for negative values.
		.value:	db  0x99,0x99,0x99,0x99,0x99,0x99,0x99,0x99,0x99
		;sign byte 0x00 = positive, 0x80 = negative
		.sign:	db	0x80

	output:		db	"-999999999999999999 = 0x"
		.hex:	times 16 db	'0'
				db	EOL
	.length:	equ	$-output
	
section .text
_start:
	xor		r15b,r15b			;lower flag in r15b
	jmp 	.convert			;convert bcd to hexadecimal
.repeat:
	inc 	r15b				;set flag
	;change sign of bcd value in .data section and in the output
	xor		al,al
	mov		byte[decimal.sign],al
	mov 	byte[output],PLUS
.convert:
	;read minimum bcd value in fpu register
	fbld    tword[decimal]
	;store bcd value back in the temporarly buffer
	fistp   qword[hexbuffer]
	;get the value in rdi
	mov		rdi,[hexbuffer]
	;reverse the order of the nibbles of rdi
	call	reversenibs
	;convert hexadecimal into ASCII, the result is
	;a 128 bit value stored in output.hex
	mov 	rdi,rax
	mov 	rsi,output.hex
	call	hex2ascii
	;show the output in stdout
	call	print
	;test if flag is set
	test 	r15b,r15b
	;if not set then we process the max value...
	jz		.repeat
	;else then both min and max are processed and exit	
	syscall exit,0
    
hex2ascii:
	;the routine converts a 64 bit hexadecimal value in rdi to
	;a 128 bit ASCII in rax:rdx and stores the string in the buffer
	;pointed to by rsi.
	;Instead of looping through the value in rdi and processing each nibble
	;this routine does the convertion branch free using rcx as the mask
	;register and r8,r9 as auxiliary registers. Only rdi and rsi are preserved.
	mov		rax,rdi
	mov	    edx,eax
    shr	    rax,32    
    mov	    r8,rax
    mov	    r9,rdx
    shl	    r8,16
    shl	    r9,16
    or	    rax,r8
    or	    rdx,r9
    mov	    rcx,0x0000FFFF0000FFFF
    and	    rax,rcx
    and	    rdx,rcx
    mov	    r8,rax
    mov	    r9,rdx
    shl	    r8,8
    shl	    r9,8
    or	    rax,r8
    or	    rdx,r9
    mov	    rcx,0x00FF00FF00FF00FF
    and	    rax,rcx
    and	    rdx,rcx
    mov	    r8,rax
    mov	    r9,rdx
    shl	    r8,4
    shl	    r9,4
    or	    rax,r8
    or	    rdx,r9
    mov	    rcx,0x0F0F0F0F0F0F0F0F
    and	    rax,rcx
    and	    rdx,rcx
	mov		rbx,0x0606060606060606
	mov 	r8,rbx
	mov		rcx,0xF0F0F0F0F0F0F0F0
	mov 	r9,rcx
	add 	rax,rbx
	add 	rdx,r8
	and 	rcx,rax
	and 	r9,rdx
	sub 	rax,rbx
	sub 	rdx,r8
	shr 	rcx,1
	shr 	r9,1
	sub 	rax,rcx
	sub 	rdx,r9
	shr 	rcx,3
	shr 	r9,3
	sub 	rax,rcx
	sub 	rdx,r9
	shr 	rbx,1
	shr 	r8,1
	add 	rbx,rcx
	add		r8,r9
	shl 	rbx,4
	shl 	r8,4
	or 		rax,rbx
	or		rdx,r8
	mov 	qword[rsi+8],rax
	mov 	qword[rsi],rdx
	ret
	
print:
	syscall	write,stdout,output,output.length
	ret

reversenibs:
	mov		rax,rdi
	mov 	edx,eax
	shr 	rax,32
	rol		al,4
	rol 	dl,4
	rol		ah,4
	rol		dh,4
	xchg	al,ah
	xchg	dl,dh
	rol 	eax,16
	rol 	edx,16
	rol		al,4
	rol		dl,4
	rol		ah,4
	rol		dh,4
	xchg	al,ah
	xchg	dl,dh
	rol 	rdx,32
	or 		rax,rdx
	ret
