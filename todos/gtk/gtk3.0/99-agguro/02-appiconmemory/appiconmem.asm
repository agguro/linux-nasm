; Name        : appiconmem.asm
;
; Build       : nasm -felf64 -o appiconmem.o -l appiconmem.lst appiconmem.asm
;               ld -s -m elf_x86_64 appiconmem.o -o appiconmem -lc --dynamic-linker /lib64/ld-linux-x86-64.so.2
;               -lgtk-3 -lgobject-2.0  -lglib-2.0 -lgdk_pixbuf-2.0 -lgdk-3
;
; Description : setting an application icon from memory and display the same icon as image in a window
;
; C - source  : http://zetcode.com/gui/gtk2/firstprograms/
;               http://stackoverflow.com/questions/14121166/gdk-pixbuf-load-image-from-memory
; remark      : I was bored always copying icons when moving applications to another location, that's why I figured
;               out how I could load an image from memory.  Both methods take space on the disk, the benefit of an
;               icon in your application is that it's always there.

bits 64

[list -]
    extern    exit
    extern    gtk_init
    extern    gtk_window_new
    extern    gtk_window_set_title
    extern    gtk_window_set_default_size
    extern    gtk_window_set_position
    extern    gtk_window_set_icon
    extern    gtk_widget_show_all
    extern    gtk_main
    extern    gtk_main_quit
    extern    g_signal_connect_data
    extern    gdk_pixbuf_new_from_file
    extern    gdk_pixbuf_loader_new
    extern    gdk_pixbuf_loader_write
    extern    gdk_pixbuf_loader_get_pixbuf
    extern    gtk_image_new_from_pixbuf
    extern    gtk_container_add   
[list +]

    %define   GTK_WINDOW_TOPLEVEL   0
    %define   GTK_WIN_POS_CENTER    1

section .data
    logo:          incbin    "../logo.png"            ; include contents from the file logo.png
    .size:         equ  $-logo
    
    window:
    .handle:       dq   0
    .title:        db   "window with application icon",0
    signal:
    .destroy:      db   "destroy",0
    
    loader:        dq   0
    pixbuffer:     dq   0
    image:         dq   0
    
section .text
    global _start

_start:
    xor     rsi, rsi                  ; argv
    xor     rdi, rdi                  ; argc
    call    gtk_init
    
    call    gdk_pixbuf_loader_new
    mov     qword [loader], rax
    mov     rdi, qword[loader]
    mov     rsi, logo
    mov     edx, logo.size
    xor     rcx, rcx
    call    gdk_pixbuf_loader_write
    
    mov     rdi, qword[loader]
    call    gdk_pixbuf_loader_get_pixbuf
    mov     qword[pixbuffer], rax
    
    mov     rdi,GTK_WINDOW_TOPLEVEL
    call    gtk_window_new
    mov     qword [window.handle], rax

    mov     rdi, qword[pixbuffer]
    call    gtk_image_new_from_pixbuf
    mov     qword[image], rax
    
    mov     rdi, qword[window.handle]
    mov     rsi, qword[image]
    call    gtk_container_add
    
    mov     rdi, qword [window.handle]
    mov     rsi, window.title
    call    gtk_window_set_title

    mov     rdi, qword [window.handle]
    mov     rsi, 230
    mov     rdx, 150
    call    gtk_window_set_default_size
    
    mov     rdi, qword [window.handle]
    mov     rsi, GTK_WIN_POS_CENTER
    call    gtk_window_set_position

    mov     rdi, qword [window.handle]
    mov     rsi, qword [pixbuffer]
    call    gtk_window_set_icon

    xor     r9d, r9d                        ; combination of GConnectFlags 
    xor     r8d, r8d                        ; a GClosureNotify for data
    mov     rcx, qword[window.handle]       ; pointer to the data to pass
    mov     rdx, gtk_main_quit              ; pointer to the handler
    mov     rsi, signal.destroy             ; pointer to the signal
    mov     rdi, qword[window.handle]       ; pointer to the widget instance
    call    g_signal_connect_data           ; the value in RAX is the handler, but we don't store it now

    mov     rdi, qword [window.handle]
    call    gtk_widget_show_all

    call    gtk_main
Exit:
    xor     rdi, rdi                        ; we don't expect much errors now
    call    exit
