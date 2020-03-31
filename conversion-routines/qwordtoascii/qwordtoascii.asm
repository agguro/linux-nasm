;name: qwordtoascii.asm
;
;description: branch free conversion of QWORD in RAX to ASCII in XMM0
;             use of R8, R9, RCX, RDX, XMM1 and XMM2
;             requires SSE
;
;build: nasm "-felf64" qwordtoascii.asm -o qwordtoascii.o
;	ld -s -melf_x86_64 qwordtoascii.o -o qwordtoascii  

bits 64

%include "unistd.inc"

global _start

section .bss

section .data
    ;dword to convert to ASCII    
    hexqword:	dq  0x0123456789ABCDEF
    output:	db  "0x"
    buffer:	dq  0,0
    crlf:	db  10
    length:	equ $-output
    
section .text

_start:
    ;qword to ascii conversion, requires SSE
    mov     rdi,qword[hexqword]
    call    qwordtoascii
    mov     rsi,buffer
    movdqu  [buffer],xmm0
    mov	    rax,qword[buffer]
    mov	    rdx,rax
    shr	    rdx,32
    rol     ax,8
    rol	    dx,8
    rol     eax,16
    rol	    edx,16
    rol     ax,8
    rol	    dx,8
    shl	    rax,32
    or	    rdx,rax
    mov	    rax,qword[buffer+8]
    mov	    qword[buffer+8],rdx
    mov	    rdx,rax
    shr	    rdx,32
    rol     ax,8
    rol	    dx,8
    rol     eax,16
    rol	    edx,16
    rol     ax,8
    rol	    dx,8
    shl	    rax,32
    or	    rdx,rax
    mov	    qword[buffer],rdx
    syscall write,stdout,output,length
    syscall exit,0

; in : RDI has the QWORD to convert
; out : XMM0 has the converted QWORD in ASCII
; R8, R9, RCX, RDX, XMM1 and XMM2 are destroyed
qwordtoascii:
    mov	    rax,rdi
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
    movq    xmm0,rdx
    pinsrq  xmm0,rax,0x01
    shl	    rcx,4
    movq    xmm1,rcx
    pinsrq  xmm1,rcx,0x01
    mov	    rax,0x0606060606060606
    movq    xmm2,rax
    pinsrq  xmm2,rax,0x01
    paddb   xmm0,xmm2
    pand    xmm1,xmm0
    psubb   xmm0,xmm2
    psrlw   xmm1,1
    psubb   xmm0,xmm1
    psrlw   xmm1,3
    psubb   xmm0,xmm1
    psrlw   xmm2,1
    paddb   xmm1,xmm2
    psllw   xmm1,4
    paddb   xmm0,xmm1
    ret
