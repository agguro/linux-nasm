;name:  hello-x.asm
;
;build: nasm -felf64 -o hello-x.o hello-x.asm
;       ld -g -melf_x86_64 hello-x.o -o hello-x -lc --dynamic-linker /lib64/ld-linux-x86-64.so.2 -lX11
;
;description:

;the XDisplay structure is derived from Xlib.h
struc XDISPLAY
    .unknown1:              resq    1   ;  0 0x00 XExtData* hook for extension to hang data
    .private1:              resq    1   ;  8 0x08 struct _XPrivate*
    .fd:                    resd    1   ; 16 0x10 int Network socket
    .private2:              resd    1   ; 20 0x14 int                                      
    .proto_major_version:   resd    1   ; 24 0x18 int - major version of server's X protocol
    .proto_minor_version:   resd    1   ; 28 0x1C int - minor version of servers X protocol
    .vendor:                resq    1   ; 32 0x20 char* - vendor of the server hardware
    .private3:              resq    1   ; 40 0x28 XID 
    .private4:              resq    1   ; 48 0x30 XID
    .private5:              resq    1   ; 56 0x38 XID
    .private6:              resq    1   ; 64 0x40 int                                           
    .resource_alloc:        resq    1   ; 72 0x48 XID - allocator function struct _XDisplay*
    .byte_order:            resd    1   ; 80 0x4C int - screen byte order, LSBFirst, MSBFirst   
    .bitmap_unit:           resd    1   ; 84 0x50 int - padding and data requirements
    .bitmap_pad:            resd    1   ; 88 0x54 int - padding requirements on bitmaps
    .bitmap_bit_order:      resd    1   ; 92 0x58 int - LeastSignificant or MostSignificant
    .nformats:              resd    1   ; 96 0x5C int - number of pixmap formats in list
    .pixmap_format:         resq    1   ;100 0x60 ScreenFormat* - pixmap format list
    .private8:              resd    1   ;108 0x68 int
    .release:               resd    1   ;112 0x6C int release of the server
    .private9:              resq    1   ;116 0x70 struct _XPrivate*
    .private10:             resq    1   ;124 0x78 struct _XPrivate*
    .qlen:                  resd    1   ;132 0x80 Length of input event queue
    .last_request_read:     resq    1   ;136 0x84 seq number of last event read
    .request:               resq    1   ;144 0x8C sequence number of last request
    .private11:             resq    1   ;152 0x94 XPointer
    .private12:             resq    1   ;160 0x9C XPointer
    .private13:             resq    1   ;168 0xA4 XPointer
    .private14:             resq    1   ;176 0xAC XPointer
    .max_request_size:      resd    1   ;184 0xB4 maximum number 32 bit words in request
    .db:                    resq    1   ;188 0xB8 struct _XrmHashBucketRec*
    .private15:             resq    1   ;196 0xC0 int* - struct _XDisplay*
    .display_name:          resq    1   ;204 0xC8 char* - "host:display" string used on this connect
    .default_screen:        resd    1   ;212 0xD0 int - default screen for operations
    .nscreens:              resd    1   ;216 0xD4 int - number of screens on this server
    .screens:               resq    1   ;220 0xD8 Screen* - pointer to list of screens
    .motion_buffer:         resq    1   ;228 0xE0 size of motion buffer
    .private16:             resq    1   ;236 0xE8
    .min_keycode:           resd    1   ;244 0xF0 minimum defined keycode
    .max_keycode:           resd    1   ;248 0xF4 maximum defined keycode
    .private17:             resq    1   ;252 0xF8 XPointer 
    .private18:             resq    1   ;260 0x100 XPointer 
    .private19:             resd    1   ;264 0x108 int 
    .xdefaults:             resq    1   ;268 0x10C char* - contents of defaults from server
    ;there is more to this structure, but it is private to Xlib
endstruc

struc SCREEN
    .ext_data:              resq    1   ;8   0  0x00 XExtData* - hook for extension to hang data
    .display:               resq    1   ;8   8  0x08 struct _XDisplay* - back pointer to display structure
    .root:                  resq    1   ;8  16  0x10 Window - Root window id.
    .width:                 resd    1   ;4  24  0x18 int - width of screen
    .height:                resd    1   ;4  28  0x1C int - height of screen
    .mwidth:                resd    1   ;4  32  0x20 int width of  in millimeters
    .mheight:               resd    1   ;4  36  0x24 int height of  in millimeters
    .ndepths:               resd    1   ;4  40  0x28 int - number of depths possible
    .depths:                resq    1   ;8  44  0x30 Depth* - list of allowable depths on the screen
    .root_depth:            resd    1   ;4  52  0x38 int - bits per pixel
    .root_visual:           resq    1   ;8  56  0x38 Visual* - root visual
    .default_gc:            resq    1   ;8  64  0x40 GC - GC for the root root visual
    .cmap:                  resq    1   ;8  72  0x48 Colormap - default color map
    .white_pixel:           resq    1   ;8  80  0x50 unsigned long - White pixel values 
    .black_pixel:           resq    1   ;8  88  0x58 unsigned long - Black pixel values
    .max_maps:              resd    1   ;4  96  0x60 int - max color maps
    .min_maps:              resd    1   ;4 100  0x64 int - min color maps
    .backing_store:         resd    1   ;4 104  0x68 int - Never, WhenMapped, Always
    .save_unders:           resd    1   ;4 108  0x6C Bool
    .root_input_mask:       resq    1   ;8 112  0x70 long - initial root input mask
endstruc

