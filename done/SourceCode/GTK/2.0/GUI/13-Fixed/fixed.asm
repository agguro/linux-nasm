;name : fixed.asm
;
;build : nasm -felf64 -o gtkfixed.o -l gtkfixed.lst gtkfixed.asm
;        ld -m elf_x86_64 -g --dynamic-linker /lib64/ld-linux-x86-64.so.2 -lc -lgtk-x11-2.0 -lglib-2.0 -lgobject-2.0 fixed.o -o fixed
;
;description : layout example, resize the window to see the effect, otherwise it's just another window
;
;source : http://zetcode.com/tutorials/gtktutorial/gtklayoutmanagement/

bits 64

[list -]
     %define   GTK_WINDOW_TOPLEVEL   0
     %define   GTK_WIN_POS_CENTER    1
     %define   FALSE                 0
     %define   TRUE                  1
     
     extern    exit
     extern    gtk_init
     extern    gtk_window_new
     extern    gtk_window_set_title
     extern    gtk_window_set_default_size
     extern    gtk_window_set_position
     extern    gtk_button_new_with_label
     extern    gtk_fixed_put
     extern    gtk_fixed_new
     extern    gtk_container_add
     extern    gtk_widget_set_size_request
     extern    g_signal_connect_data
     extern    gtk_widget_show_all
     extern    gtk_main
     extern    gtk_main_quit
[list +]

section .data
    window:
      .handle:     dq  0
      .title:      db  "gtkfixed",0
    button1:
      .handle:     dq  0
      .label:      db  "button1", 0
    button2:
      .handle:     dq  0
      .label:      db  "button2", 0
    button3:
      .handle:     dq  0
      .label:      db  "button3", 0
    fixed:
      .handle:     dq  0
    signal:
      .destroy:    db  "destroy",0
    
section .text
    global _start

_start:
    xor     rsi, rsi                  ; argv
    xor     rdi, rdi                  ; argc
    call    gtk_init
    
    mov     rdi,GTK_WINDOW_TOPLEVEL
    call    gtk_window_new
    mov     QWORD[window.handle], rax

    mov     rdi, QWORD[window.handle]
    mov     rsi, window.title
    call    gtk_window_set_title

    mov     rdi, qword [window.handle]
    mov     rsi, 290
    mov     rdx, 200
    call    gtk_window_set_default_size

    mov     rdi, QWORD[window.handle]
    mov     rsi, GTK_WIN_POS_CENTER
    call    gtk_window_set_position

    call    gtk_fixed_new
    mov     qword[fixed.handle], rax
    
    mov     rdi, qword[window.handle]
    mov     rsi, qword[fixed.handle]
    call    gtk_container_add
    
    mov     rdi, button1.label
    call    gtk_button_new_with_label
    mov     qword[button1.handle], rax
    
    mov     rdi, button2.label
    call    gtk_button_new_with_label
    mov     qword[button2.handle], rax
    
    mov     rdi, button3.label
    call    gtk_button_new_with_label
    mov     qword[button3.handle], rax

    mov     rdi, qword[fixed]
    mov     rsi, qword[button1]
    mov     rdx, 150
    mov     rcx, 50
    call    gtk_fixed_put
    
    mov     rdi, qword[fixed]
    mov     rsi, qword[button2]
    mov     rdx, 15
    mov     rcx, 15
    call    gtk_fixed_put
    
    mov     rdi, qword[fixed]
    mov     rsi, qword[button3]
    mov     rdx, 100
    mov     rcx, 100
    call    gtk_fixed_put
    
    mov     rdi, qword[button1]
    mov     rsi, 80
    mov     rdx, 35
    call    gtk_widget_set_size_request
    
    mov     rdi, qword[button2]
    mov     rsi, 80
    mov     rdx, 35
    call    gtk_widget_set_size_request
   
    mov     rdi, qword[button3]
    mov     rsi, 80
    mov     rdx, 35
    call    gtk_widget_set_size_request
    
    xor     r9d, r9d                ; combination of GConnectFlags 
    xor     r8d, r8d                ; a GClosureNotify for data
    xor     rcx, rcx                ; pointer to the data to pass
    mov     rdx, gtk_main_quit      ; pointer to the handler
    mov     rsi, signal.destroy     ; pointer to the signal
    mov     rdi, QWORD[window.handle]      ; pointer to the widget instance
    call    g_signal_connect_data   ; the value in RAX is the handler, but we don't store it now
       
    mov     rdi, QWORD[window.handle]
    call    gtk_widget_show_all

    call    gtk_main

    xor     rdi, rdi                ; we don't expect much errors now thus errorcode=0
    call    exit
