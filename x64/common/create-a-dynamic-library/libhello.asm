; Name:        libhello
; Build:       see makefile
; Description:	A "simple" shared library to use with hello.asm
; This program is a result of reading the nasm manual and reading all over the internet.
;
; My conclusion is that there is no such thing as an easy way to create shared libraries.
; At least not when you are a true beginner.
; Looking at the programcode you will understand why dynamic libraries aren't a good option to improve speed.
; My general rule is: don't make shared libraries unless it is really needed.
;
; Also it is wise to keep the ABI in consideration when you want to use shared libraries in your C (C++) programs.
; This is NOT being done in this example.

bits 64

[list -]
     %include "unistd.inc"
[list +]

align 16

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

; macro to initiate and export the global procedure while defining it as a PROCEDURE, so we don't forget to export it
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

section .data

    GLOBALDATA	 hellostring,db,{"hello from the library...", 10}
    GLOBALDATA  hellostring.length,dq,hellostring.end-hellostring
    GLOBALDATA	 hellostring.pointer,dq,hellostring
    
section .text
_start:

PROCEDURE WriteInternalString
      call     GetString
      mov      rdi, STDOUT
      mov      rax, SYS_WRITE
      syscall
ENDP WriteInternalString

; this procedure has RSI, RDX set to the string and his length we want to print
PROCEDURE WriteExternalString
      mov      rdi, STDOUT
      mov      rax, SYS_WRITE
      syscall
ENDP WriteExternalString

; get the pointer to the libary string and his length
PROCEDURE GetString
      call	GetStringPointer
      mov      rax, rsi                 ; move pointer to stringpointer in RAX
      mov      rsi, [rax]               ; move stringpointer in RSI
      mov 	rax, rdx
      mov 	rdx, [rax]
ENDP GetString

; get the pointer to the string and pointer to his length
PROCEDURE GetStringPointer
      mov 	rsi, QWORD [rbx + hellostring.pointer wrt ..got]
      mov 	rdx, QWORD [rbx + hellostring.length wrt ..got]
ENDP GetStringPointer

PROCEDURE SetStringPointer
      mov 	QWORD [rbx + hellostring.pointer wrt ..got], rsi
      mov 	QWORD [rbx + hellostring.length wrt ..got], rdx
ENDP SetStringPointer

PROCEDURE SetString
; following code is NOT the same as in SetStringPointer.
; Here we modify the stringpointer directly by obtaining the address to it in RAX and put the stringpointer in that location.
; example of indirect addressing
      mov 	rax, QWORD [rbx + hellostring.pointer wrt ..got]
      mov 	[rax], rsi
; same as for the lengtgh of the string      
      mov 	rax, QWORD [rbx + hellostring.length wrt ..got]
      mov 	[rax], rdx
ENDP SetString
