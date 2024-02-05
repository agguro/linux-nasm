; Name:     calcresult2.asm
;
; Build:    g++ -m32 -c main.cpp -o main.o
;           nasm -f elf32 -o calcresult2.o calcresult2.asm
;           g++ -m32 -o calcresult2 calcresult2.o main.o
;
; Source:   Modern x86 Assembly Language Programming

bits 32

global  calcresult2

section .text

; extern "C" void calcresult2(int a, int b, int c, int* quo, int* rem);
;
; Description:  The following function calculates quotient and remainder of (a + b) / c
;
; Returns       (a + b) / c

calcresult2:

        push ebp
        mov ebp,esp

; Calculate (a + b) / c

        mov eax,[ebp+8]                     ;eax = a
        mov ecx,[ebp+12]                    ;ecx = b
        add eax,ecx                         ;eax = a + b

        cdq                                 ;edx:eax contains dividend
        idiv dword [ebp+16]                 ;eax = quotient, edx = rem

        mov ecx,[ebp+20]                    ;ecx = ptr to quo
        mov [ecx],eax                       ;save quotent
        mov ecx,[ebp+24]                    ;ecx = ptr to rem
        mov [ecx],edx                       ;save remainder

        pop ebp
        ret