struc SCREENFORMAT
    .ext_data:              resq    1   ;8   0  0x00 XExtData* - hook for extension to hang data
    .depth:                 resd    1   ;8  44  0x30 Depth* - list of allowable depths on the screen
    .bits_per_pixel:        resd    1   ;4  52  0x38 int - bits per pixel
    .scanline_pad:          resd    1   ;8  56  0x38 Visual* - root visual
endstruc


%include "unistd.inc"

extern XOpenDisplay                                                                                                                                                           
extern XCreateSimpleWindow
extern XSelectInput
extern XMapWindow
extern XNextEvent
extern XFillRectangle
extern XDrawString
extern XCloseDisplay

%define ExposureMask 1 << 15
%define KeyPressMask 1 << 0
%define Expose  12
%define KeyPress 2

section .bss

    d:              resq    1   ;structure _XDisplay
    w:              resq    1   ;
    e:              resb    192 ;XEvent structure counts 192 bytes
    gc:             resq    1
    rootwindow:     resq    1
    blackpixel:     resq    1
    whitepixel:     resq    1

section .rodata

    msg:    db  "Hello, World!"
    .len:   equ $-msg

section .data

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

section .text

; d = XOpenDisplay(NULL);
; if (d == NULL) {
;     fprintf(stderr, "Cannot open display\n");
;     exit(1);
; }

global _start
_start:
    push    rbp
    mov     rbp,rsp
    sub     rsp,8

    xor     rdi,rdi
    call    XOpenDisplay
    add     rsp,8
    mov     qword[d],rax
    and     rax,rax
    jz      errordisplay    ;cannot open display

    mov     qword[d],rax
    ;default screen, blackpixel, whitepixel and rootwindow are parts of the display structure
    ;
    ; s = DefaultScreen(d);
    mov    rax,qword[d]
    mov    eax,dword[rax+XDISPLAY.motion_buffer-XDISPLAY]

    mov    rax,d
    mov    rax,[rax]
    add    rax,XDISPLAY.default_screen-XDISPLAY
    mov    eax,[rax]


    mov    dword[s],eax

    ;unsigned int r = RootWindow(d, s);
    mov    rax,qword[d]
    mov    rax,qword[rax+XDISPLAY.private16-XDISPLAY]
    mov    edx,dword[s]
    shl    rdx,0x7
    add    rax,rdx
    mov    rax,qword[rax+XDISPLAY.fd-XDISPLAY]
    mov    qword[rootwindow],rax

    ;unsigned int bp = BlackPixel(d,s);
    mov    rax,qword[d]
    mov    rax,qword[rax+XDISPLAY.private16-XDISPLAY]
    mov    edx,dword[s]
    shl    rdx,0x7
    add    rax,rdx
    mov    rax,qword[rax+XDISPLAY.pixmap_format-XDISPLAY]
    mov    qword  [blackpixel],rax

    ;unsigned int wp = WhitePixel(d,s);
    mov    rax,qword  [d]
    mov    rax,qword  [rax+XDISPLAY.private16-XDISPLAY]
    mov    edx,qword  [s]
    shl    rdx,0x7
    add    rax,rdx
    mov    rax,qword  [rax+XDISPLAY.bitmap_bit_order-XDISPLAY]
    mov    qword  [whitepixel],rax

    ;GC gc = DefaultGC(d,s);
    mov    rax,qword  [d]
    mov    rax,qword  [rax+XDISPLAY.private16-XDISPLAY]
    mov    edx,qword  [s]
    shl    rdx,0x7
    add    rax,rdx
    mov    rax,qword  [rax+.resource_alloc]
    mov    qword  [gc],rax

    ; w = XCreateSimpleWindow(d, RootWindow(d, s), 10, 10, 100, 100, 1, BlackPixel(d, s), WhitePixel(d, s));

    push    qword[whitepixel]
    push    qword[blackpixel]
    push    qword 1
    mov     r9,100
    mov     r8,100
    mov     rcx,10
    mov     rdx,10
    mov     rsi,qword[rootwindow]
    mov     rdi,qword[d]
    call    XCreateSimpleWindow
    mov     qword[w],rax
    add     rsp,0x18                        ;adjust stack (3 push instructions before)

    ;XSelectInput(d, w, ExposureMask | KeyPressMask);

    mov     rdx,ExposureMask|KeyPressMask
    mov     rsi,qword[w]
    mov     rdi,qword[d]
    call    XSelectInput

    ;XMapWindow(d, w);

    mov     rsi,qword[w]
    mov     rdi,qword[d]
    call    XMapWindow
    ;
    ; while (1) {
.repeat:

    ;    XNextEvent(d, &e);
    sub     rsp,8
    mov     rsi,e
    mov     rdi,qword[d]
    call    XNextEvent
    ;add     rsp,8

    ;    if (e.type == Expose) {
    mov     eax,[e]                         ;e.type
    cmp     eax,Expose
    jnz     .nexttype


    ;XFillRectangle(d, w, DefaultGC(d, s), 20, 20, 10, 10);
    ;sub     rsp,8
    push    10
    mov     r9d,10
    mov     r8d,20
    mov     ecx,20
    mov     rdx,[gc]
    mov     rsi,[w]
    mov     rdi,[d]
    call    XFillRectangle
    add     rsp,8

    ;XDrawString(d, w, DefaultGC(d, s), 10, 50, msg, strlen(msg));
    ;sub     rsp,8
    push    qword msg.len
    mov     r9,msg
    mov     r8,50
    mov     rcx,10
    mov     rdx,[gc]
    mov     rsi,qword[w]
    mov     rdi,[d]
    call    XDrawString
    add     rsp,16
    jmp     .repeat
    .nexttype:
        cmp     eax,KeyPress
        jne     .repeat
;break

    mov     rdi,qword[d]
    call    XCloseDisplay

errordisplay:
    xor     rdi,rdi
    syscall exit,0
