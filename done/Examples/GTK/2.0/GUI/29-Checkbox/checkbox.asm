; name        : checkbutton.asm
;
; build       : nasm -felf64 -o checkbutton.o -l checkbutton.lst checkbutton.asm
;               ld -s -m elf_x86_64 checkbutton.o -o checkbutton -lc --dynamic-linker /lib64/ld-linux-x86-64.so.2 -lgtk-3 -lgobject-2.0  -lglib-2.0 -lgdk_pixbuf-2.0 -lgdk-3
;
; description : Gtk widgets examples
;
; C - source  : http://zetcode.com/tutorials/gtktutorial/gtkwidgets/

bits 64

[list -]
    extern    exit
    extern    gtk_button_new_with_label
    extern    gtk_container_add
    extern    gtk_fixed_new
    extern    gtk_fixed_put
    extern    gtk_init
    extern    gtk_main
    extern    gtk_main_quit
    extern    gtk_widget_set_size_request
    extern    gtk_widget_show_all
    extern    gtk_window_new
    extern    gtk_window_set_default_size
    extern    gtk_window_set_position
    extern    gtk_window_set_title
    extern    g_print
    extern    g_signal_connect_data
    extern    gtk_check_button_new_with_label
    extern    gtk_toggle_button_get_active
    extern    gtk_toggle_button_set_active

    extern    g_signal_handler_disconnect
    extern    gtk_window_set_decorated


    %define   GTK_WIN_POS_CENTER       1
    %define   GTK_WINDOW_TOPLEVEL      0
    %define   NULL                     0
    %define   TRUE                     1
    %define   FALSE                    0
     
[list +]

section .data

window:
    .handle:  dq   0
    .title:   db   "Disconnect", 0
    .titleempty: db " ",0

fixed:
    .handle:    dq  0

checkbox:
    .handle:    dq  0
    .label:     db  "Toggle window title", 0
      
signal:
    .clicked:   db  "clicked", 0
    .destroy:   db  "destroy", 0
   
section .text
     global _start
     
_start:

    xor     rdi,rdi                      ; no commandline arguments will be passed
    xor     rsi,rsi
    call    gtk_init

    mov     rdi,GTK_WINDOW_TOPLEVEL
    call    gtk_window_new
    mov     qword[window.handle],rax

    mov     rsi,GTK_WIN_POS_CENTER
    mov     rdi,qword[window.handle]
    call    gtk_window_set_position

    mov     rdx,150
    mov     rsi,250
    mov     rdi,qword[window.handle]
    call    gtk_window_set_default_size

    mov     rsi,window.title
    mov     rdi,qword[window.handle]
    call    gtk_window_set_title

    call    gtk_fixed_new
    mov     qword[fixed.handle],rax

    mov     rsi,qword[fixed.handle]
    mov     rdi,qword[window.handle]
    call    gtk_container_add

    mov     rdi,checkbox.label
    call    gtk_check_button_new_with_label
    mov     qword[checkbox.handle],rax

    mov     rsi,TRUE
    mov     rdi,qword[checkbox.handle]
    call    gtk_toggle_button_set_active

    mov     rcx,50
    mov     rdx,10
    mov     rsi,qword[checkbox.handle]
    mov     rdi,qword[fixed.handle]
    call    gtk_fixed_put
        
    xor     r9d,r9d
    xor     r8d,r8d     
    mov     rcx,qword[checkbox.handle]
    mov     rdx,onCheckbox_clicked
    mov     rsi,signal.clicked
    mov     rdi,qword[checkbox.handle]
    call    g_signal_connect_data

    xor     r9d,r9d
    xor     r8d,r8d
    mov     rcx,NULL
    mov     rdx,gtk_main_quit
    mov     rsi,signal.destroy
    mov     rdi,qword[window.handle]
    call    g_signal_connect_data

    mov     rdi,qword[window.handle]
    call    gtk_widget_show_all

    call    gtk_main

    xor     rdi,rdi
    call    exit
    
onCheckbox_clicked:
    push	rbp
    mov		rbp,rsp

    ; RDI has GtkWidget *widget
    ; RSI has gpointer window

    call    gtk_toggle_button_get_active
    and     rax,rax
    mov     rdi,qword[window.handle]
    jz	    .notactive
    mov     rsi,window.title
    jmp	.settitle
.notactive:
    mov     rsi,window.titleempty
.settitle:
    call    gtk_window_set_title

    mov 	rsp,rbp
    pop 	rbp
    ret