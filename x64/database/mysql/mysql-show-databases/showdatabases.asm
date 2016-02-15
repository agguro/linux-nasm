; Name:          showdatabases
; Build:         see makefile
;                make , make nocgi     : build a non-cgi version of the program. (terminals)
;                make cgi              : build cgi version of the progam (webservers)
;                There is no install file, you need to copy the linked file to your cgi-bin directory.
; Run:           ./showdatabases
; Description:   Program to view all databases from mysql server according to the user who has access to it

; you need to execute sudo apt-get install libmysqlclient-dev libmysqlclient18 to install the mysql client libary

BITS 64

[list -]
    ; do not include the entire mysqlclient.inc file if you like your code to be small
    extern     mysql_close
    extern     mysql_errno
    extern     mysql_error
    extern     mysql_fetch_row
    extern     mysql_free_result
    extern     mysql_init
    extern     mysql_query
    extern     mysql_real_connect
    extern     mysql_server_end
    extern     mysql_server_init
    extern     mysql_use_result    
    %include   "unistd.inc"
    %include   "sys/stat.inc"
[list +]

section .bss
    conn:               resq  1
    result:             resq  1
    row:                resq  1
    heapstart:          resq  1
    fd:                 resq  1
    host:               resq  1
    port:               resq  1
    user:               resq  1
    password:           resq  1
    database:           resq  1
    socket:             resq  1
    clientflag:         resq  1

section .data

string:
    .filenotfound:              db      "../configuration file not found", 10
    .filenotfound.length:       equ     $-.filenotfound
    .fileread:                  db      "error reading config file", 10
    .fileread.length:           equ     $-.fileread
    .filestatus:                db      "error reading file status", 10
    .filestatus.length:         equ     $-.filestatus
    .fileclose:                 db      "error closing file", 10
    .fileclose.length:          equ     $-.fileclose
    
    .notenoughmemory:           db      "not enough memory", 10
    .notenoughmemory.length:    equ     $-.notenoughmemory
    .deallocmemory:             db      "error deallocating memory", 10
    .deallocmemory.length:      equ     $-.deallocmemory
    
    .mysqlserverinit:           db      "MySQL library could not be initialized",10
    .mysqlserverinit.length:    equ     $-.mysqlserverinit
    .mysqlobjinit:              db      "MySQL init object failed", 10
    .mysqlobjinit.length:       equ     $-.mysqlobjinit
    .mysqlresult:               db      "MySQL result error", 10
    .mysqlresult.length:        equ     $-.mysqlresult
    .mysqlfetchrow:             db      "MySQL fetch row error", 10
    .mysqlfetchrow.length:      equ     $-.mysqlfetchrow

; assemble with make cgi, if you want to make a cgi application of this program
%ifdef CGI
    reply:                      db      "Content-type: text/html",10,10
                                db      "<html><head></head><body><pre>"
                                db      "<h4>Databases on server:</h4>"
    .length:                    equ     $-reply
    .end:                       db      "</pre></body></html>"
    reply.end.length:           equ     $-reply.end
    starttag:                   db      '<a href="#">'
    .length:                    equ     $-starttag
    endtag:                     db      "</a>"
                                db      "<br />"
    .length:                    equ     $-endtag
%endif

mysqlerror:
    query:                      db      "show databases",0
    configfilename:             db      "mysql.cfg",0
    hoststring:                 db      "DBHOST="
    .length:                    equ     $-hoststring
    userstring:                 db      "DBUSER="
    .length:                    equ     $-userstring
    passwordstring:             db      "DBPASSWORD="
    .length:                    equ     $-passwordstring
    portstring:                 db      "DBPORT="
    .length:                    equ     $-portstring
    
    ; file status structure
    STAT stat
    
section .text
      global _start

_start:

%ifdef CGI
     mov       rsi, reply
     mov       rdx, reply.length
     call      String.ToStdOut
%endif

ConfigFile:
     ; open configuration file
     syscall   open, configfilename, O_RDONLY
     and       rax, rax
     js        Error.filenotfound
     mov       QWORD[fd], rax                          ; save filedescriptor
     syscall   fstat, rax, stat
     and       rax, rax
     js        Error.filestatus
; reserve memory for file contents
     syscall   brk, 0
     and       rax, rax
     js        Error.notenoughmemory
     mov       QWORD[heapstart], rax                   ; save pointer to memory break
     add       rax, QWORD[stat.st_size]                ; add filesize to allocate memory
     inc       rax                                     ; one extra byte, to be sure the string ends with 00
      
     ; try to allocate additional memory
     syscall   brk, rax
     sub       rax, rdi                                ; new memory break equal to calculated one?
     and       rax, rax
     jnz       Error.notenoughmemory
     
     ; read the file in the allocated memory
     syscall   read, QWORD[fd], QWORD[heapstart], QWORD[stat.st_size]                ; bytes to read
     
     and       rax, rax
     js        Error.fileread
     
     ; close file
     syscall   close, QWORD[fd]
     and       rax, rax
     js        Error.fileclose
     
