;project:       Webservices
;name:          sslsocket.bss.inc
;description:   .bss section for ssl socket


    ctx:        resq    1
    bio:        resq    1
    file_fd:    resq    1
    buf:        resb    1024
    buf.len:    equ     $-buf

