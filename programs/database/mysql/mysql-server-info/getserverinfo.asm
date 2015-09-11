;Name:    getserverinfo
;Build:   see makefile
;Run:     getserverinfo

bits 64

[list -]
     %include   "unistd.inc"
     %include   "sys/stat.inc"
     extern     mysql_close
     extern     mysql_get_server_info
     extern     mysql_init
     extern     mysql_real_connect
     extern     mysql_server_end
     extern     mysql_server_init
[list +]

section .bss
     mysql:         resq      1
     result:        resq      1
     row:           resq      1
     heapstart:     resq      1
     fd:            resq      1
     host:          resq      1
     port:          resq      1
     user:          resq      1
     password:      resq      1
     database:      resq      1
section .data

string:
    .filenotfound:            db      "configuration file not found", 10
    .filenotfound.length:     equ     $-.filenotfound
    .fileread:                db      "error reading config file", 10
    .fileread.length:         equ     $-.fileread
    .filestatus:              db      "error reading file status", 10
    .filestatus.length:       equ     $-.filestatus
    .fileclose:               db      "error closing file", 10
    .fileclose.length:        equ     $-.fileclose
    
    .notenoughmemory:         db      "not enough memory", 10
    .notenoughmemory.length:  equ     $-.notenoughmemory
    .deallocmemory:           db      "error deallocating memory", 10
    .deallocmemory.length:    equ     $-.deallocmemory
    
    .mysqlserverinit:         db      "MySQL library could not be initialized",10
    .mysqlserverinit.length:  equ     $-.mysqlserverinit
    .mysqlobjinit:            db      "MySQL init object failed", 10
    .mysqlobjinit.length:     equ     $-.mysqlobjinit
    .mysqlresult:             db      "MySQL result error", 10
    .mysqlresult.length:      equ     $-.mysqlresult
    .mysqlfetchrow:           db      "MySQL fetch row error", 10
    .mysqlfetchrow.length:    equ     $-.mysqlfetchrow

; assemble with make cgi, if you want to make a cgi application of this program
%ifdef CGI
    httpheader:               db      "Content-type: text/html",10,10
    .length:                  equ     $-httpheader
    br:                       db      "<br />"
    .length:                  equ     $-br
%endif

mysqlerror:
    configfilename:           db      "mysql.cfg",0
    hoststring:               db      "DBHOST="
    .length:                  equ     $-hoststring
    userstring:               db      "DBUSER="
    .length:                  equ     $-userstring
    passwordstring:           db      "DBPASSWORD="
    .length:                  equ     $-passwordstring
    portstring:               db      "DBPORT="
    .length:                  equ     $-portstring
    
    ; file status structure
    STAT stat    

section .text
      global _start

_start:

%ifdef CGI
      syscall  write, stdout, httpheader, httpheader.length
%endif      
      mov      rdi, configfilename    
      call     MySQLConnect
      and      rax, rax
      js       .return                       ; if RAX < 0 an error occured
      mov      rdi, qword[mysql]

      call     mysql_get_server_info
      mov      rsi, rax
      mov      rdi, rax
      call     String.Length
      mov      rdx, rax
%ifndef CGI
      inc      rdx
      dec      rdi
      mov      BYTE[rdi], 0x0A
%endif
%ifdef CGI
      dec      rdx
%endif
      syscall  write, stdout, rsi, rdx
      call     MySQLClose
.return:      
      syscall  exit, 0

MySQLConnect:
.checkheap:
      syscall  brk, 0
      and      rax, rax
      jnz      .checkfile
      mov      rax, -1
      jmp      .return                       ; no memory
.checkfile:
      mov      QWORD [heapstart], rax
      ; from here free heap
      syscall  open, configfilename, O_RDONLY
      and      rax, rax
      jns      .filesize      
      mov      rax, -5                       ; error file
      jmp      MySQLClose.freeheap
.filesize:
      ; from here free heap and close fd
      mov      QWORD [fd], rax
      syscall  fstat, QWORD[fd], stat
      and      rax, rax
      jns      .allocmem
      mov      rax, -6
      jmp      MySQLClose.closefd
.allocmem:
      mov      rax, QWORD [heapstart]
      add      rax, QWORD [stat.st_size]                ; add filesize to allocate memory
      inc      rax                                     ; one extra byte, to be sure the string ends with 00
      ; try to allocate memory on the heap
      syscall  brk, rax
      sub      rax, rdi                                ; new memory break equal to calculated one?
      and      rax, rax
      jz       .loadfile
      ; not enough memory free heap and close fd
      mov      rax, -8
      jmp      MySQLClose.closefd
.loadfile:      
      ; read the file in the allocated memory
      syscall  read, QWORD[fd], QWORD[heapstart], QWORD[stat.st_size]
      and      rax, rax
      jns      .parsefile
      mov      rax, -9
      jmp      MySQLClose.closefd
