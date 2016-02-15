; Name:         libmysqlmanager.asm
; Build:        see makefile
; Description:	MySQL management library
; ABI !!!
; error handling is done by passing negative numbers in rax, for MySQL we make the errors negative, he user must deal with the messaging of it.

BITS 64

    %include "fileio.inc"
    %include "syscalls.inc"
    %include "termio.inc"
    %include "mysqlclient.inc"
;    extern mysql_errno
;    extern mysql_init
;    extern mysql_real_connect
;    extern mysql_server_init
    
%macro PROLOGUE 0
      push      rbp 
      mov       rbp,rsp 
      push      rbx 
      call      .get_GOT 
.get_GOT: 
      pop       rbx 
      add       rbx,_GLOBAL_OFFSET_TABLE_+$$-.get_GOT wrt ..gotpc 
%endmacro

%macro EPILOGUE 0
      mov       rbx,[rbp-8] 
      mov       rsp,rbp 
      pop       rbp 
      ret
%endmacro

%macro PROCEDURE 1
      global MySQLManager.%1:function
      MySQLManager.%1:
          PROLOGUE
%endmacro

%macro ENDP 1
          EPILOGUE
%endmacro    

%macro GLOBALDATA 3
      global MySQLManager.%1:data (%1.end - %1)
      section .data
      %1:	%2	%3
      %1.end:
%endmacro

%macro NOSHAREDDATA 3
      global %1:data
      section .data
      %1:	%2	%3
%endmacro      

align 16

extern  _GLOBAL_OFFSET_TABLE_

section .bss
section .data
     
      NOSHAREDDATA fd,dq,0
      NOSHAREDDATA heapstart,dq,0
      NOSHAREDDATA host,dq,0
      NOSHAREDDATA user,dq,0
      NOSHAREDDATA password,dq,0
      NOSHAREDDATA port,dq,0
      NOSHAREDDATA database,dq,0
      NOSHAREDDATA clientflag,dq,0
      NOSHAREDDATA socket,dq,0
      NOSHAREDDATA mysql,dq,0
      NOSHAREDDATA filesize, dq, 0
      NOSHAREDDATA conn,dq,0
      
      NOSHAREDDATA error,dq,0
       
      STAT	filestatus
      
      hoststring:         db  "DBHOST="
      .length:            equ $ - hoststring
      userstring:         db  "DBUSER="
      .length:            equ $ - userstring
      passwordstring:     db  "DBPASSWORD="
      .length:            equ $ - passwordstring
      databasestring:     db  "DBDATABASE="
      .length:            equ $ - databasestring
      portstring:         db  "DBPORT="
      .length:            equ $ - portstring
      socketstring:       db  "DBSOCKET="
      .length:            equ $ - socketstring
      clientflagstring:   db  "DBCLIENTFLAG="
      .length:            equ $ - clientflagstring
      uuidquery:	  db  "select uuid()",0
      
section .text
_start:



PROCEDURE GetConnection
      xor	rax, rax				; clear the error variable
      mov	QWORD [rbx + error wrt ..got]
; try to initialize the server, if we don't succeed we stop before parsing the configuration file      
      xor       rdi, rdi
      xor       rsi, rsi
      xor       rdx, rdx
      call      mysql_server_init wrt ..plt
      and       rax, rax
      jz        .parsefile
      mov	rax, "SRVINIT"				; the library couldn't be initialized
      neg 	rax
      mov	QWORD[rbx + error wrt ..got]
      jmp	.exit
      
.parsefile:
; rdi has the pointer to the configuration file
; we will parse the file and get all parameters
      call	File.Open
      
; from here we need to close the FD when we are done with it      
; get the file stats, especially the size is of importance      
      mov       QWORD[rbx + fd wrt ..got], rax                         ; save filedescriptor
      mov       rdi, rax
      mov       rsi, filestatus
      mov       rax, SYS_FSTAT
      syscall
      and       rax, rax
      jns       .getfilesize
      mov	QWORD[rbx + error wrt ..got], rax
      jmp	.closefd
.getfilesize:
      mov	rax, filestatus.st_size
      mov	rax, [rax]
      mov	QWORD[rbx + filesize wrt ..got], rax
; get start of heap
      xor       rdi, rdi
      mov       rax, SYS_BRK
      syscall
      and       rax, rax
      jns       .reservememory
      mov	QWORD[rbx + error wrt ..got], rax
      jmp	.closefd					; no memory could be reserved, close fd and exit
      
      
.reservememory:
      mov	rdi, QWORD[rbx + filesize wrt ..got]
      inc 	rdi
      call	Heap.AllocateMemory
      js	------------
      
      
; try to allocate additional memory
      mov       rdi, rax
      mov       rax, SYS_BRK
      syscall
      sub       rax, rdi                                ; new memory break equal to calculated one?
      and       rax, rax
      jz       .readfile
      mov	QWORD [rbx + error wrt ..got], rax
      jmp	.closefd					; there wasn't memory enough, close fd and exit
