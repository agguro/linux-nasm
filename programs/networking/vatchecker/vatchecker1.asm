; vatchecker.asm
;
; VAT checker with requests to vatid.eu
;
; valid country codes:

;   AT Austria,   BE Belgium,    BG Bulgaria    CY Cyprus,   CZ Czech Republic,    DK Denmark,    EE Estonia,    FI Finland,    FR France,    DE Germany
;   EL Greece,    HU Hungary,    IE Ireland,    IT Italy,    LV Latvia,            LT Lithuania,  LU Luxembourg,    MT Malta,    NL Netherlands,    PL Poland
;   PT Portugal,  RO Romania,    SK Slovakia,    SI Slovenia,    ES Spain,    SE Sweden,    GB United Kingdom
;
; replies:
; if error:
;
; {  "error": { "code": "vies-unavailable", "text": "VIES Webservice currently unavailable."}}
;                       "member-state-unavailable"
;                       "invalid-input"
;
; if response/ not all fields will be available depending the VAT server from the specified country replies with address and name.
;
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
;

BITS 64
[list -]
      %include "unistd.inc"
      %include "sys/socket.inc"
[list +]

section .bss

    
      
     sockfd:             resq    1
     sock_addr:          resq    1
                                   
     memorymap:          resq    1
     bytesreceived:      resq    1
     buffer:             resb    100
     .length:            equ     $-buffer
    
    oldbrkaddr:         resq    1
    charbuffer:         resb    1
    content:        resq 1
    
     pfds:                                             ; pipe file descriptors
     .stdin:                  resd    1
     .stdout:                 resd    1

section .data
    requestmethod:      db      "REQUEST_METHOD=POST"
      .length:          equ     $-requestmethod
    contentlength:      db      "CONTENT_LENGTH="
      .length:          equ     $-contentlength
      
     ipaddress:          db   46,183,139,140                     ; ip address vatid.eu
     
     request:            db 'GET /check/'
     .countrycode:      ; db 'BE'
                         db '/'
     .vatnumber:         ;db '0823633037'
                         db '/'
                         ;db 'BE'
                         db '/'
                         ;db '0823633037'
                         db ' HTTP/1.1', 10
                         db 'Host: localhost', 10
                         db 'Accept: application/json', 10
                         db 'Accept-Language: en-US,en;q=0.5', 10
                         db 'Connection: close', 10, 10
                        
     request.length:     equ $-request
     socketerror:        db "socket error", 10
     .length:            equ $-socketerror
     connecterror:       db "connection error", 10
     .length:            equ $-connecterror
     pipeerror:          db  "pipe error", 10
     .length:            equ  $-pipeerror

     crlf:               db 10
     reply:              db 'Content-type: text/html', 0x0A, 0x0A
     .length:            equ $-reply
     
 
section .text
    global _start

_start:

; first check if the form was posted
    ; adjust stack to environment parameters
    pop         rax
    pop         rax
    pop         rax
    ; we are at the (list-1) of environment (web) variables
    mov         rbp, rsp                 ; save begin of list in r8
    
    ; let's loop through the webserver variables, searching for REQUEST_METHOD=POST
    cld
.getrequestmethod:
    pop         rsi
    or          rsi, rsi                ; done yet?
    jz          .exit                   ; we didn't find the REQUEST_METHOD=POST string   
    ; RDI contains a pointer to CONTENT_LENGTH=POST the variable we are searching for
    ; look for the required variable name amongst them
    mov         rcx, requestmethod.length
    mov         rdi, requestmethod
    rep         cmpsb                   ; compare RCX bytes
    jne         .getrequestmethod       ; no match get the next variable, if any
    
    ; we got a match, now read the CONTENT_LENGTH
    ; restore top of (list-1)
    mov         rsp, rbp
    cld                                 ; just in case
.getcontentlength:
    pop         rsi
    or          rsi, rsi                ; done yet
    jz          .exit                   ; this shouldn't occur
    ; RDI contains a pointer to CONTENT_LENGTH= the variable we are searching for
    mov         rcx, contentlength.length
    mov         rdi, contentlength
    rep         cmpsb                   ; compare RCX bytes
    jne         .getcontentlength       ; no match get the next variable, if any
    
    ; we got the CONTENT_LENGTH=, RSI points to the first character of the ASCII digit of the length
    ; initialise rcx
    xor         rcx, rcx
.nextparamstringchar:
    xor         rax, rax
    lodsb                               ; get digit
    and         al, al                   ; if 0 then no digits
    je          .endofparamstring
    
    xor         rdx, rdx
    mov         rbx, 10
    imul        rcx, rbx
    and         al, 0x0F
    add         rcx, rax                ; previous digit x 10 + current digit    
    jmp         .nextparamstringchar
.endofparamstring:   
    ; RCX contains the content_length in hexadecimal
    ; reserve space on, the heap to store the parameters from STDIN
        
    ; reserve memory for the parameters
    add         rax, QWORD[content]            ; add contentlength to the program break
    add         rax, 3                         ; add 3 more for "///"
    mov         rdi, rax
    mov         rax, SYS_BRK
    syscall
    cmp         rax, 0
    je          .exit                          ; if RAX = 0 then no memory is available, now we exit

    ; read the params in our created buffer
    mov         rsi, QWORD[oldbrkaddr]
    mov         rdx, QWORD[content]
    mov         rdi, STDOUT
    mov         rax, SYS_WRITE
    syscall
    
    ; write to stdout to check
    

    
        
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
        
; send the reply
    mov         rsi, reply
    mov         rdx, reply.length
    mov         edi, STDOUT
    mov         rax, SYS_WRITE
    syscall

   ;int 3

    ; write memorymap to STDOUT
    mov         rsi, qword[memorymap]
    mov         rdx, qword[bytesreceived]
    add         rsi, 183
    sub         rdx, 183
    mov         edi, STDOUT
    mov         rax, SYS_WRITE
    syscall
 
    
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