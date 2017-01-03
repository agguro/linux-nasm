; Name        : windows.asm
;
; Build       : nasm -felf64 -o windows.o -l windows.lst windows.asm
;               ld -s -m elf_x86_64 timer.o -o timer -lc --dynamic-linker /lib64/ld-linux-x86-64.so.2 -lgtk-3 -lgobject-2.0  -lglib-2.0 -lgdk_pixbuf-2.0 -lgdk-3 -lpango-1.0 -latk-1.0 -lgio-2.0
;               -lpangoft2-1.0  -lpangocairo-1.0 -lcairo -lfreetype -lfontconfig  -lgmodule-2.0 -lgthread-2.0 -lrt
;
; Description : windows demo
;
; C - source : http://zetcode.com/tutorials/gtktutorial/menusandtoolbars/

bits 64

[list -]
    %define   GTK_WINDOW_TOPLEVEL       0
    %define   GTK_WIN_POS_CENTER        1
    %define   FALSE                     0
    %define   TRUE                      1
    %define   FLOAT1                    0x3F800000
    %define   GTK_FILL                  4
    %define   GTK_EXPAND                1
    %define   GTK_SHRINK                2
     
    extern     exit
    extern     g_signal_connect_data
    extern     gtk_alignment_new
    extern     gtk_button_new_with_label
    extern     gtk_container_add
    extern     gtk_container_set_border_width
    extern     gtk_init
    extern     gtk_label_new
    extern     gtk_main
    extern     gtk_main_quit
    extern     gtk_table_attach
    extern     gtk_table_new
    extern     gtk_table_set_col_spacings
    extern     gtk_table_set_row_spacing
    extern     gtk_text_view_new
    extern     gtk_text_view_set_cursor_visible
    extern     gtk_text_view_set_editable
    extern     gtk_widget_set_size_request
    extern     gtk_widget_show_all
    extern     gtk_window_new
    extern     gtk_window_set_position
    extern     gtk_window_set_resizable
    extern     gtk_window_set_title    
[list +]

section .data
    window:
      .handle:     dq  0
      .title:      db  "Windows",0
    table:
      .handle:     dq  0
    labelTitle:
      .handle:     dq  0
      .caption:    db  "Windows", 0
    textViewWins:
      .handle:     dq  0
    buttonActivate:
      .handle:     dq  0
      .caption:    db  "Activate", 0
    buttonClose:
      .handle:     dq  0
      .caption:    dq  "Close", 0
    buttonHelp:
      .handle:     dq  0
      .caption:    dq  "Help", 0
    buttonOK:
      .handle:     dq  0
      .caption:    dq  "OK", 0  
    signal:
      .destroy:    db  "destroy",0
      
    vbox:          dq  0
    hbox:          dq  0
    valign:        dq  0
    halign:        dq  0
    halign2:       dq  0
    
section .text
    global _start