.readfile:      
; read the file in the allocated memory
      mov       rdi, QWORD[rbx + fd wrt ..got]
      mov       rsi, QWORD[rbx + heapstart wrt ..got]
      mov       rdx, QWORD[rbx + filesize wrt ..got]        ; bytes to read
      mov       rax, SYS_READ
      syscall
      and       rax, rax
      jns       .closefile
      mov	QWORD [rbx + error wrt ..plt]
      jmp	.freeheap
.closefile:
      mov	rdi, QWORD [rbx + fd wrt ..got]
      mov	rax, SYS_CLOSE
      syscall
; from here we don't call close fd anymore
.parsefile:
; loop through our string, replacing each 0x0A and 0x0D with 00
      mov       rsi, QWORD[rbx + heapstart wrt ..got]
      mov       rdi, QWORD[rbx + filesize wrt ..got]
      call      String.ZeroCRLF

; get the values for host, user, password, port, database, socket and clientflag, if socket and clientflag are
; empty strings then the values for these are NULL instead of the pointer to the socket and clientflag string.
; Port need to be stored as an unsigned integer.
    ; get pointer to HOST
      mov       rdi, hoststring.length
      mov       rsi, hoststring
      call      String.Search
      mov       QWORD[rbx + host wrt ..got], rax
    ; get pointer to USER
      mov       rdi, userstring.length
      mov       rsi, userstring
      call      String.Search
      mov       QWORD[rbx + user wrt ..got], rax
      ; get pointer to PASSWORD
      mov       rdi, passwordstring.length
      mov       rsi, passwordstring
      call      String.Search
      mov       QWORD[rbx + password wrt ..got], rax
      ; get pointer to PORT      
      mov       rdi, portstring.length
      mov       rsi, portstring
      call      String.Search
      ; parse PORT to integer
      mov       rdi, rax
      call      String.ToInt
      mov       QWORD[rbx + port wrt ..got], rax
      ; get pointer to DATABASE
      mov       rdi, databasestring.length
      mov       rsi, databasestring
      call      String.Search
      mov       QWORD[rbx + database wrt ..got], rax
      ; get pointer to SOCKET
      mov       rdi, socketstring.length
      mov       rsi, socketstring      
      call      String.Search
      mov       rdx, rax                        ; save pointer
      ; determine string length and if zero store pointer as NULL
      mov       rdi, rax
      call      String.Length
      and       rax, rax
      jz        .@1
      mov       rax, rdx
.@1:      
      mov       QWORD[rbx + socket wrt ..got], rax
      ; get pointer to CLIENTFLAG
      mov       rdi, clientflagstring.length
      mov       rsi, clientflagstring
      call      String.Search
      mov       rdx, rax                        ; save pointer
      ; determine string length and if zero store pointer as NULL
      mov       rdi, rax
      call      String.Length
      and       rax, rax
      jz        .@2
      mov       rax, rdx
.@2:      
      mov       QWORD[rbx + clientflag wrt ..got], rax
; the configuration file is parsed without errors, now try to get an MYSQL instance
; all values are known, now connect to mysql server
; not an embedded MySQL so all arguments must be zero
; From this point we need to cleanup the library!!!!
      xor       rdi, rdi
      call      mysql_init wrt ..plt
      and       rax, rax
      jnz	.connect
      mov	rax, "OBJINIT"
      neg 	rax
      mov	QWORD [rbx + error wrt ..got], rax
      jmp	.freeheap
      ; no errors, connect and login 
      ; rax = *connection
      mov	QWORD[rbx + mysql wrt ..got], rax
      mov	rdi, rax 				               	; value of mysql = pointer to mysql instance of connection
      push	QWORD [rbx + clientflag wrt ..got]                      ; the value of clientflags or NULL if none
      push	QWORD [rbx + socket wrt ..got]           		; the value of socket or NULL if none
      mov	r9d, DWORD [rbx + port wrt ..got]                       ; the value of the port to connect to               
      mov	r8,  QWORD [rbx + database wrt ..got]           	; pointer to zero terminated database string
      mov	rcx, QWORD [rbx + password wrt ..got]           	; pointer to zero terminated password string
      mov	rdx, QWORD [rbx + user wrt ..got]               	; pointer to zero terminated user string
      mov	rsi, QWORD [rbx + host wrt ..got]               	; pointer to zero terminated host string
      call	mysql_real_connect wrt ..plt     			; connect
      pop	rdx                     				; restore stackpointer
      pop	rdx
      cmp	rax, QWORD [rbx + mysql wrt ..got]       		; if conn == pointer to mysql instance then succes
      jne	.freeheap

	    .errorMysql:
		    mov	rdi, QWORD [rbx + heapstart wrt ..got]
		    mov	rax, SYS_BRK
		    syscall
		    mov	rdi, QWORD [rbx + mysql wrt ..got]
		    call	mysql_errno wrt ..plt
		    neg 	rax				; make rax negative
		    jmp	.exit
		    
