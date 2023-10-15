; Name:     avxbgprbitmanip.asm
;
; Build:    g++ -c -m32 main.cpp -o main.o
;           nasm -f elf32 -o avxbgprbitmanip.o avxbgprbitmanip.asm
;           g++ -m32 -o avxbgprbitmanip avxbgprbitmanip.o main.o
;
; Source:   Modern x86 Assembly Language Programming p. 486

global AvxGprCountZeroBits
global AvxGprBextr
global AvxGprAndNot

section .text

; extern "C" void AvxGprCountZeroBits(Uint32 x, Uint32* lzcnt, Uint32* tzcnt);
;
; Description:  The following function demonstrates use of the lzcnt and
;               tzcnt instructions.
;
; Requires:     BMI1, LZCNT

AvxGprCountZeroBits:
    mov     eax,[esp+4]                   ;eax = x

    lzcnt   ecx,eax                       ;count leading zeros
    mov     edx,[esp+8]
    mov     [edx],ecx                     ;save result

    tzcnt   ecx,eax                       ;count trailing zeros
    mov     edx,[esp+12]
    mov     [edx],ecx                     ;save result
    ret

; extern "C" Uint32 AvxGprBextr(Uint32 x, Uint8 start, Uint8 length);
;
; Description:  The following function demonstrates use of the
;               bextr instruction.
;
; Requires:     BMI1

AvxGprBextr:
    mov     cl,[esp+8]                    ;cl = start index
    mov     ch,[esp+12]                   ;ch = length of bit field
    bextr   eax,[esp+4],ecx               ;eax = extracted bit field
    ret

; extern "C" Uint32 AvxGprAndNot_(Uint32 x, Uint32 y);
;
; Description:  The following function demonstrates use of the
;               andn instruction.
;
; Requires:     BMI1

AvxGprAndNot:
    mov     ecx,[esp+4]
    andn    eax,ecx,[esp+8]               ;eax = ~ecx & [esp+8]
    ret
