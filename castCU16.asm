IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
	num dw 0ffffh
    str_num db 5 dup(?), '$'

; --------------------------
CODESEG

; first syntax of procedure 
proc casting
; procedure which gets one usigned number in AL register
; and return a string representation of the number in RAM.
; BX register points to start address of the string.
hai:
xor dx,dx
	mov cx,10
	div cx	; ah store the last digit of the number
	add dx,30h                     ; get char of the digit 
	mov [bx], dl                   ;s place last digit
	inc bx
	cmp bx,7
	jnz hai
    ret 
endp casting

;second syntax of procedure
print:
; the procedure print string that bx points on it
; and move the cursor to start place in next line

    mov dx, bx
	mov ah,9h
	int 21h
	mov ah, 2 ; new line
	mov dl,10
	int 21h
	mov dl,13
	int 21h
	ret
; --------------------------
start:
    mov ax, @data
	mov ds, ax
	mov bx, offset str_num
	mov si, offset num
	mov ax, [word ptr si]
	call casting
	call print
	
exit:
	mov ax, 4c00h
	int 21h
END start

