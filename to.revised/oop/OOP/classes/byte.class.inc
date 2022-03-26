; Demo BYTE class

%ifndef _CBYTE_CLASS_INC_
%define _CBYTE_CLASS_INC_

STRUC CBYTE_STRUC
    .value:       resb    1
    .Set:         resq    1     ; methods
    .Get:         resq    1
    .OnChanged:   resq    1
ENDSTRUC

%macro CBYTE 1-3
    ;BYTEMACRO methods may only be added once in a source file
    ;don't remove next 2 lines
    %ifndef CBYTEMACROS
    %define CBYTEMACROS
        %macro CBYTESET 1
            mov     rax, %1+CBYTE_STRUC.Set
            call    QWORD [rax]
        %endmacro

        %macro CBYTEGET 1
            mov     rax, %1+CBYTE_STRUC.Get
            call    QWORD [rax]
        %endmacro

        %macro CBYTEONCHANGED 1
            mov     rax, %1+CBYTE_STRUC.OnChanged
            mov     [rax], rdi
        %endmacro
    %endif

    ;define public methodes
    %define %1.Set          CBYTESET %1
    %define %1.Get          CBYTEGET %1
    %define %1.SetOnChanged CBYTEONCHANGED %1

    [section .data]
    %1: ISTRUC CBYTE_STRUC
        %if %0 > 1
            at  CBYTE_STRUC.value,      db  %2
        %else
            at  CBYTE_STRUC.value,      db  0
        %endif
        at  CBYTE_STRUC.Set,        dq CBYTESet
        at  CBYTE_STRUC.Get,        dq CBYTEGet
        %if %0 > 2
            at  CBYTE_STRUC.OnChanged,  dq      %3
        %else
            at  CBYTE_STRUC.OnChanged,  dq      0
        %endif
    IEND
%endmacro

%ifndef CBYTEMACROSCODE
%define CBYTEMACROSCODE

section .text

; method Get
; rcx : the pointer to object instance
; al : the value
CBYTEGet:
    push    rcx
    mov     rcx,rax
    sub     rcx,CBYTE_STRUC.Get - CBYTE_STRUC.value
    xor     rax,rax
    mov     al,BYTE[rcx]
    pop     rcx
    ret

;method Set
;rcx : the pointer to object instance
;rdi : lower byte has value of BYTE
;if the 'this.value' is changed then carryflag is set
CBYTESet:
    push    rax
    push    rdx
    push    rcx
    mov     rcx, rax
    sub     rcx, CBYTE_STRUC.Set - CBYTE_STRUC.value
    mov     rdx, rdi
    ;first compare the value this.byte with DL
    ;if different then set the value and trigger OnChanged procedure
    cmp     BYTE[rcx], dl
    je      __@done
    ;values are different, set the value and trigger OnChanged procedure
    mov     BYTE[rcx], dl
    push    rcx
    add     rcx, CBYTE_STRUC.OnChanged
    call    ..@execute
    pop     rcx
__@done:
    pop     rcx
    pop     rdx                 ;restore rdx
    pop     rax
    ret

..@execute:
    push    rax
    mov     rax,[rcx]
    cmp     rax,0           ;in case no method is provided skip execution
    je      ..@done
    push    rax             ;save used registers in case the callee changes them
    call    rax
    pop     rax             ;restore used registers
..@done:
    pop     rax
    ret
%endif ;CBYTEMACROSCODE

%endif ; _CBYTECLASS_INC_
