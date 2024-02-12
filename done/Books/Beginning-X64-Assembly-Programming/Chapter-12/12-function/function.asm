; function.asm
extern printf
section .data							
	radius	dq	10.0				
	pi		dq	3.14				
	fmt		db	"The area of the circle with radius %.2f is %.2f",10,0
section .bss							
section .text												
	global main						
;----------------------------------------------
main:
push 	rbp
mov 	rbp, rsp 
	call surface			; call the function
	mov	rdi,fmt          	; print format
	movsd xmm0, [radius]	; move radius (float) to xmm0
	mov	rax,1				; surface in xmm0
	call printf
        leave
ret
;----------------------------------------------
surface:
push 	rbp
mov 	rbp, rsp  		
	movsd xmm1, [radius]	; move float to xmm1
	mulsd xmm1, [radius]	; multiply xmm0 by float
	mulsd xmm1, [pi]	 	; multiply xmm0 by float
leave
ret				
