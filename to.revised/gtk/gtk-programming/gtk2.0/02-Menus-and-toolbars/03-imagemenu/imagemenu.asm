; Name        : imagemenu;asm
;
; Build       : nasm -felf64 -o imagemenu.o -l imagemenu.lst imagemenu.asm
;               ld -s -m elf_x86_64 imagemenu.o -o imagemenu -lc --dynamic-linker /lib64/ld-linux-x86-64.so.2
;               -lgtk-3 -lgobject-2.0  -lglib-2.0 -lgdk_pixbuf-2.0 -lgdk-3
; 
; Description : a menu with an image, accelerator and mnemonics example
;
; Remark      : Note that you might have Gnome configured not to show menu images.
;               To turn the menu images on, we launch the gconf-editor and go to
;               /desktop/gnome/interface/menus_have_icons and check the option.
;
; C - source : http://zetcode.com/gui/gtk2/menusandtoolbars/

bits 64

[list -]
   
     %define   GTK_WINDOW_TOPLEVEL   0
     %define   GTK_WIN_POS_CENTER    1
     %define   FALSE                 0
     %define   TRUE                  1
     ; definition in gtkaccelgroup.h
     %define   GTK_ACCEL_VISIBLE    1 << 0 ; accelerator is visible
     %define   GTK_ACCEL_LOCKED     1 << 1 ; accelerator not removable
     %define   GTK_ACCEL_MASK       0x07   ; mask
     ; definition in gdkkeysyms-compat.h
     %define   GDK_q 0x071
     ; definition in gdktypes.h
     %define   GDK_CONTROL_MASK  1 << 2

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
     extern    gtk_vbox_new
     extern    gtk_container_add
     extern    gtk_menu_bar_new
     extern    gtk_menu_new
     extern    gtk_menu_item_new_with_label
     extern    gtk_menu_item_set_submenu
     extern    gtk_menu_shell_append
     extern    gtk_box_pack_start
     extern    gtk_accel_group_new
     extern    gtk_window_add_accel_group
     extern    gtk_menu_item_new_with_mnemonic
     extern    gtk_image_menu_item_new_from_stock
     extern    gtk_separator_menu_item_new
     extern    gtk_widget_add_accelerator
     
[list +]

section .bss
    window:      resq    1   ; pointer to the GtkWidget, in this case the window
    pixbuffer:   resq    1   ; pointer to pixel buffer for icon
    error:       resq    1
    box:         resq    1
    menubar:     resq    1
    filemenu:    resq    1
    file:        resq    1
    new:         resq    1
    open:        resq    1
    sep:         resq    1
    quit:        resq    1
    accel_group: resq    1
    
section .data
    mainwindow:
    .title:      db  "imagemenu",0
    
    signal:
    .destroy:    db  "destroy",0
    .activate:   db  "activate", 0
    
    icon:        db  "icon",0
    .file:       db  "logo.png",0              ; must reside in the same directory
    menuitem:
    .file:       db  "_File", 0
    .new:        db  "_New", 0
    .newimage:   db  "gtk-new", 0
    .open:       db  "_Open", 0
    .openimage:  db  "gtk-open", 0
    .quit:       db  "_Quit", 0
    .quitimage:  db  "gtk-quit", 0
    
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

    mov     rdi, qword [window]
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
    
    mov     rdi, FALSE
    mov     rsi, 0
    call    gtk_vbox_new
    mov     qword[box], rax
    
    mov     rdi, qword[window]
    mov     rsi, qword[box]
    call    gtk_container_add
    
    call    gtk_menu_bar_new
    mov     qword[menubar], rax
    
    call    gtk_menu_new
    mov     qword[filemenu], rax

    call    gtk_accel_group_new
    mov     qword[accel_group], rax
    
    mov     rdi, qword[window]
    mov     rsi, qword[accel_group]
    call    gtk_window_add_accel_group
    
    mov     rdi, menuitem.file
    call    gtk_menu_item_new_with_mnemonic
    mov     qword[file], rax

    mov     rdi, menuitem.newimage 
    mov     rsi, 0
    call    gtk_image_menu_item_new_from_stock
    mov     qword[new], rax
    
    mov     rdi, menuitem.openimage
    mov     rsi, 0
    call    gtk_image_menu_item_new_from_stock
    mov     qword[open], rax
    
    call    gtk_separator_menu_item_new
    mov     qword[sep], rax

    mov     rdi, menuitem.quitimage
    mov     rsi, qword[accel_group]
    call    gtk_image_menu_item_new_from_stock
    mov     qword[quit], rax

    mov     rdi, qword[quit]
    mov     rsi, signal.activate
    mov     rdx, qword[accel_group]
    mov     rcx, GDK_q
    mov     r8d, GDK_CONTROL_MASK
    mov     r9d, GTK_ACCEL_VISIBLE
    call    gtk_widget_add_accelerator
        
    mov     rdi, qword[file]
    mov     rsi, qword[filemenu]
    call    gtk_menu_item_set_submenu
    
    mov     rdi, qword[filemenu]
    mov     rsi, qword[new]
    call    gtk_menu_shell_append
    
    mov     rdi, qword[filemenu]
    mov     rsi, qword[open]
    call    gtk_menu_shell_append
    
    mov     rdi, qword[filemenu]
    mov     rsi, qword[sep]
    call    gtk_menu_shell_append
    
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
    mov     rdi, qword[window]      ; pointer to the widget instance
    call    g_signal_connect_data   ; the value in RAX is the handler, but we don't store it now

    xor     r9d, r9d                ; combination of GConnectFlags 
    xor     r8d, r8d                ; a GClosureNotify for data
    xor     rcx, rcx                ; pointer to the data to pass
    mov     rdx, Quit               ; pointer to the handler
    mov     rsi, signal.activate    ; pointer to the signal
    mov     rdi, qword[quit]        ; pointer to the widget instance
    call    g_signal_connect_data   ; the value in RAX is the handler, but we don't store it now
    
    
    mov     rdi, qword[window]
    call    gtk_widget_show_all

    call    gtk_main

    xor     rdi, rdi                ; we don't expect much errors now thus errorcode=0
    call    exit

Quit:
    ; if your window disappears but your application is still running then you probably forgot this.
    
    call    gtk_main_quit
    ret