_start:
    xor     rsi, rsi                    ; argv
    xor     rdi, rdi                    ; argc
    call    gtk_init
    cmp     rax, FALSE             ; gtk could not be initialized
    je      Exit
    
    mov     rdi,GTK_WINDOW_TOPLEVEL
    call    gtk_window_new
    mov     QWORD[window.handle], rax
    
    mov     rdi, QWORD[window.handle]
    mov     rsi, GTK_WIN_POS_CENTER
    call    gtk_window_set_position

    mov     rdi, qword [window.handle]
    mov     rsi, 300
    mov     rdx, 250
    call    gtk_widget_set_size_request

    mov     rdi, qword[window.handle]
    mov     rsi, FALSE
    call    gtk_window_set_resizable
    
    mov     rdi, QWORD[window.handle]
    mov     rsi, window.title
    call    gtk_window_set_title

    mov     rdi, qword[window.handle]
    mov     rsi, 15
    call    gtk_container_set_border_width
    
    mov     rdi, 8
    mov     rsi, 4
    mov     rdx, FALSE
    call    gtk_table_new
    mov     qword[table.handle], rax
    
    mov     rdi, qword[table.handle]
    mov     rsi, 3
    call    gtk_table_set_col_spacings
    
    mov     rdi, labelTitle.caption
    call    gtk_label_new
    mov     qword[labelTitle.handle], rax
   
    xorps   xmm0, xmm0
    xorps   xmm1, xmm1
    xorps   xmm2, xmm2
    xorps   xmm3, xmm3
    call    gtk_alignment_new
    mov     qword[halign], rax
    
    mov     rdi, qword[halign]
    mov     rsi, qword[labelTitle.handle]
    call    gtk_container_add
    
    mov     rdi, qword[table.handle]
    mov     rsi, qword[halign]
    xor     rdx, rdx
    mov     rcx, 1
    xor     r8d, r8d
    mov     r9d, 1
    push    0                           ; last parameter first on stack
    push    0
    push    GTK_FILL
    push    GTK_FILL
    call    gtk_table_attach

    call    gtk_text_view_new
    mov     qword[textViewWins.handle], rax
    
    mov     rdi, qword[textViewWins.handle]
    mov     rsi, FALSE
    call    gtk_text_view_set_editable
    
    mov     rdi, qword[textViewWins.handle]
    mov     rsi, FALSE
    call    gtk_text_view_set_cursor_visible
    
    mov     rdi, qword[table.handle]
    mov     rsi, qword[textViewWins.handle]
    xor     rdx, rdx
    mov     rcx, 2
    mov     r8d, 1
    mov     r9d, 3
    push    1                           ; last parameter first on stack
    push    1
    push    GTK_FILL | GTK_EXPAND
    push    GTK_FILL | GTK_EXPAND
    call    gtk_table_attach
        
    mov     rdi, buttonActivate.caption
    call    gtk_button_new_with_label
    mov     qword[buttonActivate.handle], rax
    
    mov     rdi, qword[buttonActivate.handle]
    mov     rsi, 50
    mov     rdx, 30
    call    gtk_widget_set_size_request
    
    mov     rdi, qword[table.handle]
    mov     rsi, qword[buttonActivate.handle]
    mov     rdx, 3
    mov     rcx, 4
    mov     r8d, 1
    mov     r9d, 2
    push    1                           ; last parameter first on stack
    push    1
    push    GTK_SHRINK
    push    GTK_FILL
    call    gtk_table_attach
    
    xorps   xmm0, xmm0
    xorps   xmm1, xmm1
    xorps   xmm2, xmm2
    xorps   xmm3, xmm3
    call    gtk_alignment_new
    mov     qword[valign], rax
    
    mov     rdi, buttonClose.caption
    call    gtk_button_new_with_label
    mov     qword[buttonClose.handle], rax
    
    mov     rdi, qword[buttonClose.handle]
    mov     rsi, 70
    mov     rdx, 30
    call    gtk_widget_set_size_request
    
    mov     rdi, qword[valign]
    mov     rsi, qword[buttonClose.handle]
    call    gtk_container_add
    
    mov     rdi, qword[table.handle]
    mov     rsi, 1
    mov     rdx, 3
    call    gtk_table_set_row_spacing
    
    mov     rdi, qword[table.handle]
    mov     rsi, qword[valign]
    mov     rdx, 3
    mov     rcx, 4
    mov     r8d, 2
    mov     r9d, 3
    push    1                           ; last parameter first on stack
    push    1
    push    GTK_FILL | GTK_EXPAND
    push    GTK_FILL
    call    gtk_table_attach
    
    xorps   xmm0, xmm0
    mov     r14, FLOAT1
    movq    xmm1, r14
    xorps   xmm2, xmm2
    xorps   xmm3, xmm3
    call    gtk_alignment_new
    mov     qword[halign2], rax
    
    mov     rdi, buttonHelp.caption
    call    gtk_button_new_with_label
    mov     qword[buttonHelp.handle], rax
    
    mov     rdi, qword[halign2]
    mov     rsi, qword[buttonHelp.handle]
    call    gtk_container_add
    
    mov     rdi, qword[buttonHelp.handle]
    mov     rsi, 70
    mov     rdx, 30
    call    gtk_widget_set_size_request
    
    mov     rdi, qword[table.handle]
    mov     rsi, 3
    mov     rdx, 6
    call    gtk_table_set_row_spacing
    
    mov     rdi, qword[table.handle]
    mov     rsi, qword[halign2]
    mov     rdx, 0
    mov     rcx, 1
    mov     r8d, 4
    mov     r9d, 5
    push    0                           ; last parameter first on stack
    push    0
    push    GTK_FILL
    push    GTK_FILL
    call    gtk_table_attach
    
    mov     rdi, buttonOK.caption
    call    gtk_button_new_with_label
    mov     qword[buttonOK.handle], rax
    
    mov     rdi, qword[buttonOK.handle]
    mov     rsi, 70
    mov     rdx, 30
    call    gtk_widget_set_size_request
    
    mov     rdi, qword[table.handle]
    mov     rsi, qword[buttonOK.handle]
    mov     rdx, 3
    mov     rcx, 4
    mov     r8d, 4
    mov     r9d, 5
    push    0                           ; last parameter first on stack
    push    0
    push    GTK_FILL
    push    GTK_FILL
    call    gtk_table_attach
    
    mov     rdi, qword[window.handle]
    mov     rsi, qword[table.handle]
    call    gtk_container_add
    
    mov     rdi, QWORD[window.handle]      ; pointer to the widget instance
    mov     rsi, signal.destroy            ; pointer to the signal
    mov     rdx, gtk_main_quit             ; pointer to the handler
    mov     rcx, qword[window.handle]      ; pointer to the data to pass
    xor     r8d, r8d                       ; a GClosureNotify for data
    xor     r9d, r9d                       ; combination of GConnectFlags 
    call    g_signal_connect_data          ; the value in RAX is the handler, but we don't store it now
       
    mov     rdi, QWORD[window.handle]
    call    gtk_widget_show_all

    call    gtk_main

Exit:    
    xor     rdi, rdi                ; we don't expect much errors now thus errorcode=0
    call    exit
