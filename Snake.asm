IDEAL
MODEL small
STACK 100h
DATASEG
; ----------------------------
; your variables here
; ----------------------------
CODESEG
appleL dw ?
HeadPlace dw ?
LastMove db ?
numOfAddedBody dw 2
;-----------------------------------------------------
proc Black_Screen
;input - none
;output - black screen
;---------------------------
	push ax		;start black box 
	push di
;---------------------------
	mov di, 0			
	mov al, ' '
	mov ah, 0			;black pixel
	
Bloop:
	mov [es:di], ax		;inputs the black pixel into the current pixel
	
	add di, 2			;increases di in order to go to the next pixel
	cmp di, 4000		; checks if all the screen is black
jne Bloop
;---------------------------	
	pop di				;end black box
	pop ax
;---------------------------	
	
ret 
endp Black_Screen
;-----------------------------------------------------
;input - none
;output - delay
proc Delay
;---------------------------
	push ax		;start black box 
	push cx
;---------------------------	
	mov ax, 0c000h		;large num to delay loop
	mov cx, 50			;cx*ax
OutLoop:
		
	InLoop:			
		dec ax		;dec c000 til 0
		cmp ax, 0
	jne InLoop
		
loop OutLoop			;dec cx
;---------------------------	
	pop ax		;end black box
	pop cx
;---------------------------	
ret
endp Delay
;-----------------------------------------------------
;input - none
;output - prints star on screen (chosen location)
proc Put_Star
;---------------------------
	push ax		;start black box 
;---------------------------	
	mov al, 'O'		;char
	mov ah, 02		;attribute
	
	mov [es:di], ax		;put pixel into di
;---------------------------
	pop ax		;end black box
;---------------------------
ret
endp Put_Star
;-----------------------------------------------------
;input - none
;output - deletes a chosen pixel 
proc Del_pixel
;---------------------------
	push ax		;start black box 
;---------------------------	
	mov al, ' '			;space
	mov ah, 0			;black
	
	mov [es:di], ax		;put black pixel into di
;---------------------------	
	pop ax		;end black box 
;---------------------------
ret
endp Del_pixel
;-----------------------------------------------------
proc Up

push bp
mov bp, sp
	push di
	
	mov di, [bp+4]
	cmp di, 160
	jnl SkipU		;upper border	0-160
	jmp exit
	SkipU:
		call Del_pixel 		
		mov [lastmove], -160
		sub di, 160		;Up
		mov [bp+4], di
		call Put_star
	
pop di
pop bp

ret
endp Up
;-----------------------------------------------------
proc Down
push bp
mov bp, sp
	push di
	mov di, [bp+4]
 
	cmp di, 3840
	jnae SkipD		;lower border 3840-4000
	jmp exit
	SkipD:
		call Del_pixel
		mov [lastmove], 160
		add di, 160		;Down
		mov [bp+4], di
		call Put_star	

pop di
pop bp	

ret
endp Down
;-----------------------------------------------------
proc Left
;---------------------------
push bp
mov bp, sp
	push ax			;start black box
	push cx
	push di 
;---------------------------
	mov di, [bp+4]
	mov	cl, 160
	mov ax, di
	
	div	cl			;the trait of the left border is that if you add 2 to them they always divide by 160
	cmp ah, 0
	jne SkipL		;left border
	jmp exit
	SkipL:
		call Del_pixel
		mov [lastMove], -2
		sub di, 2			;Left
		mov [bp+4], di
		call Put_star
		
;---------------------------	
	pop di
	pop cx 			;end black box
	pop ax
pop bp
;---------------------------	
ret
endp Left
;-----------------------------------------------------
proc Right
;---------------------------
push bp
mov bp, sp
	push ax			;start black box
	push cx
	push di
;---------------------------	
	mov di, [bp+4]
	mov cl, 160
	mov ax, di
	add ax, 2
	div cl 		;the trait of the right border is that they always divide by 160
	cmp ah, 0
	jne SkipR			;right border
	jmp exit
	SkipR:
		call Del_pixel 
		mov [LastMove], 2
		add di, 2			;Right
		
		
		mov [bp+4], di
		call Put_star
	
;---------------------------	
	pop di
	pop cx			;end black box
	pop ax 
