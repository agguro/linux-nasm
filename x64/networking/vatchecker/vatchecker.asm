; vatchecker.asm
;
; VAT checker with requests to vatid.eu
;
; valid country codes:

;   AT Austria,   BE Belgium,    BG Bulgaria    CY Cyprus,   CZ Czech Republic,    DK Denmark,    EE Estonia,    FI Finland,    FR France,    DE Germany
;   EL Greece,    HU Hungary,    IE Ireland,    IT Italy,    LV Latvia,            LT Lithuania,  LU Luxembourg,    MT Malta,    NL Netherlands,    PL Poland
;   PT Portugal,  RO Romania,    SK Slovakia,    SI Slovenia,    ES Spain,    SE Sweden,    GB United Kingdom
;
; errors:
; {  "error": { "code": "vies-unavailable", "text": "VIES Webservice currently unavailable."}}
;                       "member-state-unavailable"
;                       "invalid-input"
; response:
;{
;  "response": {
;    "country_code": "BE",
;    "vat_number": "0823633037",
;    "valid": "true",
;    "name": "BVBA ABSOTECH",
;    "address": "VAARTSTRAAT 2\n3191  BOORTMEERBEEK",
;    "request_date": "2015-02-20",
;    "request_identifier": "WAPIAAAAUumRndwM"
;  }
;}

BITS 64
[list -]
      %include "unistd.inc"
      %include "sys/socket.inc"
[list +]

section .bss
 
     sockfd:             resq    1
     sock_addr:          resq    1
                                                                 ; most replies from http://vatid.eu aren't more than 200 bytes
     memorymap:          resq    1
     bytesreceived:      resq    1
     buffer:             resb    100
     .length:            equ     $-buffer

     pfds:                                             ; pipe file descriptors
     .stdin:                  resd    1
     .stdout:                 resd    1

section .data
    
     ipaddress:          db   46,183,139,140                     ; ip address vatid.eu
     
     request:            db 'GET /check/'
     .countrycode:       db 'BE'
                         db '/'
     .vatnumber:         db '0823633037'
                         db '/'
                         db 'BE'
                         db '/'
                         db '0823633037'
                         db ' HTTP/1.1', 10
                         db 'Host: localhost', 10
                         db 'Accept: application/json', 10
                         db 'Accept-Language: en-US,en;q=0.5', 10
                         db 'Connection: close', 10
                         db 10
                        
     request.length:     equ $-request
     socketerror:        db "socket error", 10
     .length:            equ $-socketerror
     connecterror:       db "connection error", 10
     .length:            equ $-connecterror
     pipeerror:          db  "pipe error", 10
     .length:            equ  $-pipeerror

     crlf:               db 10
 
section .text
    global _start

_start:
    
    ; create pipe, pdfs is an array to the READ and WRITE ends of the pipe
    mov         rdi, pfds                                       ; create pipe
    mov         rax, SYS_PIPE
    syscall
    js          .pipeerror

    ; prepare messages to be displayed with one syscall
; create a socket
        mov     rax, SYS_SOCKET          ; call socket(SOCK_STREAM, AF_NET, 0);
        mov     rdi, PF_INET             ; PF_INET = 2
        mov     rsi, SOCK_STREAM         ; SOCK_STREAM = 1
        xor     rdx, rdx                 ; IPPROTO_IP = 0
        syscall
        and     rax, rax
        jl      .socketerror
        mov     QWORD[sockfd], rax       ; save descriptor
 
; fill in sock_addr structure (on stack)
        xor     r8, r8                       ; clear the value of r8
        mov     r8d, [ipaddress]             ; http://vatid.eu/ 
        push    r8                           ; push r8 to the stack
        push    WORD 0x5000                  ; port 80 push our port number on the stack
        push    WORD AF_INET                 ; push protocol argument to the stack (AF_INET = 2)
        mov     QWORD[sock_addr], rsp        ; Save the sock_addr_in

; connect to the remote host
        mov     rax, SYS_CONNECT             ; 
        mov     rdi, QWORD[sockfd]           ; socket descriptor
        mov     rsi, QWORD[sock_addr]        ; sock_addr structure
        mov     rdx, 16                      ; length of sock_addr structure
        syscall
        and     rax, rax
        jl      .connecterror
       
; send the message to the server
        mov     rax, SYS_SENDTO
        mov     rdi, QWORD[sockfd]
        mov     rsi, request
        mov     rdx, request.length
        mov     rcx, 0                          ; flags
        mov     r8, 0                           ; pointer to destination address structure
        mov     r9, 0                           ; length of destination address structure
        syscall

; receive a message from the server
        xor     r12, r12                          ; total bytes received
.receive:
        mov     rax, SYS_RECVFROM
        mov     rdi, QWORD[sockfd]
        mov     rsi, buffer
        mov     rdx, buffer.length              ; buffer length
        mov     rcx, 0                          ; flags
        mov     r8, 0                           ; pointer to source address structure
        mov     r9, 0                           ; length of source address structure
        syscall
        and     rax, rax
        jz      .endreceive
        add    r12, rax
        

; write contents of the buffer to stdout, rax has the bytes read
        mov     rdx, rax                        ; bytes read in rdx
        mov     rax, SYS_WRITE
        mov     edi, DWORD[pfds.stdout]
        mov     rsi, buffer
        syscall
        jmp     .receive
        
.endreceive:        
        mov     qword[bytesreceived], r12
; close connection
        mov     rax, SYS_CLOSE
        mov     rdi, QWORD[sockfd]
        syscall
    
    ; create a buffer
    mov      rdi, 0                             ; kernel decides start address
    mov      rax, SYS_BRK
    syscall
    mov      qword[memorymap], rax
    
    mov      rdi, rax
    add      rdi, qword[bytesreceived]                           ; size of buffer = bytes read
    mov      rax, SYS_BRK
    syscall
         
    mov         r12, qword[bytesreceived]
    mov         r8, qword[memorymap]
    
.getnextbytes:    
    ; read from pipe
    mov         edi, DWORD[pfds.stdin]
    mov         rsi, buffer
    mov         rdx, buffer.length
    mov         rax, SYS_READ
    syscall
    sub         r12, rax
    
    mov         rcx, rax                                    ; read bytes in rcx
    mov         rdi, r8                                     ; destination
    add         r8, rax
    cld                                                     ; rsi has source
    rep         movsb

    and         r12, r12
    jnz         .getnextbytes
    
    ; write memorymap to STDOUT
    mov         rsi, qword[memorymap]
    mov         rdx, qword[bytesreceived]
    mov         edi, STDOUT
    mov         rax, SYS_WRITE
    syscall
    
; extract the data
; 
    
.endread:    
    ; unmap memory
    mov       rdi, qword[memorymap]
     mov       rax, SYS_BRK
     syscall
     
    jmp         .exit
      
; the errors

.connecterror:
        mov     rsi, connecterror
        mov     rdx, connecterror.length
        jmp     .print
 
.socketerror:
        mov     rsi, socketerror
        mov     rdx, socketerror.length
        jmp     .print
.pipeerror:
        mov     rsi, pipeerror
        mov     rdx, pipeerror.length

.print:
        mov     rdi, STDOUT
        mov     rax, SYS_WRITE
        syscall

.exit:        
        ; exit program        

        xor     rdi, rdi
        mov     rax, SYS_EXIT
        syscall