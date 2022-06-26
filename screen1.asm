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
	cmp di,(24*80+79)*2
jnz hi1
mov di,(12*80+40)*2
mov ah,200
mov [es:di],ax
ret
endp blackscreen

proc delay
mov ax,0B800h
mov es,ax
mov al,' '
mov ah,0
mov di,(0*80+1)*2
hi2:
	mov [es:di],ax
	add di,2
	cmp di,(23*80+79)*2
jnz hi2
mov di,(12*80+40)*2
mov ah,200
mov [es:di],ax
mov di,(24*80+1)*2
mov cx,0ffffh
xor bx,bx
hiii:
	hii:
		inc bx
		cmp bx,1000h
	jnz hii
	xor bx,bx
loop hiii
mov di,(24*80+0)*2
mov al,' '
mov ah,200
hi3:
	mov [es:di],ax
	add di,2
	cmp di,(25*80+0)*2
jnz hi3
ret
endp delay
start:
	mov ax, @data
	mov ds, ax
; --------------------------
; Your code here
; --------------------------
call blackscreen
call delay
exit:
	mov ax, 4c00h
	int 21h
END start


