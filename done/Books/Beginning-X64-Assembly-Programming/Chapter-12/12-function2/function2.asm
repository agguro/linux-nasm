; function2.asm
extern printf
section .data							
	radius	dq	10.0								
section .bss							
section .text

area:
	section .data
		.pi	dq	3.141592654	; local to area
	section .text 
push rbp
mov rbp, rsp
		movsd xmm1, [radius]
		mulsd xmm1, [radius]
		mulsd xmm1, [.pi]
leave
ret

circum:
	section .data
		.pi	dq	3.14		; local to circum
	section .text
push rbp
mov rbp, rsp	
		movsd xmm1, [radius]
		addsd xmm1, [radius]
		mulsd xmm1, [.pi]
leave
ret

circle:
	section .data
		.fmt_area	db	"The area of a circle with radius %.2f is %.2f",10,0
		.fmt_circum	db	"The circumference of a circle with radius %.2f is %.2f",10,0
	section .text
push rbp
mov rbp, rsp		
		call area	
		mov	rdi,.fmt_area
		movsd xmm0,[radius]
		mov	rax,2			; area in xmm1
		call printf
		call circum
		movsd xmm0,[radius]
		mov	rdi,.fmt_circum
		mov	rax,2			; circumference in xmm1
		call printf
leave
ret
	global main						
main:
    mov rbp, rsp; for correct debugging
push rbp
mov rbp, rsp
	call circle
leave
ret