; loop through our string, replacing each 0x0A and 0x0D with 00
     mov       rsi, QWORD[heapstart]
     mov       rdi, QWORD[stat.st_size]
     call      String.ZeroCRLF

; get the values for host, user, password, port, database, socket and clientflag, if socket and clientflag are
; empty strings then the values for these are NULL instead of the pointer to the socket and clientflag string.
; Port need to be stored as an unsigned integer.
     ; get pointer to HOST
     mov       rdi, hoststring.length
     mov       rsi, hoststring
     call      String.Search
     jc        Error.fileread
     mov       QWORD[host], rax
     ; get pointer to USER
     mov       rdi, userstring.length
     mov       rsi, userstring
     call      String.Search
     jc        Error.fileread
     mov       QWORD[user], rax
     ; get pointer to PASSWORD
     mov       rdi, passwordstring.length
     mov       rsi, passwordstring
     call      String.Search
     jc        Error.fileread
     mov       QWORD[password], rax
     ; get pointer to PORT      
     mov       rdi, portstring.length
     mov       rsi, portstring
     call      String.Search
     jc        Error.fileread
     ; parse PORT to integer
     mov       rdi, rax
     call      String.ToInt
     mov       QWORD[port], rax
     ; all necessary values are known, now connect to mysql server and get an uuid
     ; not an embedded MySQL so all arguments must be zero
     xor       rdi, rdi
     xor       rsi, rsi
     xor       rdx, rdx
     call      mysql_server_init
     and       rax, rax
     jnz       Error.mysqlserverinit
     ; From this point we need to cleanup the library!!!!
     xor       rdi, rdi
     call      mysql_init
     and       rax, rax
     jz        Error.mysqlobjinit
     ; no errors, connect and login 
     mov       QWORD [conn], rax                 ; save *mysql
     mov       rdi, rax                          ; value of mysql = pointer to mysql instance of connection
     push      0                                 ; the value of clientflags or NULL if none
     push      0                                 ; the value of socket or NULL if none
     mov       r9d, DWORD [port]                 ; the value of the port to connect to               
     xor       r8, r8                            ; pointer to zero terminated database string
     mov       rcx, QWORD [password]             ; pointer to zero terminated password string
     mov       rdx, QWORD [user]                 ; pointer to zero terminated user string
     mov       rsi, QWORD [host]                 ; pointer to zero terminated host string
     call      mysql_real_connect                ; connect
     pop       rdx                               ; restore stackpointer
     pop       rdx
     sub       rax, QWORD [conn]                 ; if conn == pointer to mysql instance then succes
     and       rax, rax      
     jnz       Error.mysqlconnect
     ; We are connected, execute the query

     mov       rsi, query                        ; pointer to zero terminated query string
     mov       rdi, QWORD [conn]                 ; value of mysql = pointer to mysql instance of connection
     call      mysql_query                       ; query the server
     ; check for errors
     mov       rdi, QWORD [conn]                 ; check if an error occured
     call      mysql_errno
     and       rax, rax
     jnz       Error.mysqlerror

     mov       rdi, QWORD[conn]
     call      mysql_use_result                  ; we don't ask all the records at once (less client side memory)
     and       rax, rax
     jz        Error.mysqlresult

     ; get databases from resultset
     mov       QWORD [result], rax
nextRecord:
     mov       rdi, QWORD [result]
     call      mysql_fetch_row
     ; the result is a pointer to a row
     ; first 8 bytes of that result is a pointer to the name of the item in the row
     ; we have to loop this procedure until the row == null
     ; after row == null received always check first for errors
     and       rax, rax
     jz        NoRows                            ; any record left?
     cmp       rax, 2000                         ; unknown error
     je        Error.mysqlerror
     cmp       rax, 2013                         ; connection lost
     je        Error.mysqlerror
     mov       QWORD[row], rax
%ifdef CGI
     ; print here eventually start tags
     mov       rsi, starttag
     mov       rdx, starttag.length
     call      String.ToStdOut
     ; restore row in RAX
     mov       rax, QWORD[row]
%endif      
     ; print the record
     mov       rsi, [rax]
     mov       rdi, rsi
     call      String.Length
     mov       rdx, rax
     add       rax, rsi
%ifndef CGI
     inc       rdx
     mov       BYTE [rax], 0x0A
%endif
     call      String.ToStdOut
      
%ifdef CGI
     ; print here eventually end tags
     mov       rsi, endtag
     mov       rdx, endtag.length
     call      String.ToStdOut
%endif      
      
     ; and go for next record
     jmp       nextRecord

NoRows:      
     mov       rdi, QWORD[conn]
     call      mysql_errno
     and       rax, rax
     jnz       Error.mysqlerror
     ; free result
     mov       rdi, QWORD[result]
     call      mysql_free_result
