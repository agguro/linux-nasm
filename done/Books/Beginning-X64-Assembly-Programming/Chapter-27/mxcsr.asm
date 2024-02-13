; mxcsr.asm
extern printf
extern print_mxcsr
extern print_hex
section .data							
	eleven	dq	11.0					
	two		dq	2.0
   	three 	dq  	3.0
 	ten 		dq  	10.0
   	zero    	dq  	0.0
	hex		db	"0x",0
	fmt1		db	10,"Divide, default mxcsr:",10,0
	fmt2		db	10,"Divide by zero, default mxcsr:",10,0
  	fmt4    	db  	10,"Divide, round up:",10,0
  	fmt5    	db 	10,"Divide, round down:",10,0
   	fmt6    	db  	10,"Divide, truncate:",10,0        						
	f_div	db	"%.1f divided by %.1f is %.16f, in hex: ",0
  	f_before 	db 	10,"mxcsr before:",9,0
   	f_after 	db 	"mxcsr after:",9,0

;mxcsr values
	default_mxcsr	dd 0001111110000000b
	round_nearest	dd 0001111110000000b
	round_down	dd 0011111110000000b
	round_up		dd 0101111110000000b
	truncate		dd 0111111110000000b

section .bss
        mxcsr_before 	resd      1
        mxcsr_after   	resd      1
        xmm 			resq 	1
section .text							
	global main					
main:

;    mov rbp, rsp; for correct debugging
push rbp
mov 	rbp,rsp

;division
;default mxcsr
	mov 	rdi,fmt1
	mov 	rsi,ten
	mov 	rdx,two
	mov 	ecx, [default_mxcsr]
	sub     rsp,8
	call apply_mxcsr
	add     rsp,8
;----------------------------------------------
;division with precision error
;default mxcsr
	mov 	rdi,fmt1
	mov 	rsi,ten
	mov 	rdx,three
	mov 	ecx, [default_mxcsr]
	sub     rsp,8
	call apply_mxcsr
	add     rsp,8
;divide by zero
;default mxcsr
	mov 	rdi,fmt2
	mov 	rsi,ten
	mov 	rdx,zero
	mov 	ecx, [default_mxcsr]
	sub     rsp,8
	call apply_mxcsr
	add     rsp,8
;division with precision error
;round up
	mov 	rdi,fmt4
	mov 	rsi,ten
	mov 	rdx,three
	mov 	ecx, [round_up]
	sub     rsp,8
	call apply_mxcsr
	add     rsp,8
;division with precision error
;round up
	mov 	rdi,fmt5
	mov 	rsi,ten
	mov 	rdx,three
	mov 	ecx, [round_down]
	sub     rsp,8
	call apply_mxcsr
	add     rsp,8
;division with precision error
;truncate
	mov 	rdi,fmt6
	mov 	rsi,ten
	mov 	rdx,three
	mov 	ecx, [truncate]
	sub     rsp,8
	call apply_mxcsr
	add     rsp,8
;----------------------------------------------
;division with precision error
;default mxcsr
	mov 	rdi,fmt1
	mov 	rsi,eleven
	mov 	rdx,three
	mov 	ecx, [default_mxcsr]
	sub     rsp,8
	call apply_mxcsr
	add     rsp,8
;division with precision error
;round up
	mov 	rdi,fmt4
	mov 	rsi,eleven
	mov 	rdx,three
	mov 	ecx, [round_up]
	sub     rsp,8
	call apply_mxcsr
	add     rsp,8
;division with precision error
;round up
	mov 	rdi,fmt5
	mov 	rsi,eleven
	mov 	rdx,three
	mov 	ecx, [round_down]
	sub     rsp,8
	call apply_mxcsr
	add     rsp,8
;division with precision error
;truncate
	mov 	rdi,fmt6
	mov 	rsi,eleven
	mov 	rdx,three
	mov 	ecx, [truncate]
	sub     rsp,8
	call apply_mxcsr
	add     rsp,8
leave
ret                                                                                                                         

;function ------------------------------------------------------------    
apply_mxcsr:   
push	rbp
mov 	rbp,rsp
        sub     rsp,8
    	push rsi
    	push	rdx
    	push	rcx
    	push	rbp            ; one more for stack alignment

	call	printf
    	pop 	rbp
    	pop 	rcx
    	pop 	rdx
    	pop 	rsi
    	add     rsp,8

	mov 		[mxcsr_before],ecx
    	ldmxcsr 	[mxcsr_before]
    	movsd 	xmm2, [rsi]	; double precision float into xmm2
    	divsd 	xmm2, [rdx]	; divide xmm2 
    	stmxcsr 	[mxcsr_after] 	; save mxcsr to memory
    	movsd 	[xmm],xmm2  	; for use in print_xmm
    	mov 		rdi,f_div
    	movsd	xmm0, [rsi]
    	movsd 	xmm1, [rdx]
    	
        sub     rsp,8
    	call 	printf
    	add     rsp,8

        sub     rsp,8    	
    	call 	print_xmm
    	add     rsp,8
    	
;print mxcsr
	mov 		rdi,f_before
        sub     rsp,8
    	call 	printf
    	add     rsp,8
	mov 		rdi, [mxcsr_before]
        sub     rsp,8
	call 	print_mxcsr
	    	add     rsp,8
	mov 		rdi,f_after
        sub     rsp,8
    	call 	printf
    	add     rsp,8
	mov 		rdi, [mxcsr_after]
	sub     rsp,8
	call		print_mxcsr
	add     rsp,8
leave
ret
;function ------------------------------------------------------------    
print_xmm:
push rbp
mov  rbp,rsp
	mov 	rdi, hex	;print 0x
	call printf
    	mov 	rcx,8
.loop:
    	xor 	rdi,rdi
    	mov 	dil,[xmm+rcx-1]
    	push rcx
    	call print_hex 
    	pop 	rcx
    	loop .loop   
leave
ret