.freeheap:
	mov	rdi, QWORD [rbx + heapstart wrt ..got]
	mov	rax, SYS_BRK
	syscall
	; error or not we must close the file descriptor
.closefd:
	mov	rdi, QWORD [rbx + fd wrt ..got]
	mov	rax, SYS_CLOSE
	syscall
	mov	rdx, rax
	mov	rax, QWORD [rbx + error wrt ..got]
	and	rax, rax
	jz	.exit
	stc
	jmp	.exit
	
.errorMySQLServerInit:
	mov	rax, "SRVINIT"
	neg 	rax
	stc					; set carryflag, error
.exit:      
ENDP      GetConnection

PROCEDURE GetUUID
      call	MySQLManager.GetConnection
      jc	.noresult
      mov	rdi, rax
      ; RDI has the pointer to the connection, RSI points to the query
      mov	rsi, uuidquery
      mov	QWORD[rbx + conn wrt ..got], rdi
      call      mysql_query wrt ..plt             ; query the server
      mov	rdi, QWORD[rbx + conn wrt ..got]
      ; check for errors
      call      mysql_errno wrt ..plt
      and       rax, rax
      jnz       .errorMySQL
      mov       rdi, QWORD[rbx + conn wrt ..got]
      call      mysql_use_result wrt ..plt       ; we don't ask all the records at once (less client side memory)
      and       rax, rax
      jnz       .fetchuuid
      mov	rdi, QWORD[rbx + conn wrt ..got]
      ; check for errors
      call      mysql_errno wrt ..plt
      jmp	.errorMySQL
.fetchuuid:      
      ; get uuid from resultset
      ;mov       QWORD [result], rax
      mov       rdi, rax
      call      mysql_fetch_row wrt ..plt
      and       rax, rax
      cmp       rax, 2000               ; unknown error
      je        .errorMySQL
      cmp       rax, 2013               ; connection lost
      je        .errorMySQL
      jz        .noresult
      mov	rax, [rax]
      clc
      jmp	.exit
.errorMySQL:
      neg 	rax
.noresult:      
      stc
.exit:      
ENDP      GetUUID

Heap.AllocateMemory:
; rdi has memory in bytes to reserve
      mov	rsi, rdi
      xor	rdi, rdi
      mov	rax, SYS_BRK
      syscall
      and	rax, rax
      js	.exit
      mov	QWORD [rbx + heapstart wrt ..got], rax
      add 	rax, rsi
      mov	rdi, rax
      mov	rax, SYS_BRK
      syscall
      cmp 	rax, rdi
      je	.exit
      mov	rax, -1
.exit:
      ret
      
Heap.FreeMemory:
      mov	rdi, QWORD [rbx + heapstart wrt ..got]
      mov	rax, SYS_BRK
      syscall
      ret
      
File.Open:
; rdi has file to open
      mov       rsi, O_RDONLY
      mov       rax, SYS_OPEN
      syscall
      and       rax, rax
      js        .exit
      mov	QWORD [rbx + error wrt ..plt], rax
      xor	rax, rax
.exit:      
      ret
      
; local functions
String.Search:                                  ; on succes CF=0 and RAX has pointer
      mov       rax, rdi                        ; the length in rax
      mov       r8, rsi                        ; the stringpointer in rbx
      mov       rsi, QWORD[rbx + heapstart wrt ..got]
      mov       rdx, QWORD[rbx + filesize wrt ..got]
      sub       rdx, rdi
.@1:    
      mov       rdi, r8
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
      
String.ToInt:
      push	rbx					; save rbx !! -> got
      mov       rsi, rdi
      xor       rdx, rdx
.@1:    
      xor       rax, rax
      lodsb
      and       al, al                                  ; end of string?
      jz        .@2
      and       al, 0x0F                                ; un-ascii
      and       rdx, rdx
      jz        .@3
      mov       rcx, rax
      mov       rax, rdx
      xor       rdx, rdx
      mov       rbx, 10
      imul      rbx
      mov       rdx, rcx
.@3:    
      add       rax, rdx
      mov       rdx, rax
      jmp       .@1
.@2:
      mov       rax, rdx
      pop	rbx
      ret
      
String.Length:
      xor       rcx, rcx
      dec       rcx
      xor       rax, rax
      repne     scasb
      neg       rcx
      dec       rcx
      dec       rcx
      and       rcx, rcx
      mov       rax, rcx
      ret
      
String.ZeroCRLF:
      mov       rcx, rdi
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
      
String.Write:
      mov	rdi, STDOUT
      mov	rax, SYS_WRITE
      syscall
      ret