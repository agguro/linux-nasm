; DATABUS Class
; Defines an array of 8 logical bits presented as a databus of 8 bits
; Although not really needed and in fact it must be private, the individual bit values are accessable.
; The user have to keep in mind when using this form of addressing no events wil be triggered what so ever.
; The benefit is that we can initialize a databus before any event will be triggered but also this can be avoid
; when first initialising and then assigning the procedures to the event properties.
; Calling:
;   section .data
;       DATABUS [databusname]
;
; Methods
; [databusname].[bitnr].Set         ; sets the corresponding bit in the databus
; [databusname].[bitnr].Reset       ; resets the corresponding bit in the databus
; [databusname].[bitnr].Invert      ; inverts the corresponding bit in the databus
; [databusname].[bitnr].Get         ; gets the corresponding bit value in the databus in DL
; [databusname].[bitnr].Load        ; loads the value of DL in the corresponding bit in the databus
;
; Events
; [databusname].[bitnr].OnSet       ; is triggered when the corresponding bit is set
; [databusname].[bitnr].OnReset     ; is triggered when the corresponding bit is reset
; [databusname].[bitnr].OnChanged   ; is triggered when the corresponding bit has changed value
;
; Properties
; [databusname].[bitnr].value       ; value of the corresponding bit in the databus


