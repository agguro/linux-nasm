; Demo SHORTINT class

%ifndef _SHORTINT_CLASS_INC_
%define _SHORTINT_CLASS_INC_

STRUC SHORTINT_STRUC
    .value:       resb    1
    .Set:         resq    1     ; methods
    .Get:         resq    1
    .OnChanged:   resq    1
ENDSTRUC

%macro SHORTINT 1-3
    ;BYTEMACRO methods may only be added once in a source file
    ;don't remove next 2 lines
    %ifndef SHORTINTMACROS
    %define SHORTINTMACROS
        %macro SHORTINTSET 1
            mov     rax, %1+SHORTINT_STRUC.Set
            call    QWORD [rax]
        %endmacro

        %macro SHORTINTGET 1
            mov     rax, %1+SHORTINT_STRUC.Get
            call    QWORD [rax]
        %endmacro

        %macro SHORTINTONCHANGED 1
            mov     rax, %1+SHORTINT_STRUC.OnChanged
            mov     [rax], rdi
        %endmacro
    %endif

    ;define public methodes
    %define %1.Set          SHORTINTSET %1
    %define %1.Get          SHORTINTGET %1
    %define %1.SetOnChanged SHORTINTONCHANGED %1

    [section .data]
    %1: ISTRUC SHORTINT_STRUC
        %if %0 > 1
            at  SHORTINT_STRUC.value,      db  %2
        %else
            at  SHORTINT_STRUC.value,      db  0
        %endif
        at  SHORTINT_STRUC.Set,        dq SHORTINTSet
        at  SHORTINT_STRUC.Get,        dq SHORTINTGet
        %if %0 > 2
            at  SHORTINT_STRUC.OnChanged,  dq      %3
        %else
            at  SHORTINT_STRUC.OnChanged,  dq      0
        %endif
    IEND
%endmacro

%ifndef SHORTINTMACROSCODE
%define SHORTINTMACROSCODE

section .text

; method Get
; rcx : the pointer to object instance
; al : the value
SHORTINTGet:
    push    rcx
    mov     rcx,rax
    sub     rcx,SHORTINT_STRUC.Get - SHORTINT_STRUC.value
    xor     rax,rax
    mov     al,BYTE[rcx]
    pop     rcx
    ret

;method Set
;rcx : the pointer to object instance
;rdi : lower byte has value of BYTE
;if the 'this.value' is changed then carryflag is set
SHORTINTSet:
    push    rax
    push    rdx
    push    rcx
    mov     rcx, rax
    sub     rcx, SHORTINT_STRUC.Set - SHORTINT_STRUC.value
    mov     rdx, rdi
    ;first compare the value this.byte with DL
    ;if different then set the value and trigger OnChanged procedure
    cmp     BYTE[rcx], dl
    je      __@done
    ;values are different, set the value and trigger OnChanged procedure
    mov     BYTE[rcx], dl
    push    rcx
    add     rcx, SHORTINT_STRUC.OnChanged
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
%endif ;SHORTINTMACROSCODE

%endif ; _SHORTINTCLASS_INC_
