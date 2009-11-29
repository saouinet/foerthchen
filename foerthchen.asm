; -----------------------------------
; FOeRTHchen
; Autor: Helmar Wodtke 2005
; Assembler: fasm
; -----------------------------------

format ELF executable

entry start

DCELLS = 100
STATIC = 1
DESTRUCTIVE_EMIT = 0

	USER0 equ usr0

macro STARTUP {
start:	mov esi,stck
	mov edi,dats + DCELLS * 4
	mov ebx,CCT
	push ebx
	push bye
	jmp next
} ; /STARTUP

macro INTERFACE {

key:	push ecx
	push ebx
	push eax
	DUP
	xor eax,eax
	DUP
	mov ecx,esi
	mov al,3
	jmp sys1

bye:	xor eax,eax
	inc eax
sys1:	xor ebx,ebx
sysc:	push edx
	xor edx,edx
	inc edx
	int 80h
	pop edx
	pop eax
	pop ebx
	lodsd
	pop ecx
	ret

emit:	push ecx
	push ebx
	push eax
	mov ecx,esp
	xor ebx,ebx
	inc ebx
	xor eax,eax
	mov al,4
	jmp sysc

} ; /INTERFACE

macro CCT_EXT {}

include "core.asm"

edic:	rd 1024 * 8    ; place for 1024 word definitions
dats:	rd   32 * 1024 ; data & stack are 32K
stck:	rd  100 * 4    ; stack underflow reserve
