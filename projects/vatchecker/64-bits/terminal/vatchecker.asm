; Name:        vatchecker.asm
; Build:       see makefile
; Description: VAT checker with requests to vatid.eu
;
; valid country codes are:
;
;   AT Austria,  BE Belgium, BG Bulgaria, CY Cyprus,   CZ Czech Republic, DK Denmark,   EE Estonia,       FI Finland, FR France,      DE Germany
;   EL Greece,   HU Hungary, IE Ireland,  IT Italy,    LV Latvia,         LT Lithuania, LU Luxembourg,    MT Malta,   NL Netherlands, PL Poland
;   PT Portugal, RO Romania, SK Slovakia, SI Slovenia, ES Spain,          SE Sweden,    GB United Kingdom
;
; remark: 
; For vatnumbers from Austria you need to add U after the countrycode yourself. ATU12345678
; A more complete list for valid vatnumber lengths can be found at http://en.wikipedia.org/wiki/VAT_identification_number
;
; read:  http://vatid.eu/ for more information on the vat checking service

bits 64

[list -]
     %include "../includes/unistd.inc"
     %include "../includes/sys/socket.inc"
     %define DOUBLE_QUOTE     '"'
     %define VERSION          "0.0.0"
[list +]

section .bss

     sockfd:             resq      1
     sock_addr:          resq      1
     bytesreceived:      resq      1
     heapstart:          resq      1                        ; start of heap
     nextblock:          resq      1
     endheap:            resq      1
     requestlength:      resq      1                        ; real length of request

section .data

     ipaddress:          db        46,183,139,140                     ; ip address vatid.eu
     port:               db        00,80                              ; big endian notation, low value in lower address

     socketerror:        db        "socket error", 10
     .length:            equ       $-socketerror
     connecterror:       db        "connection error", 10
     .length:            equ       $-connecterror
     heaperror:          db        "out of memory error", 10
     .length:            equ       $-heaperror
     senderror:          db        "send error", 10
     .length:            equ       $-senderror
     unexpectederror:    db        "unexpected error after scasb", 10
     .length:            equ       $-unexpectederror
     crlf:               db        10
     replywrong:         db        "The received reply could not be read.",10
     .length:            equ       $-replywrong
     invalidVat:         db        "invalid vatnumber.", 10
     .length:            equ       $-invalidVat
     VersionMessage:     db        "VATCHECKER version ",VERSION," assembled with Nasm version ", __NASM_VER__ ,10                        
     .length:            equ       $-VersionMessage
     UsageMessage:       db        "This software is free under the GPL  http://www.gnu.org/copyleft/gpl.html", 10
                         db        "You should have received the source code, if not send me an email at admin@agguro.be with subject=sourcecode vatchecker", 10, 10
                         db        "usage: vatchecker [vatnumber]", 10
                         db        "       vatchecker [option]", 10, 10
                         db        "       -h     show help", 10
                         db        "       -v     show version", 10, 10
                         db        "response: vatnumber, companyname, companyaddress, postal code and city, data of request, requestid", 10, 10
                         db        "A valid vatnumber start with a two letter countrycode and a vatnumber for the selected country.", 10
                         db        "    Supported countries are:", 10
                         db        "    AT Austria          ES Spain             LV Latvia", 10
                         db        "    BE Belgium          FI Finland           MT Malta", 10
                         db        "    BG Bulgaria         FR France            NL Netherlands", 10
                         db        "    CY Cyprus           GB United Kingdom    PL Poland", 10
                         db        "    CZ Czech Republic   HU Hungary           PT Portugal", 10
                         db        "    DE Germany          IE Ireland           RO Romania", 10
                         db        "    DK Denmark          IT Italy             SE Sweden", 10
                         db        "    EE Estonia          LT Lithuania         SI Slovenia", 10
                         db        "    EL Greece           LU Luxembourg        SK Slovakia", 10, 10
                         db        "When a connection to http://vatid.eu can be made the following error responses are possible:", 10
                         db        "    VIES unavailable.", 10
                         db        "    Memberstate unavailable.", 10
                         db        "    Cannot process this request. Please check your input parameters.", 10
                         db        "First to errormessages occur when the VIES server or a memberstate server is not available for some reason, try again later.", 10
     .length:            equ       $-UsageMessage
     RequestMessage:
     .part1:             db        "GET /check/"
     .part1length:       equ       $-RequestMessage.part1
     .slash:             db        "/"
     .part2:             db        " HTTP/1.1", 10
                         db        "Host: localhost", 10
                         db        "Accept: application/json", 10
                         db        "Connection: close", 10, 10
     .part2length:       equ       $-RequestMessage.part2
     .length:            equ       $-RequestMessage

