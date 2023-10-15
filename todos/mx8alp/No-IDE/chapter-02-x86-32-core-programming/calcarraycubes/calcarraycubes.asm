; Name:     calcarraycubes.asm
;
; Build:    g++ -m32 -c main.cpp -o main.o
;           nasm -f elf32 -o calcarraycubes.o calcarraycubes.asm
;           g++ -m32 -o calcarraycubes calcarraycubes.o main.o
;
; Source:   Modern x86 Assembly Language Programming p.55

global  CalcArrayCubes

section .text

; extern "C" bool CalcArrayCubes(int* y, const int* x, int n);
;
; Description:  The following function calculates y[n] = x[n]³
;
; Returns       0 = Invalid 'n'
;               1 = Success

%define y    [ebp+8]
%define x    [ebp+12]
%define n    [ebp+16]

CalcArrayCubes:
    push    ebp
    mov     ebp,esp
    push    esi
    push    edi
    push    ebx
    ; Load arguments, make sure 'n' is valid
    xor     eax,eax                 ;error return code
    mov     ecx,n                   ;ecx = 'n'
    test    ecx,ecx
    jle     .error                  ;jump if 'n' <= 0
    ; Initialize pointer to x[0] and direction flag
    mov     esi,x
    mov     edi,y
    pushfd                          ;save current direction flag
    cld                             ;EFLAGS.DF = 0
; Repeat loop until array calculation is finished
.repeat:
    lodsd                           ;eax = x[n]
    mov     ebx, eax                ;ebx = x[n]
    imul    eax                     ;x[n]*x[n]
    imul    ebx                     ;x[n]*x[n]*x[n]
    stosd
    dec     ecx                     ;n--
    jnz     .repeat
    popfd                           ;restore direction flag
    mov     eax,1                   ;set success return code
.error:
    pop     ebx
    pop     edi
    pop     esi
    pop     ebp
    ret
