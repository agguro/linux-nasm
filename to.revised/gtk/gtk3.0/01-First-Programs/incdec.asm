; Name        : inc-dec.asm
;
; Build       : nasm -felf64 -o inc-dec.o -l inc-dec.lst inc-dec.asm
;               ld -s -m elf_x86_64 aboutbox.o -o aboutbox -lc --dynamic-linker /lib64/ld-linux-x86-64.so.2
;               -lgtk-3 -lgobject-2.0  -lglib-2.0 -lgdk_pixbuf-2.0 -lgdk-3
;
; Description : three widgets example (two buttons and one label)
;
; C - source  : http://zetcode.com/gui/gtk2/firstprograms/

bits 64

[list -]
    extern  exit
    extern  sprintf
    extern  gtk_init
    extern  gtk_window_new
    extern  gtk_window_set_title
    extern  gtk_window_set_default_size
    extern  gtk_window_set_position
    extern  gtk_window_set_icon
    extern  gtk_fixed_new
    extern  gtk_container_add
    extern  gtk_button_new_with_label
    extern  gtk_widget_set_size_request
    extern  gtk_fixed_put
    extern  gtk_label_new
    extern  gtk_label_set_text
    extern  gtk_widget_show_all
    extern  gtk_main
    extern  gtk_main_quit
    extern  g_signal_connect_data
    extern  gdk_pixbuf_new_from_file
[list +]

    %define GTK_WINDOW_TOPLEVEL   0
    %define GTK_WIN_POS_CENTER    1
    %define WIDTH   250
    %define HEIGHT  150
    
section .bss
    window:         resq    1       ; pointer to the GtkWidget, in this case the window
    pixbuffer:      resq    1       ; pointer to pixel buffer for icon
    error:          resq    1
    frame:          resq    1
    plusbutton:     resq    1       ; the plus button
    minusbutton:    resq    1       ; the minus button
    label:          resq    1       ; the label
    buffer:         resb    5       ; buffer for counter (label text)

section .data

    title:          db      "increase - decrease",0
    destroy:        db      "destroy",0
    clicked:        db      "clicked",0
    icon:           db      "icon",0
    iconfile:       db      "logo.png",0              ; must reside in the same directory
    plussign:       db      "+",0
    minussign:      db      "-",0
    labeltext:      db      "0",0
    text1:          db      "increased",0
    text2:          db      "decreased",0
    count:          dq      0                        ; our counter
    mask:           db      "%d",0
    
section .text
    global _start

_start:
    xor     rsi, rsi                  ; argv
    xor     rdi, rdi                  ; argc
    call    gtk_init
    
    mov     rdi, iconfile
    mov     rsi, error
    call    gdk_pixbuf_new_from_file
    mov     qword [pixbuffer], rax
    
    mov     rdi,GTK_WINDOW_TOPLEVEL
    call    gtk_window_new
    mov     qword [window], rax
    
    mov     rdi, qword [window]
    mov     rsi, title
    call    gtk_window_set_title

    mov     rdi, qword [window]
    mov     rsi, WIDTH                              ; width
    mov     rdx, HEIGHT                             ; height
    call    gtk_window_set_default_size
    
    mov     rdi, qword [window]
    mov     rsi, GTK_WIN_POS_CENTER
    call    gtk_window_set_position

    mov     rdi, qword [window]
    mov     rsi, qword [pixbuffer]
    call    gtk_window_set_icon

    ; new frame for the buttons
    call    gtk_fixed_new
    mov     qword[frame], rax
    
    ; add to the window
    mov     rdi, qword[window]
    mov     rsi, qword[frame]
    call    gtk_container_add
    
    ; create + button
    mov     rdi, plussign
    call    gtk_button_new_with_label
    mov     qword[plusbutton], rax

    ; set size
    mov     rdi, qword[plusbutton]
    mov     rsi, 80
    mov     rdx, 35
    call    gtk_widget_set_size_request
    
    ; add to the frame
    mov     rdi, qword[frame]
    mov     rsi, qword[plusbutton]
    mov     rdx, 50
    mov     rcx, 20
    call    gtk_fixed_put

    ; create - button
    mov     rdi, minussign
    call    gtk_button_new_with_label
    mov     qword[minusbutton], rax

    ; set size
    mov     rdi, qword[minusbutton]
    mov     rsi, 80
    mov     rdx, 35
    call    gtk_widget_set_size_request
    
    ; add to the frame
    mov     rdi, qword[frame]
    mov     rsi, qword[minusbutton]
    mov     rdx, 50
    mov     rcx, 80
    call    gtk_fixed_put

    ; create the label; print to buffer
    mov     rdi, buffer
    mov     rsi, mask
    mov     rdx, qword[count]
    xor     rax, rax
    call    sprintf
    ; set buffer as label text
    xor     rdi, rdi                   ; no tekst
    call    gtk_label_new
    mov     qword[label], rax
    mov     rdi, qword[label]
    mov     rsi, buffer
    call    gtk_label_set_text
    
    ; add to frame
    mov     rdi, qword[frame]
    mov     rsi, qword[label]
    mov     rdx, 190
    mov     rcx, 58
    call    gtk_fixed_put

    ; show all windows
    mov     rdi, qword[window]
    call    gtk_widget_show_all

    ; add signal handlers
    ; Quit
    xor     r9d, r9d                ; combination of GConnectFlags 
    xor     r8d, r8d                ; a GClosureNotify for data
    xor     rcx, rcx                ; pointer to the data to pass
    mov     rdx, gtk_main_quit      ; pointer to the handler
    mov     rsi, destroy            ; pointer to the signal
    mov     rdi, qword[window]      ; pointer to the widget instance
    call    g_signal_connect_data   ; the value in RAX is the handler, but we don't store it now

    ; button plus clicked
    mov     rdi, qword[plusbutton]
    mov     rsi, clicked
    mov     rdx, Increase
    xor     rcx, rcx                     ; qword[label] is a global variable, so we don't pass label to signal handler
    xor     r8d, r8d
    xor     r9d, r9d
    call    g_signal_connect_data

    ; button plus clicked
    mov     rdi, qword[minusbutton]
    mov     rsi, clicked
    mov     rdx, Decrease
    xor     rcx, rcx                   ; qword[label] is a global variable, so we don't pass label to signal handler
    xor     r8d, r8d
    xor     r9d, r9d
    call    g_signal_connect_data

    call    gtk_main

    xor     rdi, rdi                   ; we don't expect much errors now
    call    exit

; signal handlers     
Increase:
    ; adjust counter
    inc     qword[count]
    ; print to buffer
    mov     rdi, buffer
    mov     rsi, mask
    mov     rdx, qword[count]
    xor     rax, rax
    call    sprintf
    ; set buffer as label text
    mov     rdi, qword[label]
    mov     rsi, buffer
    call    gtk_label_set_text
    ret
    
Decrease:
    ; adjust counter
    dec     qword[count]
    ; print to buffer
    mov     rdi, buffer
    mov     rsi, mask
    mov     rdx, qword[count]
    xor     rax, rax
    call    sprintf
    ; set buffer as label text
    mov     rdi, qword[label]
    mov     rsi, buffer
    call    gtk_label_set_text
    ret