section .text
     global _start
_start:

     pop       rax                                ; get number of arguments
     dec       rax                                ; minus one for programname gives number of arguments
     xor       rax, 1                             ; if only one argument then this will result in zero
     jnz       ShowUsage                          ; more than one argument
     pop       rbx                                ; get programname
     pop       rsi                                ; get first and only argument
     push      rsi                                ; restore stack to previous state
     push      rbx
     push      rax

     cld
     lodsb
     cmp       al, '-'                            ; load first byte of argument
     jne       startCheck                         ; if not '-' then assume vatnumber
     lodsb                                        ; it is an option
     cmp       al, 'v'                            ; if v then we show the version
     je        ShowVersion                        ; show version information
     jmp       ShowUsage                          ; in all other cases show usage

startCheck:
     ; get string length of vatnumber
     ; RSI points to the VAT number
     dec       rsi                                ; adjust RSI
     mov       r9, rsi                            ; save offset to vatnumber in R9
     mov       rdi, rsi
     mov       rcx, -1
     xor       al, al                             ; search for end of string
     repne     scasb                              ; scan for 0 byte
     jnz       Error.unexpected                   ; in case something goes wrong searching the zero byte, we end with a message
                                                  ; in case someone wants to feed a very large file to it
     neg       rcx                                ; end of string found, calculate the length
     dec       rcx                                ; minus one passed the zero byte
     dec       rcx                                ; minus one for the zero byte
     mov       r8, rcx                            ; save length in R8
     ; rcx has the length of the vatnumber, create a heap to buffer the request
     syscall   brk, 0                             ; [MACRO] get start of heap memory
     
     and       rax, rax                           ; check if an error occured
     js        Error.heap                         ; if yes, we are out of memory
     ; calculate length of the required buffer size for the request,
     ; we will push the request in one single action instead of sending peaces
     mov       r10, r8                            ; save length vatnumber in R10
     shl       r10, 1                             ; we need to store vatnumber twice
     add       r10, RequestMessage.length
     inc       r10                                ; plus two slashes
     inc       r10
     mov       qword[requestlength], r10          ; save request length
     mov       qword[heapstart], rax              ; save start of heap
     add       rax, r10                           ; add request length
     
     syscall   brk, rax                           ; [MACRO] reserve memory on heap
     
     and       rax, rax                           ; check again for errors
     js        Error.heapagain                    ; if yes we are out of error

     ; we have the memory we need, build the request string in this memory
     ; first copy the first part of the request to the heap
     mov       rdi, qword[heapstart]
     mov       rsi, RequestMessage.part1
     mov       rcx, RequestMessage.part1length
     rep       movsb                              ; copy RCX bytes from RSI to RDI(heap memory)
     ; now copy /countrycode/vatnumber twice right behind the first part of the request
     mov       r10, rdi                           ; save start of countrycode, we need it again
     mov       rcx, 2                             ; copy next two bytes from VAT number R9
     mov       rsi, r9                            ; set pointer to VAT number in RSI
     rep       movsb                              ; save countrycode in heap
     mov       rsi, RequestMessage.slash          ; point RSI to '/'
     movsb                                        ; copy in heap
     inc       r9
     inc       r9                                 ; adjust offset in vatnumber to the number
     mov       rsi, r9                            ; point RSI to this number
     mov       rcx, r8                            ; length of vatnumber in RCX -> bytes to copy
     dec       rcx                                ; adjust RCX
     dec       rcx                                ; minus two for countrycode
     rep       movsb                              ; save vatnumber
     mov       rsi, RequestMessage.slash          ; point RSI to '/'
     movsb                                        ; add again a '/' to the request
     mov       rsi, r10                           ; start of countrycode in heap in RSI
     mov       rcx, r8                            ; length of vatnumber in RCX
     inc       rcx                                ; plus one for the slash
     rep       movsb                              ; make copy of already stored vatnumber in heap
     ; copy the last part of the request in the heap
     mov       rsi, RequestMessage.part2
     mov       rcx, RequestMessage.part2length
     rep       movsb                              ; copy RCX bytes from RSI to RDI(heap memory)
     
     ; the requeststring is made. The request can be made however we do not know how long the reply will be
     ; so we have to re-allocate the heap to store the reply.
     ; will be available in STDIN.

     ; first create a socket
     syscall   socket,PF_INET, SOCK_STREAM, 0     ; [MACRO] create a socket
     
     and       rax, rax                           ; on error
     js        Error.socket                       ; free allocated memory, display error and exit
     mov       qword[sockfd], rax                 ; save socket descriptor
     ; fill in sock_addr structure (on stack)
     xor       r8, r8                             ; clear the value of R8, ipaddress is 4 bytes
     mov       r8d, DWORD[ipaddress]              ; http://vatid.eu/ ipaddress
     push      r8                                 ; push r8 to the stack

     xor       r8, r8                             ; clear R8, value of port is 2 bytes
     mov       r8w, WORD[port]
     push      r8w                                ; push PORT on stack
     push      WORD AF_INET                       ; push protocol argument to the stack (AF_INET = 2)
     mov       QWORD[sock_addr], rsp              ; Save pointer to the sock_addr_in structure

     ; connect to the remote host      
     syscall   connect, QWORD[sockfd], QWORD[sock_addr], 16      ; [MACRO] connect to remote host
     and       rax, rax                                          ; on error
     js        Error.connect                                     ; free allocated memory, display error and exit

     ; send the message to the server
     syscall   sendto, QWORD[sockfd], QWORD[heapstart], QWORD[requestlength], 0, 0, 0
     and       rax, rax                           ; on error               
     js        Error.send                         ; free allocated memory, display error and exit

     ; prepare the heap to receive the chunks of data we will get from the reply
     mov       rax, QWORD[heapstart]
     mov       QWORD[nextblock], rax              ; save start of heap as the begin of a new block
     
     syscall   brk, QWORD[heapstart]              ; [MACRO] clear allocated memory
     and       rax, rax
     js        Error.heapagain
     add       rax, 256                           ; add 256 bytes
     syscall   brk, rax                           ; [MACRO] allocate them
     and       rax, rax                           ; on error
     js        Error.heapagain                    ; free allocated memory, display error and exit
     
     mov       QWORD[endheap], rax                ; save end of heap
     xor       r12, r12                           ; clear bytesreceived
     
     ; reveive the chunks of data
