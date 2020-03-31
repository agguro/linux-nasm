%ifndef _threads_inc_
%define _threads_inc_

%include "unistd.inc"
%include "sys/sched.inc"
%include "sys/mman.inc"

%define THREAD_FLAGS	CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_PARENT|CLONE_THREAD|CLONE_IO
%define STACK_SIZE	(4096 * 1024)
%define MAX_LINES	10000					; number of output lines before exiting

%endif 		;; _threads_inc_
