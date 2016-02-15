%ifndef _ASM_SIGNALS_INC_
%define _ASM_SIGNALS_INC_

; Linux x86_64 signals

%define SIGHUP       1        ; Hangup
%define SIGINT       2        ; User interrupt requested from terminal, e.g. when Ctrl-C is pressed
%define SIGQUIT      3        ; Quit, e.g. when Ctrl-\ is pressed
%define SIGILL       4        ; Illegal instruction
%define SIGTRAP      5        ; Trace trap (used by debugger)
%define SIGABRT      6        ; abort
%define SIGBUS       7        ; Bus error
%define SIGFPE       8        ; Floating-point arithmetic exception
%define SIGKILL      9        ; Kill (Cannot be caught or ignored)
%define SIGUSR1      10       ; User-defined signal 1
%define SIGSEGV      11       ; Segmentation violation
%define SIGUSR2      12       ; User-defined signal 2
%define SIGPIPE      13       ; Broken pipe (attempt to write to a pipe without a process connected to the other end)
%define SIGALRM      14       ; Timer set by alarm or setitimer function expired
%define SIGTERM      15       ; Software termination signal from kill
%define SIGSTKFLT    16       ; x86 FPU stack fault
%define SIGCHLD      17       ; Child process status has changed
%define SIGCONT      18       ; The stopped process is continued
%define SIGSTOP      19       ; Stop (Cannot be caught or ignored)
%define SIGTSTP      20       ; User stop requested from terminal, e.g. when Ctrl-Z is pressed
%define SIGTTIN      21       ; Terminal read attempted when the process is in the background
%define SIGTTOU      22       ; Terminal write attempted when the process is in the background
%define SIGURG       23       ; Urgent condition on socket, e.g. out-of-band data is received on a network connection
%define SIGXCPU      24       ; CPU limit exceeded
%define SIGXFSZ      25       ; File size limit exceeded
%define SIGVTALRM    26       ; Virtual interval timer set by the setitimer function expired
%define SIGPROF      27       ; Profiling interval timer set by the setitimer function expired
%define SIGWINCH     28       ; Terminal window size change
%define SIGIO        29       ; Pollable or async I/O event occurred
%define SIGPWR       30       ; Power failure restart
%define SIGSYS       31       ; Illegal system call
%define SIGRTMIN     32
%define SIGRTMAX     64

%define SIGIOT       SIGABRT
%define SIGPOLL      SIGIO
%define SIGLOST      SIGIO
%define SIGIO        SIGPOLL
%define SIGINFO      SIGPWR
%define SIGUNUSED    SIGSYS
%define SIGCLD       SIGCHLD

; SA_FLAGS values:
;
; SA_ONSTACK indicates that a registered stack_t will be used.
; SA_RESTART flag to get restarting signals (which were the default long ago)
; SA_NOCLDSTOP flag to turn off SIGCHLD when children stop.
; SA_RESETHAND clears the handler when the signal is delivered.
; SA_NOCLDWAIT flag on SIGCHLD to inhibit zombies.
; SA_NODEFER prevents the current signal from being masked in the handler.
;
; SA_ONESHOT and SA_NOMASK are the historical Linux names for the Single
; Unix names RESETHAND and NODEFER respectively.

%define SA_NOCLDSTOP  0x00000001
%define SA_NOCLDWAIT  0x00000002
%define SA_SIGINFO    0x00000004
%define SA_ONSTACK    0x08000000
%define SA_RESTART    0x10000000
%define SA_NODEFER    0x40000000
%define SA_RESETHAND  0x80000000
%define SA_NOMASK     SA_NODEFER
%define SA_ONESHOT    SA_RESETHAND
%define SA_RESTORER   0x04000000

; sigaltstack controls

%define SS_ONSTACK   1
%define SS_DISABLE   2
%define MINSIGSTKSZ  2048
%define SIGSTKSZ     8192

; macros

STRUC SIGACTION_STRUC
  .sa_handler:      resq      1
  .sa_sigaction:    resq      1
  .sa_mask:         resb      128
  .sa_flags:        resd      1
  .sa_restorer:     resq      1
ENDSTRUC

%macro SIGACTION 1
  %1: ISTRUC SIGACTION_STRUC
    at  SIGACTION_STRUC.sa_handler,      dq 0
    at  SIGACTION_STRUC.sa_sigaction,    dq 0
    at  SIGACTION_STRUC.sa_mask,         times 128 db 0
    at  SIGACTION_STRUC.sa_flags,        dd 0
    at  SIGACTION_STRUC.restorer,        dq 0
  IEND

  %define %1.sa_handler     %1+SIGACTION_STRUC.sa_handler
  %define %1.sa_sigaction   %1+SIGACTION_STRUC.sa_sigaction
  %define %1.sa_mask        %1+SIGACTION_STRUC.sa_mask
  %define %1.sa_flags       %1+SIGACTION_STRUC.sa_flags
  %define %1.sa_restorer    %1+SIGACTION_STRUC.sa_restorer
%endmacro

;*************************************************************************
; TO-DO
;*************************************************************************
;STRUC SIGINFO_T_STRUC
;    .si_signo:                  ; Signal number */int
;    .si_errno:                  ; An errno value */int
;    .si_code:                   ; Signal code */int
;    .si_trapno:                 ; Trap number that caused hardware-generated signal (unused on most architectures) */ int
;    .si_pid:                    ; Sending process ID */pid_t
;    .si_uid:                    ; Real user ID of sending process */uid_t
;    .si_status:                 ; Exit value or signal */int
;    .si_utime:                  ; User time consumed */ clock_t
;    .si_stime:                  ; System time consumed */clock_t
;    .si_value:                  ; Signal value */sigval_t
;    .si_int:                    ; POSIX.1b signal */int
;    .si_ptr:            resq 1  ; POSIX.1b signal */void
;    .si_overrun:                ; Timer overrun count; POSIX.1b timers */int
;    .si_timerid:                ; Timer ID; POSIX.1b timers */int
;   .si_addr:           resq 1   ; Memory location which caused fault */void
;    .si_band:                   ; Band event (was int in glibc 2.3.2 and earlier) */long     
;    .si_fd:                     ; File descriptor */ int
;    .si_addr_lsb:               ; Least significant bit of address (since kernel 2.6.32) */ short
;ENDSTRUC

;%macro SIGINFO_T_STRUC 1
;*************************************************************************

%elif
  %warning "signals.inc already included"
%endif
