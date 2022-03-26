; Name        : mycpuWidget.asm
;
; Build       : nasm -felf64 -o mycpuWidget.o -l mycpuWidget.lst mycpuWidget.asm
;               ld -s -m elf_x86_64 mycpuWidget.o -o mycpuWidget -lc --dynamic-linker /lib64/ld-linux-x86-64.so.2 -lgtk-3 -lgobject-2.0  -lglib-2.0 -lgdk_pixbuf-2.0 -lgdk-3
;
; Description : a custom PU Widget example
;
; C - source : http://zetcode.com/gui/gtk2/customwidget/

bits 64

[list -]
    %define   GTK_WINDOW_TOPLEVEL   0
    %define   GTK_WIN_POS_CENTER    1
    %define   FALSE                 1
    %define   TRUE                  0
    
    extern    exit
    extern    gtk_init
    extern    gtk_window_new
    extern    gtk_window_set_title
    extern    gtk_container_set_border_width
    extern    gtk_vbox_new
    extern    gtk_hbox_new
    extern    gtk_vscale_new_with_range
    extern    gtk_range_set_inverted
    extern    g_signal_connect_data
    extern    gtk_box_pack_start
    extern    gtk_container_add
    extern    gtk_widget_show_all
    extern    gtk_main
    extern    gtk_main_quit
[list +]

section .bss
    window: resq 1
    hbox:   resq 1
    vbox:   resq 1
    hcpu:   resq 1              ;cpu is a reserver name
    scale:  resq 1

section .rodata
    szValueChanged: db  "value-changed",0
    szDestroy:      db  "destroy",0
    szTitle:        db  "CPU widget",0

section .text
    global _start

_start:
    xor     rsi, rsi
    xor     rdi, rdi
    call    gtk_init
    
    mov     rdi,GTK_WINDOW_TOPLEVEL
    call    gtk_window_new
    mov     qword[window], rax

    mov     rdi, qword[window]
    mov     rsi, 15
    call    gtk_container_set_border_width

    mov     rdi, qword[window]
    mov     rsi, szTitle
    call    gtk_window_set_title

    mov     rdi,0
    mov     rsi,FALSE
    call    gtk_vbox_new
    mov     qword[vbox],rax

    mov     rdi,25
    mov     rsi,FALSE
    call    gtk_hbox_new
    mov     qword[hbox],rax

;   cpu = my_cpu_new();

    mov     rdi, qword[vbox]
    mov     rsi, qword[hcpu]
    mov     rdx, FALSE
    mov     rcx, FALSE
    xor     r8, r8
    xor     r9, r9
    call    gtk_box_pack_start

    mov     rdi,0
    mov     rsi,100
    mov     rdx,1
    call    gtk_vscale_new_with_range
    mov     qword[scale],rax 
   
    mov     rdi,qword[scale]
    mov     rsi,TRUE
   call     gtk_range_set_inverted

    mov     rdi, qword[hbox]
    mov     rsi, qword[scale]
    mov     rdx, FALSE
    mov     rcx, FALSE
    xor     r8, r8
    xor     r9, r9
    call    gtk_box_pack_start

    mov     rdi, qword[vbox]
    mov     rsi, qword[hbox]
    mov     rdx, FALSE
    mov     rcx, FALSE
    xor     r8, r8
    xor     r9, r9
    call    gtk_box_pack_start
   
    mov     rdi, qword[window]
    mov     rsi, qword[vbox]
    call    gtk_container_add

    xor     r9d, r9d                ; combination of GConnectFlags 
    xor     r8d, r8d                ; a GClosureNotify for data
    xor     rcx, qword[hcpu]        ; pointer to the data to pass
    mov     rdx, cb_changed         ; pointer to the handler
    mov     rsi, szValueChanged     ; pointer to the signal
    mov     rdi, qword[scale]       ; pointer to the widget instance
    call    g_signal_connect_data   ; the value in RAX is the handler, but we don't store it now

    xor     r9d, r9d                ; combination of GConnectFlags 
    xor     r8d, r8d                ; a GClosureNotify for data
    xor     rcx, rcx                ; pointer to the data to pass
    mov     rdx, gtk_main_quit      ; pointer to the handler
    mov     rsi, szDestroy          ; pointer to the signal
    mov     rdi, qword[window]      ; pointer to the widget instance
    call    g_signal_connect_data   ; the value in RAX is the handler, but we don't store it now

    mov     rdi, qword[window]
    call    gtk_widget_show_all

    call    gtk_main

    xor     rdi, rdi                ; we don't expect much errors now thus errorcode=0
    call    exit
    
    

    
       


cb_changed:
    push    rbp

;   void cb_changed(GtkRange *range, GtkWidget *cpu) {
;       my_cpu_set_percent(MY_CPU(cpu), gtk_range_get_value(range));
;   }

    pop     rbp
    ret





