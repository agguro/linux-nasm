;name : windowicon.asm
;
;build : /usr/bin/nasm -felf64 -Fdwarf -g -o windowicon.o windowicon.asm
;        ld --dynamic-linker /lib64/ld-linux-x86-64.so.2 -no-pie -melf_x86_64 -g -o windowicon windowicon.o -lc -lgtk-x11-2.0 -lgdk-x11-2.0 -lgobject-2.0 -lgdk_pixbuf-2.0
;
;description : a simple window with application icon
;
; Remark      : when copying the application to another location you need to copy the image file 'favicon.png' in the same directory.
;
;source : http://zetcode.com/gui/gtk2/firstprograms/

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

section .rodata
    szTitle:        db   "icon",0
    szDestroy:      db   "destroy",0
    szFile:         db   "icon.png",0                   ;must be in the build directory
    szErrPixbuf:    db   "ERROR loading %s",10,0

section .bss
    window:         resq   1
    icon:           resq   1
    pixbuffer:      resq   1
    error:          resq   1
    
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
    mov     qword [window],rax
    ;set the title
    mov     rdi,qword [window]
    mov     rsi,szTitle
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
    mov     rdi,szFile
    mov     rsi,error
    call    gdk_pixbuf_new_from_file
    mov     qword [pixbuffer],rax
    and     rax,rax
    jnz     .no_icon_file_error
    ;print error to terminal if there was an error
    mov     rsi,szFile
    mov     rdi,szErrPixbuf
    xor     rax,rax
    call    printf
    jmp     .skiploadicon
    ;if no erro then the image is in the pixel buffer
    ;and we can set the icon
.no_icon_file_error:     
    mov     rdi,qword [window]
    mov     rsi,qword [pixbuffer]
    call    gtk_window_set_icon
.skiploadicon:
    ;connect signal destroy with gtk_main_quit event handler
    xor     r9d,r9d                  ; combination of GConnectFlags 
    xor     r8d,r8d                  ; a GClosureNotify for data
    xor     rcx,rcx                  ; pointer to the data to pass
    mov     rdx,gtk_main_quit        ; pointer to the handler
    mov     rsi,szDestroy            ; pointer to the signal
    mov     rdi,qword[window]        ; pointer to the widget instance
    call    g_signal_connect_data    ; the value in RAX is the handler, but we don't store it now
    ;show the window
    mov     rdi,qword [window]
    call    gtk_widget_show
    ;enter process loop
    call    gtk_main
    ;exi program
    xor     rdi,rdi
    call    exit
