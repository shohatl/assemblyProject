IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
; Your variables here
list dw 7,4,1,8,5,8,9,0,3,2,5,7,1,2
list_end dw ?
; --------------------------
CODESEG
; input - si - first num location, dx - word after last number
;output - the smallest number location in the list (bx)
;gets the location of the smallest number
proc min
push bp
mov bp,sp
push dx
push si	
push bx	
push ax
push cx

	mov dx,sp
	mov si,[bp+8]	;list_end
	mov bx,[bp+4]	;gets the number of how many numbers are we checking	(si)
	put_next:	;moves the list into ss
		mov ax,[bx]
		push ax
		add bx,2
		cmp bx,si	;(list_end)
	jnz put_next
	
	mov cx,dx	;get the number of how many numbers there are
	sub cx,sp
	sar cx,1	;the number of how many numbers there are in the list
	
	pop ax		;gets the first number we are going to check
	mov dx,cx	;dx will save the location of the smallest number in the list
	dec cx
	
	compare_min:	;gets the smallest number location in the list
		pop bx
		cmp bx,ax
		jnl next_num	;if the number is smaller than it will be saved in ax and it's location in dx
		mov ax,bx
		mov dx,cx
		next_num:
	loop compare_min
	dec dx	;-1 becuse the first number is location 0
	shl dx,1	;gets the smallest number location in the ds(converts it to words)
	mov bx,dx
	add bx,[bp+4]	;(si)
	mov [bp+6],bx	;(bx)

pop cx
pop ax
pop bx
pop si
pop dx
pop bp
ret
endp min

;input - the smallest number location(bx), the first number location(si)
;output - swaps between the first number and the smallest number
;swaps the smallest with the first number in the list 
proc swap
push bp 
mov bp,sp
push ax
push dx
push si	
push bx 


	mov si,[bp+4]	;the location of the first number
	mov bx,[bp+6]	;the location of the smallest number
	mov ax,[bx]	
	mov dx,[si]		;the location of the first num in the chain
	mov [si],ax		;swaps between the numbers
	mov [bx],dx
	
pop bx
pop si
pop dx
pop ax
pop bp
ret
endp swap
start:
	mov ax, @data
	mov ds, ax
; --------------------------
; Your code here
mov si,offset list
mov dx,offset list_end
push dx		;(bp+8)
sub dx,2
orderize:	;puts the numbers from smallest to biggest
	push bx	;(bp+6)
	push si	;(bp+4)
	call min
	call swap
	pop si
	pop bx
	add si,2
	cmp si,dx
jnz orderize
; --------------------------
pop dx
exit:
	mov ax, 4c00h
	int 21h
END start


