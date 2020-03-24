; Name:     ssetextstringcalclength.asm
; Source:   Modern x86 Assembly Language Programming p. 312

global SseTextStringCalcLength_

section .text

; extern "C" int SseTextStringCalcLength_(const char* s);
; Description:  The following function calculates the length of a
;               text string using the x86-SSE instruction pcmpistri.
; Returns:      Length of text string
; Requires      SSE4.2

%define s   [ebp+8]

SseTextStringCalcLength_:
    push    ebp
    mov     ebp,esp
; Initialize registers for string length calculation
    mov     eax,s                   ;eax ='s'
    sub     eax,16                  ;adjust eax for use in loop
    mov     edx,0ff01h
    movd    xmm1,edx                ;xmm1[15:0] = char range
; Calculate next address and test for near end-of-page condition
.@1:
    add     eax,16                  ;eax = next text block
    mov     edx,eax
    and     edx,0fffh               ;edx = low 12 bits of address
    cmp     edx,0ff0h
    ja      .nearEndOfPage          ;jump if within 16 bytes of page boundary
    ; Test current text block for '\0' byte
    pcmpistri xmm1,[eax],14h        ;compare char range and text
    jnz       .@1                              ;jump if '\0' byte not found
    ; Found '\0' byte in current block (index in ECX)
    ; Calculate string length and return
    add     eax,ecx                 ;eax = ptr to '\0' byte
    sub     eax,s                   ;eax = final string length
    pop     ebp
    ret
; Search for the '\0' terminator by examining each character
.nearEndOfPage:
    mov     ecx,4096                ;ecx = size of page in bytes
    sub     ecx,edx                 ;ecx = number of bytes to check
.@2:
    mov     dl,[eax]                ;dl = next text string character
    or      dl,dl
    jz      .foundNull              ;jump if '\0' found
    inc     eax                     ;eax = ptr to next char
    dec     ecx
    jnz     .@2                     ;jump if more chars to test
    ; Remainder of text string can be searched using 16 byte blocks
    ; EAX is now aligned on a 16-byte boundary
    sub     eax,16                  ;adjust eax for use in loop
.@3:
    add       eax,16                ;eax = ptr to next text block
    pcmpistri xmm1,[eax],14h        ;compare char range and text
    jnz       .@3                   ;jump if '\0' byte not found
    ; Found '\0' byte in current block (index in ECX)
    add     eax,ecx                 ;eax = ptr to '\0' byte
; Calculate final string length and return
.foundNull:
    sub     eax,s                   ;eax = final string length
    pop     ebp
    ret
