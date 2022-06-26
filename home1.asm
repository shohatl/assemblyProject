IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
; Your variables here

; --------------------------
CODESEG
start:
	mov ax, @data
	mov ds, ax
; --------------------------
; Your code here
hi:
	mov si,0h
	mov al,[si]
	cmp al,'$'
	jz hai
		and al,11111011b
		or al,00100000b
		mov [si],al
		inc si
		jmp hi
	hai:
; --------------------------
	
exit:
	mov ax, 4c00h
	int 21h
END start


