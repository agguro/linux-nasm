;name        : integerlogical.asm
;description : Calculate (((a & b) | c ) ^ d) + g_Val1
;source      : Modern X86 Assembly Language Programming 2nd Edition
;build       : mkdir build && cd build && qmake .. && make
;use         : extern "C" unsigned int IntegerLogical_(unsigned int a, unsigned int b, unsigned int c, unsigned int d);

bits 64

extern _g_Val1:data

global IntegerLogical_

section .text

IntegerLogical_:

; Calculate (((a & b) | c ) ^ d) + g_Val1
    ;because eax must return the final result, we initialize eax with edi
    mov     eax,edi             ;eax = a
    and     eax,esi             ;eax = a & b
    or      eax,edx             ;eax = (a & b) | c
    xor     eax,ecx             ;eax = ((a & b) | c) ^ d
    add     eax,[_g_Val1]       ;eax = (((a & b) | c) ^ d) + g_Val1
    ret                         ;return to caller
