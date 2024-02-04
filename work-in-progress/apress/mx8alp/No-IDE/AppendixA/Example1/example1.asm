; Name:     calcresult1.asm
;
; Build:    g++ -m32 -c main.cpp -o main.o
;           nasm -f elf32 -o calcresult1.o calcresult1.asm
;           g++ -m32 -o calcresult1 calcresult1.o main.o
;
; Source:   Modern x86 Assembly Language Programming

bits 32

global  calcresult1

section .text

; extern "C" int calcresult1(int a, int b, int c);
;
; Description:  The following function calculates (a + b) * c
;
; Returns       (a + b) * c in eax

calcresult1:

        push ebp
        mov ebp,esp

        mov eax,[ebp+8]                     ;eax = a
        mov ecx,[ebp+12]                    ;ecx = b
        mov edx,[ebp+16]                    ;edx = c

        add eax,ecx                         ;eax = a + b
        imul eax,edx                        ;eax = (a + b) * c

        pop ebp
        ret

