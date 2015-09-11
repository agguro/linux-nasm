; httpserver.asm
;
; A very very basic httpserver demonstration.
; For this I got my inspiration from the 32 bit application httpd from asmutils-0.18.
; http://asm.sourceforge.net/asmutils.html
;
; update: 4/11/2014 : bug in creating the socket,  mov rdi, PF_INET and mov rsi, SOCK_STREAM
;                     added %define for constants AF_INET, SOCK_STREAM, PF_INET, IPPROTO_IP, INADDR_ANY
; to-do: - a lot!!
;        - configuration file
;        - execute binary files (cgi-bin)
;        - environment variables
;        - special tag support php, aspx like but for Nasm
;        - .... suggestions?
;
; Application: This program running as local webserver is usefull to watch requests send to the webserver.
;
; Read also the info.txt file.
 
BITS 64
[list -]
      %include "unistd.inc"
      %include "sys/wait.inc"
      %include "sys/socket.inc"
[list +]



section .bss
 
sockfd:                 resq 1
sock_addr:              resq 1
 
section .data
 
; message to keep user confortable that the server is actually running
server_listening:         db "server is listening"
lf                        db 10
server_listening.length:  equ $-server_listening
 
trying:                   db  "starting..."
trying.length:            equ $-trying
 
; the buffer to read the client request, in this application we only read and show the contents of such a request.
; Sometimes there is interesting info in it.  In more advanced webserver applications we need to parse the required
; page, serve the page and eventually perform cgi scripts.
buffer:                   times 1024 db 0
.length: equ $-buffer
 
; A full webserver reply 200.  We can send other pages too. A full list of status codes can be found at
; http://en.wikipedia.org/wiki/List_of_HTTP_status_codes

reply:               ;   db 'HTTP/1.1 301 Moved Permanently', 10
                     ;   db 'Location: http://www.agguro.be/index.php', 10, 10   <-- example of redirect -->
                     
                        db 'HTTP/1.1 200 OK',10
                        db 'Server: demo web server',10               ; change 'demo web server' to your own name
                        db 'Set-Cookie:UserID=XYZ', 10                ; change the cookies and un remark them if you like 
                        db 'Set-Cookie:Password=XYZ123', 10
                        db 'Set-Cookie:Domain=www.agguro.be', 10
                        db 'Set-Cookie:Path=/', 10
                        db 'Content-length: 296',10                   ; the length of the webpage we will send back, calculated last-first+1
                        db 'Content-Type: text/html',10,10            ; the content type
                        db '<!DOCTYPE html><html>'
                        db '<head><title>demo webserver</title></head>'
                        db '<body><h1>Demo webserver</h1>'
                        db '<form method="post" action="http://localhost:4444/?t=1">'
                        db '<input type="text" name="inputfield" value="type something" />'
                        db '<button type="submit" name="submit" value="name">Send data</button>'
                        db '</form></body></html>'
reply.length:           equ $-reply
 
socketerror:            db "socketerror", 10
.length:                equ $-socketerror
listenerror:            db "listenerror", 10
.length:                equ $-listenerror

port:                   db 17,92           ; port 4444 (256 * 17 + 92)

section .text
 
global _start
 
_start:
 
; create a socket
        mov     rax, SYS_SOCKET          ; call socket(SOCK_STREAM, AF_NET, 0);
        mov     rdi, PF_INET             ; PF_INET = 2
        mov     rsi, SOCK_STREAM         ; SOCK_STREAM = 1
        mov     rdx, IPPROTO_IP          ; IPPROTO_IP = 0
        syscall
        cmp     rax, 0
        jz      .socketerror
        mov     QWORD[sockfd], rax
 
; fill in sock_addr structure (on stack)
        xor     r8, r8                   ; clear the value of r8
        mov     r8, INADDR_ANY           ; (INADDR_ANY = 0) - if changed to 100007Fx(IP address : 127.0.0.1) we can only connect locally
        push    r8                       ; push r8 to the stack
        push    WORD [port]              ; push our port number to the stack
        push    WORD AF_INET             ; push protocol argument to the stack (AF_INET = 2)
        mov     QWORD[sock_addr], rsp    ; Save the sock_addr_in
 
