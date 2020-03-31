;name:         bcd2ascii.asm
;
;build:        nasm -felf64 bcd2ascii.asm -l bcd2ascii.lst -o bcd2ascii.o
;              ld -s -melf_x86_64 -o bcd2ascii bcd2ascii.o 
;
;description:
;

bits 64

[list -]
     %include "unistd.inc"
[list +]

section .bss
	buffer:	resb	32
	
section .data
    
     msg:       db  "This program must be viewed in a debugger.", 10
     .length:   equ     $-msg
     
section .text
global _start

_start:
    ; remember to store the decimal as hexadecimal number
    mov       rdi,0x1111222233334444
    mov		  rsi,buffer
    call      bcd2ascii
    syscall   write,stdout,msg,msg.length
    syscall   exit,0

bcd2ascii:
	mov		rdx,rdi
	mov		cl,32
	mov		eax,edx
	shr		rdx,cl
	mov		r8,rdx
	mov		r9,rax
	shr		cl,1
	ror		r8,cl
	ror		r9,cl
	rol		edx,cl
	rol		eax,cl
	rol		rdx,cl
	rol		rax,cl
	or		rdx,r8
	or		rax,r9
	shl		cl,1
	rol		rdx,cl
	rol		rax,cl
	mov 	rcx,0x0F0F0F0F0F0F0F0F
	and		rdx,rcx
	and		rax,rcx
	mov		rcx,0x3030303030303030
	or		rdx,rcx
	or		rax,rcx
	;return result in rdx:rax
	ret
