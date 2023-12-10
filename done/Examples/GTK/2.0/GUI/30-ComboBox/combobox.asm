;name        : combobox.asm
;
;build       : nasm -felf64 -o combobox.o -l combobox.lst combobox.asm
;              ld -m elf_x86_64 combobox.o -o combobox -lc --dynamic-linker /lib64/ld-linux-x86-64.so.2 -lgtk-x11-2.0 -lgobject-2.0  -lglib-2.0 -lgdk_pixbuf-2.0 -lgdk-x11-2.0
;
;description : combobox widgets examples
;
;source      : http://zetcode.com/tutorials/gtktutorial/gtkwidgets/

bits 64

[list -]
     
    %define   GTK_WINDOW_TOPLEVEL   0
    %define   GTK_WIN_POS_CENTER    1
    extern    exit
    extern    gtk_init
    extern    gtk_window_new
    extern    gtk_window_set_title
    extern    gtk_window_set_default_size
    extern    gtk_window_set_position
    extern    gtk_window_set_icon
    extern    gtk_widget_show_all
    extern    gtk_main
    extern    gtk_main_quit
    extern    g_signal_connect_data
    extern    gdk_pixbuf_new_from_file
    extern    gdk_pixbuf_loader_new
    extern    gdk_pixbuf_loader_write
    extern    gdk_pixbuf_loader_get_pixbuf
    extern    gtk_container_add    
    extern    gtk_fixed_new
    extern    gtk_fixed_put
    extern    gtk_combo_box_text_append_text
    extern    gtk_combo_box_text_new
    extern    gtk_combo_box_text_get_active_text
    extern    gtk_label_new
    extern    gtk_label_set_text

[list +]

section .data

logo:   incbin  "./logo.png"
    .size:      equ       $-logo
    
window:
    .title:     db  "GtkComboBox", 0
    .handle:    dq  0

signal:
    .destroy:   db  "destroy", 0
    .changed:   db  "changed", 0

combo:
    .txt1:      db  "Ubuntu", 0
    .txt2:      db  "Mandriva", 0
    .txt3:      db  "Fedora", 0
    .txt4:      db  "Mint", 0
    .txt5:      db  "Gentoo", 0
    .txt6:      db  "Debian", 0
    .handle:    dq  0
  
label:
    .caption:   db  "here comes your choice", 0
    .handle:    dq  0

fixed:
    .handle:    dq  0
     
pixbuf_loader:
    .handle:    dq  0

pixbuf:
    .handle:    dq  0


section .text
    global _start

_start:

    ; Folowing code generates a window, shows it and can be closed. It has an application icon set
    ; and will be used for all GtkWidget demonstrations
    
    xor     rsi, rsi            ;argv
    xor     rdi, rdi            ;argc
    call    gtk_init

    ; loading the the application icon in a buffer -> pixbuffer

    call    gdk_pixbuf_loader_new                   
    mov     qword[pixbuf_loader.handle], rax        ; pointer to loader in pixbuf_loader.handle

    mov     rdi, qword[pixbuf_loader.handle]
    mov     rsi, logo
    mov     edx, logo.size
    xor     rcx, rcx
    call    gdk_pixbuf_loader_write


    mov     rdi, qword[pixbuf_loader.handle]
    call    gdk_pixbuf_loader_get_pixbuf
    mov     qword[pixbuf.handle], rax               ; pointer to pixbuffer

    ; the main window
    xor     rdi, rdi                                ; GTK_WINDOW_TOPLEVEL = 0 in RDI
    call    gtk_window_new
    mov     qword[window.handle], rax               ; pointer to window

    mov     rdi, qword[window.handle]               ; pointer to window in RDI
    mov     rsi, window.title
    call    gtk_window_set_title

    mov     rdi, qword[window.handle]               ; pointer to window in RDI
    mov     rsi, 500
    mov     rdx, 300
    call    gtk_window_set_default_size

    mov     rdi, qword[window.handle]               ; pointer to window in RDI
    mov     rsi, GTK_WIN_POS_CENTER
    call    gtk_window_set_position

    mov     rdi, qword[window.handle]               ; pointer to window instance in RDI
    mov     rsi, qword[pixbuf.handle]               ; pointer to pixbuffer instance in RSI
    call    gtk_window_set_icon

    xor     r9d, r9d                                ; combination of GConnectFlags
    xor     r8d, r8d                                ; a GClosureNotify for data
    mov     rcx, qword[window.handle]               ; pointer to window instance in RCX
    mov     rdx, gtk_main_quit                      ; pointer to the handler
    mov     rsi, signal.destroy                     ; pointer to the signal
    mov     rdi, qword[window.handle]               ; pointer to window instance in RDI
    call    g_signal_connect_data                   ; the value in RAX is the handler, but we don't store it now

    call    gtk_fixed_new
    mov     qword[fixed.handle],rax                 ; pointer to fixed in R14

    call    gtk_combo_box_text_new       
    mov     qword[combo.handle],rax                 ; pointer to combobox in r12

    mov     rdi, qword[combo.handle]
    mov     rsi, combo.txt1
    call    gtk_combo_box_text_append_text

    mov     rdi, qword[combo.handle]
    mov     rsi, combo.txt2
    call    gtk_combo_box_text_append_text

    mov     rdi, qword[combo.handle]
    mov     rsi, combo.txt3
    call    gtk_combo_box_text_append_text

    mov     rdi, qword[combo.handle]
    mov     rsi, combo.txt4
    call    gtk_combo_box_text_append_text

    mov     rdi, qword[combo.handle]
    mov     rsi, combo.txt5
    call    gtk_combo_box_text_append_text

    mov     rdi, qword[combo.handle]
    mov     rsi, combo.txt6
    call    gtk_combo_box_text_append_text

    mov     rdi, qword[fixed.handle]
    mov     rsi, qword[combo.handle]
    mov     rdx, 50                                 ; position of combobox (x)
    mov     rcx, 50                                 ; position of combobox (y)
    call    gtk_fixed_put

    mov     rdi, qword[window.handle]
    mov     rsi, qword[fixed.handle]
    call    gtk_container_add

    mov     rdi, label.caption
    call    gtk_label_new
    mov     qword[label.handle],rax                 ;label handle

    mov     rsi, rax
    mov     rdi, qword[fixed.handle]
    mov     rdx, 50                                ; position of label (x)
    mov     rcx, 30                                ; position of label (y)
    call    gtk_fixed_put

    xor     r9d, r9d                                ; combination of GConnectFlags
    xor     r8d, r8d                                ; a GClosureNotify for data
    mov     rcx, qword[label.handle]                ; pointer to label instance in RCX
    mov     rdx, combo_select                       ; pointer to the handler
    mov     rsi, signal.changed                     ; pointer to the signal
    mov     rdi, qword[combo.handle]                ; pointer to combo instance in RDI
    call    g_signal_connect_data                   ; the value in RAX is the handler, but we don't store it now

    mov     rdi, qword[window.handle]               ; pointer to window instance in RDI
    call    gtk_widget_show_all

    call    gtk_main
    Exit:
    xor     rdi, rdi
    call    exit

combo_select:
    ; RDI has pointer to calling widget (combobox)

    push    rbp
    mov     rbp, rsp
    call    gtk_combo_box_text_get_active_text
    mov     rdi, qword[label.handle]
    mov     rsi, rax
    call    gtk_label_set_text
    leave
    ret
