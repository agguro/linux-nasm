;project:   Informat
;
;name:      stringsearch.asm
;
;date:      17 aug 2020
;
;description:   search in a giving string at rsi with length r8 for the presence of
;               a substring at rdi with length rdx.  If present rax returns
;               the address of the first occurence, if not present then rax
;               returns -1.
;
;to do:         find a better algorithm

bits 64

global stringsearch

section .text

stringsearch:
    push    rbp
    mov     rbp,rsp
    push    rcx                     ;save used register values
    push    r14
    push    r15
    ;rdi has the address of the substring
    ;rsi has the address of the string
    mov     rcx,rdx                 ;length of substring in rcx
    mov     rax,rsi                 ;address of string in rax
    add     rax,r8                  ;address of last byte in string
    sub     rax,rdx                 ;the max length we are looking in of the string
    mov     r14,rdi                 ;address of substring in r14
    mov     r15,rcx                 ;length of substring in r15
.search:
    cmp     rsi,rax                 ;if rsi points at total length minus length of substring then stop
    ja      .notfound
    mov     rdi,r14                 ;address of substring in rdi
    mov     rcx,r15                 ;length of substring in rcx
    cld                             ;search from begin to end
    repe    cmpsb                   ;compare byte by byte, stop if different
    jne     .search                 ;bytes doesn't match, repeat at next string position
    ;there is a match, we've found the presence of the substring
    mov     rax,rsi                 ;load address of last byte of substring in rax 
    sub     rax,r15                 ;subtract the length to get position of first byte
    jmp     .return
    ;we looked until the end of the string minus the length of the substring and found no match
.notfound:
    xor     rax,rax                 ;return -1
    dec     rax
.return:
    pop     r15                     ;restore used register values
    pop     r14
    pop     rcx
    mov     rsp,rbp
    pop     rbp
    ret
