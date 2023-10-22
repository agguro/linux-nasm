;name : simplewindow.asm
;
;build : nasm -felf64 -o simplewindow.o -l simplewindow.lst simplewindow.asm
;               
;description : a simple window with the basic functionalities and a title
;
;source : http://zetcode.com/gui/gtk2/firstprograms/

bits 64

[list -]
    %define    GTK_WINDOW_TOPLEVEL   0
    %define    GTK_WIN_POS_CENTER    1
    extern     gtk_init
    extern     gtk_main
    extern     gtk_main_quit
    extern     gtk_widget_show
    extern     gtk_window_new
    extern     gtk_window_set_title
    extern     g_signal_connect_data
    extern     exit
[list +]

section .rodata
    szTitle:      db    "simple window",0
    szDestroy:    db    "destroy",0

section .bss
    window:       resq    1
    
section .text
global _start

_start:
    ;init gtk
    xor     rdi,rdi                 
    xor     rsi,rsi
    call    gtk_init
    ;if initialization doesn't succeed then the application
    ;terminates.  If that is unwanted behaviour then we need
    ;to use gtk_init_check instead.
    ;https://developer.gnome.org/gtk2/stable/gtk2-General.html#gtk-init
    ;create a new window
    mov     rdi,GTK_WINDOW_TOPLEVEL
    call    gtk_window_new
    mov     qword[window],rax
    ;set the title
    mov     rdi,rax
    mov     rsi,szTitle
    call    gtk_window_set_title
    ;connect the destroy signal to gtk_main_quit event handler
    xor     r9d,r9d                    ; combination of GConnectFlags 
    xor     r8d,r8d                    ; a GlosureNotify for data
    xor     rcx,rcx                    ; pointer to the data to pass
    mov     rdx,gtk_main_quit          ; pointer to the handler
    mov     rsi,szDestroy              ; pointer to the signal
    mov     rdi,qword[window]          ; pointer to the widget instance
    ;C programs uses g_signal_connect, this is not a library function.
    call    g_signal_connect_data
    ;show the window
    mov     rdi,qword[window]
    call    gtk_widget_show
    ;go into applications main loop
    call    gtk_main
.exit:    
    ;exit program
    xor     rdi,rdi
    call    exit
