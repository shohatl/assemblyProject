; Author - Maryanovsky Alla
; This program puts star on the middle of display
; and moves it with right button
IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------

CODESEG

proc delay
    push si
	push cx
	
	mov si, 0FFFFH
od:
    mov cx, 5H
odin:
    loop odin
	dec si
	jnz od
	
	pop cx
	pop si
	ret
endp delay	
	
proc put_star
    push ax

	mov ah, 0Ah             ; color        
	mov al, '*'            ; we'll put one star on the screen
	
	mov [es:di], ax        ; [es:di] - logical address; es*16 + di = 20 bit physical address	
	
	pop ax
	ret
endp put_star
	
proc clear_star
    push ax

	mov ah, 0              ; color        
	mov al, ' '            ; we'll put one star on the screen
	
	mov [es:di], ax        ; [es:di] - logical address; es*16 + di = 20 bit physical address	
	
	pop ax
	ret
endp clear_star
	
start:
  	
	mov ax, 0b800h         ; start address of text video memory
	                       ; 80 columns * 25 rows * 2 bytes per character:
						   ; low byte = character code; high byte = attribute (background+color)
	mov es, ax
	
	mov di,  (13*80+39)*2  ; address on the middle of display
	
	
waitfordata:

	
	mov ah, 1                ; check keyboard status 
    int 16h
	je waitfordata           ; keyboard buffer empty, we still waiting for input
	

	
	cmp ah, 1h                ; is it esc button?
	je exit
	
	cmp ah, 4dh             ; is it right button?
	jne waitfordata
	
	
	add di, 2                  ; go right
	
	jmp waitfordata
	
exit:
	mov ax, 4c00h
	int 21h
END start