.parsefile:      
      call     GetConnectionParameters
      and      rax, rax
      js       .return                       ; if RAX < 0 then we have an error

      xor      rdi, rdi
      xor      rsi, rsi
      xor      rdx, rdx
      call     mysql_server_init
      and      rax, rax
      jz       .mysqlinit
      mov      rax, -1                       ; server init error
      jmp      .return
.mysqlinit:      
      xor      rdi, rdi
      call     mysql_init
      and      rax, rax
      jnz      .mysqlconnect
      mov      rax, -2                       ; mysql init error
      jmp      .return
.mysqlconnect:
      mov      QWORD [mysql], rax                 ; save *MYSQL
      mov      rdi, QWORD [mysql]                ; value of mysql = pointer to mysql instance of connection
      push     0                                 ; the value of clientflags or NULL if none
      push     0                                 ; the value of socket or NULL if none
      mov      r9d, DWORD [port]                 ; the value of the port to connect to               
      mov      r8,  QWORD [database]             ; pointer to zero terminated database string
      mov      rcx, QWORD [password]             ; pointer to zero terminated password string
      mov      rdx, QWORD [user]                 ; pointer to zero terminated user string
      mov      rsi, QWORD [host]                 ; pointer to zero terminated host string
      call     mysql_real_connect                ; connect
      pop      rdx                               ; restore stackpointer
      pop      rdx
      cmp      rax, QWORD [mysql]                 ; CONN = MYSQL?
      je       .return                            ; rax has connection
      mov      rax, -4
      jmp      MySQLClose
.return:
      ret
;-----------------------------------------------------------------------------------
MySQLClose:
.close:
      mov      rdi, QWORD [mysql]
      call     mysql_close
      call     mysql_server_end
.closefd:
      syscall  close, QWORD[fd]
.freeheap:      
      ; release any remaining memory
      syscall  brk, QWORD[heapstart]
      ret
      
;-----------------------------------------------------------------------------------      
GetConnectionParameters:      
      ; loop through our string, replacing each 0x0A and 0x0D with 00
      mov      rsi, QWORD[heapstart]
      mov      rdi, QWORD[stat.st_size]
      call     String.ZeroCRLF
; get the values for host, user, password, port, database, socket and clientflag, if socket and clientflag are
; empty strings then the values for these are NULL instead of the pointer to the socket and clientflag string.
; Port need to be stored as an unsigned integer.
      ; get pointer to HOST
      mov      rdi, hoststring.length
      mov      rsi, hoststring
      call     String.Search
      mov      QWORD[host], rax
      ; get pointer to USER
      mov      rdi, userstring.length
      mov      rsi, userstring
      call     String.Search
      mov      QWORD[user], rax
      ; get pointer to PASSWORD
      mov      rdi, passwordstring.length
      mov      rsi, passwordstring
      call     String.Search
      mov      QWORD[password], rax
      ; get pointer to PORT      
      mov      rdi, portstring.length
      mov      rsi, portstring
      call     String.Search
      ; parse PORT to integer
      mov      rdi, rax
      call     String.ToInt
      mov      QWORD[port], rax
.return:      
      ret
      
String.Search:                                  ; on succes CF=0 and RAX has pointer
      mov      rax, rdi                        ; the length in rax
      mov      r8, rsi                        ; the stringpointer in rbx
      mov      rsi, QWORD[heapstart]
      mov      rdx, QWORD[stat.st_size]
      sub      rdx, rdi
.@1:    
      mov      rdi, r8
      mov      rcx, rax
      cld
      repe     cmpsb
      je       .@2
      dec      rdx
      and      rdx, rdx
      jnz      .@1
      stc
      ret
.@2:
      mov      rax, rsi
      clc
      ret
      
String.ToInt:
      mov      rsi, rdi
      xor      rdx, rdx
.@1:    
      xor      rax, rax
      lodsb
      and      al, al                                  ; end of string?
      jz       .@2
      and      al, 0x0F                                ; un-ascii
      and      rdx, rdx
      jz       .@3
      mov      rcx, rax
      mov      rax, rdx
      xor      rdx, rdx
      mov      rbx, 10
      imul     rbx
      mov      rdx, rcx
.@3:    
      add      rax, rdx
      mov      rdx, rax
      jmp      .@1
.@2:
      mov      rax, rdx
      ret
      
String.Length:
      xor      rcx, rcx
      dec      rcx
      xor      rax, rax
      repne    scasb
      neg      rcx
      dec      rcx
      dec      rcx
      and      rcx, rcx
      mov      rax, rcx
      ret
      
String.ZeroCRLF:
      mov      rcx, rdi
      inc      rcx
.@1:
      cld
      lodsb
      cmp      al, 0x0A
      je       .@2
      cmp      al, 0x0D
      jne      .@3
.@2:
      dec      rsi
      xor      al, al
      mov      BYTE[rsi], al
.@3:      
      loop     .@1
      ret