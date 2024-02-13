;name        : integeraddsub.asm
;description : Calculate a + b + c - d
;source      : Modern X86 Assembly Language Programming 2nd Edition
;build       : mkdir build && cd build && qmake .. && make
;use         : extern "C" int IntegerAddSub_(int a, int b, int c, int d);

bits 64

global IntegerAddSub_

section .text

IntegerAddSub_:

; Calculate a + b + c - d
    mov     eax,edi         ;eax = a
    add     eax,esi         ;eax = a + b
    add     eax,edx         ;eax = a + b + c
    sub     eax,ecx         ;eax = a + b + c - d
    ret                     ;return result to caller
