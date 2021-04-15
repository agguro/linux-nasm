%ifndef _DYNAMIC_INC_
%define _DYNAMIC_INC_

%include "unistd.inc"
%include "sharedlib.inc"

extern  _GLOBAL_OFFSET_TABLE_
extern  printf                   ;function from libc
extern  glib_major_version       ;variable from libg

;global functions
global  getversion:function
global  getversionstring1:function
global  getversionstring2:function
global  printversionstring1:function
global  printversionstring2:function

;data accessable from the mainprogram
global  versionstring1:data (versionstring1.len)

%endif
