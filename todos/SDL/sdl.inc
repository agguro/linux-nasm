;    SDL - Simple DirectMedia Layer
;    Copyright (C) 1997-2012 Sam Lantinga
;
;    This library is free software; you can redistribute it and/or
;    modify it under the terms of the GNU Lesser General Public
;    License as published by the Free Software Foundation; either
;    version 2.1 of the License, or (at your option) any later version.
;
;    This library is distributed in the hope that it will be useful,
;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;    Lesser General Public License for more details.
;
;    You should have received a copy of the GNU Lesser General Public
;    License along with this library; if not, write to the Free Software
;    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
;
;    Sam Lantinga
;    slouken@libsdl.org
;
;    Builded to include file for NASM by Agguro

;  Main include header for the SDL library

%ifndef ASM_SDL_INC
%define ASM_SDL_INC


%include "SDL_main.inc"
%include "SDL_stdinc.inc"
%include "SDL_audio.inc"
%include "SDL_cdrom.inc"
%include "SDL_cpuinfo.inc"
%include "SDL_endian.inc"
%include "SDL_error.inc"
%include "SDL_events.inc"
%include "SDL_loadso.inc"
%include "SDL_mutex.inc"
%include "SDL_rwops.inc"
%include "SDL_thread.inc"
%include "SDL_timer.inc"
%include "SDL_video.inc"
%include "SDL_version.inc"

; SDL.inc
; As of version 0.5, SDL is loaded dynamically into the application

; SDL_INIT Flags
; These are the flags which may be passed to SDL_Init() -- you should
; specify the subsystems which you will be using in your application.

%define SDL_INIT_TIMER          0x00000001
%define SDL_INIT_AUDIO          0x00000010
%define SDL_INIT_VIDEO          0x00000020
%define SDL_INIT_CDROM          0x00000100
%define SDL_INIT_JOYSTICK       0x00000200
%define SDL_INIT_NOPARACHUTE    0x00100000  ; Don't catch fatal signals
%define SDL_INIT_EVENTTHREAD    0x01000000  ; Not supported on all OS's
%define SDL_INIT_EVERYTHING     0x0000FFFF

%elif
%warning "SDL.inc already included"
%endif