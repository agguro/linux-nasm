; Name        : statusbarandcheckmenuitem
; Build       : see makefile
; Run         : ./statusbarandcheckmenuitem
; Description : a window with a checkmenu item and a statusbar

; Note that you might have Gnome configured not to show menu images. To turn the menu images on, we launch the gconf-editor and go to /desktop/gnome/interface/menus_have_icons and check the option. 
; C - source : http://zetcode.com/tutorials/gtktutorial/menusandtoolbars/
 
; for this program to link you need sudo apt-get install gtk+-3.0-dev
; this will install libgtk3-dev and a lot more development libraries.

bits 64

[list -]
     ; you can search following values with:
     ; grep "[search string" /usr/include/gtk-3.0/gdk/*.h   for GDK_
     ; or grep "search string" /usr/include/gtk-3.0/gtk/*.h for GTK_
     

     %define   GTK_WINDOW_TOPLEVEL   0
     %define   GTK_WIN_POS_CENTER    1
     %define   FALSE                 0
     %define   TRUE                  1

     extern    gtk_init
     extern    gtk_window_new
     extern    gtk_window_set_position
     extern    gtk_window_set_default_size
     extern    gtk_window_set_title
     extern    gdk_pixbuf_new_from_file
     extern    gtk_window_set_icon
     extern    gtk_box_new
     extern    gtk_container_add
     extern    gtk_menu_bar_new
     extern    gtk_menu_new
     extern    gtk_menu_item_new_with_label
     extern    gtk_check_menu_item_new_with_label
     extern    gtk_check_menu_item_set_active
     extern    gtk_menu_item_set_submenu
     extern    gtk_menu_shell_append
     extern    gtk_box_pack_start
     extern    gtk_statusbar_new
     extern    gtk_statusbar_push
     extern    gtk_box_pack_end
     extern    g_signal_connect_data
     extern    gtk_widget_show_all
     extern    gtk_main
     extern    exit
     extern    gtk_main_quit
     extern    gtk_check_menu_item_get_active
     extern    gtk_widget_show
     extern    gtk_widget_hide
;    extern    gtk_statusbar_get_context_id			; unused

[list +]

section .bss
    window:          resq    1       ; pointer to the GtkWidget, in this case the window
    pixbuffer:       resq    1       ; pointer to pixel buffer for icon
    error:           resq    1
    box:             resq    1
    menubar:         resq    1
    viewmenu:        resq    1
    view:            resq    1
    tog_stat:        resq    1
    statusbar:       resq    1
    ;contextid:       resq    1		no need for this
    
section .data
    mainwindow:
    .title:      db  "menu",0
    
    signal:
    .destroy:    db  "destroy",0
    .activate:   db  "activate", 0
    
    icon:        db  "icon",0
    .file:       db  "logo.png",0              ; must reside in the same directory
    menuitem:
    .view:       	db  "View", 0
    .viewstatusbar:     db  "View statusbar", 0
    statusbartxt:	db  "here is the statusbar", 0
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
    call    gtk_box_new					; don't use gtk_vbox_new <- deprecated
    mov     qword[box], rax
    
    mov     rdi, qword[window]
    mov     rsi, qword[box]
    call    gtk_container_add
    
    call    gtk_menu_bar_new
    mov     qword[menubar], rax
    
    call    gtk_menu_new
    mov     qword[viewmenu], rax

    mov     rdi, menuitem.view
    call    gtk_menu_item_new_with_label
    mov     qword[view], rax
    
    mov     rdi, menuitem.viewstatusbar
    call    gtk_check_menu_item_new_with_label
    mov     qword[tog_stat], rax
    
    mov     rdi, qword[tog_stat]
    mov     rsi, TRUE
    call    gtk_check_menu_item_set_active
    
    mov     rdi, qword[view]
    mov     rsi, qword[viewmenu]
    call    gtk_menu_item_set_submenu
    
    mov     rdi, qword[viewmenu]
    mov     rsi, qword[tog_stat]
    call    gtk_menu_shell_append
            
    mov     rdi, qword[menubar]
    mov     rsi, qword[view]
    call    gtk_menu_shell_append
    
    mov     rdi, qword[box]
    mov     rsi, qword[menubar]
    mov     rdx, FALSE
    mov     rcx, FALSE
    mov     r8d, 3
    mov     r9d, 0
    call    gtk_box_pack_start
    
    call    gtk_statusbar_new
    mov     qword[statusbar], rax
 
    ; not needed
    ;mov     rdi, qword[statusbar]
    ;mov     rsi, statusbartxt
    ;call    gtk_statusbar_get_context_id
    ;mov     qword[contextid], rax
    
    mov     rdi, qword[statusbar]
    mov     rsi, 0				;normally qword[contextid]
    mov     rdx, menuitem.viewstatusbar
    call    gtk_statusbar_push
 
    mov     rdi, qword[box]
    mov     rsi, qword[statusbar]
    mov     rdx, FALSE
    mov     rcx, FALSE
    mov     r8d, 1
    xor     r9d, r9d
    call    gtk_box_pack_end
    
    xor     r9d, r9d                ; combination of GConnectFlags 
    xor     r8d, r8d                ; a GClosureNotify for data
    xor     rcx, rcx                ; pointer to the data to pass
    mov     rdx, Quit               ; pointer to the handler
    mov     rsi, signal.destroy     ; pointer to the signal
    mov     rdi, QWORD[window]      ; pointer to the widget instance
    call    g_signal_connect_data   ; the value in RAX is the handler, but we don't store it now

    xor     r9d, r9d                ; combination of GConnectFlags 
    xor     r8d, r8d                ; a GClosureNotify for data
    mov     rcx, statusbar          ; pointer to the data to pass
    mov     rdx, Toggle_Statusbar   ; pointer to the handler
    mov     rsi, signal.activate    ; pointer to the signal
    mov     rdi, QWORD[tog_stat]    ; pointer to the widget instance
    call    g_signal_connect_data   ; the value in RAX is the handler, but we don't store it now
    
    mov     rdi, QWORD[window]
    call    gtk_widget_show_all

    call    gtk_main

    ; without next line the application works but ends with an error
    xor     rdi, rdi
    call    exit

Quit:
    ; if your window disappears but your application is still running then you probably forgot this.
    call    gtk_main_quit
    ret
    
Toggle_Statusbar:
    mov	   rdi, qword[tog_stat]
    call   gtk_check_menu_item_get_active
    and    rax, rax
    jz     .hide
    mov    rdi, qword[statusbar]
    call   gtk_widget_show
    ret
.hide:
    mov    rdi, qword[statusbar]
    call   gtk_widget_hide
    ret
