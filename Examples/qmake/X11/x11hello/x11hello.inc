%ifndef _X11HELLO_INC_
%define _X11HELLO_INC_

%include "unistd.inc"
extern XOpenDisplay
extern XCreateSimpleWindow
extern XSelectInput
extern XMapWindow
extern XNextEvent
extern XFillRectangle
extern XDrawString
extern XCloseDisplay

%define ExposureMask 1 << 15
%define KeyPressMask 1 << 0
%define Expose  12
%define KeyPress 2

%define HEIGHT 250
%define WIDTH  600

;the XDisplay structure is derived from Xlib.h
struc XDISPLAY
    .unknown1:              resq    1   ;  0 XExtData* hook for extension to hang data
    .private1:              resq    1   ;  8 struct _XPrivate*
    .fd:                    resd    1   ; 10 int Network socket
    .private2:              resd    1   ; 14 int
    .proto_major_version:   resd    1   ; 18 int - major version of server's X protocol
    .proto_minor_version:   resd    1   ; 1C int - minor version of servers X protocol
    .vendor:                resq    1   ; 20 char* - vendor of the server hardware
    .private3:              resq    1   ; 28 XID
    .private4:              resq    1   ; 30 XID
    .private5:              resq    1   ; 38 XID
    .private6:              resd    1   ; 40 int
    .resource_alloc:        resq    1   ; 44 XID - allocator function struct _XDisplay*
    .byte_order:            resd    1   ; 4C int - screen byte order, LSBFirst, MSBFirst
    .bitmap_unit:           resd    1   ; 50 int - padding and data requirements
    .bitmap_pad:            resd    1   ; 54 int - padding requirements on bitmaps
    .bitmap_bit_order:      resd    1   ; 58 int - LeastSignificant or MostSignificant
    .nformats:              resd    1   ; 5C int - number of pixmap formats in list
    .pixmap_format:         resq    1   ; 60 ScreenFormat* - pixmap format list
    .private8:              resd    1   ; 68 int
    .release:               resd    1   ; 6C int release of the server
    .private9:              resq    1   ; 70 struct _XPrivate*
    .private10:             resq    1   ; 78 struct _XPrivate*
    .qlen:                  resd    1   ; 80 Length of input event queue
    .last_request_read:     resq    1   ; 84 seq number of last event read
    .request:               resq    1   ; 8C sequence number of last request
    .private11:             resq    1   ; 94 XPointer
    .private12:             resq    1   ; 9C XPointer
    .private13:             resq    1   ; A4 XPointer
    .private14:             resq    1   ; AC XPointer
    .max_request_size:      resd    1   ; B4 maximum number 32 bit words in request
    .db:                    resq    1   ; B8 struct _XrmHashBucketRec*
    .private15:             resq    1   ; C0 int* - struct _XDisplay*
    .display_name:          resq    1   ; C8 char* - "host:display" string used on this connect
    .default_screen:        resd    1   ; D0 int - default screen for operations
    .nscreens:              resd    1   ; D4 int - number of screens on this server
    .screens:               resq    1   ; D8 Screen* - pointer to list of screens
    .motion_buffer:         resq    1   ; E0 size of motion buffer
    .private16:             resq    1   ; E8
    .min_keycode:           resd    1   ; F0 minimum defined keycode
    .max_keycode:           resd    1   ; F4 maximum defined keycode
    .private17:             resq    1   ; F8 XPointer
    .private18:             resq    1   ; 100 XPointer
    .private19:             resd    1   ; 108 int
    .xdefaults:             resq    1   ; 10C char* - contents of defaults from server
    ;there is more to this structure, but it is private to Xlib
endstruc

struc SCREEN
    .ext_data:          resq    1   ;XExtData* - hook for extension to hang data
    .display:           resq    1   ;struct _XDisplay* - back pointer to display structure
    .root:              resq    1   ;Window - Root window id.
    .width:             resd    1   ;int - width of screen
    .height:            resd    1   ;int - height of screen
    .mwidth:            resd    1   ;int width of  in millimeters
    .mheight:           resd    1   ;int height of  in millimeters
    .ndepths:           resd    1   ;int - number of depths possible
    .depths:            resq    1   ;Depth* - list of allowable depths on the screen
    .root_depth:        resd    1   ;int - bits per pixel
    .root_visual:       resq    1   ;Visual* - root visual
    .default_gc:        resq    1   ;GC - GC for the root root visual
    .cmap:              resq    1   ;Colormap - default color map
    .white_pixel:       resq    1   ;unsigned long - White pixel values
    .black_pixel:       resq    1   ;unsigned long - Black pixel values
    .max_maps:          resd    1   ;int - max color maps
    .min_maps:          resd    1   ;int - min color maps
    .backing_store:     resd    1   ;int - Never, WhenMapped, Always
    .save_unders:       resd    1   ;Bool
    .root_input_mask:   resd    1   ;long - initial root input mask
endstruc


%endif
