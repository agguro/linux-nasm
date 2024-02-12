; arguments1.asm
; the program in the bookis for Windows.  This one is modified for Linux

extern printf
section .data				
	first	db	"A",0					
	second	db	"B",0
	third	db	"C",0
	fourth	db	"D",0			
	fifth	db	"E",0
	sixth	db	"F",0
	seventh	db	"G",0
	eighth  db	"H",0
	ninth   db	"I",0
	tenth   db	"J",0
 	fmt	db	"The string is: %s%s%s%s%s%s%s%s%s%s",10,0
 	
section .bss										
section .text									
	global main						
main:

    push	rbp
    mov 	rbp,rsp
    sub     rsp,8               ;align stack
    
    mov rax,0
    mov rdi, fmt
    mov rsi, first
    mov rdx, second
    mov rcx, third
    mov r8, fourth
    mov r9, fifth
    
    push    tenth
    push    ninth
    push    eighth
    push    seventh
    push    sixth

    call    printf
    add     rsp,48              ;adjust stack 5 variables + alignment
         
;windowsstyle    
;	sub	rsp,8
;	mov rcx, fmt					
;	mov rdx, first	
;	mov r8, second
;	mov r9, third			
;	push tenth			; now start pushing in
;	push ninth			; reverse order
;	push eighth			
;	push seventh
;	push sixth
;	push fifth
;	push fourth
;	sub  rsp,32       	; shadow space
;	call printf
;	add	rsp,32+8	

    mov rsp,rbp
    pop rbp
ret
