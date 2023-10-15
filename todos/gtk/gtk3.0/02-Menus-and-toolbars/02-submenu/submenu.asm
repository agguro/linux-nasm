; Name        : submenu.asm
;
; Build       : nasm -felf64 -o submenu.o -l submenu.lst submenu.asm
;               ld -s -m elf_x86_64 submenu.o -o submenu -lc --dynamic-linker /lib64/ld-linux-x86-64.so.2
;               -lgtk-3 -lgobject-2.0 -lglib-2.0 -lgdk-3
;
; Description : a submenu example
;
; C - source  : http://zetcode.com/gui/gtk2/menusandtoolbars/

bits 64

[list -]
    %define   GTK_WINDOW_TOPLEVEL   0
    %define   GTK_WIN_POS_CENTER    1
    %define   FALSE                 0
    %define   TRUE                  1
    %define   GTK_ORIENTATION_HORIZONTAL 1
    %define   GTK_ORIENTATION_VERTICAL   0
    extern  exit
    extern  gtk_init
    extern  gtk_window_new
    extern  gtk_window_set_title
    extern  gtk_window_set_default_size
    extern  gtk_window_set_position
    extern  gtk_widget_show_all
    extern  gtk_main
    extern  gtk_main_quit
    extern  g_signal_connect_data
    extern  gtk_box_new
    extern  gtk_container_add
    extern  gtk_menu_bar_new
    extern  gtk_menu_new
    extern  gtk_menu_item_new_with_label
    extern  gtk_menu_item_set_submenu
    extern  gtk_menu_shell_append
    extern  gtk_box_pack_start
    extern  gtk_separator_menu_item_new
[list +]

section .bss
    
section .data
    window:
      .handle:  dq  0
      .title:   db  "submenu",0
    vbox:
      .handle:  dq  0
    menubar:
      .handle:  dq  0
    fileMenu:
      .handle:  dq  0
    imprMenu:
      .handle:  dq  0
    sep:
      .handle:  dq  0
    fileMi:
      .handle:  dq  0
      .text:    db  "File",0
    imprMi:
      .handle:  dq  0
      .text:    db  "Import",0
    feedMi:
      .handle:  dq  0
      .text:    db  "Import news feed...",0
    bookMi:
      .handle:  dq  0
      .text:    db  "Import bookmarks...",0
    mailMi:
      .handle:  dq  0
      .text:    db  "Import mail...",0
    quitMi:
      .handle:  dq  0
      .text:    db  "Quit",0
    
    signal:
      .destroy: db  "destroy",0
      .activate:db  "activate", 0    
 ;   icon:       db  "icon",0
 ;     .file:    db  "logo.png",0              ; must reside in the same directory
    
section .text
    global _start