%ifndef _ASM_DATABUS_CLASS_
%define _ASM_DATABUS_CLASS_

    %include "classes/bit.class.inc"

    STRUC DATABUS_STRUC
    .0:        resq    1   ; LSB
    .1:        resq    1   ;
    .2:        resq    1   ;
    .3:        resq    1   ;
    .4:        resq    1   ;
    .5:        resq    1   ;
    .6:        resq    1   ;
    .7:        resq    1   ; MSB
    ENDSTRUC

    %macro DATABUS 1

    %ifndef DATABUSMACROS
    %define DATABUSMACROS
       
        %macro DATABUSBITSET 1
            mov     rax, %1
            mov     rax, [rax]
            add     rax, BIT_STRUC.Set
            call    [rax]
        %endmacro
        
        %macro DATABUSBITRESET 1
            mov     rax, %1
            mov     rax, [rax]
            add     rax, BIT_STRUC.Reset
            call    QWORD [rax]
        %endmacro

        %macro DATABUSBITINVERT 1
            mov     rax, %1
            mov     rax, [rax]
            add     rax, BIT_STRUC.Invert
            call    QWORD [rax]
        %endmacro

        %macro DATABUSBITGET 1
            mov     rax, %1
            mov     rax, [rax]
            add     rax, BIT_STRUC.Get
            call    QWORD [rax]
        %endmacro
        
        %macro DATABUSBITLOAD 1
            mov     rax, %1
            mov     rax, [rax]
            add     rax, BIT_STRUC.Load
            call    QWORD [rax]
        %endmacro
        
        %macro  DATABUSBITONCHANGED 1
            mov     rax, %1
            mov     rax, [rax]
            add     rax, BIT_STRUC.OnChanged
            mov     [rax], rdx
        %endmacro
        
        %macro  DATABUSBITONSET 1
            mov     rax, %1
            mov     rax, [rax]
            add     rax, BIT_STRUC.Set
            mov     [rax], rdx
        %endmacro

        %macro  DATABUSBITONRESET 1
            mov     rax, %1
            mov     rax, [rax]
            add     rax, BIT_STRUC.OnReset
            mov     [rax], rdx
        %endmacro

    %endif
               
        %define %1.0    %1+DATABUS_STRUC.0
        %define %1.1    %1+DATABUS_STRUC.1
        %define %1.2    %1+DATABUS_STRUC.2
        %define %1.3    %1+DATABUS_STRUC.3
        %define %1.4    %1+DATABUS_STRUC.4
        %define %1.5    %1+DATABUS_STRUC.5
        %define %1.6    %1+DATABUS_STRUC.6
        %define %1.7    %1+DATABUS_STRUC.7
                      
        %define %1.0.Set     DATABUSBITSET %1.0
        %define %1.1.Set     DATABUSBITSET %1.1
        %define %1.2.Set     DATABUSBITSET %1.2
        %define %1.3.Set     DATABUSBITSET %1.3
        %define %1.4.Set     DATABUSBITSET %1.4
        %define %1.5.Set     DATABUSBITSET %1.5
        %define %1.6.Set     DATABUSBITSET %1.6
        %define %1.7.Set     DATABUSBITSET %1.7
        
        %define %1.0.Reset     DATABUSBITRESET %1.0
        %define %1.1.Reset     DATABUSBITRESET %1.1
        %define %1.2.Reset     DATABUSBITRESET %1.2
        %define %1.3.Reset     DATABUSBITRESET %1.3
        %define %1.4.Reset     DATABUSBITRESET %1.4
        %define %1.5.Reset     DATABUSBITRESET %1.5
        %define %1.6.Reset     DATABUSBITRESET %1.6
        %define %1.7.Reset     DATABUSBITRESET %1.7
        
        %define %1.0.Invert     DATABUSBITINVERT %1.0
        %define %1.1.Invert     DATABUSBITINVERT %1.1
        %define %1.2.Invert     DATABUSBITINVERT %1.2
        %define %1.3.Invert     DATABUSBITINVERT %1.3
        %define %1.4.Invert     DATABUSBITINVERT %1.4
        %define %1.5.Invert     DATABUSBITINVERT %1.5
        %define %1.6.Invert     DATABUSBITINVERT %1.6
        %define %1.7.Invert     DATABUSBITINVERT %1.7
        
        %define %1.0.Get     DATABUSBITGET %1.0
        %define %1.1.Get     DATABUSBITGET %1.1
        %define %1.2.Get     DATABUSBITGET %1.2
        %define %1.3.Get     DATABUSBITGET %1.3
        %define %1.4.Get     DATABUSBITGET %1.4
        %define %1.5.Get     DATABUSBITGET %1.5
        %define %1.6.Get     DATABUSBITGET %1.6
        %define %1.7.Get     DATABUSBITGET %1.7
        
        %define %1.0.Load     DATABUSBITLOAD %1.0
        %define %1.1.Load     DATABUSBITLOAD %1.1
        %define %1.2.Load     DATABUSBITLOAD %1.2
        %define %1.3.Load     DATABUSBITLOAD %1.3
        %define %1.4.Load     DATABUSBITLOAD %1.4
        %define %1.5.Load     DATABUSBITLOAD %1.5
        %define %1.6.Load     DATABUSBITLOAD %1.6
        %define %1.7.Load     DATABUSBITLOAD %1.7
        
        %define %1.0.OnChanged     DATABUSBITONCHANGED %1.0
        %define %1.1.OnChanged     DATABUSBITONCHANGED %1.1
        %define %1.2.OnChanged     DATABUSBITONCHANGED %1.2
        %define %1.3.OnChanged     DATABUSBITONCHANGED %1.3
        %define %1.4.OnChanged     DATABUSBITONCHANGED %1.4
        %define %1.5.OnChanged     DATABUSBITONCHANGED %1.5
        %define %1.6.OnChanged     DATABUSBITONCHANGED %1.6
        %define %1.7.OnChanged     DATABUSBITONCHANGED %1.7

        %define %1.0.OnSet     DATABUSBITONSET %1.0
        %define %1.1.OnSet     DATABUSBITONSET %1.1
        %define %1.2.OnSet     DATABUSBITONSET %1.2
        %define %1.3.OnSet     DATABUSBITONSET %1.3
        %define %1.4.OnSet     DATABUSBITONSET %1.4
        %define %1.5.OnSet     DATABUSBITONSET %1.5
        %define %1.6.OnSet     DATABUSBITONSET %1.6
        %define %1.7.OnSet     DATABUSBITONSET %1.7

        %define %1.0.OnReset     DATABUSBITONRESET %1.0
        %define %1.1.OnReset     DATABUSBITONRESET %1.1
        %define %1.2.OnReset     DATABUSBITONRESET %1.2
        %define %1.3.OnReset     DATABUSBITONRESET %1.3
        %define %1.4.OnReset     DATABUSBITONRESET %1.4
        %define %1.5.OnReset     DATABUSBITONRESET %1.5
        %define %1.6.OnReset     DATABUSBITONRESET %1.6
        %define %1.7.OnReset     DATABUSBITONRESET %1.7

        [section .data]
        
        %1: ISTRUC DATABUS_STRUC
                at  DATABUS_STRUC.0,     dq .0
                at  DATABUS_STRUC.1,     dq .1
                at  DATABUS_STRUC.2,     dq .2
                at  DATABUS_STRUC.3,     dq .3
                at  DATABUS_STRUC.4,     dq .4
                at  DATABUS_STRUC.5,     dq .5
                at  DATABUS_STRUC.6,     dq .6
                at  DATABUS_STRUC.7,     dq .7
            IEND
            
        ; the first BIT is the datatype structure, the second with numbering the name of the memoryaddress
        BIT .0
        BIT .1
        BIT .2
        BIT .3
        BIT .4
        BIT .5
        BIT .6
        BIT .7
        
    %endmacro

%endif