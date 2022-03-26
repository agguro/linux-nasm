; Name        : gtkvbox.asm
;
; Build       : nasm -felf64 -o gtkvbox.o -l gtkvbox.lst gtkvbox.asm
;               ld -s -m elf_x86_64 aboutbox.o -o aboutbox -lc --dynamic-linker /lib64/ld-linux-x86-64.so.2 -lgtk-3 -lgobject-2.0  -lglib-2.0 -lgdk_pixbuf-2.0 -lgdk-3
;
; Description : layout example
;
; C - source : http://zetcode.com/tutorials/gtktutorial/gtklayoutmanagement/

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
     extern    gtk_container_set_border_width
     extern    gtk_vbox_new
     extern    gtk_container_add
     extern    gtk_button_new_with_label
     extern    g_signal_connect_data
     extern    gtk_box_pack_start
     extern    gtk_container_add
     extern    gtk_widget_show_all
     extern    gtk_main
     extern    gtk_main_quit
[list +]

section .data
    window:
      .handle:     dq  0
      .title:      db  "GtkVBox",0
    vbox:
      .handle:     dq  0
    settings:
      .handle:     dq  0
      .label:      db  "Settings", 0
    accounts:
      .handle:     dq  0
      .label:      db  "Accounts", 0
    loans:
      .handle:     dq  0
      .label:      db  "Loans", 0
    cash:
      .handle:     dq  0
      .label:      db  "Cash", 0
    debts:
      .handle:     dq  0
      .label:      db  "Debts", 0
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
    mov     rsi, 230
    mov     rdx, 250
    call    gtk_window_set_default_size

    mov     rdi, QWORD[window.handle]
    mov     rsi, GTK_WIN_POS_CENTER
    call    gtk_window_set_position

    mov     rdi, qword[window.handle]
    mov     rsi, 5
    call    gtk_container_set_border_width
    
    mov     rdi, TRUE
    mov     rsi, 1
    call    gtk_vbox_new
    mov     qword[vbox.handle], rax
    
    mov     rdi, qword[window.handle]
    mov     rsi, qword[vbox.handle]
    call    gtk_container_add
    
    mov     rdi, settings.label
    call    gtk_button_new_with_label
    mov     qword[settings.handle], rax
    
    mov     rdi, accounts.label
    call    gtk_button_new_with_label
    mov     qword[accounts.handle], rax
    
    mov     rdi, loans.label
    call    gtk_button_new_with_label
    mov     qword[loans.handle], rax

    mov     rdi, cash.label
    call    gtk_button_new_with_label
    mov     qword[cash.handle], rax

    mov     rdi, debts.label
    call    gtk_button_new_with_label
    mov     qword[debts.handle], rax

    mov     rdi, qword[vbox]
    mov     rsi, qword[settings.handle]
    mov     rdx, TRUE
    mov     rcx, TRUE
    xor     r8, r8
    xor     r9, r9
    call    gtk_box_pack_start
    
    mov     rdi, qword[vbox]
    mov     rsi, qword[accounts.handle]
    mov     rdx, TRUE
    mov     rcx, TRUE
    xor     r8, r8
    xor     r9, r9
    call    gtk_box_pack_start
        
    mov     rdi, qword[vbox]
    mov     rsi, qword[loans.handle]
    mov     rdx, TRUE
    mov     rcx, TRUE
    xor     r8, r8
    xor     r9, r9
    call    gtk_box_pack_start
        
    mov     rdi, qword[vbox]
    mov     rsi, qword[cash.handle]
    mov     rdx, TRUE
    mov     rcx, TRUE
    xor     r8, r8
    xor     r9, r9
    call    gtk_box_pack_start
    
    mov     rdi, qword[vbox]
    mov     rsi, qword[debts.handle]
    mov     rdx, TRUE
    mov     rcx, TRUE
    xor     r8, r8
    xor     r9, r9
    call    gtk_box_pack_start
    
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
