; -----------------------------------
; FOeRTHchen
; Autor: Helmar Wodtke 2005
; Assembler: fasm
; -----------------------------------

usr0:

macro KEY   { call dword [ebx]        }
macro EMIT  { call dword [ebx+v_wemi] }
macro DUP   { call dword [ebx+v_wdup] }
macro NEXT  { ret                     }
macro Dict n,l {
	dd n
	dw l - usr0
}
macro Ccte n,l {
n = $-CCT
	dd l
}

STARTUP
INTERFACE

execu:	xchg eax,edx
	lodsd
	call edx
	jmp next

eoi:	pop dword [ebx]
	pop ebp
	jmp nextd

notfnd:	mov al,"?"
	EMIT
	jmp next

nxword:	call parse.a
	or eax,eax
	jz eoi
find:	mov edx,[ebx+v_edic]
.a:	sub edx,6
	cmp edx,ebx
	jc notfnd
	cmp [edx],eax
	jnz .a
	xor eax,eax
	mov ax,[edx+4]
	cmp ax,dats - usr0
  if ~STATIC
	pushf
	add eax,USER0
	popf
  else
	lea eax,[eax + usr0]
  end if
	jc execu
	push ebp
	push dword [ebx]
	xchg ebp,eax
  if ~STATIC
	mov edx,USER0
	add edx,altkey - usr0
	mov dword [ebx],edx
  else
	mov dword [ebx],altkey
  end if
nextd:	lodsd
next:	KEY
	or eax,eax
	jz eoi
	cmp al,33
	jc nextd
	cmp al, '0'
	jc nxword
	cmp al, '9' + 1
	jnc nxword
	sub al, '0'
.b:	KEY
	xchg eax,ecx
	lodsd
	sub cl, '0'
	jc next
	xor edx,edx
	mov dl,10
	mul edx
	add eax,ecx
	jmp .b

parse:	KEY
	cmp al,33
	jnc .a
	lodsd
	jmp parse
.a:	mov cl,8
.b:	KEY
	xchg eax,edx
	lodsd
	cmp dl,33
	jc .c
	cmp cl,32
	jz .b
	shl edx,cl
	or eax,edx
	add cl,8
	jmp .b
.c:	NEXT


altkey:	DUP
	xor eax,eax
	cmp byte [ebp], ";"
	jz .q
	mov al, byte [ebp]
	inc ebp
.q:	NEXT

; -----------------------------------

dot:	xor ecx,ecx
	push edi
	lea edi,[ecx+10]
.a:	xor edx,edx
	div edi
	push edx
	inc ecx
	or eax,eax
	jnz .a
	lodsd
.b:	DUP
	pop eax
	add al,'0'
	EMIT
	loop .b
	pop edi
	NEXT

words:
  if ~DESTRUCTIVE_EMIT
	DUP
	push esi
	lea esi,[ebx + 4]
.a:	xor ecx,ecx
	mov cl,4
.b:	lodsb
	cmp al,0
	jz .c
	push esi
	EMIT
	pop esi
	loop .b
	inc ecx
.c:	loopz .b
	mov al,32
	EMIT
	dec esi
	dec esi
	cmp esi,[ebx + v_edic]
	jc .a
.q:	pop esi
	lodsd
	NEXT
  else
	DUP
	lea edx,[ebx + 4]
	xchg edx,esi
.a:	xor ecx,ecx
	mov cl,4
.b:	lodsb
	cmp al,0
	jz .c
	xchg edx,esi
	DUP
	EMIT
	xchg edx,esi
	loop .b
	inc ecx
.c:	loopz .b
	xchg edx,esi
	DUP
	mov al,32
	EMIT
	xchg edx,esi
	inc esi
	inc esi
	cmp esi,[ebx + v_edic]
	jc .a
.q:	xchg edx,esi
	lodsd
	NEXT
  end if

defi:	push edi
	mov edi,[ebx + v_edic]
	call parse
	stosd
	pop edx
  if ~STATIC
	mov eax,edx
	sub eax,USER0
  else
	lea eax,[edx - usr0]
  end if
	stosw
	mov [ebx + v_edic],edi
	mov edi,edx
.z:	lodsd
	KEY
	stosb
	cmp al,";"
	jnz .z
w_drop:	lodsd
	NEXT

types:	KEY
	cmp al,'"'
	jz w_drop
	EMIT
	jmp types

w_dup:	sub esi,4
	mov [esi],eax
	NEXT

w_swap:	xchg eax,[esi]
	NEXT

w_to_r:	pop ecx
	push eax
	lodsd
	jmp ecx

w_r_fr:	pop ecx
	DUP
	pop eax
	jmp ecx

w_add:	xchg eax,edx
	lodsd
	add eax,edx
	NEXT

w_mul:	mul dword [esi]
nip:	add esi,4
	NEXT

w_and:	and eax,[esi]
	jmp nip

w_or:	or eax,[esi]
	jmp nip

w_xor:	xor eax,[esi]
	jmp nip

w_dmod:	xchg eax,[esi]
	xor edx,edx
	div dword [esi]
	mov [esi],eax
	xchg eax,edx
	NEXT

comment:
	KEY
	cmp al,")"
	lodsd
	jnz comment
	NEXT

cond:	or eax,eax
	lodsd
	jz comment
econd:	NEXT

gcond:	xchg eax,edx
	lodsd
	cmp edx,eax
	lodsd
	jnc comment
	NEXT

minus1:	DUP
	or eax,-1
	NEXT

fetch:
  if STATIC
	mov eax,[ebx + dats-CCT + eax*4]
  else
	mov edx,CELL0
	mov eax,[edx + eax*4]
  end if
	NEXT

setcl:
  if STATIC
	lea edx,[ebx + dats-CCT + eax*4]
  else
	mov edx,CELL0
	lea edx,[edx + eax*4]
  end if
	lodsd
	mov [edx],eax
	lodsd
	NEXT

; -----------------------------------

CCT_EXT
  if ~STATIC
Ccte v_usr0, usr0
Ccte v_dats, dats
  end if
Ccte v_edic, edic
Ccte v_wdup, w_dup
Ccte v_wemi, emit
CCT:      dd key
Dict "emit", emit
Dict "(.)" , dot
Dict "bye" , bye
Dict "word", words
Dict ":"   , defi
Dict '."'  , types
Dict "dup" , w_dup
Dict "drop", w_drop
Dict "swap", w_swap
Dict ">r"  , w_to_r
Dict "r>"  , w_r_fr
Dict "+"   , w_add
Dict "*"   , w_mul
Dict "/mod", w_dmod
Dict "and" , w_and
Dict "or"  , w_or
Dict "xor" , w_xor
Dict "("   , comment
Dict "if(" , cond
Dict ">if(", gcond
Dict ")els", comment
Dict "els(", econd
Dict ")"   , econd
Dict "-1"  , minus1
Dict "@"   , fetch
Dict "!"   , setcl
