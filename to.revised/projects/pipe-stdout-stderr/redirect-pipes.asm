; Name:         redirect-pipes.asm
; Description:  make two named pipes
;
; build: nasm "-felf64" redirect-pipes.asm redirect-pipes.o
;        ld -s -melf_x86_64 -o redirect-pipes redirect-pipes.o 

[list -]
     %include "unistd.inc"
     %include "fcntl.inc"
[list +]
    %define STDOUTPIPE	"pipe2stdout"
    %define STDERRPIPE  "pipe2stderr"
    %define SCRIPT      'tty > pipe2stdout;exec<&-;exec>&-;while:;do sleep 3600;done'
bits 64

section .data
	
	pipescreated:	db		STDOUTPIPE," and ",STDERRPIPE, " created.",10
	.len:			equ 	$-pipescreated
    sMknoderror:    db		"mknod error: check existence of named pipes, remove manually and rerun this program.",10
    .len:           equ		$-sMknoderror
    stdoutpipe:	    db		STDOUTPIPE,0
    stderrpipe:	    db		STDERRPIPE,0
    pfds:
    .stdin:			dd      0
	.stdout:		dd      0
	.stderr:		dd      0
	swap:			dd      0
	fdstdout:		dq		0
	fdstderr:		dq		0
	msgOut:			db		0x1B,"[33m",0x1B,"[32mNORMAL message",10
	.len:			equ 	$-msgOut
	msgErr:			db		0x1B,"[33m",0x1B,"[31mERROR message",10
	.len:			equ 	$-msgErr
	
	filename:		db		"/usr/bin/xterm",0
	arg1:			db		"-title",0
	arg2:			db		STDOUTPIPE,0
	arg3:			db		"-hold",0
	arg4:           db      "-e",0
	arg5:			db 		"/bin/sh",0
	arg6:			db		"-c",0
	arg7:			db		SCRIPT,0


	env1:			db		"DISPLAY=:0",0
	env2:			db		"PATH=/usr/bin/",0
	
	argvpout:		dq		filename
					dq		arg1
					dq		arg2
					dq		arg3
					dq		arg4
					dq		arg5
					dq		arg6
					dq		arg7
					dq		0
	
	argvperr:		dq		filename
					dq		arg1
					dq		arg2
					dq		arg3
	;				dq		arg5
					dq		0

	envp:			dq		env1
					dq		env2
					dq		0
					
section .text
     global _start
     
_start:
	
	syscall unlink,stdoutpipe
	syscall unlink,stderrpipe
	
	;create the pipes
	;create named pipe for stdout
	syscall mknod,stdoutpipe, S_IFIFO | S_IRUSR | S_IWUSR, 0
	syscall mknod,stderrpipe, S_IFIFO | S_IRUSR | S_IWUSR, 0

	;	and 	rax,rax
;	js		.mknoderror
;	syscall write,[fdstdout],msgOut,msgOut.len
	
;	syscall open,stderrpipe,O_WRONLY
;	mov		[fdstderr],rax
;	syscall write,[fdstderr],msgErr,msgErr.len
	

;	syscall open,stdoutpipe,O_WRONLY
;	mov		[fdstdout],rax
	
;	syscall fork
;	jnz		.child
	syscall execve,filename,argvpout,envp
	syscall exit,0
	syscall wait4,0,0,0,0
	syscall exit,0
	
.mknoderror:
	;mknod also gives errors when the named pipe already exist
	syscall write,stderr,sMknoderror,sMknoderror.len
	syscall	exit,1
	
