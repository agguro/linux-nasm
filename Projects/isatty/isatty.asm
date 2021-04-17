;name: isatty.asm
;
;description:
;

bits 64

%include "../isatty/isatty.inc"

global main

section .bss
;uninitialized read-write data 

section .data
    TERMIOS	termios                         ;termios structure
    gtkwindow:  dq  0
    gtkdialog:  dq  0
    loader:     dq  0
    pixbuffer:
    .icon:      dq  0
    .image:     dq  0
    envplist:   dq  0

section .rodata
    logo:       incbin "../isatty/logo.png"
    .size:      equ $-logo
    picture:    incbin "../isatty/picture.png"
    .size:      equ $-picture
    aboutdialog:
    .title:     db  " TTY or not example", 0
    .version:   db  "version 1.0", 0
    .copyright: db  "(c) agguro - 2021", 0
    .comments:  db  "This is an example on checking if an application is", 10
                db  "started from a terminal or from a desktop.", 10
                db  "This and more examples can be found at", 0
    .website:   db  "https://www.linuxnasm.be", 0
    .len:       equ $-aboutdialog

    msgTerminal: db  "TTY or not example - version 1.0", 10
                 db  "(c) agguro - 2021 (https://linuxnasm.be)", 10
    .len:        equ $-msgTerminal
    msgGUIterminal: db  "The application seems to be started from a terminal session on your desktop,", 10
                    db  "instead you can start this program in a GUI or open a real terminal with CTRL-ALT-F1.", 10
    .len:           equ $-msgGUIterminal
    msgRealterminal: db "The commandline version of the application can, for example, start here.", 10, 10
    .len:            equ $-msgRealterminal

section .text

main:
    push    rbp
    mov     rbp,rsp
    ;get the enviroment parameterlist pointer
    mov     rax,rsi                         ;location of address programname
    mov     rdx,rdi                         ;arguments on commandline in rdx
    shl     rdx,3                           ;multiply by 8
    add     rax,rdx                         ;add to location of address programname
    add     rax,8                           ;skip null pointer of argument list
    mov     qword [envplist],rax            ;save start of environment parameter list
    ;check if the application is ran from a terminal session
    syscall ioctl,stdin,TCGETS,termios
    ;if the result in rax is a negative value then we aren't running from a terminal
    test    rax,rax
    js      .notfromterminal
    ;if rax returns zero the program is running from a terminal
    ;we have to figure out if the terminal is started from a desktop (GUI) or not
    ;this can be done by looking for the environment parameter TERM=linux.
    mov     rax,qword [envplist]            ;read start of environment parameter list
.repeat:
    mov     r15,qword [rax]                 ;read address of environment parameter
    test    r15,r15                         ;check if at end of list
    jz      .endoflist
    mov     edx,dword [r15]                 ;read first dword
    cmp     edx,"TERM"
    je      .foundkeyword
    jmp     .next
.foundkeyword:
    mov     dl,byte [r15+4]
    cmp     dl,"="
    jne     .next
    mov     rdx,qword [r15+5]
    shl     rdx,24
    shr     rdx,24
    mov     rcx,"linux"
    xor     rdx,rcx
    test    rdx,rdx
    jz      .inarealterminal
.next:
    add     rax,8                           ;next environment parameter
    jmp     .repeat

.endoflist:
    ;if we arrive here we are in a GUI terminal
    syscall write,stdout,msgTerminal,msgTerminal.len
    syscall write,stdout,msgGUIterminal,msgGUIterminal.len
    jmp     .done

.inarealterminal:
    ;if we are here we are in a real terminal, just to make the difference we show
    ;another message (but it can be the same or just the application that starts)
    syscall write,stdout,msgTerminal,msgTerminal.len
    syscall write,stdout,msgRealterminal,msgRealterminal.len

.done:
    mov     rsp,rbp
    pop     rbp
    ret

.notfromterminal:
    xor     rsi, rsi                        ;argv
    xor     rdi, rdi                        ;argc
    call    gtk_init                        ;initialize gtk
    ; loading the the application icon in a buffer -> pixbuffer
    call    gdk_pixbuf_loader_new
    mov     qword [loader], rax             ;save pointer to loader
    ;copy icon data into pixbuffer.icon
    mov     rdi, qword [loader]
    mov     rsi, logo
    mov     edx, logo.size
    xor     rcx, rcx
    call    gdk_pixbuf_loader_write
    ;load data from pixbuffer
    mov     rdi, qword [loader]
    call    gdk_pixbuf_loader_get_pixbuf
    mov     qword [pixbuffer.icon], rax     ;save pointer to pixbuffer icon
    ;create new window
    mov     rdi,GTK_WINDOW_TOPLEVEL
    call    gtk_window_new
    mov     qword [gtkwindow], rax      ;save handle to new window
    ;create a new dialog box
    call    gtk_about_dialog_new
    mov     qword[gtkdialog], rax
    ;show and run dialogbox
    mov     rdi, qword [gtkwindow]
    call    show_about
    ;destroy gtk window and associated dialogs
    mov     rdi, qword [gtkwindow]
    call    gtk_widget_destroy
.exit:
    xor     rax,rax             ;return error code
    mov     rsp,rbp
    pop     rbp
    ret                         ;exit is handled by compiler

show_about:
    ; RDI has GtkWidget *widget
    ; RSI has gpointer data
    ; create stackframe to prevent segmentation faults
    push    rbp
    mov     rbp, rsp
    call    gdk_pixbuf_loader_new
    mov     qword [loader], rax
    mov     rdi, qword[loader]
    mov     rsi, picture
    mov     edx, picture.size
    xor     rcx, rcx
    call    gdk_pixbuf_loader_write
    mov     rdi, qword[loader]
    call    gdk_pixbuf_loader_get_pixbuf
    mov     qword[pixbuffer.image], rax
    mov     rdi, qword[gtkdialog]
    mov     rsi, aboutdialog.title
    call    gtk_about_dialog_set_program_name
    mov     rdi, qword[gtkdialog]
    mov     rsi, aboutdialog.version
    call    gtk_about_dialog_set_version
    mov     rdi, qword[gtkdialog]
    mov     rsi, aboutdialog.copyright
    call    gtk_about_dialog_set_copyright
    mov     rdi, qword[gtkdialog]
    mov     rsi, aboutdialog.comments
    call    gtk_about_dialog_set_comments
    mov     rdi, qword[gtkdialog]
    mov     rsi, aboutdialog.website
    call    gtk_about_dialog_set_website
    mov     rdi, qword[gtkdialog]
    mov     rsi, aboutdialog.website
    call    gtk_about_dialog_set_website_label
    mov     rdi, qword[gtkdialog]
    mov     rsi, qword[pixbuffer.image]
    call    gtk_about_dialog_set_logo
    mov     rdi, qword[gtkdialog]
    mov     rsi, qword[pixbuffer.icon]
    call    gtk_window_set_icon
    mov     rdi, qword[gtkdialog]
    call    gtk_dialog_run
    mov     rsp,rbp
    pop     rbp
    ret
