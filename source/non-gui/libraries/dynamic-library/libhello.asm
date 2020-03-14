; Name:         libhello.asm
;
; Build:        nasm -felf64 -o libhello.o libhello.asm -l libhello.lst
;               ld -lc --dynamic-linker /lib64/ld-linux-x86-64.so.2 -shared -soname libhello.so -o libhello.so.1.0 libhello.o
;
; Description:	A "simple" shared library to use with hello.asm
;
; Remark:
; My conclusion is that there is no such thing as an easy way to create shared libraries.
; At least not when you are a true beginner.
; Looking at the programcode you will understand why dynamic libraries aren't a good option to improve speed.
; My general rule is: I don't make shared libraries unless it is really needed.
;
; Also it is wise to keep the ABI in consideration when you want to use shared libraries in your C (C++) programs.
; This is NOT being done in this example.

bits 64
align 16

[list -]
    %include "unistd.inc"
[list +]


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

; data section

GLOBALDATA	 hellostring,db,{"hello from the library...", 10}
GLOBALDATA   hellostring.length,dq,hellostring.end-hellostring
GLOBALDATA	 hellostring.pointer,dq,hellostring

; code section

section .text

_start:

    PROCEDURE WriteInternalString
        call     GetString
        ; offset and length of message already in rsi, rdx
        syscall write, stdout, rsi, rdx
    ENDP WriteInternalString

    ; this procedure has RSI, RDX set to the string and his length we want to print
    PROCEDURE WriteExternalString
        ; offset and length of message already in rsi, rdx
        syscall write, stdout, rsi, rdx
    ENDP WriteExternalString

    ; get the pointer to the libary string and his length
    PROCEDURE GetString
        call    GetStringPointer
        mov     rax, rsi                 ; move pointer to stringpointer in RAX
        mov     rsi, [rax]               ; move stringpointer in RSI
        mov 	rax, rdx
        mov 	rdx, [rax]       
    ENDP GetString

    ; set pointer to string and length of string
    PROCEDURE GetStringPointer
        mov 	rsi, qword [rbx + hellostring.pointer wrt ..got]
        mov 	rdx, qword [rbx + hellostring.length wrt ..got]
    ENDP GetStringPointer

    ; set pointer to string and length of string
    PROCEDURE SetStringPointer
        mov 	qword [rbx + hellostring.pointer wrt ..got], rsi
        mov 	qword [rbx + hellostring.length wrt ..got], rdx
    ENDP SetStringPointer

    ; next code is NOT the same as in SetStringPointer.
    ; Here we modify the stringpointer directly by obtaining the address to it in RAX and put the stringpointer in that location.
    ; example of indirect addressing
    PROCEDURE SetString
        mov     rax, qword [rbx + hellostring.pointer wrt ..got]
        mov 	[rax], rsi
        ; same as for the lengtgh of the string      
        mov 	rax, qword [rbx + hellostring.length wrt ..got]
        mov 	[rax], rdx
    ENDP SetString
