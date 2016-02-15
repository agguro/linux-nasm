; Name:         libmysqlmanager.asm
; Build:        see makefile
; Description:	MySQL management library
; ABI !!!


BITS 64

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
      mysqlmanager.%1.end:
%endmacro    


align 16

extern  _GLOBAL_OFFSET_TABLE_

section .bss

section .data
            
    mysqlhost:          dq 0
    mysqlport:          dd 0
    mysqluser:          dq 0
    mysqlpassword:      dq 0
    mysqldatabase:      dq 0
    mysqlsocket:        dq 0
    mysqlclientflag:    dq 0
    
section .text
_start:

PROCEDURE Connect

ENDP      Connect

PROCEDURE GetHost
    mov       rax, mysqlhost
    mov       rax, [rax]
ENDP      GetHost

