; Name        : gtkalignment.asm
;
; Build       : nasm -felf64 -o gtkalignment.o -l gtkalignment.lst gtkalignment.asm
;               ld -s -m elf_x86_64 gtkalignment.o -o gtkalignment -lc --dynamic-linker /lib64/ld-linux-x86-64.so.2 -lgtk-3 -lgobject-2.0  -lglib-2.0 -lgdk_pixbuf-2.0 -lgdk-3
;
; Description : layout example
;
; C - source  : http://zetcode.com/tutorials/gtktutorial/gtklayoutmanagement/

bits 64

[list -]
     %define   GTK_WINDOW_TOPLEVEL   0
     %define   GTK_WIN_POS_CENTER    1
     %define   FALSE                 0
     %define   TRUE                  1
     
     %define   GTK_ORIENTATION_HORIZONTAL 0
     %define   GTK_ORIENTATION_VERTICAL   1
     %define   FLOAT1		              0x3F800000
     
     extern    exit
     extern    gtk_init
     extern    gtk_window_new
     extern    gtk_window_set_title
     extern    gtk_window_set_default_size
     extern    gtk_window_set_position
     extern    gtk_button_new_with_label
     extern    gtk_container_set_border_width
     extern    gtk_button_new_with_label
     extern    g_signal_connect_data
     extern    gtk_container_add
     extern    gtk_widget_show_all
     extern    gtk_main
     extern    gtk_main_quit
     extern    gtk_vbox_new
     extern    gtk_hbox_new
     extern    gtk_box_pack_start
     extern    gtk_alignment_new
     extern    gtk_widget_set_size_request
     
[list +]

section .data

     window:
      .handle:     dq  0
      .title:      db  "gtkAlignment",0
    bttnOK:
      .label:      dq  "OK", 0
      .handle:     dq  0
    bttnClose:
      .label:      dq  "Close", 0
      .handle:     dq  0
    signal:
      .destroy:    db  "destroy",0
      
    vbox:          dq  0
    hbox:          dq  0
    valign:        dq  0
    halign:        dq  0
    
section .text
    global _start

_start:
    ; init gtk
    xor     rsi, rsi                  ; argv
    xor     rdi, rdi                  ; argc
    call    gtk_init
    cmp     rax, FALSE			; gtk could not be initialized
    je      Exit
    
    ; create a new window instance
    mov     rdi,GTK_WINDOW_TOPLEVEL
    call    gtk_window_new
    mov     QWORD[window.handle], rax
    
    ; create a vertical box
    mov     rdi, FALSE
    mov     rsi, 5
    call    gtk_vbox_new
    mov     qword[vbox], rax
    
    ; create a horizontal box, buttons added to this 
    mov     rdi, TRUE
    mov     rsi, 3
    call    gtk_hbox_new
    mov     qword[hbox], rax
    
    ; create a vertical alignment widget
    xorps   xmm0, xmm0
    mov     r14, FLOAT1
    movq    xmm1, r14
    xorps   xmm2, xmm2
    xorps   xmm3, xmm3
    call    gtk_alignment_new
    mov     qword[valign], rax
    
    ; create a horizontal alignment widget
    mov     r14, FLOAT1
    movq    xmm0, r14
    xorps   xmm1, xmm1
    xorps   xmm2, xmm2
    xorps   xmm3, xmm3
    call    gtk_alignment_new
    mov     qword[halign], rax
    
    ; create buttons OK and Close
    mov     rdi, bttnOK.label
    call    gtk_button_new_with_label
    mov     qword[bttnOK.handle], rax
    
    mov     rdi, bttnClose.label
    call    gtk_button_new_with_label
    mov     qword[bttnClose.handle], rax
    
    ; set predefined size for the OK button
    mov     rdi, qword[bttnOK.handle]
    mov     rsi, 70
    mov     rdx, 30
    call    gtk_widget_set_size_request

    ; add both buttons to the horizontal box
    mov     rdi, qword[hbox]
    mov     rsi, qword[bttnOK.handle]
    call    gtk_container_add

    mov     rdi, qword[hbox]
    mov     rsi, qword[bttnClose.handle]
    call    gtk_container_add

    ; add vertical alignment widget to the vertical orientated box
    mov     rdi, qword[vbox]
    mov     rsi, qword[valign]
    call    gtk_container_add
    
    ; add horizontal orientated box to the horizontal alignment widget
    mov     rdi, qword[halign]
    mov     rsi, qword[hbox]
    call    gtk_container_add
    
    mov     rdi, qword[vbox]
    mov     rsi, qword[halign]
    mov     rdx, 0
    mov     rcx, 0
    mov     r8d, 0
    xor     r9, r9
    call    gtk_box_pack_start
    
    mov     rdi, qword[window.handle]
    mov     rsi, qword[vbox]
    call    gtk_container_add
    
    ; set windows properties
    mov     rdi, QWORD[window.handle]
    mov     rsi, GTK_WIN_POS_CENTER
    call    gtk_window_set_position

    mov     rdi, qword [window.handle]
    mov     rsi, 300
    mov     rdx, 250
    call    gtk_window_set_default_size

    mov     rdi, QWORD[window.handle]
    mov     rsi, window.title
    call    gtk_window_set_title

    mov     rdi, qword[window.handle]
    mov     rsi, 10
    call    gtk_container_set_border_width
    
    mov     rdi, QWORD[window.handle]      ; pointer to the widget instance
    mov     rsi, signal.destroy            ; pointer to the signal
    mov     rdx, gtk_main_quit             ; pointer to the handler
    mov     rcx, qword[window.handle]      ; pointer to the data to pass
    xor     r8d, r8d                	   ; a GClosureNotify for data
    xor     r9d, r9d                	   ; combination of GConnectFlags 
    call    g_signal_connect_data          ; the value in RAX is the handler, but we don't store it now
       
    mov     rdi, QWORD[window.handle]
    call    gtk_widget_show_all

    call    gtk_main

Exit:    
    xor     rdi, rdi                ; we don't expect much errors now thus errorcode=0
    call    exit
