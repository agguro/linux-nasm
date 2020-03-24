; Name:     ssetextstringreplacechar.asm
; Source:   Modern x86 Assembly Language Programming p. 316

global SseTextStringReplaceChar_

section .data
align 16
    PxorNotMask: times 16 db 0xff                 ;pxor logical not mask

section .text

; extern "C" int SseTextStringReplaceChar_(char* s, char old_char, char new_char);
; Description:  The following function replaces all instances of old_char
;               with new_char in the provided text string.
; Requires      SSE4.2 and POPCNT feature flag.

%define s           [ebp+8]
%define old_char    [ebp+12]
%define new_char    [ebp+16]

SseTextStringReplaceChar_:
    push    ebp
    mov     ebp,esp
    push    ebx
    push    esi
    push    edi

; Initialize
    mov     eax,s                       ;eax = 's'
    sub     eax,16                      ;adjust eax for loop below
    xor     edi,edi                     ;edi = num replaced chars

; Build packed old_char and new_char
    movzx   ecx,byte old_char
    movd    xmm1,ecx                    ;xmm1[7:0] = old_char
    movzx   ecx,byte new_char           ;ecx = new char
    movd    xmm6,ecx
    pxor    xmm5,xmm5
    pshufb  xmm6,xmm5                   ;xmm6 = packed new_char
    movdqa  xmm7,[PxorNotMask]          ;xmm7 = pxor not mask

; Calculate next string address and test for near end-of-page condition
.loop1:
    add     eax,16                      ;eax = next text block
    mov     edx,eax
    and     edx,0fffh                   ;edx = low 12 bits of address
    cmp     edx,0ff0h
    ja      .nearEndOfPage              ;jump if within 16 bytes of page boundary

; Compare current text block to find characters
    movdqu    xmm2,[eax]                ;load next text block
    pcmpistrm xmm1,xmm2,40h             ;test for old_char match
    setz      cl                        ;set if '\0' found
    jc        .foundMatch1              ;jump if matches found
    jz        .done                     ;jump if '\0' found
    jmp       .loop1                    ;jump if no matches found

; Character matches found (xmm0 = match mask)
; Update character match count in EDI
.foundMatch1:
    pmovmskb edx,xmm0                   ;edx = match mask
    popcnt   edx,edx                    ;count the number of matches
    add      edi,edx                    ;edi = total match count

; Replace all old_char with new_char
    movdqa  xmm3,xmm0                   ;xmm3 = match mask
    pxor    xmm0,xmm7
    pand    xmm0,xmm2                   ;remove old_chars
    pand    xmm3,xmm6
    por     xmm0,xmm3                   ;insert new_chars
    movdqu  [eax],xmm0                  ;save updated string
    or      cl,cl                       ;does current block contain '\0'?
    jnz     .done                       ;jump if yes
    jmp     .loop1                      ;continue processing text string

; Replace old_char with new_char near end of page
.nearEndOfPage:
    mov     ecx,4096                    ;size of page in bytes
    sub     ecx,edx                     ;ecx = number of bytes to check
    mov     dl,[ebp+12]                 ;dl = old_char
    mov     dh,[ebp+16]                 ;dh = new_char

.loop2:
    mov     bl,[eax]                    ;load next input string character
    or      bl,bl
    jz      .done                       ;jump if '\0' found
    cmp     dl,bl
    jne     .@1                         ;jump if no match
    mov     [eax],dh                    ;replace old_char with new_char
    inc     edi                         ;update num replaced characters
.@1:
    inc     eax                         ;eax = ptr to next char
    dec     ecx
    jnz     .loop2                      ;repeat until end of page
    sub     eax,16                      ;adjust eax to eliminate jump

; Process remainder of text string; note that movdqa can now be used
.loop3:
    add       eax,16                    ;eax = next text block
    movdqa    xmm2,[eax]                ;load next text block
    pcmpistrm xmm1,xmm2,40h             ;test for old_char match
    setz      cl                        ;set if '\0' found
    jc        .foundMatch3              ;jump if matches found
    jz        .done                     ;jump if '\0' found
    jmp       .loop3                    ;jump if no matches found

.foundMatch3:
    pmovmskb edx,xmm0                   ;edx = match mask
    popcnt   edx,edx                    ;count the number of matches
    add      edi,edx                    ;edi = total match count

; Replace all old_char with new_char
    movdqa  xmm3,xmm0                   ;xmm3 = match mask
    pxor    xmm0,xmm7
    pand    xmm0,xmm2                   ;mask out all old_chars
    pand    xmm3,xmm6
    por     xmm0,xmm3                   ;insert new_chars
    movdqa  [eax],xmm0                  ;save updated string
    or      cl,cl                       ;does current block contain '\0'?
    jnz     .done                       ;jump if yes
    jmp     .loop3                      ;continue processing text string

.done:
    mov     eax,edi                     ;eax = num replaced characters
    pop     edi
    pop     esi
    pop     ebx
    pop     ebp
    ret
