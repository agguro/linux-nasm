; Name        : center.asm
;
; Build       : aclocal && autoconf && automake --add-missing --foreign
;               mkdir build
;               cd build
;               ../configure
;               make
;
; Description : a simple window centered on screen
;
; Source  : http://zetcode.com/gui/gtk2/firstprograms/

bits 64

[list -]
    %define    GTK_WINDOW_TOPLEVEL 0
    %define    GTK_WIN_POS_CENTER  1
    extern     exit
    extern     gtk_init
    extern     gtk_main
    extern     gtk_main_quit
    extern     gtk_window_new
    extern     gtk_window_set_title
    extern     gtk_window_set_default_size
    extern     gtk_window_set_position
    extern     gtk_widget_show
    extern     g_signal_connect_data
[list +]

section .rodata
    szTitle:       db  "center",0
    szDestroy:     db  "destroy",0

section .data
    window:        dq  0

section .text

global _start
_start:
    ;init gtk
    xor     rsi, rsi                    ;argv
    xor     rdi, rdi                    ;argc
    call    gtk_init
    ;create new window
    mov     rdi,GTK_WINDOW_TOPLEVEL
    call    gtk_window_new
    mov     qword[window],rax
    ;set window title
    mov     rdi,qword[window]
    mov     rsi,szTitle
    call    gtk_window_set_title
    ;set the window size
    mov     rdi,qword[window]
    mov     rsi,230
    mov     rdx,150
    call    gtk_window_set_default_size
    ;set window position
    mov     rdi,qword[window]
    mov     rsi,GTK_WIN_POS_CENTER
    call    gtk_window_set_position
    ;connect signal destroy to event handler gtk_main_quit
    xor     r9d,r9d                     ;combination of GConnectFlags 
    xor     r8d,r8d                     ;a GClosureNotify for data
    xor     rcx,rcx                     ;pointer to the data to pass
    mov     rdx,gtk_main_quit           ;pointer to the handler, exit = c function
    mov     rsi,szDestroy               ;pointer to the signal
    mov     rdi,qword[window]           ;pointer to the widget instance
    call    g_signal_connect_data       ;the value in RAX is the handler, but we don't store it now
    ;show the window
    mov     rdi,qword[window]
    call    gtk_widget_show
    ;enter main loop
    call    gtk_main
    ;exit program
    xor     rdi, rdi
    call    exit
