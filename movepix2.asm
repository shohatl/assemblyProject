IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
; Your variables here
apple_place dw 2000
; --------------------------
CODESEG
;no input
;no output
;prints on the screen blacks
proc blackscreen
	push ax
	push di
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
	pop di
	pop ax
ret
endp blackscreen

;no input
;no output
;makes a delay
proc delay
	push cx
	push bx
	mov cx,0aaaah
		xor bx,bx
		hiii:
			hii:
				inc bx
				cmp bx,50h
			jnz hii
			xor bx,bx
		loop hiii
	pop bx
	pop cx
ret
endp delay

;input - ds:apple_place
;output - ds:apple_place
;prints a apple on the screen if there isn't a apple on the screen
proc apple
	push ax
	push es
	push di
	mov di,[si]
	mov ax,0B800h
	mov es,ax
	mov ax,[es:di]
	pop di
	cmp al,160	;checks if there is a apple on the screen
	jz outt
	mov ax,40h
	mov es,ax
notvalid:
	mov ax,[es:6Ch]
	and ax,0000011111111111b	;2047
	cmp ax,1999		;check if the number is a actual number
	ja notvalid
	rol ax,1
	cmp di,ax
	je notvalid
	push di
	mov di,ax
	mov [si],di		;the place of the apple
	mov ax,0B800h
	mov es,ax
	mov al,160
	mov ah,0eh
	mov [es:di],ax		;prints the apple
	
pop di
	outt:
pop es
pop ax
ret
endp apple

;input - the place of the pixel (di)
;output -  di-160
;moves the pixel up
proc movepixup
push ax
	mov al,' '
	mov ah,0
	mov [es:di],ax
	mov al,'@'
	mov ah,04h
	sub di,160
	mov [es:di],ax
pop ax
ret
endp movepixup

;input - the place of the pixel (di)
;output -  di+160
;moves the pixel down
proc movepixdown
push ax
	mov al,' '
	mov ah,0
	mov [es:di],ax
	mov al,'@'
	mov ah,04h
	add di,160
	mov [es:di],ax
pop ax
ret
endp movepixdown

;input - the place of the pixel (di)
;output -  di+2
;moves the pixel to the right
proc movepixright
push ax
	mov al,' '
	mov ah,0
	mov [es:di],ax
	mov al,'@'
	mov ah,04h
	add di,2
	mov [es:di],ax
pop ax
ret
endp movepixright

;input - the place of the pixel (di)
;output -  di+2
;moves the pixel to the left
proc movepixleft
push ax
	mov al,' '
	mov ah,0
	mov [es:di],ax
	mov al,'@'
	mov ah,04h
	sub di,2
	mov [es:di],ax
	pop ax
ret
endp movepixleft
start:
	mov ax, @data
	mov ds, ax
; --------------------------
; Your code here
; --------------------------
mov si,offset apple_place
call blackscreen
mov ax,0b800h
mov es,ax
mov di,(12*80+40)*2
mov al,'@'
mov ah,04h
mov [es:di],ax
movepix:
	mov ah,1
	int 16h
	jne skip	;waits for a input (char)
		call apple
		jmp movepix
	skip:
	mov ah,0
	int 16h
	
	cmp al,'w'
	jnz w
		waitw:	;moves up until there is a new input(char)
		cmp di,160	;if it reaches to the edge then the pixel will stop moving
		jl w
			call delay
			mov ah,1
			int 16h
			jne w
			call movepixup
			call apple
			call delay
			mov ah,1
			int 16h
			je waitw
	w:
	cmp al,'s'
	jnz s
		waits:	;moves down until there is a new input(char)
		cmp di,160*24-1	;if it reaches to the edge then the pixel will stop moving
		ja s
			call delay
			mov ah,1
			int 16h
			jne s
			call movepixdown
			call apple
			call delay
			mov ah,1
			int 16h
			je waits
	s:
	cmp al,'d'
	jnz d
		waitd:	;moves to the right until there is a new input(char)
		mov cl,160
		mov ax,di
		add ax,2
		div cl
		cmp ah,0	;if it reaches to the edge then the pixel will stop moving
		jz d
			call delay
			mov ah,1
			int 16h
			jne d
			call movepixright
			call apple
			call delay
			mov ah,1
			int 16h
			je waitd
	d:
	cmp al,'a'
	jnz a
		waita:	;moves to the left until there is a new input(char)
		mov cl,160
		mov ax,di
		div cl
		cmp ah,0	;if it reaches to the edge then the pixel will stop moving
		jz a
			call delay
			mov ah,1
			int 16h
			jne a
			call movepixleft
			call apple
			call delay
			mov ah,1
			int 16h
			je waita
	a:
	cmp al,'q'	;if the input is "q" the the program will end
	jz stop
jmp movepix
stop:
exit:
	mov ax, 4c00h
	int 21h
END start


