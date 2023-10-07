;project:       Webservices
;name:          definitions.asm
;build:         nasm -felf64 definitions.asm -l definitions.lst -o definitions.o
;               ld -melf_x86_64 -g --dynamic-linker /lib64/ld-linux-x86-64.so.2 -o definitions definitions.o `pkg-config --libs openssl`
;description:   Get Smartschool definitions

%include "definitions/main.inc"

section .text

_start:

;open file in read/write mode, create it if not exists, after the file creation we got
;a file with read/write permissions for the owner and the owners group.

;O_RDWR to have the possibility to tail -f and watch the output

    syscall open,filename,O_RDWR | O_CREAT, S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP
    test    rax,rax
    js      file_creation_error                 ;negative return values are errors
    mov     qword[file_fd],rax

;the file is created and open for writing, connect, get reply and store it in the file
    xor     rdi,rdi
    xor     rsi,rsi
    call    OPENSSL_init_ssl
    test    rax,rax
    jz      ssl_uninitialized_error

; ssl has been initialized
    call    TLS_client_method
    mov     rdi,rax
    call    SSL_CTX_new
    mov     qword[ctx],rax
    test    rax,rax
    jz      ctx_null_error

    mov     rdi,qword[ctx]
    call    BIO_new_ssl_connect
    mov     qword[bio],rax
;BIO_set_conn_hostname
    mov     rcx,host            ;hostname zero-terminated
    xor     rdx,rdx             ;0 <- must be zero
    mov     rsi,C_SET_CONNECT
    mov     rdi,qword[bio]
    extern  BIO_ctrl
    call    BIO_ctrl
;BIO_do_connect
    xor     rcx,rcx             ;0 <- must be zero
    xor     rdx,rdx             ;0 <- must be zero
    mov     rsi,BIO_C_DO_STATE_MACHINE
    mov     rdi,qword[bio]
    call    BIO_ctrl
    test    rax,rax
    setle   al
    test    al,al
    jnz     connection_failed_error

    mov     rdx,request.len
    mov     rsi,request
    mov     rdi,qword[bio]
    extern  BIO_write
    call    BIO_write
    test    eax,eax
    setle   al
    test    al,al
    jnz     request_failed_error
    jmp     get_response

get_chunk:
    test    rax,rax
    jle     done
    syscall write,qword[file_fd],buf,rax

get_response:
    mov     rdx,buf.len
    mov     rsi,buf
    mov     rdi,qword[bio]
    call    BIO_read
    jmp     get_chunk

done:
    mov     rdi,qword[bio]
    call    BIO_free_all
    mov     rdi,qword[ctx]
    call    SSL_CTX_free
    xor     rdi,rdi
    jmp     exit
    connection_failed_error:
    mov     rsi,msg_connection_failed
    mov     rdx,msg_connection_failed.len
    jmp     write

request_failed_error:
    mov     rsi,msg_request_failed
    mov     rdx,msg_request_failed.len
    jmp     write

ctx_null_error:
    mov     rsi,msg_ctx_null
    mov     rdx,msg_ctx_null.len
    jmp     write

ssl_uninitialized_error:
    mov     rsi,msg_ssl_uninitialized
    mov     rdx,msg_ssl_uninitialized.len
    jmp     write

file_creation_error:
    mov     rsi,error_msg_file_creation
    mov     rdx,error_msg_file_creation.len
write:
    syscall write,stdout        ;write error message
    jmp     exit

exit:
    syscall exit,0
