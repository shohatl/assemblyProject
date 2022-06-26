IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
; Your variables here
apple_place dw 2000
pix_place dw (12*80+39)*2,(12*80+40)*2,(12*80+41)*2
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
	mov cx,04455h
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
push si
push di
	mov si,offset apple_place
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
pop si
pop es
pop ax
ret
endp apple

;input - the pixels location(ds:pix_place),the direction the snake is going(es:bp+2)
;output - the new location of the snake(ds:pix_place)
;prints the new location of the snake
proc movepix
push ax
push es
push si
push di
push cx
	mov si,offset pix_place
	mov di,[si+4]
	mov ax,0B800h
	mov es,ax
	mov al,' '
	mov ah,0
	mov [es:di],ax
	mov ax,[si+2]
	mov [si+4],ax
	mov ax,[si]
	mov [si+2],ax
	mov di,[bp+2]
	add ax,di
	mov [si],ax
	
	mov cx,2
	mov ax,0B800h
	mov es,ax
	mov al,'@'
	mov ah,08h
	mov di,[si]
	mov [es:di],ax
	mov al,'@'
	mov ah,04h
	add si,2
	print_pix:
		mov di,[si]
		mov [es:di],ax
		add si,2
	loop print_pix
pop cx	
pop di
pop si
pop es
pop ax
ret
endp movepix


start:
	mov ax, @data
	mov ds, ax
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Your code here
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
push ax
push bp
mov bp,sp	;the direction the point is going
call blackscreen
;prints the snake for the first time on the screen
mov cx,2
mov ax,0B800h
mov es,ax
mov si,offset pix_place
mov al,'@'
mov ah,08h
mov di,[si]
mov [es:di],ax
mov al,'@'
mov ah,04h
add si,2
print_pixx:
mov di,[si]
mov [es:di],ax
add si,2
loop print_pixx

mov si,offset pix_place		;will help us check if the first pix has hit a border
movepixx:
	mov ah,1
	int 16h
	jne skip	;waits for a input (char)
		call apple
		jmp movepixx
	skip:
	mov ah,0
	int 16h
	
	cmp al,'w'	;moves snake up
	jnz w
		waitw:	;moves up until there is a new input(char)
		mov ax,[si]
		cmp ax,160	;if it reaches to the edge then the pixel will stop moving
		jl w
			call delay
			mov ah,1
			int 16h
			jne w
			mov ax,-160
			mov [bp+2],ax
			call movepix
			call apple
			call delay
			mov ah,1
			int 16h
			je waitw
	w:
	cmp al,'s'	;moves snake down
	jnz s
		waits:	;moves down until there is a new input(char)
		mov ax,[si]
		cmp ax,160*24-1	;if it reaches to the edge then the pixel will stop moving
		ja s
			call delay
			mov ah,1
			int 16h
			jne s
			mov ax,160
			mov [bp+2],ax
			call movepix
			call apple
			call delay
			mov ah,1
			int 16h
			je waits
	s:
	cmp al,'d'	;moves snake right
	jnz d
		waitd:	;moves to the right until there is a new input(char)
		mov ax,[si]
		mov cl,160
		add ax,2
		div cl
		cmp ah,0	;if it reaches to the edge then the pixel will stop moving
		jz d
			call delay
			mov ah,1
			int 16h
			jne d
			mov ax,2
			mov [bp+2],ax
			call movepix
			call apple
			call delay
			mov ah,1
			int 16h
			je waitd
	d:
	cmp al,'a'	;moves snake left
	jnz a
		waita:	;moves to the left until there is a new input(char)
		mov ax,[si]
		mov cl,160
		div cl
		cmp ah,0	;if it reaches to the edge then the pixel will stop moving
		jz a
			call delay
			mov ah,1
			int 16h
			jne a
			mov ax,-2
			mov [bp+2],ax
			call movepix
			call apple
			call delay
			mov ah,1
			int 16h
			je waita
	a:
	cmp al,'q'	;if the input is "q" the the program will end
	jz stop
jmp movepixx
stop:
exit:
	mov ax, 4c00h
	int 21h
END start


