IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
; Your variables here
db 0,1
; --------------------------
CODESEG
proc hai
mov al,[bx]
add al,[bx+1]
mov [bx+2],al
inc bx
ret
endp hai
start:
	mov ax, @data
	mov ds, ax
; --------------------------
; Your code here
; --------------------------
xor bx,bx
ha:
	call hai
	cmp bx,10
jnz ha
exit:
	mov ax, 4c00h
	int 21h
END start


