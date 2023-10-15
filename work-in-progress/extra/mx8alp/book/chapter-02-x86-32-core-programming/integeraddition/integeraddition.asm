; Name:     integeraddition.asm
;
; Build:    g++ -m32 -c main.cpp -o main.o
;           nasm -f elf32 -o integeraddition.o integeraddition.asm
;           g++ -m32 -o integeraddition integeraddition.o main.o
;
; Source:   Modern x86 Assembly Language Programming p.46

; These are defined in IntegerAddition.cpp
extern GlChar
extern GlShort
extern GlInt
extern GlLongLong

global IntegerAddition

section .text

; extern "C" void IntegerTypes_(char a, short b, int c, long long d);
;
;
; Description:  This function demonstrates simple addition using
;               various-sized integers.
;

%define a       [ebp+8]
%define b       [ebp+12]
%define c       [ebp+16]
%define dlow    [ebp+20]
%define dhigh   [ebp+24]

IntegerAddition:
    ; Function prolog
    push    ebp
    mov     ebp,esp
    ; Compute GlChar += a
    mov     al,a
    add     [GlChar],al
    ; Compute GlShort += b, note offset of 'b' on stack
    mov     ax,b
    add     [GlShort],ax
    ; Compute GlInt += c, note offset of 'c' on stack
    mov     eax,c
    add     [GlInt],eax
    ; Compute GlLongLong += d, note use of dword ptr operator and adc
    mov     eax,dlow
    mov     edx,dhigh
    add     dword[GlLongLong],eax
    adc     dword[GlLongLong+4],edx
    ; Function epilog
    pop     ebp
    ret
