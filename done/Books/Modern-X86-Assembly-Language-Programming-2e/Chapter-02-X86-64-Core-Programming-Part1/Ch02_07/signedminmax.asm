;name        : signedminmax.asm
;description : Min and max of signed integers
;source      : Modern X86 Assembly Language Programming 2nd Edition
;build       : mkdir build && cd build && qmake .. && make
;use         : extern "C" int SignedMinA_(int a, int b, int c);
;              returns:      min(a, b, c)
;              extern "C" int SignedMaxA_(int a, int b, int c);
;              returns:      max(a, b, c)
;              extern "C" int SignedMinB_(int a, int b, int c);
;              returns:      min(a, b, c)
;              extern "C" int SignedMaxB_(int a, int b, int c);
;              returns:      max(a, b, c)


bits 64

global SignedMinA_
global SignedMaxA_
global SignedMinB_
global SignedMaxB_

section .text

SignedMinA_:
; in : edi = a
;      esi = b
;      edx = c
; out: eax = min(a, b, c)
    mov     eax,edi
    cmp     eax,esi                         ;compare a and b
    jle     .@1                              ;jump if a <= b
    mov     eax,esi                         ;eax = b
.@1:
    cmp     eax,edx                         ;compare min(a, b) and c
    jle     .@2
    mov     eax,edx                         ;eax = min(a, b, c)
.@2:
    ret

SignedMaxA_:
; in : edi = a
;      esi = b
;      edx = c
; out: eax = max(a, b, c)
    mov     eax,edi
    cmp     eax,esi                         ;compare a and b
    jge     .@1                              ;jump if a >= b
    mov     eax,esi                         ;eax = b
.@1:
    cmp     eax,edx                         ;compare max(a, b) and c
    jge     .@2
    mov     eax,edx                         ;eax = max(a, b, c)
.@2:
    ret

SignedMinB_:
; in : edi = a
;      esi = b
;      edx = c
; out: eax = min(a, b, c)
    mov     eax,edi
    cmp     eax,esi
    cmovg   eax,esi                       ;ecx = min(a, b)
    cmp     eax,edx
    cmovg   eax,edx                       ;ecx = min(a, b, c)
    ret

SignedMaxB_:
; in : edi = a
;      esi = b
;      edx = c
; out: eax = max(a, b, c)
    mov     eax,edi
    cmp     eax,esi
    cmovl   eax,esi                       ;ecx = max(a, b)
    cmp     eax,edx
    cmovl   eax,edx                       ;ecx = max(a, b, c)
    ret
