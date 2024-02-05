; Name:     calcresult4.asm
;
; Build:    default build is for 64 bits
;           64 bits build:
;           nasm -f elf64 -D BITS=64 -o example4.o example4.asm
;           g++ -D BITS=64 -c main.cpp -o main.o
;           g++ -D BITS=64 -o example4 example4.o main.o
;
;           32 bits build:
;           nasm -f elf32 -D BITS=32 -o example4.o example4.asm
;           g++ -m32 -D BITS=32 -c main.cpp -o main.o
;           g++ -m32 -D BITS=32 -o example4 example4.o main.o
;
; Source:   Modern x86 Assembly Language Programming

; extern "C" bool calcresult4(int* y, const int* x, int n);
;
; returns: rax = 0 on succes, rax = 1 when an error (n<=0) occured
;          on succes int* y is an array with the squares of the corresponding x

section .text

global calcresult4

calcresult4:

;do not use %define BITS
;it's part of the commandline option -D see Makefile
   
%if BITS=32

    bits 32

    push ebp
    mov ebp,esp
    push ebx
    push esi

    mov ecx,[ebp+8]                     ;ecx = ptr to y
    mov edx,[ebp+12]                    ;edx = ptr to x
    mov ebx,[ebp+16]                    ;eax = n
    test ebx,ebx                        ;is n <= 0?
    jle error                           ;jump if n <= 0

    xor esi,esi                         ;i = 0;
@1:
    mov eax,[edx+esi*4]                 ;eax = x[i]
    imul eax,eax                        ;eax = x[i] * x[i]
    mov [ecx+esi*4],eax                 ;save result to y[i]

    add esi,1                           ;i = i + 1
    cmp esi,ebx
    jl @1                               ;jump if i < n

    xor eax,eax                         ;set success return code
    jmp return
        
error:
    mov eax,1                           ;set error return code
    
return:
    pop esi
    pop ebx
    mov esp,ebp
    pop ebp
    ret
    
%else

    bits 64

; Register arguments: rdi = ptr to y, rsi = ptr to x, and rdx = n

    movsxd rdx,edx                      ;sign-extend n to 64 bits
    test rdx,rdx                        ;is n <= 0?
    jle error                           ;jump if n <= 0

    xor r9,r9                           ;i = 0;
@1:
    mov eax,[rsi+r9*4]                  ;eax = x[i]
    imul eax,eax                        ;eax = x[i] * x[i]
    mov [rdi+r9*4],eax                  ;save result to y[i]

    add r9,1                            ;i = i + 1
    cmp r9,rdx
    jl @1                               ;jump if i < n

    xor eax,eax                         ;set success return code
    ret

error:
    mov eax,1                           ;set error return code
    ret
    
%endif

