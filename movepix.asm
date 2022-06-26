IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
; Your variables here
; --------------------------
CODESEG
proc blackscreen
mov ax,0B800h
mov es,ax
mov al,' '
mov ah,0
mov di,(0*80+0)*2
hi1:
	mov [es:di],ax
	add di,2
	cmp di,(25*80+0)*2
jnz hi1
ret
endp blackscreen

proc movepixup
	mov al,' '
	mov ah,0
	mov [es:di],ax
	mov al,'#'
	mov ah,200
	sub di,160
	mov [es:di],ax
ret
endp movepixup

proc movepixdown
	mov al,' '
	mov ah,0
	mov [es:di],ax
	mov al,'#'
	mov ah,200
	add di,160
	mov [es:di],ax
ret
endp movepixdown

proc movepixright
	mov al,' '
	mov ah,0
	mov [es:di],ax
	mov al,'#'
	mov ah,200
	add di,2
	mov [es:di],ax
ret
endp movepixright

proc movepixleft
	mov al,' '
	mov ah,0
	mov [es:di],ax
	mov al,'#'
	mov ah,200
	sub di,2
	mov [es:di],ax
ret
endp movepixleft
start:
	mov ax, @data
	mov ds, ax
; --------------------------
; Your code here
; --------------------------
mov cl,160
call blackscreen
mov ax,0b800h
mov es,ax
mov di,(12*80+40)*2
mov al,'#'
mov ah,200
mov [es:di],ax
movepix:
	mov ah,0
	int 16h
	cmp al,'w'
	jnz	w
		cmp di,160
		jl w
			call movepixup
	w:
	cmp al,'s'
	jnz s
		cmp di,160*24-1
		ja s
			call movepixdown
	s:
	cmp al,'d'
	jnz d
		mov ax,di
		add ax,2
		div cl
		cmp ah,0
		jz d
			call movepixright
	d:
	cmp al,'a'
	jnz a
		mov ax,di
		div cl
		cmp ah,0
		jz a
			call movepixleft
	a:
	cmp al,'q'
	jz outt
jmp movepix
outt:
exit:
	mov ax, 4c00h
	int 21h
END start


