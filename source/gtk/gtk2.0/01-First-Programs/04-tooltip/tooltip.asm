; Name        : tooltip.asm
;
; Build       : nasm -felf64 -o tooltip.o -l tooltip.lst tooltip.asm
;               ld -m elf_x86_64 -g --dynamic-linker /lib64/ld-linux-x86-64.so.2 -lc -lgtk-x11-2.0 -lglib-2.0 -lgobject-2.0 tooltip.o -o tooltip
;
; Description : tooltip demo
;
; C - source  : http://zetcode.com/gui/gtk2/firstprograms/

bits 64

[list -]
    extern gtk_init
    extern gtk_window_new
    extern gtk_window_set_title
    extern gtk_window_set_default_size
    extern gtk_container_set_border_width
    extern gtk_button_new_with_label
    extern gtk_widget_set_tooltip_text
    extern gtk_alignment_new
    extern gtk_container_add
    extern gtk_widget_show_all
    extern gtk_main_quit
    extern g_signal_connect_data
    extern gtk_main
    extern exit
[list +]

section .data
    window:
        .handle:    dq  0
        .title:     db  "Tooltip", 0
    signal:
        .destroy:   db  "destroy", 0
    button:
        .handle:    dq  0
        .caption:   db  "Button", 0
        .tooltip:   db  "Button Widget",0
    halign:
        .handle:    dq  0
        
    section .text

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
    mov     qword[window.handle],rax        ;save handle
    ;set title
    mov     rdi,qword[window.handle]         
    mov     rsi,window.title
    call    gtk_window_set_title
    ;set size
    mov     rdi,qword[window.handle]         
    mov     rsi,300                         ;width
    mov     rdx,200                         ;height
    call    gtk_window_set_default_size
    ;set border width
    mov     rdi,qword[window.handle]         
    mov     rsi,15                          ;borderwidth
    call    gtk_container_set_border_width
    ;create a button
    mov     rdi, button.caption
    call    gtk_button_new_with_label
    mov     qword[button.handle],rax        ;save handle
    ;set the button tooltip
    mov     rdi,qword[button.handle]
    mov     rsi,button.tooltip
    call    gtk_widget_set_tooltip_text
    ;horizontal alignment
    xor     rdi,rdi
    xor     rsi,rsi
    xor     rdx,rdx
    call    gtk_alignment_new
    mov     qword[halign.handle],rax
    ;add the button to the halign container
    mov     rdi,qword[halign.handle]
    mov     rsi,qword[button.handle]
    call    gtk_container_add
    ;add the halign container to the window
    mov     rdi,qword[window.handle]
    mov     rsi,qword[halign.handle]
    call    gtk_container_add
    ;show window
    mov     rdi,qword[window.handle]
    call    gtk_widget_show_all
    ;connect destroy signal to the window
    xor     r9d,r9d                         ;combination of GConnectFlags
    xor     r8d,r8d                         ;a GClosureNotify for data
    mov     rcx,qword[window.handle]        ;pointer to window instance in RCX
    mov     rdx,gtk_main_quit               ;pointer to the handler
    mov     rsi,signal.destroy              ;pointer to the signal
    mov     rdi,qword[window.handle]        ;pointer to window instance in RDI
    call    g_signal_connect_data           ;the value in RAX is the handler, but we don't store it now
    ;go into application main loop
    call    gtk_main
    ;exit program
    xor     rdi, rdi
    call    exit
