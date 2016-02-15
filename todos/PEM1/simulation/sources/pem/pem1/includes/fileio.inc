%ifndef _ASM_FILEIO_INC_
%define _ASM_FILEIO_INC_

  %define       O_RDONLY    0
  %define       O_WRONLY    1
  %define       O_RDWR      2

  ;The following flags are defined for the st_mode field:

  %define S_IFMT     61440 ; bit mask for the file type bit fields
  %define S_IFSOCK   49152 ; socket
  %define S_IFLNK    40960 ; symbolic link
  %define S_IFREG    32768 ; regular file
  %define S_IFBLK    24576 ; block device
  %define S_IFDIR    16384 ; directory
  %define S_IFCHR    8192  ; character device
  %define S_IFIFO    4096  ; FIFO
  %define S_ISUID    2048  ; set UID bit
  %define S_ISGID    1024  ; set-group-ID bit (see below)
  %define S_ISVTX    512   ; sticky bit (see below)

  %define S_IRWXU    448   ; mask for file owner permissions
  %define S_IRUSR    256   ; owner has read permission
  %define S_IWUSR    128   ; owner has write permission
  %define S_IXUSR    64    ; owner has execute permission

  %define S_IRWXG    56    ; mask for group permissions
  %define S_IRGRP    32    ; group has read permission
  %define S_IWGRP    16    ; group has write permission
  %define S_IXGRP    8     ; group has execute permission

  %define S_IRWXO    7     ; mask for permissions for others (not in group)
  %define S_IROTH    4     ; others have read permission
  %define S_IWOTH    2     ; others have write permission
  %define S_IXOTH    1     ; others have execute permission

  ; STAT structure definition

  STRUC STAT_STRUC
  .st_dev         resq 1  ; device
  .st_ino         resq 1  ; file serial number
  .st_nlink       resq 1  ; link count 
  .st_mod         resd 1  ; file mode
  .st_uid         resd 1  ; user id of owner
  .st_gid         resd 1  ; group id of owner
  .st_rdev        resq 1  ; device number if device
  ._pad1          resd 1
  .st_size        resq 1  ; filesize in bytes
  .st_blksize     resd 1  ; optimal block size for I/O
  ._pad2          resd 1
  .st_blocks      resq 1  ; number of 512-byte blocks allocated
  .st_atime       resq 1  ; last access time secs
  .st_atime_nsec  resq 1  ; last access time nsecs
  .st_mtime       resq 1  ; last modification time secs
  .st_mtime_nsec  resq 1  ; last modification time nsecs
  .st_ctime       resq 1  ; last status changed time secs
  .st_ctime_nsec  resq 1  ; last status changed time nsecs
  ._unused1       resq 1
  ._unused2       resq 1
  ._unused3       resq 1
  ENDSTRUC

  %macro STAT 1
    %1: ISTRUC STAT_STRUC
      at STAT_STRUC.st_dev,         dq 0    ; device
      at STAT_STRUC.st_ino,         dq 0    ; file serial number
      at STAT_STRUC.st_nlink,       dq 0    ; link count 
      at STAT_STRUC.st_mod,         dd 0    ; file mode
      at STAT_STRUC.st_uid,         dd 0    ; user id of owner
      at STAT_STRUC.st_gid,         dd 0    ; group id of owner
      at STAT_STRUC.st_rdev,        dq 0    ; device number if device
      at STAT_STRUC._pad1,          dd 0
      at STAT_STRUC.st_size,        dq 0    ; filesize in bytes
      at STAT_STRUC.st_blksize,     dd 0    ; optimal block size for I/O
      at STAT_STRUC._pad2,          dd 0
      at STAT_STRUC.st_blocks,      dq 0    ; number of 512-byte blocks allocated
      at STAT_STRUC.st_atime,       dq 0    ; last access time secs
      at STAT_STRUC.st_atime_nsec,  dq 0    ; last access time nsecs
      at STAT_STRUC.st_mtime,       dq 0    ; last modification time secs
      at STAT_STRUC.st_mtime_nsec,  dq 0    ; last modification time nsecs
      at STAT_STRUC.st_ctime,       dq 0    ; last status changed time secs
      at STAT_STRUC.st_ctime_nsec,  dq 0    ; last status changed time nsecs
      at STAT_STRUC._unused1,       dq 0
      at STAT_STRUC._unused2,       dq 0
      at STAT_STRUC._unused3,       dq 0
    IEND  

    ; definition macro's for STAT structure

    %define %1.st_dev        %1+STAT_STRUC.st_dev
    %define %1.st_ino        %1+STAT_STRUC.st_ino
    %define %1.st_nlink      %1+STAT_STRUC.st_nlink
    %define %1.st_mod        %1+STAT_STRUC.st_mod
    %define %1.st_uid        %1+STAT_STRUC.st_uid
    %define %1.st_gid        %1+STAT_STRUC.st_gid
    %define %1.st_rdev       %1+STAT_STRUC.st_rdev
    %define %1._pad1         %1+STAT_STRUC._pad1
    %define %1.st_size       %1+STAT_STRUC.st_size
    %define %1.st_blksize    %1+STAT_STRUC.st_blksize
    %define %1._pad2         %1+STAT_STRUC._pad2
    %define %1.st_blocks     %1+STAT_STRUC.st_blocks
    %define %1.st_atime      %1+STAT_STRUC.st_atime
    %define %1.st_atime_nsec %1+STAT_STRUC.st_atime_nsec
    %define %1.st_mtime      %1+STAT_STRUC.st_mtime
    %define %1.st_mtime_nsec %1+STAT_STRUC.st_mtime_nsec
    %define %1.st_ctime      %1+STAT_STRUC.st_ctime
    %define %1.st_ctime_nsec %1+STAT_STRUC.st_ctime_nsec
    %define %1._unused1      %1+STAT_STRUC._unused1
    %define %1._unused2      %1+STAT_STRUC._unused2
    %define %1._unused3      %1+STAT_STRUC._unused3
  %endmacro
    
%elif
    %warning "termio.inc already included"
%endif
