; Name        : simplemenu
; Build       : see makefile
; Run         : ./simplemenu
; Description : a simple menu example

; for this program to link you need sudo apt-get install gtk+-3.0-dev
; this will install libgtk3-dev and a lot more development libraries.

; C - source : http://zetcode.com/tutorials/gtktutorial/menusandtoolbars/

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
     extern    gtk_window_set_icon
     extern    gtk_widget_show_all
     extern    gtk_main
     extern    gtk_main_quit
     extern    g_signal_connect_data
     extern    gdk_pixbuf_new_from_file
     extern    gtk_box_new
     extern    gtk_container_add
     extern    gtk_menu_bar_new
     extern    gtk_menu_new
     extern    gtk_menu_item_new_with_label
     extern    gtk_menu_item_set_submenu
     extern    gtk_menu_shell_append
     extern    gtk_box_pack_start
     
[list +]

section .bss
    window:          resq    1   ; pointer to the GtkWidget, in this case the window
    pixbuffer:       resq    1       ; pointer to pixel buffer for icon
    error:           resq    1
    box:             resq    1
    menubar:         resq    1
    filemenu:        resq    1
    file:            resq    1
    quit:            resq    1
    
section .data
    mainwindow:
    .title:      db  "simple menu",0
    
    signal:
    .destroy:    db  "destroy",0
    .activate:   db  "activate", 0
    
    icon:        db  "icon",0
    .file:       db  "logo.png",0              ; must reside in the same directory
    menuitem:
    .file:       db  "File", 0
    .quit:       db  "Quit", 0
    
section .text
    global _start

_start:
    xor     rsi, rsi                  ; argv
    xor     rdi, rdi                  ; argc
    call    gtk_init
    
    mov     rdi,GTK_WINDOW_TOPLEVEL
    call    gtk_window_new
    mov     QWORD[window], rax

    mov     rdi, QWORD[window]
    mov     rsi, GTK_WIN_POS_CENTER
    call    gtk_window_set_position

    mov     rdi, qword [window]
    mov     rsi, 250
    mov     rdx, 200
    call    gtk_window_set_default_size

    ; gtk_window_set_title
    mov     rdi, QWORD[window]
    mov     rsi, mainwindow.title
    call    gtk_window_set_title

    mov     rdi, icon.file
    mov     rsi, error
    call    gdk_pixbuf_new_from_file
    mov     qword [pixbuffer], rax

    mov     rdi, qword [window]
    mov     rsi, qword [pixbuffer]
    call    gtk_window_set_icon
    
    mov     rdi, TRUE					; for vertical menus use FALSE
    mov     rsi, 0
    call    gtk_box_new
    mov     qword[box], rax
    
    mov     rdi, qword[window]
    mov     rsi, qword[box]
    call    gtk_container_add
    
    call    gtk_menu_bar_new
    mov     qword[menubar], rax
    
    call    gtk_menu_new
    mov     qword[filemenu], rax
    
    mov     rdi, menuitem.file
    call    gtk_menu_item_new_with_label
    mov     qword[file], rax

    mov     rdi, menuitem.quit
    call    gtk_menu_item_new_with_label
    mov     qword[quit], rax
    
    mov     rdi, qword[file]
    mov     rsi, qword[filemenu]
    call    gtk_menu_item_set_submenu
    
    mov     rdi, qword[filemenu]
    mov     rsi, qword[quit]
    call    gtk_menu_shell_append
    
    mov     rdi, qword[menubar]
    mov     rsi, qword[file]
    call    gtk_menu_shell_append
    
    mov     rdi, qword[box]
    mov     rsi, qword[menubar]
    mov     rdx, FALSE
    mov     rcx, FALSE
    mov     r8d, 3
    mov     r9d, 0
    call    gtk_box_pack_start
    
    xor     r9d, r9d                ; combination of GConnectFlags 
    xor     r8d, r8d                ; a GClosureNotify for data
    xor     rcx, rcx                ; pointer to the data to pass
    mov     rdx, Quit               ; pointer to the handler
    mov     rsi, signal.destroy     ; pointer to the signal
    mov     rdi, QWORD[window]      ; pointer to the widget instance
    call    g_signal_connect_data   ; the value in RAX is the handler, but we don't store it now

    xor     r9d, r9d                ; combination of GConnectFlags 
    xor     r8d, r8d                ; a GClosureNotify for data
    xor     rcx, rcx                ; pointer to the data to pass
    mov     rdx, Quit               ; pointer to the handler
    mov     rsi, signal.activate    ; pointer to the signal
    mov     rdi, QWORD[quit]        ; pointer to the widget instance
    call    g_signal_connect_data   ; the value in RAX is the handler, but we don't store it now
    
    
    mov     rdi, QWORD[window]
    call    gtk_widget_show_all

    call    gtk_main

    xor     rdi, rdi                ; we don't expect much errors now thus errorcode=0
    call    exit

Quit:
    ; if your window disappears but your application is still running then you probably forgot this.
    
    call    gtk_main_quit
    ret