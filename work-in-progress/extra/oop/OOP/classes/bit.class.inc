; BIT Class
; Defines a single logical bit.
; Each time a bit is set, the OnSet event, if a bit is reset, the OnReset event and if
; a bit changes value the OnChanged event will be triggered
; Usage:
; section .data
;   BIT [bitname]
; Methods:
;   [bitname].Set       ; sets the bitvalue to one      CF=1 if value has changed
;   [bitname].Reset     ; resets the bitvalue to zero   CF=1 if value has changed
;   [bitname].Invert    ; inverts the bitvalue          CF=1 (value always changes
;   [bitname].Get       ; returns the bitvalue in DL
;   [bitname].Load      ; loads the value in DL into the bitvalue   CF=1 if value has changed
; Events:
;   [bitname].OnChanged ; pointer to routine executed when the value of [bitname] is changed
;   [bitname].OnSet     ; pointer to routine executed when the bit is set
;   [bitname].OnReset   ; pointer to routine executed when the bit is reset
; Properties:
;   [bitname].value     ; value of the bit

%ifndef _ASM_BIT_CLASS_
%define _ASM_BIT_CLASS_

    STRUC BIT_STRUC
    .value:       resb    1
    .Set:         resq    1     ; methods
    .Reset:       resq    1
    .Invert:      resq    1
    .Get:         resq    1
    .Load:        resq    1
    .OnChanged:   resq    1
    .OnSet:       resq    1
    .OnReset:     resq    1
    ENDSTRUC

    %macro BIT 1

    %ifndef BITMACROS
    %define BITMACROS
                
        %macro BITSET 1
            mov     rax, %1+BIT_STRUC.Set
            call    QWORD [rax]
        %endmacro
        
        %macro BITRESET 1
            mov     rax, %1+BIT_STRUC.Reset
            call    QWORD [rax]
        %endmacro
        
        %macro BITINVERT 1
            mov     rax, %1+BIT_STRUC.Invert
            call    QWORD [rax]
        %endmacro
        
        %macro BITGET 1
            mov     rax, %1+BIT_STRUC.Get
            call    QWORD [rax]
        %endmacro
        
        %macro BITLOAD 1
            mov     rax, %1+BIT_STRUC.Load
            call    QWORD [rax]
        %endmacro
        
        %macro BITONCHANGED 1
            mov     rax, %1+BIT_STRUC.OnChanged
            mov     [rax], rdx
        %endmacro
        
        %macro BITONSET 1
            mov     rax, %1+BIT_STRUC.OnSet
            mov     [rax], rdx
        %endmacro

        %macro BITONRESET 1
            mov     rax, %1+BIT_STRUC.OnReset
            mov     [rax], rdx
        %endmacro

    %endif    
        
        %define %1.Set          BITSET %1
        %define %1.Reset        BITRESET %1
        %define %1.Invert       BITINVERT %1
        %define %1.Get          BITGET %1
        %define %1.Load         BITLOAD %1
        %define %1.OnChanged    BITONCHANGED %1
        %define %1.OnSet        BITONSET %1
        %define %1.OnReset      BITONRESET %1
        %define %1.value        BYTE [%1+BIT_STRUC.value]
        
        [section .data]
        %1: ISTRUC BIT_STRUC
                at  BIT_STRUC.value,      db 0
                at  BIT_STRUC.Set,        dq BITSet
                at  BIT_STRUC.Reset,      dq BITReset
                at  BIT_STRUC.Invert,     dq BITInvert
                at  BIT_STRUC.Get,        dq BITGet
                at  BIT_STRUC.Load,       dq BITLoad
                at  BIT_STRUC.OnChanged,  dq 0
                at  BIT_STRUC.OnSet,      dq 0
                at  BIT_STRUC.OnReset,    dq 0
            IEND   
    %endmacro

        ; Allthough not the best practice in OOP programming 'jmp' instructions are used to
        ; parts of other procedures (methods).  In real OOP we will not do this.
        
        section .text

        ; method Load
        ; Loads this.value with contents in DL and returns
        ; if this.value has changed the CF = 1 else CF = 0
        BITLoad:
            mov     rcx, rax
            sub     rcx, BIT_STRUC.Load - BIT_STRUC.value
            jmp     ..@setvalue
            
        ; method Reset
        ; rcx : the pointer to object instance
        ; if the 'this.value' is changed then carryflag is set
        BITReset:
            mov     rcx, rax
            sub     rcx, BIT_STRUC.Reset - BIT_STRUC.value
            mov     dl, 0
            jmp     ..@setvalue
            
        ; method Set
        ; rcx : the pointer to object instance
        ; if the 'this.value' is changed then carryflag is set
        BITSet:
            mov     rcx, rax
            sub     rcx, BIT_STRUC.Set - BIT_STRUC.value
            mov     dl, 1
            jmp     ..@setvalue
        
        ; method Get
        ; rcx : the pointer to object instance
        ; dl : the value
        BITGet:
            mov     rcx, rax
            sub     rcx, BIT_STRUC.Get - BIT_STRUC.value
            mov     dl, BYTE[rcx]
            ret
        
        ; method Invert
        ; rcx : pointer to object instance
        ; inverts this.value
        BITInvert:
            mov     rcx, rax
            sub     rcx, BIT_STRUC.Invert - BIT_STRUC.value
            mov     dl, BYTE[rcx]
            xor     dl, 1
            jmp     ..@savevalue
            
        ..@setvalue:
            cmp     BYTE[rcx], dl
            je      ..@checkvalue
            
        ..@savevalue:
            mov     BYTE[rcx], dl
            push    rcx
            add     rcx, BIT_STRUC.OnChanged
            call    ..@execute 
            pop     rcx
        ..@checkvalue:
            cmp     BYTE[rcx], 0
            je      ..@OnReset
            add     rcx, BIT_STRUC.OnSet
            jmp    ..@execute
            
        ..@OnReset:
            add     rcx, BIT_STRUC.OnReset
            ; when extending the code, don't forget to add 'jmp ..@execute'
                    
        ..@execute:
            mov     rax, [rcx]
            cmp     rax, 0          ; in case no method is provided skip execution
            je      ..@done
            push    rax             ; save used registers in case the callee changes them
            push    rcx
            push    rdx
            call    rax
            pop     rdx             ; restore used registers
            pop     rcx
            pop     rax
        ..@done:
            ret

%endif