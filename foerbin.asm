; -----------------------------------
; FOeRTHchen
; Autor: Helmar Wodtke 2005
; Assembler: fasm
; -----------------------------------

use32

org 0

DCELLS = 10
STATIC = 0
DESTRUCTIVE_EMIT = 1
	USER0 equ dword [ebx + v_usr0]
	CELL0 equ dword [ebx + v_dats]

macro STARTUP {

start:	pusha
	mov eax,CCT
	call .a
.a:	pop edx
	sub edx,.a
	lea esi,[edx + stck]
	lea edi,[edx + dats]
	lea ecx,[edx + bye ]
	mov [edx + eax + v_oebx], ebx
	lea ebx,[edx + eax]
	mov [ebx + v_usr0],edx
	lea eax,[edx + edic]
	mov [ebx + v_edic],eax
	lea eax,[edx + w_dup]
	mov [ebx + v_wdup],eax
	lea eax,[edx + emit]
	mov [ebx + v_wemi],eax
	lea eax,[edx + key]
	mov [ebx],eax
	mov [ebx + v_olds],esp
	mov [ebx + v_dats],edi
	add edi,DCELLS * 4
	push ecx
	push ecx
	jmp next

} ; /STARTUP

macro INTERFACE {

emit:	push ecx
	mov ecx,v_emit
iface:	push ebp
	push ebx
	push edx
	push edi
	mov edx,ebx
	mov ebx,[edx + v_oebx]
	call dword [edx + ecx]
	pop edi
	pop edx
	pop ebx
	pop ebp
	pop ecx
	ret

key:	push ecx
	mov ecx,v_getk
	jmp iface

bye:	mov esp,[ebx + v_olds]
	popa
	ret

} ; /INTERFACE

macro CCT_EXT {

v_olds = $-CCT
	dd 0
v_oebx = $-CCT
	dd 0
v_getk = $-CCT
	dd 0
v_emit = $-CCT
	dd 0

} ; /CCT_EXT

include "core.asm"

edic:	rb  200 * 6    ; place for 200 word definitions
dats:	rb    5 * 1024 ; data & stack are 5K
stck:	rb  100 * 4    ; stack underflow reserve
