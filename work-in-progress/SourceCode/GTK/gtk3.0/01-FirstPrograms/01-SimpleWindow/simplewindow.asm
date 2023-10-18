;name : simplewindow.asm
;
;build : nasm -felf64 -o simplewindow.o -l simplewindow.lst simplewindow.asm
;        ld -s -m elf_x86_64 simplewindow.o -o simplewindow --dynamic-linker -lc `pkg-config --libs gtk+-3.0`
;
;description : a simple window with the basic functionalities and a title
;
;source : http://zetcode.com/gui/gtk2/firstprograms/

bits 64

[list -]
    %define   GTK_WINDOW_TOPLEVEL   0
    %define   GTK_WIN_POS_CENTER    1
    %define   FALSE                 0
    %define   TRUE                  1
    
    extern    gtk_init
    extern    gtk_main
    extern    gtk_main_quit
    extern    gtk_widget_show
    extern    gtk_window_new
    extern    gtk_window_set_title
    extern    g_signal_connect_data
    extern    exit
[list +]

section .data
    window:
    .handle:      dq    0
    .title:       db    "A simple window",0
    signal:
    .destroy:     db    "destroy",0
    
section .text
global _start

_start:
    ;init gtk
    ;in this example I get the pointers to argc and argv also.
    ;in case you should use commandline arguments refer to:
    ;https://developer.gnome.org/gtk3/stable/gtk3-General.html#gtk-init_with_args
    ;the stack however when you watch this program in a debugger is at entry:
    ;rsp        argc
    ;rsp+8      name of program(simplewindow in this case)
    ;rsp+16     argv1
    ;rsp+24     argv2
    ;....
    ;rsp+8*n    0000000000000000
    ;rsp+8*n+8  envp1
    ;....       envp2
    ;....
    ;rsp+...    0000000000000000
    ;so instead of calling gtk_init_with_args, we can easely(?) parse the arguments from commandline
    ;ourself AFTER calling gtk_init with rdi and rsi = 0.  In this example I pass *argc and ***argv
    ;to gtk_init. (only in this example)
    ;*argc has to be 32 bits long otherwise we will receive a segmentation fault.
    mov     rdi,rsp                 
    mov     rsi,rdi
    add     rdi,4                       ;*argc is 32 bits long
    add     rsi,8                       ;***argv is 64 bits long
    call    gtk_init
    ;when rax returns 0 then gtk_init fails and we should terminate the program.
    ;if run from commandline you can write a message on screen to eventually
    ;use a textbased version of this program...
    and     rax,rax
    jz      .exit
    ;create a new window
    mov     rdi,GTK_WINDOW_TOPLEVEL
    call    gtk_window_new
    mov     qword[window.handle],rax
    ;set the title
    mov     rdi,rax
    mov     rsi,window.title
    call    gtk_window_set_title
    ;conect the destroy signal to gtk_main_quit event handler
    xor     r9d,r9d                    ; combination of GConnectFlags 
    xor     r8d,r8d                    ; a GClosureNotify for data
    xor     rcx,rcx                    ; pointer to the data to pass
    mov     rdx,gtk_main_quit          ; pointer to the handler
    mov     rsi,signal.destroy         ; pointer to the signal
    mov     rdi,qword[window.handle]   ; pointer to the widget instance
    call    g_signal_connect_data
    ;show the window
    mov     rdi,qword[window.handle]
    call    gtk_widget_show
    ;go into applications main loop
    call    gtk_main
.exit:    
    ;exit program
    xor     rdi,rdi
    call    exit
