;name: wordtoascii.asm
;
;description: branch free conversion of a WORD in DI to ASCII in AX
;             with use of BX and CX as help registers.
;
;build: nasm "-felf64" wordtoascii.asm -o wordtoascii.o
;	ld -s -melf_x86_64 wordtoascii.o -o wordtoascii  
;
;the algorithm: see wordtoascii.txt file

bits 64

%include "unistd.inc"

global _start

section .bss

section .data
    hexword:	dw  0x9C1F
    output:	db  "0x"
    buffer:	dd  0
    crlf:	db  10
    length:	equ $-output
        
section .text

_start:
    mov	    di,word[hexword]
    call    wordtoascii
    rol     ax,8
    rol     eax,16
    rol     ax,8
    mov	    dword[buffer],eax
    syscall write,stdout,output,length
    syscall exit,0
    
; in : DI has the WORD to convert
; out : EAX has the converted QWORD in ASCII
; RBX and RCX are destroyed
wordtoascii:
    mov	    ax,di
    ror	    rax,8
    rol	    ax,4
    shr	    al,4
    rol	    rax,16
    shr	    ax,4
    shr	    al,4
    mov	    ebx,0x06060606
    mov	    ecx,0xF0F0F0F0
    add	    eax,ebx
    and	    ecx,eax
    sub	    eax,ebx
    shr	    ecx,1
    sub	    eax,ecx
    shr	    ecx,3
    sub	    eax,ecx
    shr	    ebx,1
    add	    ebx,ecx
    shl	    ebx,4
    or	    eax,ebx
    ret
