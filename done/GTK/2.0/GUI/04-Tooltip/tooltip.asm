;name : tooltip.asm
;
;build : /usr/bin/nasm -felf64 -Fdwarf -g -o tooltip.o tooltip.asm
;        ld --dynamic-linker /lib64/ld-linux-x86-64.so.2 -no-pie -melf_x86_64 -g -o tooltip tooltip.o -lc -lgtk-x11-2.0 -lgdk-x11-2.0 -lgobject-2.0 -lgdk_pixbuf-2.0
;
;description : a button with a tooltip in a simple window. Hoover over the button and wait...
;
;source : http://zetcode.com/gui/gtk2/firstprograms/

bits 64

[list -]
    extern    gtk_init
    extern    gtk_window_new
    extern    gtk_window_set_title
    extern    gtk_window_set_default_size
    extern    gtk_container_set_border_width
    extern    gtk_button_new_with_label
    extern    gtk_widget_set_tooltip_text
    extern    gtk_alignment_new
    extern    gtk_container_add
    extern    gtk_widget_show_all
    extern    gtk_main_quit
    extern    g_signal_connect_data
    extern    gtk_main
    extern    exit
[list +]

section .rodata
    szTitle:         db  "Tooltip", 0
    szDestroy:       db  "destroy", 0
    szCaption:       db  "Button", 0
    szTooltip:       db  "Button Widget",0

section .bss
    window:        resq  1
    button:        resq  1
    halign:        resq  1
        
section .text

global _start
_start:
    ;init gtk
    xor     rsi,rsi                         ;argv
    xor     rdi,rdi                         ;argc
    call    gtk_init
    ;the main window
    xor     rdi,rdi                         ;GTK_WINDOW_TOPLEVEL
    call    gtk_window_new
    mov     qword[window],rax
    ;set title
    mov     rdi,qword[window]         
    mov     rsi,szTitle
    call    gtk_window_set_title
    ;set size
    mov     rdi,qword[window]         
    mov     rsi,300                         ;width
    mov     rdx,200                         ;height
    call    gtk_window_set_default_size
    ;set border width
    mov     rdi,qword[window]         
    mov     rsi,15                          ;borderwidth
    call    gtk_container_set_border_width
    ;create a button
    mov     rdi,szCaption
    call    gtk_button_new_with_label
    mov     qword[button],rax
    ;set the button tooltip
    mov     rdi,qword[button]
    mov     rsi,szTooltip
    call    gtk_widget_set_tooltip_text
    ;horizontal alignment
    xor     rdi,rdi
    inc rdi
    xor     rsi,rsi
    xor     rdx,rdx
    call    gtk_alignment_new
    mov     qword[halign],rax
    ;add the button to the halign container
    mov     rdi,qword[halign]
    mov     rsi,qword[button]
    call    gtk_container_add
    ;add the halign container to the window
    mov     rdi,qword[window]
    mov     rsi,qword[halign]
    call    gtk_container_add
    ;show window
    mov     rdi,qword[window]
    call    gtk_widget_show_all
    ;connect destroy signal to the window
    xor     r9d,r9d                      ;combination of GConnectFlags
    xor     r8d,r8d                      ;a GClosureNotify for data
    mov     rcx,qword[window]            ;pointer to window instance in RCX
    mov     rdx,gtk_main_quit            ;pointer to the handler
    mov     rsi,szDestroy                ;pointer to the signal
    mov     rdi,qword[window]            ;pointer to window instance in RDI
    call    g_signal_connect_data        ;the value in RAX is the handler, but we don't store it now
    ;go into application main loop
    call    gtk_main
    ;exit program
    xor     rdi, rdi
    call    exit
