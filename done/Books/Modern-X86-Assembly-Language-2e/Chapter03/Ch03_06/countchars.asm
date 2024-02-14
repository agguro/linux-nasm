;name        : countchars.asm
;description : This function counts the number of occurrences
;              of a character in a string.
;source      : Modern X86 Assembly Language Programming 2nd Edition
;build       : mkdir build && cd build && qmake .. && make
;use         : extern "C" unsigned long long CountChars_(const char* s, char c);
;              returns: Number of occurrences found.

bits 64

global CountChars_

section .text

CountChars_:
; in : rdi = s ptr
;    : rsi = c
; out : rax = number of occurences of character c in string s

; Load parameters and initialize count registers
    mov     cl,sil         ;cl = c
    ;next instruction can be omitted when coding the caller:
    ;unsigned long long CountChars_(char c, const char* s)
    mov     rsi,rdi        ;rsi = s
    xor     edx,edx        ;rdx = Number of occurrences
    xor     r8d,r8d        ;r8 = 0 (required for add below)

; Repeat loop until the entire string has been scanned
.repeat:
    lodsb                  ;load next char into register al
    or      al,al          ;test for end-of-string
    jz      .done          ;jump if end-of-string found
    cmp     al,cl          ;test current char
    sete    r8b            ;r8b = 1 if match, 0 otherwise
    add     rdx,r8         ;update occurrence count
    jmp     .repeat
.done:
    mov     rax,rdx        ;rax = number of occurrences

; Return
    ret
