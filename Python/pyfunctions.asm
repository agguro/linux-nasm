;name: pyfunctions.asm
;
;build: release version:
;           nasm -felf64 -o pyfunctions.o pyfunctions.asm
;           ld -lc --dynamic-linker /lib64/ld-linux-x86-64.so.2 -shared -soname pyfunctions.so -o pyfunctions.so.1.0 pyfunctions.o -R .
;           ln -sf pyfunctions.so.1.0 pyfunctions.so
;       debug/development version
;           nasm -felf64 -Fdwarf -g -o sharedlib-dev.o sharedlib.asm
;           ld -lc --dynamic-linker /lib64/ld-linux-x86-64.so.2 -shared -soname sharedlib-dev.so -o sharedlib-dev.so.1.0 sharedlib-dev.o -R .
;           ln -sf sharedlib-dev.so.1.0 sharedlib-dev.so
;
;description: A simple shared library to use with python

bits 64

extern  _GLOBAL_OFFSET_TABLE_

;global functions
global  square:function

section .data
       
    
section .rodata

section .text
_start:
    
;a global function to get the version number returned in rax
square:
    push    rbp
    mov     rbp,rsp 
    push    rbx 
    call    .get_GOT 
.get_GOT: 
    pop     rbx 
    add     rbx,_GLOBAL_OFFSET_TABLE_+$$-.get_GOT wrt ..gotpc 
    ;two ways to get the external vaiable
    ;first if it's stored in the datasegment, but this is a long approach
    mov     rax,rdi
    mul     rdi
    mov     rbx,[rbp-8] 
    mov     rsp,rbp 
    pop     rbp 
    ret
