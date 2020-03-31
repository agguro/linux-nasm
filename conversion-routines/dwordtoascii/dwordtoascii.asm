;name: dwordtoascii.asm
;
;description: branch free conversion of a DWORD in EDI to ASCII in RAX
;             use of RCX, RBX and RDX as help registers
;
;build: nasm "-felf64" dwordtoascii.asm -o dwordtoascii.o
;	ld -s -melf_x86_64 dwordtoascii.o -o dwordtoascii
;
;the algorithm: see dwordtoascii.txt file

bits 64

%include "unistd.inc"

global _start

section .bss

section .data
    ;dword to convert to ASCII
    hexdword:	dd  0xABCDEF01
    output:	db  "0x"
    buffer:	dq  0
    crlf:	db  10
    length:	equ $-output

section .text

_start:
    mov	    edi,dword[hexdword]
    call    dwordtoascii
    mov	    rdx,rax
    shr	    rdx,32
    rol     ax,8
    rol	    dx,8
    rol     eax,16
    rol	    edx,16
    rol     ax,8
    rol	    dx,8
    shl	    rax,32
    or	    rax,rdx
    mov	    qword[buffer],rax
    syscall write,stdout,output,length
    syscall exit,0

; in : EDI has the DWORD to convert
; out : RAX has the converted byte
; values of RBX, RCX and RDX are destroyed.
dwordtoascii:
    mov	    eax,edi
    mov	    edx,eax
    shl	    rdx,16
    or	    rax,rdx
    mov	    rcx,0x0000FFFF0000FFFF
    and	    rax,rcx
    mov	    rdx,rax
    shl	    rdx,8
    or	    rax,rdx
    mov	    rcx,0x00FF00FF00FF00FF
    and	    rax,rcx
    mov	    rdx,rax
    shl	    rdx,4
    or	    rax,rdx
    mov	    rcx,0x0F0F0F0F0F0F0F0F
    and	    rax,rcx
    mov	    rbx,0x0606060606060606
    shl	    rcx,4
    add	    rax,rbx
    and	    rcx,rax
    sub	    rax,rbx
    shr	    rcx,1
    sub	    rax,rcx
    shr	    rcx,3
    sub	    rax,rcx
    shr	    rbx,1
    add	    rbx,rcx
    shl	    rbx,4
    or	    rax,rbx
    ret
