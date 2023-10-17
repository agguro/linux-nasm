;name        : global.asm
;description : additional chapter to use the examples in the book
;              Modern X86 Assembly Language Programming 2nd Edition with g++, Nasm and Linux
;build       : mkdir build && cd build && qmake .. && make
;use         : extern "C" int get_variable_from_asm_();
;              extern "C" int get_variable_from_c_();
;              extern "C" void run_c_function_(void(*function)());
;              extern "C" void* function_from_asm_();
;              extern "C" int variable_from_asm_;

bits 64

[list -]
    %include "unistd.inc"
[list +]

; variables originating from C/C++ source
extern variable_from_c:data

; variable originting from assembly source
global variable_from_asm_:data variable_from_asm_.end - variable_from_asm_
global constant_from_asm_:data constant_from_asm_.end - constant_from_asm_

; routines exposed to C/C++
global get_variable_from_c_:function
global get_variable_from_asm_:function
global run_c_function_:function
global function_from_asm_:function

;contant values
section .rodata
    constant_from_asm_:   dq  9876
    .end:
    message:    db   "this output came from a asm function ran in C/C++ using his pointer",0x0a
    .length:    equ  $-message

; variables
section .data
    variable_from_asm_:   dq  54321
    .end:

section .text

get_variable_from_asm_:
    mov     rax,variable_from_asm_
    mov     rax,[rax]
    ret

get_variable_from_c_:
    mov     rax,variable_from_c
    mov     rax,[rax]
    ret

run_c_function_:
    mov     rax,rdi
    call    rax
    ret

function_from_asm_:
    syscall write,stdout,message,message.length
    ret
