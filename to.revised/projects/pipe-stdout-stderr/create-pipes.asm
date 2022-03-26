; Name:         create-pipes.asm
; Description:  make two named pipes
;
; build: nasm "-felf64" create-pipes.asm create-pipes.o
;        ld -s -melf_x86_64 -o create-pipes create-pipes.o 

[list -]
     %include "unistd.inc"
     %include "fcntl.inc"
[list +]
    %define STDOUTPIPE	"pipe2stdout"
    %define STDERRPIPE  "pipe2stderr"
    
bits 64

section .data

	pipescreated:	db		STDOUTPIPE," and ",STDERRPIPE, " created.",10
	.len:			equ 	$-pipescreated
    sMknoderror:    db		"mknod error: check existence of named pipes, remove manually and rerun this program.",10
    .len:           equ		$-sMknoderror
    stdoutpipe:	    db		STDOUTPIPE,0
    stderrpipe:	    db		STDERRPIPE,0
        
section .text
     global _start
     
_start:
	
	;create the pipes
	;create named pipe for stdout
	syscall mknod,stdoutpipe, S_IFIFO | S_IRUSR | S_IWUSR, 0
	and 	rax,rax
	js		.mknoderror
	
	;create named pipe for stderr
	syscall mknod,stderrpipe, S_IFIFO | S_IRUSR | S_IWUSR, 0
	and 	rax,rax
	js		.mknoderror
	
	syscall write,stdout,pipescreated,pipescreated.len
	syscall	exit,0
	
.mknoderror:
	;mknod also gives errors when the named pipe already exist
	syscall write,stderr,sMknoderror,sMknoderror.len
	syscall	exit,1
	
