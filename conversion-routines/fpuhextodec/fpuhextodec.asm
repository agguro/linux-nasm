;name: fpuhextodec.asm
;
;description:
;	conversion from hexadecimal to decimal using the FPU.
;	Shows the minimum and the maximum hexadecimal and equivalent
;	binary coded decimal useable in a fpu.
;
;build:
;	nasm -felf64 fpuhextodec.asm
;	ld -s -melf_x86_64 -o fpuhextodec fpuhextodec.o

bits 64

%include "unistd.inc"
%define EOF		10
%define PLUS	"+"
%define MINUS	"-"

global _start

section .bss
    decbuffer:	rest 	1
    
section .data

	hexadecimal:
		.min:	dq	0xF21F494C589C0001		;-999999999999999999
		.max:	dq  0x0DE0B6B3A763FFFF		;+999999999999999999
	output:
					db	"0x"
		.hexmin:	times 16 db 0
					db	" = "
		.decmin:	times 19 db 0
					db	EOF
					db	"0x"
		.hexmax:	times 16 db 0
					db	" = "
		.decmax:	times 19 db 0
					db	EOF
		.length:	equ	$-output

section .text

_start:
	mov 	rdi,[hexadecimal.min]
	call 	reversenibs
	mov 	rdi,rax
	mov		rsi,output.hexmin
	call 	hex2ascii

    fild    qword[hexadecimal.min]
    fbstp   tword[decbuffer]
	mov		rdi,decbuffer
	mov 	rsi,output.decmin
	call 	bcd2ascii
	
	mov 	rdi,[hexadecimal.max]
	call 	reversenibs
	mov 	rdi,rax
	mov		rsi,output.hexmax
	call 	hex2ascii

	fild    qword[hexadecimal.max]
    fbstp   tword[decbuffer]
	mov		rdi,decbuffer
	mov 	rsi,output.decmax
	call 	bcd2ascii
    mov		rdi,output.decmin

    call 	print
	
	syscall exit,0

bcd2ascii:
	mov		al,byte[rdi+9]		;get sign byte
	cmp		al,0x80
	je		.isnegative
	mov 	byte[rsi],PLUS
	jmp 	.getdecimals
.isnegative:
	mov 	byte[rsi],MINUS
.getdecimals:
	xor		ecx,ecx
	mov 	cl,byte[rdi+8]
	;convert bcd in cl
	shl		cx,4
	shr		cl,4
	or		cx,0x3030
	rol		cx,8
	mov		word[rsi+1],cx
	xor		ecx,ecx
	mov		cl,byte[rdi+7]
	shl		cx,4
	shr		cl,4
	or		cx,0x3030
	rol		cx,8
	mov		word[rsi+3],cx
	xor		ecx,ecx
	mov		cl,byte[rdi+6]
	shl		cx,4
	shr		cl,4
	or		cx,0x3030
	rol		cx,8
	mov		word[rsi+5],cx
	xor		ecx,ecx
	mov		cl,byte[rdi+5]
	shl		cx,4
	shr		cl,4
	or		cx,0x3030
	rol		cx,8
	mov		word[rsi+7],cx
	xor		ecx,ecx
	mov		cl,byte[rdi+4]
	shl		cx,4
	shr		cl,4
	or		cx,0x3030
	rol		cx,8
	mov		word[rsi+9],cx
	xor		ecx,ecx
	mov		cl,byte[rdi+3]
	shl		cx,4
	shr		cl,4
	or		cx,0x3030
	rol		cx,8
	mov		word[rsi+11],cx
	xor		ecx,ecx
	mov		cl,byte[rdi+2]
	shl		cx,4
	shr		cl,4
	or		cx,0x3030
	rol		cx,8
	mov		word[rsi+13],cx
	xor		ecx,ecx
	mov		cl,byte[rdi+1]
	shl		cx,4
	shr		cl,4
	or		cx,0x3030
	rol		cx,8
	mov		word[rsi+15],cx
	xor		ecx,ecx
	mov		cl,byte[rdi]
	shl		cx,4
	shr		cl,4
	or		cx,0x3030
	rol		cx,8
	mov		word[rsi+17],cx
	ret

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
