;project:       Informat
;
;name:          login-cli.asm
;
;date:          17 aug 2020
;
;description:   login from a Linux terminal for Informat
;
;build:         nasm "-felf64" login-cli.asm -o login-cli.o
;               nasm "-felf64" stringsearch.asm -o stringsearch.o
;               ld -s -melf_x86_64 -no-pie login-cli.o -o login-cli stringsearch.o

bits 64

%include "login-cli.inc"

global _start

section .text

_start:

;Before we build up the request we ask for the users credentials.  If an attempt to use
;the program withoutthe application starts we need to provide credentials, otherwise we can't use
;the application.  We put a zero at the end of the input to create an environment
;variable later for the username and the password password .

;ask for the username and store it
syscall write,stdout,login_msg,login_msg.len
syscall read,stdin,login_buf,login_buf.len
    add     rsi,rax              ;last byte of login input is EOL
    dec     rax               ;the real length without the EOL
    mov     qword[login_length],rax     ;store the length for later use

;ask for the password
syscall write,stdout,password_msg,password_msg.len
syscall read,stdin,password_buf,password_buf.len
    add     rsi,rax              ;last byte of login input is EOL
    dec     rax               ;the real length without the EOL
    mov     qword[password_length],rax    ;store for later use

;Allocate just enough memory for the request.
;prepare the request
    syscall brk,0              ;get memory break addres
    mov     qword[heap_start],rax

;check rax, if zero there is no memory left and we can't continue.
;Alternatively we can store it all in a memory mapped file and send it by using the filedescriptor.
    and     rax,rax              
    js      error              ;for now we just bail out

;calculate the length of the memory to allocate
    mov     rdi,request.len         ;length of request

;this is the reason why we store the length of the login an dpassword input
    add     rdi,qword[login_length]     ;plus length of login string
    add     rdi,qword[password_length]    ;plus length of password string
    mov     qword[heap_size],rdi     ;store the size of required bytes to allocate
    add     rdi,qword[heap_start]     ;calculate the new memory break address
    syscall brk,rdi
    mov     qword[new_heap_start],rax    ;in case all goes fine, store the result

;the return value must be the same as the required allocated memory otherwise the request
;can't be build and not be send.  In this case we redirect the user 
    xor     rax,rdi              ;is the result what we
    jnz     error              ;memory could not be reserved
;now store the request 'pieces' in the allocated memory.  For the GET method this is
;a bit painfull.  A POST request seems to be easier but takes also 5 parts.
    mov     rsi,request.part1         
    mov     rcx,request.part1.len
    mov     rdi,qword[heap_start]
    rep     movsb
    mov     rsi,login_buf
    mov     rcx,qword[login_length]
    rep     movsb
    mov     rsi,request.part2
    mov     rcx,request.part2.len
    rep     movsb
    mov     rsi,password_buf
    mov     rcx,qword[password_length]
    rep     movsb
    mov     rsi,request.part3
    mov     rcx,request.part3.len
    rep     movsb    

%ifdef DEBUG
    ;print the request
    syscall write,stdout,qword[heap_start],qword[heap_size]
%endif

;create a socket
    syscall socket, PF_INET, SOCK_STREAM , IPPROTO_IP
    and     rax,rax
    js      error
    mov     qword[fdsocket],rax        ;save socket descriptor
    ;fill in the socket structure
    mov     word[sockaddr_in.sin_family],AF_INET
    mov     ax,word[port]
    mov     word[sockaddr_in.sin_port],ax
    mov     eax,dword[ipaddress]
    mov     dword[sockaddr_in.sin_addr],eax

;set the socket options
    syscall setsockopt, qword[fdsocket],SOL_SOCKET,SO_RCVTIMEO,time_out,time_out.size

;connect to the remote host
    syscall connect,qword[fdsocket],sockaddr_in,sockaddr_in.size
    and     rax,rax
    js      error

%ifdef DEBUG
    ;we are connected
    syscall write,stdout,connected,connected.len
%endif

;send the request
    syscall sendto,qword[fdsocket],qword[heap_start],qword[heap_size],0,0,0
    and     rax,rax
    js      error

;free the allocated memory
    syscall brk,qword[heap_start]
    and     rax, rax
    js      error                ;if negative then error
    ;allocate BUFFERSIZE bytes for the reply
    add     rax, BUFFERSIZE            ;add BUFFERSIZE bytes to the current memory break
    syscall brk, rax
    mov     qword[heap_start],rax     ;heap start and ...
    mov     qword[new_heap_start],rax    ;new heap start (or heap end) are the same now
    xor     rax, rdi                ;rax = new memory pointer, test if different from start of heap
    jnz     error                ;if zero then memory is allocated otherwise we have to free the allocated heap
    xor     r14,r14              ;total bytes read will be stored in r14
    ;now we can send the request and receive the reply, if any
    get_reply:
    mov     r15,qword[new_heap_start]    
    mov     rdi,qword[heap_start]
    add     rdi,r14
    add     rdi,BUFFERSIZE
    syscall brk,rdi
    mov     qword[new_heap_start],rax
;receive the reply
    syscall recvfrom,qword[fdsocket],r15,BUFFERSIZE,0,0,0
    and     rax, rax
    jz      close_socket
    js      close_socket
    add     r14,rax              ;add received bytes to total bytes read
;go to receive next bytes
    jmp     get_reply
close_socket:
    ;store total bytes read
    mov     qword[heap_size],r14

%ifdef DEBUG
    ;we print the buffer
    syscall write,stdout,qword[heap_start],r14
    syscall write,stdout,eol,eol.len
%endif

syscall close,qword[fdsocket]
    mov     qword[fdsocket],0         ;just to be sure

;we have the reply in the heap, look for the closing tag </boolean>
    mov     rdi,login_reply
    mov     rsi,qword[heap_start]
    mov     rdx,login_reply.len
    mov     r8,qword[heap_size]
    call    stringsearch
    and     rax,rax
    js      exit_without_login

;we've found the tag
;read 4 bytes before this tag and compare them with 'true'.
;if not the same then we aren't logged in and we stop the program.
    sub     rax,4
    mov     eax,dword[rax]
    xor     eax,'true'
    jnz     exit_without_login

;print the logged in message
    syscall write,stdout,login_succesfull,login_succesfull.len


%ifdef DEBUG
    ;disconnected message
    syscall write,stdout,disconnected,disconnected.len
%endif

exit:
    ;release allocated memory
    syscall brk,rdi,qword[heap_start]
    ; exit program
    syscall exit,0

exit_without_login:
    ;release allocated memory
    syscall brk,rdi,qword[heap_start]
    syscall write,stdout,access_denied,access_denied.len
    syscall exit,EACCES

error:
    ;later we need to distinguish the errors
    syscall write,stderr,errormsg,errormsg.len
    syscall exit,1