CloseConnection:
     mov       rdi, QWORD [conn]
     call      mysql_close
ServerEnd:        
     call      mysql_server_end
FreeHeap:
     syscall   brk, QWORD[heapstart]
     and       rax, rax
     js        Error.deallocmemory
      
%ifdef CGI
     mov       rsi, reply.end
     mov       rdx, reply.end.length
     call      String.ToStdOut
%endif

Exit:
     syscall   exit, 0

Error:
.mysqlserverinit:
     mov       rsi, string.mysqlserverinit
     mov       rdx, string.mysqlserverinit.length
     call      String.ToStdErr
     jmp       Exit
.mysqlobjinit:
     mov       rsi, string.mysqlobjinit
     mov       rdx, string.mysqlobjinit.length
     call      String.ToStdErr
     jmp       ServerEnd
.mysqlconnect:
     push      ServerEnd
     jmp       ._error
.mysqlerror:
     push      CloseConnection
._error:     
     mov       rdi, QWORD [conn]
     call      mysql_error
     mov       rsi, rax
     mov       rdi, rax
     call      String.Length
     mov       rdx, rax
     inc       rdx
     add       rax, rsi
     mov       BYTE [rax], 0x0A
     call      String.ToStdErr
     ret                                  ; get jump address from stack and jump
.mysqlresult:
     mov       rsi, string.mysqlresult
     mov       rdx, string.mysqlresult.length
     call      String.ToStdErr
     jmp       CloseConnection
.mysqlfetchrow:
     mov       rsi, string.mysqlfetchrow
     mov       rdx, string.mysqlfetchrow.length
     call      String.ToStdErr
     jmp       CloseConnection   
.notenoughmemory:
     mov       rsi, string.notenoughmemory
     mov       rdx, string.notenoughmemory.length
     jmp       Exit
.deallocmemory:
     mov       rsi, string.deallocmemory
     mov       rdx, string.deallocmemory.length
     call      String.ToStdErr
     jmp       Exit
.fileread:
     mov       rsi, string.fileread
     mov       rdx, string.fileread.length
     call      String.ToStdErr
     jmp       Exit
.filenotfound:
     mov       rsi, string.filenotfound
     mov       rdx, string.filenotfound.length
     call      String.ToStdErr
     jmp       Exit
.filestatus:
     mov       rsi, string.filestatus
     mov       rdx, string.filestatus.length
     call      String.ToStdErr
     jmp       Exit
.fileclose:
     mov       rsi, string.fileclose
     mov       rdx, string.fileclose.length
     call      String.ToStdErr
     jmp       Exit      

String.ToStdErr:
     push      rcx
     push      r11
     mov       rdi, stderr
     jmp       _syscallwrite
     
String.ToStdOut:
     push      rcx
     push      r11
     mov       rdi, stdout
_syscallwrite:     
     syscall   write, rdi, rsi, rdx
     pop       r11
     pop       rcx
     ret
     
String.Search:                                    ; on succes CF=0 and RAX has pointer
     mov       rax, rdi                          ; the length in rax
     mov       rbx, rsi                          ; the stringpointer in rbx
     mov       rsi, QWORD[heapstart]
     mov       rdx, QWORD[stat.st_size]
     sub       rdx, rdi
.@1:    
     mov       rdi, rbx
     mov       rcx, rax
     cld
     repe      cmpsb
     je        .@2
     dec       rdx
     and       rdx, rdx
     jnz       .@1
     stc
     ret
.@2:
     mov       rax, rsi
     clc
     ret
      
String.ToInt:                                     ; convert string to unsigned integer value
     mov       rsi, rdi
     xor       rdx, rdx
.@1:    
     xor       rax, rax
     lodsb
     and       al, al                            ; end of string?
     jz        .@2
     and       al, 0x0F                          ; un-ascii
     and       rdx, rdx
     jz        .@3
     mov       rcx, rax
     mov       rax, rdx
     xor       rdx, rdx
     mov       rbx, 10
     mul       rbx
     mov       rdx, rcx
.@3:    
     add       rax, rdx
     mov       rdx, rax
     jmp       .@1
.@2:
     mov       rax, rdx
     ret
      
String.Length:
     xor       rcx, rcx                          ; determine string length of a string in RDI
     dec       rcx
     xor       rax, rax
     repne     scasb
     neg       rcx
     dec       rcx
     dec       rcx
     and       rcx, rcx
     mov       rax, rcx                          ; return length in RAX
     ret
     
String.ZeroCRLF:                                  ; used to parse configuration file
     mov       rcx, rdi                          ; replaces LF en CR by NULL
     inc       rcx
.@1:
     cld
     lodsb
     cmp       al, 0x0A
     je        .@2
     cmp       al, 0x0D
     jne       .@3
.@2:
     dec       rsi
     xor       al, al
     mov       BYTE[rsi], al
.@3:      
     loop      .@1
     ret