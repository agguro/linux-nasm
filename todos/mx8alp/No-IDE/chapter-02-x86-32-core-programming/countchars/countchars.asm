; Name:     countchars.asm
;
; Build:    g++ -m32 -c main.cpp -o main.o
;           nasm -f elf32 -o countchars.o countchars.asm
;           g++ -m32 -o countchars countchars.o main.o
;
; Source:   Modern x86 Assembly Language Programming p.71

global  CountChars

section .text

; extern "C" int CountChars(wchar_t* s, wchar_t c);
;
;
; Description:  This function counts the number of occurrences
;               of 'c' in 's'
;
; Returns:      Number of occurrences of 'c'

%define s   [ebp+8]
%define c   [ebp+12]

CountChars:
    push    ebp
    mov     ebp,esp
    push    esi
    ; Load parameters and initialize count registers
    mov     esi,s           ;esi = 's'
    mov     ecx,c           ;cx = 'c'
    xor     edx,edx         ;edx = Number of occurrences
    ; Repeat loop until the entire string has been scanned
    ; on Linux wchar_t is 32 bits!!
.l1:
    lodsd                   ;load next char into ax
    or      eax,eax         ;test for end-of-string
    jz      .l2             ;jump if end-of-string found
    cmp     eax,ecx         ;test current char
    jne     .l1             ;jump if no match
    inc     edx             ;update match count
    jmp     .l1

.l2:
    mov     eax,edx         ;eax = character count
    pop     esi
    pop     ebp
    ret
