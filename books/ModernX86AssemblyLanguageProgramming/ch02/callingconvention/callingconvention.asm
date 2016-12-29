; extern "C" void CalculateSums(int a, int b, int c, int* s1, int* s2, int* s3);
;
; Name:         callingconvention.asm
;
; Description:  This function demonstrates a complete assembly language
;               prolog and epilog.
;
; Returns:      None.
;
; Computes:     *s1 = a + b + c
;               *s2 = a * a + b * b + c * c
;               *s3 = a * a * a + b * b * b + c * c * c
;
; Source:       Modern x86 Assembly Language Programming p.37

global  CalculateSums

section .text

CalculateSums:
    ; registry values at entry
    ; edi : a
    ; esi : b
    ; edx : c
    ; rcx : pointer to s1
    ; r8  : pointer to s2 and temporarly storage
    ; r9  : pointer to s3 and temporarly storage
    ; r10 : temporarly storage
    ; local variables to store results temporarly

    %define a       dword[rbp-12]
    %define b       dword[rbp-8]
    %define c       dword[rbp-4]
    %define ptrS1   dword[rcx]
    %define ptrS2   dword[r8]
    %define ptrS3   dword[r9]
    
    ; prolog
    push    rbp
    mov     rbp, rsp
    sub     rsp, 12                 ; allocate local storage space 3 times a dword size
    
    mov     a, edi                  ; store a,b and c locally
    mov     b, esi
    mov     c, edx
    
    mov     eax, edi
    add     eax, esi
    add     eax, edx                ; a+b+c
    mov     ptrS1, eax              ; store result in s1
    
    imul    edi, a                  ; a*a
    imul    esi, b                  ; b*b
    imul    edx, c                  ; c*c 
    
    mov     eax, edi
    add     eax, esi
    add     eax, edx                ; a*a+b*b+c*c
    mov     ptrS2, eax         ; store result in s2
    
    imul    edi, a                  ; a*a*a
    imul    esi, b                  ; b*b*b
    imul    edx, c                  ; c*c*c

    mov     eax, edi
    add     eax, esi
    add     eax, edx                ; a*a*a+b*b*b+c*c*c

    mov     ptrS3, eax         ; store result in s3
    
    ; epilog
    mov     rsp, rbp
    pop     rbp
    ret
