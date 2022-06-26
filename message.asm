IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
; Your variables here
dir dw 0	;the direction of the snake
endgame dw 0	;0 if he didnt lose and 1 if he lost
apple_place dw 4000	;the current location of the apple
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
		cmp di,4000
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
	hiii:
		xor bx,bx
		hii:
			inc bx
			cmp bx,50h
		jnz hii
	loop hiii

pop bx
pop cx
ret
endp delay
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;input - the place of the apple (bp+12)
;output - new location of apple (bp+12) ;if the snake ate an apple ((bp+10) increases by one
;prints a apple on the screen if there isn't a apple on the screen,increases the number of pixels in the snake if it ate an apple
proc apple
push bp
mov bp,sp
push ax
push es
push si
push cx
push di
push bx

	mov si,[bp+12]	;checks if there is an apple on the screen	(apple_place)
	mov di,[si]	;the location of the apple
	mov ax,0B800h
	mov es,ax
	mov ax,[es:di]
	cmp ah,0eh	;the color of a apple
	jz outt	;doesn't print a new apple if there is one on the screen
	
	mov si,[bp+10]	;adds another pixel to the snake because it ate an apple	(pix_num)
	mov bx,[si]
	inc bx
	mov [si],bx 
	
	mov ax,40h
	mov es,ax
	notvalid:
		mov ax,[es:6Ch]	;gets a number from the timer
		xor di,ax		;makes it even more random
		and di,0000011111111111b	;2047
		cmp di,1999		;checks if the number is a actual pixel on the screen
	ja notvalid
	shl di,1	;changes to the pixels place
	
	mov ax,0B800h	
	mov es,ax
	mov ax,[es:di]		;checks if it is on a "empty" (black) pixel
	cmp ah,0	;the color of an empty tile
	jne notvalid
	
	mov si,[bp+12]	;saves the new location of the apple	(apple_place)
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
pop bp
ret
endp apple
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;input - the pixels location (bp+8), the direction the snake is going (bp+4), the number how pixel in the snake (bp+10)
;output - the new location of the snake (bp+8), if the snake lost (bp+6)
;prints the new location of the snake
proc movepix
push bp
mov bp,sp
push ax
push es
push si
push di
push cx
push bx

	mov ax,0B800h
	mov es,ax
	mov si,[bp+8]		;checks if the snake is going to hit itself (pix_place)
	mov di,[si]
	mov si,[bp+4]	;(dir)
	add di,[si]		;the new location of the first pixel
	mov ax,[es:di]
	cmp al,'@'	;checks if there is going to be an overlay
	jnz continue	;if it hits itself it wont move
	mov si,[bp+6]	;(endgame)
	mov [word ptr si],1
	jmp endmove
	continue:
	
	mov si,[bp+10]	;(pix_num)	gets the number of pixels -1 (cx)
	mov bx,[si]		; the location of the last pix after the pointer (bx)
	dec bx	;needs to be -1 because the pointer points to the first number
	mov cx,bx
	shl bx,1	;needs to be times two because it is a word and not a byte
	
	mov si,[bp+8]		;delets the last pix	(pix_place)
	mov di,[si+bx]
	mov al,' '
	mov ah,0
	mov [es:di],ax
	
	change:		;changes the pixels location
	push [si+bx-2]
	pop [si+bx]
	sub bx,2
	loop change
	
	mov si,[bp+4]	;(dir)
	mov di,[si]
	mov si,[bp+8]	;(pix_place)
	add di,[si]		;changes the first pixel location
	mov [si],di	;saves the new location of the first pixel
	
	mov al,'@'	;prints the first pixel
	mov ah,08h	
	mov [es:di],ax
	
	endmove:
	
pop bx
pop cx	
pop di
pop si
pop es
pop ax
pop bp
ret
endp movepix
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;input - first pixel place (bp+8)
;output - if the snake lost (bp+6), new direction (bp+4)
;moves the snake up
proc up
push bp
mov bp,sp
push ax
push si

	mov si,[bp+8]	;(pix_place)
	mov ax,[si]
	cmp ax,159	;if it reaches to the edge then the user will lose	(last byte of the last pixel in row 1)
	ja edge_up
		mov si,[bp+6]	;(endgame)
		mov [word ptr si],1
		jmp end_up
	edge_up:
	
				mov ax,-160		;moves the snake up
				
				mov si,[bp+4]	;the direction	(new direction)	(dir)
				mov [si],ax	;saves the direction	(dir)
				
	end_up:
	
pop si
pop ax
pop bp
ret
endp up
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;input - first pixel place (bp+8)
;output - if the snake lost (bp+6), new direction (bp+4)
;moves the snake down
proc down
push bp
mov bp,sp
push ax
push si

	mov si,[bp+8]	;(pix_place)
	mov ax,[si]
	cmp ax,3839	;if it reaches to the edge then the user will lose	(last byte of the last pixel in row 24)
	jl edge_down
		mov si,[bp+6]	;(endgame)
		mov [word ptr si],1
		jmp end_down
	edge_down:
		
			mov ax,160		;;moves the snake down
			
			mov si,[bp+4]	;the direction	(new direction)	(dir)
			mov [si],ax	;saves the direction	(dir)
			
	end_down:
	
pop si
pop ax
pop bp
ret
endp down
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;input - first pixel place (bp+8)
;output - if the snake lost (bp+6), new direction (bp+4)
;moves the snake right
proc right
push bp
mov bp,sp
push ax
push si

	mov si,[bp+8]	;(pix_place)
	mov ax,[si]
	mov cl,160
	add ax,2
	div cl
	cmp ah,0	;if it reaches to the edge then the user will lose
	jnz edge_right
		mov si,[bp+6]	;(endgame)
		mov [word ptr si],1
		jmp end_right
	edge_right:

			mov ax,2	;moves the snake right
			
			mov si,[bp+4]	;the direction	(new direction)	(dir)
			mov [si],ax	;saves the direction	(dir)
			
	end_right:
	
pop si
pop ax
pop bp
ret
endp right
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;input - first pixel place (bp+8)
;output - if the snake lost (bp+6), new direction (bp+4)
;moves the snake left
proc left
push bp
mov bp,sp
push ax
push si

	mov si,[bp+8]	;(pix_place)
	mov ax,[si]
	mov cl,160
	div cl
	cmp ah,0	;if it reaches to the edge then the user will lose
	jnz edge_left
		mov si,[bp+6]	;(endgame)
		mov [word ptr si],1
		jmp end_left
	edge_left:

			mov ax,-2		;moves the snake left
			
			mov si,[bp+4]	;the direction	(new direction)	(dir)
			mov [si],ax	;saves the direction	(dir)
			
	end_left:
	
pop si
pop ax
pop bp
ret
endp left
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

start:
	mov ax, @data
	mov ds, ax
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Your code here
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
call blackscreen	;makes the screen black
mov cx,3	;prints the snake for the first time on the screen
mov ax,0B800h
mov es,ax
mov si,offset pix_place
mov al,'@'	;the char of the snake
mov ah,08h	;the color of the snake
mov di,[si]
print_pixx:
	mov di,[si]
	mov [es:di],ax
	add si,2
loop print_pixx		;prints the pixels

push offset apple_place		;(bp+12)	will help us later
push offset pix_num			;(bp+10)
push offset pix_place		;(bp+8)
push offset endgame			;(bp+6)
mov si,offset dir			;(bp+4)
push si
mov bx,offset endgame
	
call apple	;prints a apple on the screen for the first time

waitforfirstinput:	;the snake cannot move left after he "spawns" because his body is there
	mov ah,0
	int 16h
	cmp al,'d'
jnz waitforinput
jmp waitforfirstinput
newinput:
	mov ah,0
	int 16h
	waitforinput:
	

	
	cmp al,'w'	;moves snake up
	jnz w
		cmp [si],160	;checks if he can physically move
		jz go_s
			go_w:
			mov al,'w'	;changes the last button pressed to 'w'
			call up
	w:
	
	cmp al,'s'	;moves snake down
	jnz s
		cmp [si],-160	;checks if he can physically move
		jz go_w
			go_s:
			mov al,'s'	;changes the last button pressed to 's'
			call down
	s:

	cmp al,'d'	;moves snake right
	jnz d
		cmp [si],-2	;checks if he can physically move
		jz go_a
			go_d:
			mov al,'d'	;changes the last button pressed to 'd'
			call right
	d:
	
	cmp al,'a'	;moves snake left
	jnz a
		cmp [si],2	;checks if he can physically move
		jz go_d
			go_a:
			mov al,'a'	;changes the last button pressed to 'a'
			call left
	a:
	
	cmp al,'q'	;if the input is "q" the the program will end
		jz stop
	
	
	call movepix
	
	cmp [word ptr bx],1	;if he touched himself or on of the borders then he will lose
	jz stop

	call apple	;puts an apple if there isnt one
	call delay	;puts a delay because the user needs to see the snake move
	
	mov ah,1	;checks for new input
	int 16h
	je waitforinput
jmp newinput
stop:
pop si
pop si
pop si
pop si
pop si
exit:
	mov ax, 4c00h
	int 21h
END start


