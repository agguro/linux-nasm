;name: sayhello.asm
;
;description:
;

bits 64

%include "../QtWidgetNasm/inc/sayhello.inc"

global sayhello

section .rodata
    ;for QStrings we must use unicode
    hello:  db  "H",0,"e",0,"l",0,"l",0,"o",0," ",0,"f",0,"r",0,"o",0,"m",0," ",0,"N",0,"a",0,"s",0,"m",0,".",0,0

section .text

sayhello:
    ;return pointer to caller
    mov rax, hello
    ret