.receive:
     syscall   recvfrom, QWORD[sockfd], QWORD[nextblock], 256, 0, 0, 0
     and       rax, rax                           ; if RAX is zero, we did not receive data from the reply
     jz        .endreceive                        ; so we are done receiving
     
     add       r12, rax                           ; add to bytes received
     mov       rax, QWORD[endheap]
     mov       QWORD[nextblock], rax              ; move end of heap to start of next block ofd memory
     add       rax, 256                           ; add 256 bytes to to allocate memory
     syscall   brk, rax                           ; reserve extra memory
     and       rax, rax                           ; on error
     js        Error.heapagain                    ; free allocated memory, display error and exit
     mov       QWORD[endheap], rax                ; store new end of the heap
     jmp       .receive                           ; receive next chunk of data from the reply

     ; done receiving the reply, save the real length of the reply stored in R12 in bytesreceived
.endreceive:
     mov       QWORD[bytesreceived], r12
     ; close connection
     syscall   close, QWORD[sockfd]

     ; parse the reply
     ; look for first occurence of { in the reply
     ; if parsing fails, then we jump to replywrong, in this case the remote server use a different layout for
     ; the reply and we need to rewrite this application. (from here)
     mov       rdi, QWORD[heapstart]              ; point RDI to start of heap = start of reply
     mov       rcx, QWORD[bytesreceived]          ; only search in the received bytes
     mov       al, '{'                            ; seearch for {
     repne     scasb                              ; compare RCX bytes    
     jne         Error.replyWrong                 ; not found something went wrong, review application??
     ; we have found the {, now move to the first letter after the double quote
     add       rdi, 4                             ; adjust pointer
     sub       rcx, 4                             ; adjust remaining bytes in reply
     ; read next 8 bytes from the reply
     mov       eax, DWORD[rdi]                    ; search for 'resp' or 'erro'
     cmp       eax, 'resp'
     je        .gotResponse
     cmp       eax, 'erro'
     jne       Error.replyWrong                   ; not found something went wrong, review application??
     ; the received reply indicates an error
     mov       al, ':'                            ; third ':' has the error text
     repne     scasb
     jne       Error.replyWrong                   ; not found something went wrong, review application??
     repne     scasb
     jne       Error.replyWrong                   ; not found something went wrong, review application??
     repne     scasb
     jne       Error.replyWrong                   ; not found something went wrong, review application??
     inc       rdi                                ; move two byte further to get the error message
     inc       rdi
     mov       rsi, rdi                           ; save offset of error message in RSI
     mov       al, DOUBLE_QUOTE                   ; scan for end of string
     repne     scasb
     jne       Error.replyWrong                   ; not found something went wrong, review application??
     mov       byte[rdi-1], 0x0A                  ; put end of line in place of the double quote
     mov       rdx, rdi                           ; RDI has pointer to end of string, put in RDX
     sub       rdx, rsi                           ; minus start of the string gives the length in RDX
     call      Print                              ; print the message
     call      DeallocateMemory                   ; free the heap
     jmp       Exit                               ; and exit
     
     ; we can go further examining the vatnumber
.gotResponse:
     mov       r8, rdi                            ; save start of response
     mov       r9, rcx                            ; save remaining length of response
     mov       al, ':'                            ; fourth : has the validity of the number
     repne     scasb
     jne       Error.replyWrong                   ; not found something went wrong, review application??
     repne     scasb
     jne       Error.replyWrong                   ; not found something went wrong, review application??
     repne     scasb
     jne       Error.replyWrong                   ; not found something went wrong, review application??
     repne     scasb
     jne       Error.replyWrong                   ; not found something went wrong, review application??
     cmp       byte[rdi+2], 't'
     jne       Error.invalidVat

     ; for debugging
     ;  syscall write, stdout, qword[heapstart],qword[bytesreceived]

     ; we got a valid vatnumber
     ; we show all field values except the valid field
     mov       rdi, r8
     mov       rcx, r9
     ; look for second : in reply, two bytes further we got the company name
     mov       al, ':'
     repne     scasb
     jne       Error.replyWrong                   ; not found something went wrong, review application??
     repne     scasb                              ; countrycode
     jne       Error.replyWrong                   ; not found something went wrong, review application??
     inc       rdi
     inc       rdi                                ; point to the double quote
     dec       rcx
     dec       rcx                                ; adjust remaining length
     mov       rsi, rdi                           ; save offset
     mov       al,DOUBLE_QUOTE                    ; search for end of string
     repne     scasb                              ; we got end of string
     jne       Error.replyWrong                   ; not found something went wrong, review application??
     dec       rdi
     inc       rcx
     mov       rdx, rdi
     sub       rdx, rsi                           ; calculate length
     call      Print

     mov       al, ':'
     repne     scasb                              ; vat number
     jne       Error.replyWrong                   ; not found something went wrong, review application??
     inc       rdi
     inc       rdi                                ; point to double quote
     dec       rcx
     dec       rcx                                ; adjust remaining length
     mov       rsi, rdi                           ; save offset
     mov       al,DOUBLE_QUOTE                    ; search for end of string
     repne     scasb                              ; we got end of string
     jne         Error.replyWrong                 ; not found something went wrong, review application??
     mov       byte[rdi-1], ','                   ; put comma at end of string
     mov       rdx, rdi                           
     sub       rdx, rsi                           ; calculate length
     call      Print

     mov       al,':'
     repne     scasb                              ; valid --> will not be shown
     jne       Error.replyWrong                   ; not found something went wrong, review application??

     repne     scasb                              ; companyname
     jne       Error.replyWrong                   ; not found something went wrong, review application??
     inc       rdi
     inc       rdi                                ; point to double quote
     dec       rcx
     dec       rcx                                ; adjust remaining length
     mov       rsi, rdi                           ; save offset
     mov       al,DOUBLE_QUOTE
     repne     scasb                              ; we got end of string
     jne       Error.replyWrong                   ; not found something went wrong, review application??
     mov       byte[rdi-1], ','
     mov       rdx, rdi
     sub       rdx, rsi                           ; calculate length
     call      Print

     ; an issue in the company address is that street and city is separated by \n
     ; another issue is that between postalcode and city are two spaces.
     ; we fix this here
     ; get the entire address
     mov       al,':'
     repne     scasb                              ; address
     jne       Error.replyWrong                   ; not found something went wrong, review application??
     inc       rdi
     inc       rdi                                ; point to double quote
     dec       rcx
     dec       rcx                                ; adjust remaining length
     mov       rsi, rdi                           ; save offset
     ; fix \n in the address
     mov       al,'\'                             ; look for \n
     repne     scasb
     jne       Error.replyWrong                   ; not found something went wrong, review application??
     mov       byte[rdi-1], ','                   ; replace with ,
     mov       rdx, rdi
     sub       rdx, rsi
     call      Print

     inc       rdi                                ; skip byte n in \n
     dec       rcx
     mov       rsi, rdi                           ; save offset

     ; now scan for spaces
     mov       al,' '
     repne     scasb
     jne       Error.replyWrong                   ; not found something went wrong, review application??
     mov       rdx, rdi
     sub       rdx, rsi
     call      Print

     ; check spaces after previous one

     mov       al, ' '
     rep       scasb
     je        Error.replyWrong                   ; not found something went wrong, review application??
     dec       rdi                                ; once found we adjust the pointer
     inc       rcx                                ; and adjust length

     mov       rsi, rdi
     mov       al,DOUBLE_QUOTE
     repne     scasb                              ; we got end of string
     jne         Error.replyWrong                 ; not found something went wrong, review application??
     mov       byte[rdi-1], ','
     mov       rdx, rdi
     sub       rdx, rsi                           ; calculate length
     call      Print

     mov       al,':'
     repne     scasb                              ; request date
     jne         Error.replyWrong                 ; not found something went wrong, review application??
     inc       rdi
     inc       rdi                                ; point to double quote
     dec       rcx
     dec       rcx                                ; adjust remaining length
     mov       rsi, rdi                           ; save offset

     mov       al,DOUBLE_QUOTE
     repne     scasb                              ; we got end of string
     jne         Error.replyWrong                 ; not found something went wrong, review application??
     mov       byte[rdi-1], ','
     mov       rdx, rdi
     sub       rdx, rsi                           ; calculate length
     call      Print

     mov       al,':'
     repne     scasb                              ; request identiefier
     jne       Error.replyWrong                   ; not found something went wrong, review application??
     inc       rdi
     inc       rdi                                ; point to double quote
     dec       rcx
     dec       rcx                                ; adjust remaining length
     mov       rsi, rdi                           ; save offset
     mov       al,DOUBLE_QUOTE
     repne     scasb                              ; we got end of string
     jne         Error.replyWrong                 ; not found something went wrong, review application??
     mov       byte[rdi-1], 0x0A
     mov       rdx, rdi
     sub       rdx, rsi                           ; calculate length
     call      Print
  
; unmap memory
;FreeHeap:
     call      DeallocateMemory
Exit:        
     syscall   exit, 0

; the errors
Error:
.connect:
     call      DeallocateMemory
     mov       rsi, connecterror
     mov       rdx, connecterror.length
     call      Print
     jmp       Exit

.socket:
     call      DeallocateMemory
     mov       rsi, socketerror
     mov       rdx, socketerror.length
     call      Print
     jmp       Exit

.heapagain:
; we have an error after we received the heapstart
; to be sure we free all allocated memory
     call      DeallocateMemory
     ; don't check for errors this time, we are already exiting the program
.heap:
     ; display what happened
     mov       rsi, heaperror
     mov       rdx, heaperror.length
     call      Print
     jmp       Exit

.send:
     mov       rsi, senderror
     mov       rdx, senderror.length
     call      Print
     jmp       Exit

.replyWrong:
     mov       rsi, replywrong
     mov       rdx, replywrong.length
     call       Print
     mov       rsi, qword[heapstart]
     mov       rdx, qword[bytesreceived]
     call      Print
     call      DeallocateMemory
     jmp       Exit

.invalidVat:
     call      DeallocateMemory
     mov       rsi, invalidVat
     mov       rdx, invalidVat.length
     call      Print
     jmp       Exit

.unexpected:
     mov       rsi, unexpectederror
     mov       rdx, unexpectederror.length
     call      Print
     jmp       Exit

DeallocateMemory:
     mov       rax, qword[heapstart]
     syscall   brk, rax
     ret

ShowUsage:
     mov       rsi, UsageMessage
     mov       rdx, UsageMessage.length
     call      Print
     jmp       Exit

ShowVersion:
     mov       rsi, VersionMessage
     mov       rdx, VersionMessage.length
     call      Print
     jmp       Exit

Print:
     push      rax
     push      rcx
     push      r11
     push      rsi
     push      rdi
     push      rdx
     syscall write, stdout, rsi, rdx
     pop       rdx
     pop       rdi
     pop       rsi
     pop       r11
     pop       rcx
     pop       rax
     ret 