_start:
    ;init gtk
    xor     rsi, rsi                  ; argv
    xor     rdi, rdi                  ; argc
    call    gtk_init
    ;create window
    mov     rdi,GTK_WINDOW_TOPLEVEL
    call    gtk_window_new
    mov     qword[window.handle],rax
    ;set window position
    mov     rdi,qword[window.handle]
    mov     rsi,GTK_WIN_POS_CENTER
    call    gtk_window_set_position
    ;set window size
    mov     rdi,qword[window.handle]
    mov     rsi,300
    mov     rdx,200
    call    gtk_window_set_default_size
    ; set window title
    mov     rdi, qword[window]
    mov     rsi, window.title
    call    gtk_window_set_title
    ; create a box
    mov     rdi,GTK_ORIENTATION_HORIZONTAL
    mov     rsi,0
    call    gtk_box_new                     ;gtk_vbox_new is deprecated
    mov     qword[vbox.handle],rax
    ;ad vbox to window
    mov     rdi,qword[window.handle]
    mov     rsi,qword[vbox.handle]
    call    gtk_container_add
    ; create a menubar
    call    gtk_menu_bar_new
    mov     qword[menubar.handle],rax
    ; create a filemenu
    call    gtk_menu_new
    mov     qword[fileMenu.handle],rax
    ; create menuitem File
    mov     rdi, fileMi.text
    call    gtk_menu_item_new_with_label
    mov     qword[fileMi.handle],rax
    ; create imprMenu
    call    gtk_menu_new
    mov     qword[imprMenu.handle],rax
    ; create menuitems for import menuitem
    mov     rdi,imprMi.text
    call    gtk_menu_item_new_with_label
    mov     qword[imprMi.handle],rax
    ; create menuitem "Import news feed..."
    mov     rdi,feedMi.text
    call    gtk_menu_item_new_with_label
    mov     qword[feedMi.handle],rax
    ; create menuitem "Import bookmarks..."
    mov     rdi,bookMi.text
    call    gtk_menu_item_new_with_label
    mov     qword[bookMi.handle],rax
    ; create menuitem "Import mail..."
    mov     rdi,mailMi.text
    call    gtk_menu_item_new_with_label
    mov     qword[mailMi.handle],rax
    ; set this submenu
    mov     rdi,qword[imprMi]
    mov     rsi,qword[imprMenu]
    call    gtk_menu_item_set_submenu
    ; append feed menuitem
    mov     rdi,qword[imprMenu]
    mov     rsi,qword[feedMi]
    call    gtk_menu_shell_append
    ; append book menuitem
    mov     rdi,qword[imprMenu]
    mov     rsi,qword[bookMi]
    call    gtk_menu_shell_append
    ; append mail menuitem
    mov     rdi,qword[imprMenu]
    mov     rsi,qword[mailMi]
    call    gtk_menu_shell_append
    ; create a separator
    call    gtk_separator_menu_item_new
    mov     qword[sep.handle],rax
    ; create menuitem Quit
    mov     rdi,quitMi.text
    call    gtk_menu_item_new_with_label
    mov     qword[quitMi.handle],rax
    ; create the fileMenu
    mov     rdi,qword[fileMi]
    mov     rsi,qword[fileMenu]
    call    gtk_menu_item_set_submenu
    ; append imprMi to the fileMenu
    mov     rdi,qword[fileMenu]
    mov     rsi,qword[imprMi]
    call    gtk_menu_shell_append
    ; append the separator
    mov     rdi,qword[fileMenu]
    mov     rsi,qword[sep]
    call    gtk_menu_shell_append
    ; append the quitMi menu
    mov     rdi,qword[fileMenu]
    mov     rsi,qword[quitMi]
    call    gtk_menu_shell_append
    ; append this menu to the menubar
    mov     rdi,qword[menubar]
    mov     rsi,qword[fileMi]
    call    gtk_menu_shell_append
    
    mov     rdi,qword[vbox]
    mov     rsi,qword[menubar]
    mov     rdx,FALSE
    mov     rcx,FALSE
    xor     r8,r8
    xor     r9,r9
    call    gtk_box_pack_start
    
    xor     r9d, r9d                ; combination of GConnectFlags 
    xor     r8d, r8d                ; a GClosureNotify for data
    xor     rcx, rcx                ; pointer to the data to pass
    mov     rdx, gtk_main_quit      ; pointer to the handler
    mov     rsi, signal.destroy     ; pointer to the signal
    mov     rdi, qword[window.handle]      ; pointer to the widget instance
    call    g_signal_connect_data   ; the value in RAX is the handler, but we don't store it now

    xor     r9d, r9d                ; combination of GConnectFlags 
    xor     r8d, r8d                ; a GClosureNotify for data
    xor     rcx, rcx                ; pointer to the data to pass
    mov     rdx, gtk_main_quit      ; pointer to the handler
    mov     rsi, signal.activate    ; pointer to the signal
    mov     rdi, qword[quitMi.handle]        ; pointer to the widget instance
    call    g_signal_connect_data   ; the value in RAX is the handler, but we don't store it now
        
    mov     rdi, qword[window.handle]
    call    gtk_widget_show_all

    call    gtk_main

    xor     rdi, rdi                ; we don't expect much errors now thus errorcode=0
    call    exit

Quit:
    ; if your window disappears but your application is still running then you probably forgot this.
    
    call    gtk_main_quit
    ret
