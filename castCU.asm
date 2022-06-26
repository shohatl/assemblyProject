IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
	num db 255
    str_num db 3 dup(?), '$'

; --------------------------
CODESEG

; first syntax of procedure 
proc casting
; procedure which gets one usigned number in AL register
; and return a string representation of the number in RAM.
; BX register points to start address of the string.
hai:
	xor ah, ah
	mov cl,10
	div cl                         ; ah store the last digit of the number
	add ah,30h                     ; get char of the digit 
	mov [bx], ah                   ; place last digit
	inc bx
	cmp bx,4
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
	mov al, [si]
	call casting
	call print
	
exit:
	mov ax, 4c00h
	int 21h
END start

