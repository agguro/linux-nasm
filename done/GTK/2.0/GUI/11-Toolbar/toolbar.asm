;name : toolbar.asm
;
;build : /usr/bin/nasm -felf64 -Fdwarf -g -o toolbar.o toolbar.asm
;        ld --dynamic-linker /lib64/ld-linux-x86-64.so.2 -no-pie -melf_x86_64 -g -o toolbar toolbar.o -lc -lgtk-x11-2.0 -lgdk-x11-2.0 -lgobject-2.0 -lgdk_pixbuf-2.0 -lglib-2.0
;
;description : a window with a toolbar
;
;source : http://zetcode.com/gui/gtk2/menusandtoolbars/

bits 64

[list -]
    %define   GTK_WINDOW_TOPLEVEL   0
    %define   GTK_WIN_POS_CENTER    1
    %define   FALSE                 0
    %define   TRUE                  1
    %define   GTK_TOOLBAR_ICONS     0
    
    extern    gtk_init
    extern    gtk_window_new
    extern    gtk_window_set_position
    extern    gtk_window_set_default_size
    extern    gtk_window_set_title
    extern    gdk_pixbuf_new_from_file
    extern    gtk_window_set_icon
    extern    gtk_vbox_new
    extern    gtk_container_add
    extern    gtk_toolbar_new
    extern    gtk_toolbar_set_style
    extern    gtk_container_set_border_width
    extern    gtk_tool_button_new_from_stock
    extern    gtk_toolbar_insert
    extern    exit
    extern    gtk_separator_tool_item_new
    extern    gtk_box_pack_start
    extern    g_signal_connect_data
    extern    gtk_widget_show_all
    extern    gtk_main
    extern    gtk_main_quit
[list +]

section .bss
    window:     resq    1   ; pointer to the GtkWidget, in this case the window
    pixbuffer:  resq    1   ; pointer to pixel buffer for icon
    error:      resq    1
    box:        resq    1
    toolbar:    resq    1
    new:        resq    1
    open:       resq    1
    save:       resq    1
    sep:        resq    1
    quit:       resq    1
    
section .data
    mainwindow:
    .title:     db  "toolbar",0
      
    icon:       db  "icon",0
    .file:      db  "logo.png",0              ; must reside in the same directory
    toolbaritem:
    .new:	db  "gtk-new", 0
    .open:      db  "gtk-open", 0
    .save:      db  "gtk-save", 0
    .quit:      db  "gtk-quit", 0
    signal:
    .clicked:	db  "clicked", 0
    .destroy:   db  "destroy", 0
    
section .text
    global _start

_start:
    xor     rsi, rsi                  ; argv
    xor     rdi, rdi                  ; argc
    call    gtk_init
    
    mov     rdi,GTK_WINDOW_TOPLEVEL
    call    gtk_window_new
    mov     qword[window], rax

    mov     rdi, qword[window]
    mov     rsi, GTK_WIN_POS_CENTER
    call    gtk_window_set_position

    mov     rdi, qword[window]
    mov     rsi, 250
    mov     rdx, 200
    call    gtk_window_set_default_size

    ; gtk_window_set_title
    mov     rdi, qword[window]
    mov     rsi, mainwindow.title
    call    gtk_window_set_title

    mov     rdi, icon.file
    mov     rsi, error
    call    gdk_pixbuf_new_from_file
    mov     qword [pixbuffer], rax

    mov     rdi, qword [window]
    mov     rsi, qword [pixbuffer]
    call    gtk_window_set_icon
    
    mov     rdi,FALSE
    mov     rsi,0
    call    gtk_vbox_new                         ; don't use gtk_vbox_new <- deprecated
    mov     qword[box], rax
    
    mov     rdi, qword[window]
    mov     rsi, qword[box]
    call    gtk_container_add
    
    call    gtk_toolbar_new
    mov     qword[toolbar], rax
    
    mov     rdi, qword[toolbar]
    mov     rsi, GTK_TOOLBAR_ICONS
    call    gtk_toolbar_set_style
    
    mov     rdi, qword[toolbar]
    mov     rsi, 2
    call    gtk_container_set_border_width
    
    mov     rdi, toolbaritem.new
    call    gtk_tool_button_new_from_stock
    mov     qword[new], rax
    mov     rdi, qword[toolbar]
    mov     rsi, qword[new]
    mov     rdx, -1
    call    gtk_toolbar_insert
    
    mov     rdi, toolbaritem.open
    call    gtk_tool_button_new_from_stock
    mov     qword[open], rax
    mov     rdi, qword[toolbar]
    mov     rsi, qword[open]
    mov     rdx, -1
    call    gtk_toolbar_insert
    
    mov     rdi, toolbaritem.save
    call    gtk_tool_button_new_from_stock
    mov     qword[save], rax
    mov     rdi, qword[toolbar]
    mov     rsi, qword[save]
    mov     rdx, -1
    call    gtk_toolbar_insert
    
    call    gtk_separator_tool_item_new
    mov     qword[sep], rax
    mov     rdi, qword[toolbar]
    mov     rsi, qword[sep]
    mov     rdx, -1
    call    gtk_toolbar_insert
    
    mov     rdi, toolbaritem.quit
    call    gtk_tool_button_new_from_stock
    mov     qword[quit], rax
    mov     rdi, qword[toolbar]
    mov     rsi, qword[quit]
    mov     rdx, -1
    call    gtk_toolbar_insert

    mov     rdi, qword[box]
    mov     rsi, qword[toolbar]
    mov     rdx, FALSE
    mov     rcx, FALSE
    mov     r8d, 5
    xor     r9d, r9d
    call    gtk_box_pack_start
    
    xor     r9d, r9d                ; combination of GConnectFlags 
    xor     r8d, r8d                ; a GClosureNotify for data
    xor     rcx, rcx                ; pointer to the data to pass
    mov     rdx, gtk_main_quit      ; pointer to the handler
    mov     rsi, signal.clicked     ; pointer to the signal
    mov     rdi, qword[quit]        ; pointer to the widget instance
    call    g_signal_connect_data   ; the value in RAX is the handler, but we don't store it now

    xor     r9d, r9d                ; combination of GConnectFlags 
    xor     r8d, r8d                ; a GClosureNotify for data
    xor     rcx, rcx                ; pointer to the data to pass
    mov     rdx, gtk_main_quit      ; pointer to the handler
    mov     rsi, signal.destroy     ; pointer to the signal
    mov     rdi, qword[window]      ; pointer to the widget instance
    call    g_signal_connect_data   ; the value in RAX is the handler, but we don't store it now
    
    mov     rdi, qword[window]
    call    gtk_widget_show_all

    call    gtk_main

    xor     rdi, rdi
    call    exit
