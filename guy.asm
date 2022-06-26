IDEAL
MODEL small
STACK 100h
DATASEG
head_place dw (12*80+40)*2
CODESEG
;making the screen for play
proc Screen
push di
push ax
push si
mov di,0
Jump:
	mov [es:di],ax
	add di,2
	cmp di,(24*80+80)*2
jnz Jump
	mov di,[offset head_place]
	mov al,'*'
	mov ah,200
	mov [es:di],ax	
pop si
pop ax
pop di
ret
endp Screen

proc delay
push bx
	xor bx,bx
	hiii:
		hii:
			inc bx
			cmp bx,25h
		jnz hii
		xor bx,bx
	loop hiii
pop bx
	ret
endp delay

proc Move
push di
push ax
push si
waiting_data:
	call delay
	mov ah,1
	int 16h
	
	je waiting_data1

	mov ah,0
	int 16h
	waiting_data1:
	cmp al,'w'
	je moveup
	cmp al,'s'
	je movedown
	cmp al,'a'
	je moveleft
	cmp al,'d'
	je moveright
	cmp al,'q'
	je exit_game1
	
jmp waiting_data

	moveup:
	push ax
	push di
	mov di,[offset head_place]
	cmp di,160	;limit of up
	jl exit_game1
	call CleanPix
	sub di,160
	call For_ax
	mov [es:di],ax
	mov [offset head_place],di
	pop di
	pop ax
	jmp waiting_data
	
	movedown:
	push ax
	mov di,[offset head_place]
	cmp di,24*160-2	;limit of down
	ja exit_game1
	call CleanPix
	add di,160
	call For_ax
	mov [es:di],ax
	mov [si],di
	pop ax
	jmp waiting_data
	
	exit_game1:
	jmp exit_game2

	moveleft:
	push ax
	mov ax,[offset head_place]	
	mov cl,160	;limit of up
	div cl
	cmp ah,0	
	jl exit_game1
	call CleanPix
	mov di,[offset head_place]
	sub di,2
	call For_ax
	mov [es:di],ax
	mov [si],di
	pop ax
	jmp waiting_data
	
	moveright:
	push ax
	mov ax,[offset head_place]
	add ax,2
	mov cl,160
	div cl
	cmp ah,0
	jl exit_game1
	call CleanPix
	mov di,[offset head_place]
	add di,2
	call For_ax
	mov [es:di],ax
	mov [si],di
	pop ax
	jmp waiting_data
		
exit_game2:
pop si
pop ax
pop di
ret
endp Move

proc CleanPix
push ax
push di
	mov di,[offset head_place]
	mov al,' '
	mov ah,0
	mov [es:di],ax
pop di
pop ax
ret
endp CleanPix

proc For_ax
	mov al,'*'
	mov ah,200
ret
endp For_ax
start:
	mov ax, @data
	mov ds, ax
	mov ax,0b800h
	mov es,ax
	mov al,' '
	mov ah,0
	mov si,offset head_place
	call Screen
	call Move
exit:
	mov ax, 4c00h
	int 21h
END start