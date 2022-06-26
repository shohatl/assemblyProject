IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
; Your variables here
	note dw 3837, 40, 3225, 40, 2154, 40, 2281, 40, 3837, 40, 40, 3837, 3225, 40, 2154, 40, 2281, 0 ;17 notes and breaks, control word at end to restart
	timing dd 5 dup (200000), 100000, 200000, 3 dup (100000), 5 dup (200000), 100000, 500000 ;17 timings adjusted for 150 bpm
	message db 'Press any key to exit',13,10,'$'
	
	false equ 0
	timerUp equ [byte ptr es:bx]
; --------------------------
CODESEG
start:
	mov ax, @data
	mov ds, ax
	mov ax,0b800h
	mov es,ax
; --------------------------
; Your code here
	mov bx,0	;prepare for int 15h 83h
	mov si,offset note
	mov di,offset timing	;prepare variables
	; open speaker
	in al,61h
	or al,00000011b
	out 61h,al
; play frequency 
play:
	mov [byte ptr es:bx],0 ;resets timer signal
	cmp [word ptr si],0	; restart tune if we reached the end
	jne keepMusic
		mov si,offset note
		mov di,offset timing
keepMusic:
	
		mov dx,[word ptr di]
		mov cx,[word ptr di + 2]
		mov ax,8300h	;set a timer to the note time, i use this to keep measurable tempo
		int 15h	 	 	;in order to play the music in the tempo i want it to be
				
		mov al,0B6h
		out 43h,al	;send control word to chage frequency
		mov ax,[si]
		out 42h,al
		mov al,ah
		out 42h,al	;send note to speaker
		
		add si,2
		add di,4	;move registers to next value
	
		signaloop:
			mov ah,1
			int 16h	;is there key press
			je noStart
				mov ah,0
				int 16h	;if there is, take it
				jmp endIt
		noStart:
			cmp timerUp,false
			jne play ;if timer is over, play next note
				jmp signaloop
endIt:
; close the speaker
	in al, 61h
	and al, 11111100b
	out 61h, al
;cancel the wait in int 15h 8300, else next run it won't work
	mov ax, 8301h
	int 15h
; --------------------------	
exit:
	mov ax, 4c00h
	int 21h
END start


