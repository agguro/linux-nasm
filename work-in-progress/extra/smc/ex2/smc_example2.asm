;name: smc_example2.asm
;
;build: 
;
;source: https://stackoverflow.com/questions/4812869/how-to-write-self-modifying-code-in-x86-assembly
;        [CasseroleBoi]

bits 64

%include "unistd.inc"
%include "asm-generic/mman.inc"

section .bss

align 4096  ; page size on my machine. You can automate this process using
            ; libc's getpagesize() to make it bit more portable, but hey!,
            ; this is a minimum viable product!

exec: resb 4096




section .text

    mprotectsuccess: db "mprotect output value 0", 0x0A
    .len:   equ $-mprotectsuccess

    mprotectfailure: db "mprotect failure, segfault", 0x0A
    .len:   equ $-mprotectfailure

    message:	db "copied code executed!", 0x0A
    .len:	equ	$-message
    
global _start

_start:


    syscall mprotect,exec,4096,PROT_EXEC | PROT_READ | PROT_WRITE
    and rax, rax
    jz  .success
.failure:
    syscall write, stdout,mprotectfailure,mprotectfailure.len
    jmp .continue                   ;run into trouble
.success:
    syscall write, stdout,mprotectsuccess,mprotectsuccess.len
.continue:

    mov  r15, back

    ;copy code into section .bss   
    mov	rsi,code
    mov	rdi,exec
    mov rcx,code.len
    rep movsb

    mov rax, exec
    jmp rax
    
back:   
    syscall exit,0

    
code:
	syscall write,stdout,message,message.len
	jmp r15
.len: equ $-code	
