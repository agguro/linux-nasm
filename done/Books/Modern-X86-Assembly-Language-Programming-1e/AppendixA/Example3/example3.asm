; Name:     calcresult3.asm
;
; Build:    g++ -c main.cpp -o main.o
;           nasm -f elf64 -o calcresult3.o calcresult3.asm
;           g++ -o calcresult3 calcresult3.o main.o
;
; Source:   Modern x86 Assembly Language Programming

bits 64

global  calcresult3

section .text

; extern "C" double calcresult3(int a, int b, double c, double d);
;
; Description:  The following function calculates the sum of the squares of a,b,c and d
;
; Returns;      sqrt(a * a + b * b + c * c + d * d)

calcresult3:

    imul rdi,rdi                        ;rdi = a * a
    imul rsi,rsi                        ;rsi = b * b
        
    ;DFPP = Double Precision Floating Point
    
    cvtsi2sd xmm2,rdi                   ;convert rdi to DPFP
    cvtsi2sd xmm3,rsi                   ;convert rsi to DPFP

    mulsd xmm0,xmm0                     ;xmm2 = c * c
    mulsd xmm1,xmm1                     ;xmm3 = d * d

    addsd xmm0,xmm1                     ;xmm0 = a * a + b * b
    addsd xmm2,xmm3                     ;xmm2 = c * c + d * d
    addsd xmm0,xmm2                     ;xmm0 = sum of squares
    sqrtsd xmm0,xmm0                    ;xmm0 = sqrt(sum of squares)
    ret

