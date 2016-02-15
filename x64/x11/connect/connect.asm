%include "unistd.inc"

extern XOpenDisplay
extern XDisplayName
extern XCloseDisplay
extern printf
extern exit
extern puts

bits 64
section .bss
display_name:  resq      1
screen:        resd      1
depth:         resd      1
connection:    resd      1
width:         resd      1
height:        resd      1

section .data
string1:  db "The display is %s",10, 0
string2:  db "Width : %d",10, 0
string6:  db "Height : %d", 10, 0
string3:  db "Connection number is %d", 10, 0
string4:  db "You live in prehistoric times",10, 0
string5:  db "You have got a coloured monitor with depth of %d",10, 0

section .text

global _start

_start:

mov    edi,0x0
call   XOpenDisplay
mov    QWORD [display_name],rax

; display_name structure

; screen = DefaultScreen(display_name);
mov    rax,QWORD [display_name]
mov    eax,DWORD [rax+0xe0]
mov    DWORD [screen],eax

; depth = DefaultDepth(display_name,screen);
mov    rax,QWORD [display_name]
mov    rax,QWORD [rax+0xe8]
mov    edx,DWORD [screen]
movsxd rdx,edx
shl    rdx,0x7
add    rax,rdx
mov    eax,DWORD [rax+0x38]
mov    DWORD [depth],eax

; connection = ConnectionNumber(display_name);
mov    rax,QWORD [display_name]
mov    eax,DWORD [rax+0x10]
mov    DWORD [connection],eax                     ; rbp-0xc
;printf("The display is::%s\n",XDisplayName((char*)display_name));
mov    rax,QWORD [display_name]
mov    rdi,rax
call   XDisplayName
mov    rsi,rax
mov    edi,string1
mov    eax,0x0
call   printf

mov    rax,QWORD [display_name]
mov    rax,QWORD [rax+0xe8]
mov    edx,DWORD [screen]
movsxd rdx,edx
shl    rdx,0x7
add    rax,rdx
mov    eax,DWORD [rax+0x18]
mov    DWORD[width], eax

mov    esi,eax
mov    edi,string2
mov    eax,0x0
call   printf

mov    rax,QWORD [display_name]
mov    rax,QWORD [rax+0xe8]
mov    edx,DWORD [screen]
movsxd rdx,edx
shl    rdx,0x7
add    rax,rdx
mov    eax,DWORD [rax+0x1c]
mov    DWORD[height], eax

mov    esi,eax
mov    edi,string6
mov    eax,0x0
call   printf

mov    eax,DWORD [connection]
mov    esi,eax
mov    edi,string3
mov    eax,0x0
call   printf

; if(depth == 1)
cmp    DWORD [depth],0x1
jne    showDepth
; printf("You live in prehistoric times\n");
mov    edi,string4
call   puts
jmp    closeDisplay
;else
;                printf("You've got a coloured monitor with depth of %d\n",
showDepth:
mov    eax,DWORD [depth]
mov    esi,eax
mov    edi,string5
mov    eax,0x0
call   printf

closeDisplay:
mov    rax,QWORD [display_name]
mov    rdi,rax
call   XCloseDisplay

syscall exit, 0