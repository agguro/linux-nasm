;project:   Webservices
;name:      sslsocket.rodata.inc
;description:   .rodata section for ssl socket


    msg_ctx_null:               db  MSG_CTX_NULL,LF
    .len:                       equ $-msg_ctx_null
    msg_ssl_uninitialized:      db  MSG_SSL_UNINITIALIZED, LF
    .len:                       equ $-msg_ssl_uninitialized   

    error_msg_file_creation:    db  ERROR_FILE_CREATION,LF
    .len:                       equ $-error_msg_file_creation

    msg_connection_failed:      db  ERROR_CONNECTION_FAILED,LF
    .len:                       equ $-msg_connection_failed

    msg_request_failed:         db  ERROR_REQUEST_FAILED,LF
    .len:                       equ $-msg_request_failed
