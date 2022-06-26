IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
	
     db 3 dup(3,7), '$'
     dw 3 dup(3,7), '$'
num  db -1
     dw 10b, 10, 10h

; --------------------------
CODESEG

start:
    mov ax, @data
	mov ds, ax
	mov bx, offset num
	mov al, [bx+3]
	mov ah, [bx+4]
	
exit:
	mov ax, 4c00h
	int 21h
END start