pop bp
;---------------------------
ret
endp Right
;-----------------------------------------------------
;input: none
;output: RNG
proc RNG	 ;problem (?)
	
push bp		
mov bp, sp		;SS access
;---------------------------	
	push ax
	push dx			;start black box
	push bx	
	push cx
;---------------------------	
	mov cx, 2
	mov ah, 0
	int 1ah		;pc clock
	
	mov ax, dx	;clock inputs into dx, then the program into ax
	mul cx 		;doubles the num bcz we need an even num
	mov bx, 4000	
	div bx	; we divide the clock num by 4000
	
	mov [bp+4], dx	;we input the module num from before into si(in procedure apple) 
;---------------------------
	pop cx
	pop bx
	pop dx			;end black box
	pop ax
;---------------------------
pop bp
ret
endp RNG
;-----------------------------------------------------
;input - none
;output - none 
proc apple   
;---------------------------
push ax
push si
push bx
;---------------------------
	Again:
	push si 
	call RNG		;RNG
	pop si
	
	mov bx, [es:si]
	mov [appleL] , si ; the place of the apple
	cmp bx, ' ' 	  ;if the apple is located in black pixel then proceed. else return and cmp again
	jne Again
	mov al, 'Q'		;apple shape
	mov ah, 04		;apple color
	
	mov [es:si], ax	;we put the apple into a random place (the RNG goes to si)
	
;---------------------------
pop bx
pop si
pop ax
;---------------------------
ret
endp apple

proc eat_apple

push bp
mov bp, sp
push di

	mov di, [bp+4]
	cmp di, [appleL]		; if the snake is in the same location of the apple then call an apple 
	jne Looop	
	call apple
	Looop:

pop di
pop bp
ret
endp eat_apple

start:
	mov ax, @data
	mov ds, ax
; ----------------------------
; your code here
; ----------------------------

	mov ax, 0b800h
	mov es, ax
	
	call Black_Screen 

	mov di, (12*80+42)*2
	mov di, (12*80+40)*2
	mov di, (12*80+38)*2
	
	mov al, 'O'
	mov ah, 02
	mov [es:di], ax
	call apple
;-----------------------------------Move Snake-----------------------------------
MoveLoop:
	mov ah, 0
	int 16h
	
	MoveStill:
	cmp al, 'w'
	jne Con1
	LU:
		cmp [lastmove], 160
		je LD
		push di
		call up					;move pixel up
		pop di
		mov [HeadPlace], di		;sets the new place of the head
		call delay				;delay the loops
		push di					;blackbox
		call eat_apple			;makes changes if the conditions are true
		pop di					;blackbox
		mov ah, 1
		int 16h
	je LU
	Con1:
	cmp al, 's'
	jne Con2
	LD:
		cmp [lastmove], -160
		je LU
		push di
		call down				;move pixel down
		pop di
		mov [HeadPlace], di		;sets the new place of the head
		call delay				;delay the loops
		push di					;blackbox
		call eat_apple			;makes changes if the conditions are true
		pop di					;blackbox
		mov ah, 1
		int 16h
	je LD
	con2:
	cmp al, 'a'
	jne Con3
	LL:
		cmp [lastmove], 2
		je LR
		push di
		call left				;move pixel left
		pop di
		mov [HeadPlace], di		;sets the new place of the head
		call delay				;delay the loops
		push di					;blackbox
		call eat_apple			;makes changes if the conditions are true
		pop di					;blackbox
		mov ah, 1
		int 16h
	je LL
	con3:
	cmp al, 'd'
	jne Con4
	LR:
		cmp [lastmove], -2
		je LL
		push di
		call right				;move pixel right
		pop di
		mov [HeadPlace], di		;sets the new place of the head
		call delay				;delay the loops
		push di					;blackbox
		call eat_apple			;makes changes if the conditions are true
		pop di					;blackbox
		mov ah, 1		
		int 16h
	je LR	
	Con4:
	cmp al, 'm'			;Move out of loop
	jne Next
		jmp exit
	Next:
	jmp MoveLoop

;-----------------------------------Move Snake-----------------------------------		
			
exit:
	mov ax, 4c00h
	int 21h
END start
