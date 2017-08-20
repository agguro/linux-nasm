; Name        : checkmenuitem.asm
;
; Build       : nasm -felf64 -o checkmenuitem.o -l checkmenuitem.lst checkmenuitem.asm
;               ld -s -m elf_x86_64 checkmenuitem.o -o checkmenuitem -lc --dynamic-linker /lib64/ld-linux-x86-64.so.2
;               -lgtk-3 -lgobject-2.0  -lglib-2.0 -lgdk-3
;
; Description : Gtk widgets examples
;
; C - source  : http://zetcode.com/gui/gtk2/menusandtoolbars/

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
[list +]

section .bss
       
section .data
    window:
    .handle:    dq  0
    .title:     db  "menu",0
    box:
    .handle:    dq  0
    menubar:
    .handle:    dq  0
    menu:
    .handle:    dq  0
    menuItemView:
    .handle:    dq  0
    .text:      db  "View",0
    checkMenuItem:
    .handle:    dq  0
    .text:      db  "View statusbar",0
    statusbar:
    ;this address will be passed in rsi in routine toggle_statusbar
    ;to get the handle to the statusbar use [rsi]
    .handle:    dq  0
    signal:
    .destroy:   db  "destroy",0
    .activate:  db  "activate", 0

section .text
    global _start

_start:
    ;init gtk
    xor     rsi, rsi                  ; argv
    xor     rdi, rdi                  ; argc
    call    gtk_init
    ;create new window
    mov     rdi,GTK_WINDOW_TOPLEVEL
    call    gtk_window_new
    mov     qword[window.handle], rax
    ;set window position
    mov     rdi, qword[window.handle]
    mov     rsi, GTK_WIN_POS_CENTER
    call    gtk_window_set_position
    ;set window size
    mov     rdi,qword[window.handle]
    mov     rsi,300
    mov     rdx,200
    call    gtk_window_set_default_size
    ;set window title
    mov     rdi, qword[window.handle]
    mov     rsi, window.title
    call    gtk_window_set_title
    ;create a horizontal box
    mov     rdi, TRUE					; for vertical menus use FALSE
    mov     rsi, 0
    call    gtk_box_new					; don't use gtk_vbox_new <- deprecated
    mov     qword[box.handle], rax
    ;add box to window
    mov     rdi, qword[window.handle]
    mov     rsi, qword[box.handle]
    call    gtk_container_add
    ;create menubar
    call    gtk_menu_bar_new
    mov     qword[menubar.handle], rax
    ;create a menu
    call    gtk_menu_new
    mov     qword[menu.handle], rax
    ;create menuitem View
    mov     rdi, menuItemView.text
    call    gtk_menu_item_new_with_label
    mov     qword[menuItemView.handle], rax
    ;create checkmenuitem "View statusbar"
    mov     rdi, checkMenuItem.text
    call    gtk_check_menu_item_new_with_label
    mov     qword[checkMenuItem.handle], rax
    ;set checkmenuitem to checked
    mov     rdi, qword[checkMenuItem.handle]
    mov     rsi, TRUE
    call    gtk_check_menu_item_set_active
    ;set menuitem View to the menu
    mov     rdi, qword[menuItemView.handle]
    mov     rsi, qword[menu.handle]
    call    gtk_menu_item_set_submenu
    ;append checkMenuItem to the menu
    mov     rdi, qword[menu.handle]
    mov     rsi, qword[checkMenuItem.handle]
    call    gtk_menu_shell_append
    ;append menuitem View to the menubar
    mov     rdi, qword[menubar.handle]
    mov     rsi, qword[menuItemView.handle]
    call    gtk_menu_shell_append
    ;add the menubar to the box
    mov     rdi, qword[box.handle]
    mov     rsi, qword[menubar.handle]
    mov     rdx, FALSE                          ;don't expand
    mov     rcx, FALSE                          ;don't fill
    mov     r8d, 0                              ;padding = 0
    call    gtk_box_pack_start
    ;create a statusbar
    call    gtk_statusbar_new
    mov     qword[statusbar.handle], rax
    ;the original example doesn't require a text on the statusbar, on Linux Mint
    ;however the statusbar isn't viewable if nothing appears on it, therefor this
    ;addition.
    ;push the statusbar message on the statusbar stack
    mov     rdi, qword[statusbar.handle]
    mov     rsi, 0
    mov     rdx, checkMenuItem.text
    call    gtk_statusbar_push
    ;add the statusbar to the box at the end
    mov     rdi, qword[box.handle]
    mov     rsi, qword[statusbar.handle]
    mov     rdx, FALSE                          ;don't expand
    mov     rcx, TRUE                           ;fill the entire area
    mov     r8d, 0                              ;padding = 0
    call    gtk_box_pack_end
    ;connect the window signal quit to the event gtk_main_quit
    xor     r9d, r9d                            ;combination of GConnectFlags 
    xor     r8d, r8d                            ;a GClosureNotify for data
    xor     rcx, rcx                            ;pointer to the data to pass
    mov     rdx, gtk_main_quit                  ;pointer to the handler
    mov     rsi, signal.destroy                 ;pointer to the signal
    mov     rdi, qword[window.handle]           ;pointer to the widget instance
    call    g_signal_connect_data               ;the value in rax is the handler, but we don't store it now
    ;connect the checkMenuItem signal activate to the event toggle_statusbar
    xor     r9d, r9d                            ;combination of GConnectFlags 
    xor     r8d, r8d                            ;a GClosureNotify for data
    mov     rcx, qword[statusbar.handle]        ;pointer to the data to pass
    mov     rdx, toggle_statusbar               ;pointer to the handler
    mov     rsi, signal.activate                ;pointer to the signal
    mov     rdi, qword[checkMenuItem.handle]    ;pointer to the widget instance
    call    g_signal_connect_data               ;the value in rax is the handler, but we don't store it now
    ;show the window
    mov     rdi, qword[window.handle]
    call    gtk_widget_show_all
    ;main window loop
    call    gtk_main
    ;exit window
    xor     rdi, rdi
    call    exit
   
toggle_statusbar:
    ;rdi has the checkMenuItem.handle
    ;rsi has the statusbar.handle
    call   gtk_check_menu_item_get_active
    mov    rdi, rsi
    and    rax, rax
    jz     .hide
    call   gtk_widget_show
    ret
.hide:
    ;mov    rdi, qword[statusbar.handle]
    call   gtk_widget_hide
    ret