; Name        : applicationicon.asm
;
; Build       : nasm -felf64 -o applicationicon.o -l applicationicon.lst applicationicon.asm
;               ld -s -m elf_x86_64 applicationicon.o -o applicationicon -lc --dynamic-linker /lib64/ld-linux-x86-64.so.2
;               -lgtk-3 -lgobject-2.0  -lglib-2.0 -lgdk_pixbuf-2.0 -lgdk-3
;
; Description : a simple window with the basic functionalities and a title, centered on screen with application icon
;
; Remark      : when copying the application to another location you need to copy the image file 'logo.png' with it in
;               the same directory.
;
; C - source  : http://zetcode.com/gui/gtk2/firstprograms/

bits 64

[list -]
    extern    exit
    extern    printf
    extern    gtk_init
    extern    gtk_window_new
    extern    gtk_window_set_title
    extern    gtk_window_set_default_size
    extern    gtk_window_set_position
    extern    gtk_window_set_icon
    extern    gtk_widget_show
    extern    gtk_main
    extern    gtk_main_quit
    extern    g_signal_connect_data
    extern    gdk_pixbuf_new_from_file
    %define   GTK_WINDOW_TOPLEVEL   0
    %define   GTK_WIN_POS_CENTER    1
[list +]

section .data
    window:
    .handle:    dq   0
    .title:     db   "window with application icon",0
    signal:
    .destroy:   db   "destroy",0
    icon:
    .pixbuffer: dq   0
    .file:      db   "logo.png",0                   ;must reside in the same directory
    .error:     dq   0
    error:
    .pixbuf:    db   "ERROR loading %s",10,0

section .text
    global _start

_start:
    ;init gtk
    xor     rsi,rsi                                ;argv
    xor     rdi,rdi                                ;argc
    call    gtk_init
    ;create a new window
    mov     rdi,GTK_WINDOW_TOPLEVEL
    call    gtk_window_new
    mov     qword [window.handle], rax
    ;set the title
    mov     rdi,qword [window]
    mov     rsi,window.title
    call    gtk_window_set_title
    ;set the size
    mov     rdi,qword [window]
    mov     rsi,230
    mov     rdx,150
    call    gtk_window_set_default_size
    ;set the position
    mov     rdi,qword [window]
    mov     rsi,GTK_WIN_POS_CENTER
    call    gtk_window_set_position
    ;load imagefile in a pixbuffer
    mov     rdi,icon.file
    mov     rsi,icon.error
    call    gdk_pixbuf_new_from_file
    mov     qword [icon.pixbuffer],rax
    and     rax,rax
    jnz     .no_icon_file_error
    ;print error to terminal if there was an error
    mov     rsi,icon.file
    mov     rdi,error.pixbuf
    xor     rax,rax
    call    printf
    jmp     .skiploadicon
    ;if no erro then the image is in the pixel buffer
    ;and we can set the icon
.no_icon_file_error:     
    mov     rdi,qword [window]
    mov     rsi,qword [icon.pixbuffer]
    call    gtk_window_set_icon
.skiploadicon:
    ;connect signal destroy with gtk_main_quit event handler
    xor     r9d,r9d                ; combination of GConnectFlags 
    xor     r8d,r8d                ; a GClosureNotify for data
    xor     rcx,rcx                ; pointer to the data to pass
    mov     rdx,gtk_main_quit      ; pointer to the handler
    mov     rsi,signal.destroy            ; pointer to the signal
    mov     rdi,qword[window]      ; pointer to the widget instance
    call    g_signal_connect_data   ; the value in RAX is the handler, but we don't store it now
    ;show the window
    mov     rdi,qword [window]
    call    gtk_widget_show
    ;enter process loop
    call    gtk_main
    ;exi program
    xor     rdi,rdi
    call    exit