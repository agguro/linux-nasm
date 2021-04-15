;name: x11hello.asm
;
;description: a x11 windows with some text.
;

bits 64

%include "../x11hello/x11hello.inc"

global main

align 16

section .bss
;uninitialized read-write data 
    d:              resq    1       ;pointer to display
    w:              resq    1       ;pointer to window
    e:              resb    192     ;XEvent structure counts 192 bytes
    gc:             resq    1       ;graphic context
    r:              resq    1       ;rootwindow
    blackpixel:     resq    1
    whitepixel:     resq    1

section .data
;initialized read-write data, structure definitions are in x11hello.inc
    s istruc SCREEN
        at    SCREEN.ext_data,          dq    0   ;XExtData* - hook for extension to hang data
        at    SCREEN.display,           dq    0   ;struct _XDisplay* - back pointer to display structure
        at    SCREEN.root,              dq    0   ;Window - Root window id
        at    SCREEN.width,             dd    0   ;int - width of screen
        at    SCREEN.height,            dd    0   ;int - height of screen
        at    SCREEN.mwidth,            dd    0   ;int width of  in millimeters
        at    SCREEN.mheight,           dd    0   ;int height of  in millimeters
        at    SCREEN.ndepths,           dd    0   ;int - number of depths possible
        at    SCREEN.depths,            dq    0   ;Depth* - list of allowable depths on the screen
        at    SCREEN.root_depth,        dd    0   ;int - bits per pixel
        at    SCREEN.root_visual,       dq    0   ;Visual* - root visual
        at    SCREEN.default_gc,        dq    0   ;GC - GC for the root root visual
        at    SCREEN.cmap,              dq    0   ;Colormap - default color map
        at    SCREEN.white_pixel,       dq    0   ;unsigned long - White pixel values
        at    SCREEN.black_pixel,       dq    0   ;unsigned long - Black pixel values
        at    SCREEN.max_maps,          dd    0   ;int - max color maps
        at    SCREEN.min_maps,          dd    0   ;int - min color maps
        at    SCREEN.backing_store,     dd    0   ;int - Never, WhenMapped, Always
        at    SCREEN.save_unders,       dd    0   ;Bool
        at    SCREEN.root_input_mask,   dd    0   ;long - initial root input mask
    iend

section .rodata
;read-only data
    msg:    db  "Hello, World!"
    .len:   equ $-msg

section .text

main:
    ; d = XOpenDisplay(NULL);
    push    rbp
    mov     rbp,rsp
    sub     rsp,0x20

    xor     rdi,rdi
    call    XOpenDisplay
    and     rax,rax
    jz      errordisplay    ;cannot open display
    mov     qword[d],rax    ;save d

    mov    eax,dword[rax+0xe0]
    mov    rax,d
    mov    rax,[rax]
    add    rax,XDISPLAY.default_screen-XDISPLAY
    mov    eax,[rax]
    mov    dword [s],eax

    mov    rax,qword[d]
    mov    rax,qword[rax+0xe8]
    mov    edx,dword[s]
    shl    rdx,0x7
    add    rax,rdx
    mov    rax,qword [rax+0x10]
    mov    qword [r],rax

    mov    rax,qword[d]
    mov    rax,qword[rax+0xe8]
    mov    edx,dword[s]
    shl    rdx,0x7
    add    rax,rdx
    mov    rax,qword[rax+0x60]
    mov    qword[blackpixel],rax

    mov    rax,qword[d]
    mov    rax,qword[rax+0xe8]
    mov    edx,dword[s]
    shl    rdx,0x7
    add    rax,rdx
    mov    rax,qword[rax+0x58]
    mov    qword[whitepixel],rax

    mov    rax,qword[d]
    mov    rax,qword[rax+0xe8]
    mov    edx,dword[s]
    shl    rdx,0x7
    add    rax,rdx
    mov    rax,qword[rax+0x48]
    mov    qword[gc],rax

    push    qword[whitepixel]
    push    qword[blackpixel]
    push    qword 1
    mov     r9,HEIGHT
    mov     r8,WIDTH
    mov     rcx,10
    mov     rdx,10
    mov     rsi,qword[r]
    mov     rdi,qword[d]
    call    XCreateSimpleWindow
    mov     qword[w],rax

    mov     rdx,ExposureMask|KeyPressMask
    mov     rsi,qword[w]
    mov     rdi,qword[d]
    call    XSelectInput

    mov     rsi,qword[w]
    mov     rdi,qword[d]
    call    XMapWindow

    add     rsp,0x18
.repeat:
    mov     rsi,e
    mov     rdi,qword[d]
    call    XNextEvent

    ;    if (e.type == Expose) {
    mov     eax,[e]                         ;e.type
    cmp     eax,Expose
    jnz     .keypress

    push    10
    mov     r9d,10
    mov     r8d,20
    mov     ecx,20
    mov     rdx,[gc]
    mov     rsi,[w]
    mov     rdi,[d]
    call    XFillRectangle

    push    qword msg.len
    mov     r9,msg
    mov     r8,50
    mov     rcx,10
    mov     rdx,[gc]
    mov     rsi,qword[w]
    mov     rdi,[d]
    call    XDrawString
    jmp     .repeat
.keypress:
    cmp     eax,KeyPress
    je      .break
    jmp     .repeat

.break:

    mov     rsp,rbp
    pop     rbp
    mov     rdi,qword[d]
    call    XCloseDisplay

errordisplay:
    xor     rax,rax             ;return error code
    ret                         ;exit is handled by compiler
