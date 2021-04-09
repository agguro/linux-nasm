;name: x11info.asm
;
;description: ;description: This is a first attempt to get X11 and nasm to work.
;             This program is taken from a c source file from Brian Hammond 2/9/96.
;             connect.c and rebuild to nasm, just because I like it.
;

bits 64

%include "../../../qmake/X11/x11info/x11info.inc"

global main

section .bss
;uninitialized read-write data 
    display_name:  resq     1
    screen:        resd     1
    depth:         resd     1
    connection:    resd     1
    width:         resd     1
    height:        resd     1

section .data
;initialized read-write data

section .rodata
;read-only data
    string1:  db "The display is %s",10, 0
    string2:  db "Width : %d",10, 0
    string6:  db "Height : %d", 10, 0
    string3:  db "Connection number is %d", 10, 0
    string4:  db "You live in prehistoric times",10, 0
    string5:  db "You have got a coloured monitor with depth of %d",10, 0

section .text

main:
    push    rbp
    mov     rbp,rsp

    xor     edi,edi
    call    XOpenDisplay
    mov     qword[display_name],rax
    ; display_name structure
    ; screen = DefaultScreen(display_name);
    mov     rax,qword[display_name]
    mov     eax,dword[rax+0xe0]
    mov     dword[screen],eax
    ; depth = DefaultDepth(display_name,screen);
    mov     rax,qword[display_name]
    mov     rax,qword[rax+0xe8]
    mov     edx,dword[screen]
    movsxd  rdx,edx
    shl     rdx,0x7
    add     rax,rdx
    mov     eax,dword[rax+0x38]
    mov     dword[depth],eax
    ;connection = ConnectionNumber(display_name);
    mov     rax,qword[display_name]
    mov     eax,dword[rax+0x10]
    mov     dword[connection],eax                     ; rbp-0xc
    ;printf("The display is::%s\n",XDisplayName((char*)display_name));
    mov     rax,qword[display_name]
    mov     rdi,rax
    call    XDisplayName
    mov     rsi,rax
    mov     edi,string1
    xor     eax,eax
    call    printf
    mov     rax,qword[display_name]
    mov     rax,qword[rax+0xe8]
    mov     edx,dword[screen]
    movsxd  rdx,edx
    shl     rdx,0x7
    add     rax,rdx
    mov     eax,dword[rax+0x18]
    mov     dword[width],eax
    mov     esi,eax
    mov     edi,string2
    xor     eax,eax
    call    printf
    mov     rax,qword[display_name]
    mov     rax,qword[rax+0xe8]
    mov     edx,dword[screen]
    movsxd  rdx,edx
    shl     rdx,0x7
    add     rax,rdx
    mov     eax,dword[rax+0x1c]
    mov     dword[height],eax
    mov     esi,eax
    mov     edi,string6
    xor     eax,eax
    call    printf
    mov     eax,dword[connection]
    mov     esi,eax
    mov     edi,string3
    xor     eax,eax
    call    printf
    ; if(depth == 1)
    cmp     dword[depth],0x1
    jne     showDepth
    ; printf("You live in prehistoric times\n");
    mov     edi,string4
    call    puts
    jmp     closeDisplay
    ;else printf("You've got a coloured monitor with depth of %d\n",
showDepth:
    mov     eax,dword[depth]
    mov     esi,eax
    mov     edi,string5
    xor     eax,eax
    call    printf
closeDisplay:
    mov     rax,qword[display_name]
    mov     rdi,rax
    call    XCloseDisplay

    xor     rax,rax             ;return error code
    mov     rsp,rbp
    pop     rbp
    ret                         ;exit is handled by compiler
