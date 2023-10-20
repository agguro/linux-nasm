%ifndef GOT_INC
%define GOT_INC

extern  _GLOBAL_OFFSET_TABLE_

; five macros to make life a bit easier
; each global function/method/routine (whatever you call it) must start with the PROLOGUE
%macro PROLOGUE 0
    push      rbp
    mov       rbp,rsp
    push      rbx
    call      .get_GOT
.get_GOT:
    pop       rbx
    add       rbx,_GLOBAL_OFFSET_TABLE_+$$-.get_GOT wrt ..gotpc
%endmacro

; each global function/method/routine (whatever you call it) must end with the EPILOGUE
%macro EPILOGUE 0
    mov       rbx,[rbp-8]
    mov       rsp,rbp
    pop       rbp
    ret
%endmacro

; macro to initiate and export the global procedure while defining it as a PROCEDURE
; doing so it's harder to forget to export it
%macro PROCEDURE 1
global    %1:function
%1:
    PROLOGUE
%endmacro

; macro to end the procedure
%macro ENDP 1
    EPILOGUE
%endmacro

; self defined macro to declare global data and export it the same time
%macro GLOBALDATA 3
global    %1:data (%1.end - %1)
section   .data
    %1:	%2	%3
    %1.end:
%endmacro

%endif // GOT_INC
