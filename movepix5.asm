IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
; Your variables here
end_snake db 0
apple_place dw 4000
pix_num dw 2 ;needs to be number of pix-1 because proc apple adds one
pix_place dw (12*80+39)*2,(12*80+40)*2,(12*80+41)*2	;the location of the pixels
;it needs yo be last because every time it eats a apple his size increases by one
; --------------------------
CODESEG
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;no input
;no output
;makes a delay
proc delay
	push cx
	push bx
	mov cx,9999h
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
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;input - ds:apple_place,pix_num
;output - ds:apple_place ;if the snake ate an apple ds:pix_num increases by one
;prints a apple on the screen if there isn't a apple on the screen,increases the number of pixels in the snake if it ate an apple
proc apple
push ax
push es
push si
push cx
push di
push bx

	mov si,offset apple_place	;checks if there is a apple on the screen
	mov di,[si]
	mov ax,0B800h
	mov es,ax
	mov ax,[es:di]
	cmp ah,0eh
	mov di,ax	;helps us later in the random
	jz outt	;doesn't print a new apple if there is one on the screen
	
	mov si,offset pix_num	;adds another pixel to the snake because it ate an apple
	mov bx,[si]
	inc bx
	mov [si],bx 
	
	mov ax,40h
	mov es,ax
	notvalid:
		mov ax,[es:6Ch]	;gets a number from the timer
		mul ax
		xor di,ax		;makes it even more random
		and di,0000011111111111b	;2047
		cmp di,1999		;checks if the number is a actual pixel on the screen
	ja notvalid
	shl di,1	;changes to the pixels place
	
	mov ax,0B800h	;checks if it is on a "empty" (black) pixel
	mov es,ax
	mov ax,[es:di]
	cmp ah,0
	jne notvalid
	
	mov si,offset apple_place	;saves the new location of the apple (saves it in ds:apple_place)
	mov [si],di		;the place of the apple
	
	mov al,160	;prints the apple on the screen
	mov ah,0eh
	mov [es:di],ax
	
	outt:
pop bx
pop di
pop cx
pop si
pop es
pop ax
ret
endp apple
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

proc check_move

	mov si,offset pix_place		;checks if the snake is going to hit itself
	mov ax,0B800h
	mov es,ax
	mov di,[si]
	add di,[ss:100h]
	mov ax,[es:di]
	cmp al,'@'
	jnz continue
	mov si,offset end_snake
	mov [byte ptr si],1
	jmp lose
	continue:

; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;input - the pixels location(ds:pix_place),the direction the snake is going(es:100h),the number how pixel in the snake(ds:pix_num)
;output - the new location of the snake(ds:pix_place)
;prints the new location of the snake
proc movepixup
push ax
push es
push si
push di
push cx
push bx

	mov si,offset pix_place		;checks if the snake is going to hit itself
	mov ax,0B800h
	mov es,ax
	mov di,[si]
	add di,[ss:100h]
	mov ax,[es:di]
	cmp al,'@'
	jnz continue
	mov si,offset end_snake
	mov [byte ptr si],1
	jmp lose
	continue:
	
	mov si,offset pix_num
	mov bx,[si]		;gets the number of pixels -1 (cx), the location of the last pix after the pointer (bx)
	dec bx	;needs to be -1 because the pointer points to the first number
	mov cx,bx
	shl bx,1	;needs to be times two because it is a word and not a byte
	
	mov si,offset pix_place		;delets the last pix
	mov di,[si+bx]
	mov al,' '
	mov ah,0
	mov [es:di],ax
	
	change:		;changes the pixels location
	push [si+bx-2]
	pop [si+bx]
	sub bx,2
	loop change
	
	mov ax,[si]		;changes the first pixel location
	mov di,[ss:100h]
	add ax,di
	mov [si],ax
	
	mov si,offset pix_place		;prints the first pixel
	mov al,'@'
	mov ah,08h
	mov di,[si]
	mov [es:di],ax
	
	lose:
pop bx
pop cx	
pop di
pop si
pop es
pop ax
ret
endp movepix
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
start:
	mov ax, @data
	mov ds, ax
; --------------------------
; Your code here
; --------------------------
exit:
	mov ax, 4c00h
	int 21h
END start


