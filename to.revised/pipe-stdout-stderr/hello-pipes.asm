; Name:         hello3pipes.asm
; Description:  Writes “STDOUT: Hello world!” to stdout
;                      “STDERR: Hello World!” to stderr
;
; build: nasm "-felf64" hello.asm -l hello.lst -o hello.o
;        ld -s -melf_x86_64 -o hello hello.o 
;
; However we distinguished the writes to stdout and stderr, both messages are written
; to stdout.
; stdin remains on the terminal where this program is ran from.

[list -]
     %include "unistd.inc"
     %include "fcntl.inc"
[list +]
    %define STDOUTPIPE	"pipe2stdout"
    %define STDERRPIPE  "pipe2stderr"
    
bits 64

section .data

    msg2stdout:    db    "STDOUT: Hello world! nice and clean.",10
    .len:          equ   $-msg2stdout
    msg2stderr:    db    "STDERR: Hello world! full of bugs.",10
    .len: 	       equ   $-msg2stderr
    sMknoderror:   db    "mknod error"
    .len:          equ   $-sMknoderror
    stdoutpipe:	   db    STDOUTPIPE,0
    stderrpipe:	   db    STDERRPIPE,0
        
section .text
     global _start
     
_start:
	;create the pipes
	;create named pipe for stdout
	syscall   mknod,stdoutpipe, S_IFIFO | S_IRUSR | S_IWUSR, 0
	and 	rax,rax
	js		.mknoderror
	
	;create named pipe for stdout
	syscall   mknod,stderrpipe, S_IFIFO | S_IRUSR | S_IWUSR, 0
	and 	rax,rax
	js		.mknoderror
	
	
	syscall	write,stdout,msg2stdout,msg2stdout.len
	syscall	write,stderr,msg2stderr,msg2stderr.len
	syscall	exit,0
	
.mknoderror:
	syscall write,stdout,sMknoderror,sMknoderror.len
	syscall	exit,0
	