; bind the socket to the address, keep trying until we succeed.
; if the address is still in use, bind will fail, we can avoid this with the setsockopt syscall, but we use INADDR_ANY so anyone can
; bind to the server's socket.  Therefor I don't use setsockopt.
; You can read more here: http://hea-www.harvard.edu/~fine/Tech/addrinuse.html
; Instead I keep trying until the server allows us to bind again, in the mainwhile we wait ....
 
        mov     rsi, trying
        mov     rdx, trying.length

        mov     rdi, STDOUT
        mov     rax, SYS_WRITE
        syscall
.tryagain: 
        mov     rax, SYS_BIND             ; bind(sockfd, sockaddr, addrleng);
        mov     rdi, qword[sockfd]        ; sockfd from socket syscall
        mov     rsi, qword[sock_addr]     ; sockaddr 
        mov     rdx, 16                   ; addrleng the ip address length
        syscall
        and     rax, rax
        jnz     .tryagain
 
.bindsucces:
        ; first end the previous line with LF
        mov     rsi, lf
        mov     rdx, 1
        mov     rdi, STDOUT
        mov     rax, SYS_WRITE
        syscall
 
        mov     rax, SYS_LISTEN           ; int listen(sockfd, backlog);
        mov     rdi, qword[sockfd]        ; sockfd
        xor     rsi, rsi                  ; backlog
        syscall
        or      rax, rax
        jnz     .listenerror
 
        ; inform user that the server is listening
        mov     rsi, server_listening
        mov     rdx, server_listening.length
        mov     rdi, STDOUT
        mov     rax, SYS_WRITE
        syscall
 
.acceptloop:
        mov     rax, SYS_ACCEPT           ; int accept(sockfd, sockaddr, socklen);
        mov     rdi, qword[sockfd]        ; sockfd
        xor     rsi, rsi                  ; sockaddr
        xor     rdx, rdx                  ; socklen
        syscall 
        cmp     rax, 0
        js      .acceptloop
        mov     r12, rax                  ; use the accept socket from here
 
        mov     rdi, -1                   ; following the original source we need two
        mov     rsi, 0                    ; WAIT4 to prevent zombies. I tried without it,
        mov     rdx, WNOHANG              ; with zombies as a result
        mov     rcx, 0
        mov     rax, SYS_WAIT4
        syscall
 
        mov     rdi, -1
        mov     rsi, 0
        mov     rdx, WNOHANG
        mov     rcx, 0
        mov     rax, SYS_WAIT4
        syscall
 
        ; we have accepted a connection, let a child do the work while the parent wait to accept other connections
        mov     rax, SYS_FORK
        syscall
        and     rax, rax
        jz      .serveclient              ; Child continues here
 
        mov     rdi, r12                  ; parent closes the connection
        mov     rax, SYS_CLOSE
        syscall
        jmp     .acceptloop               ; and go back to accept new incoming connections
 
.serveclient:
        ; the client has send a request, we read this and put it in a buffer
        mov     rax, SYS_READ
        mov     rdi, r12
        mov     rsi, buffer
        mov     rdx, buffer.length
        syscall
 
        ; write received request to the terminal (later this can be a log file)
        ; the actual read bytes are stored in RAX
        mov     rdx, rax
        mov     rsi, buffer
        mov     rdi, STDOUT
        mov     rax, SYS_WRITE
        syscall
 
        ; additional end of line
        mov     rsi, lf
        mov     rdx, 1
        mov     rdi, STDOUT
        mov     rax, SYS_WRITE
        syscall
 
        ; here we should parse the request from client that's put in STDIN
        ; now we just reply with the so called "reply"
        ; decision making stuff comes here, exp: CGI scripts, request for additional pages etc...
        ; see the original source
 
        ; send the reply to the client
        mov     rdi, r12
        mov     rsi, reply
        mov     rdx, reply.length
        mov     rax, SYS_WRITE
        syscall
 
        ; we are done, exit Child process
        xor     rdi, rdi
        mov     rax, SYS_EXIT
        syscall
 
; the errors
.listenerror:
        mov     rsi, listenerror
        mov     rdx, listenerror.length
        jmp     .print
 
.socketerror:
        mov     rsi, socketerror
        mov     rdx, socketerror.length
        jmp     .print
 
.print:
        mov     rdi, STDOUT
        mov     rax, SYS_WRITE
        syscall
.exit:  
        xor     rdi, rdi
        mov     rax, SYS_EXIT
        syscall