IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
; Your variables here
; --------------------------
;=============================================
;=============================================
filename db 'benji.bmp',0
filehandle dw ?
Header db 54 dup (0)
Palette db 256*4 dup (0)
ScrLine db 320 dup (0)
ErrorMsg db 'Error', 13, 10,'$'
;=============================================
;=============================================

SQU_SIZE dw 8 ;size of one color (8x8 pixels)

CODESEG

proc blackback
push di
push cx

mov di,(76+23*320)
mov cx,150

lopforveri:
push cx
mov cx,150
lopforhorii:
mov [byte ptr es:di],0
inc di
loop lopforhorii
pop cx
add di,320-150
loop lopforveri

pop cx
pop di
			
				
				ret
				endp blackback
;this procdure draw a signle square.
proc squ ;input:di (location),ax (color),SUQ_SIZE (size of square). output:none.
push bp
mov bp,sp
push di
push cx
push ax

mov di,[bp+4]
mov cx,[bp+6]
mov ax,[bp+8]

loforver:
push cx
push di
mov cx,[bp+6]
lopforhori:
mov [es:di],al
inc di
loop lopforhori
pop di
pop cx
add di,320
loop loforver

pop ax
pop cx
pop di
pop bp

		ret 6
		endp squ
		
		
		
;==========================================================================================
;==========================================================================================
proc OpenFile
; Open file
mov ah, 3Dh
xor al, al
mov dx, offset filename
int 21h
jc openerror
mov [filehandle], ax

ret
openerror:
mov dx, offset ErrorMsg
mov ah, 9h
int 21h
ret
endp OpenFile
;==========================================================================================


;==========================================================================================
proc ReadHeader
; Read BMP file header, 54 bytes
mov ah,3fh
mov bx, [filehandle]
mov cx,54
mov dx,offset Header
int 21h
ret
endp ReadHeader
;==========================================================================================


;==========================================================================================
proc ReadPalette
; Read BMP file color palette, 256 colors * 4 bytes (400h)
mov ah,3fh
mov cx,400h
mov dx,offset Palette
int 21h
ret
endp ReadPalette
;==========================================================================================


;==========================================================================================
proc CopyPal
; Copy the colors palette to the video memory
; The number of the first color should be sent to port 3C8h
; The palette is sent to port 3C9h
mov si,offset Palette
mov cx,256
mov dx,3C8h
mov al,0
; Copy starting color to port 3C8h
out dx,al
; Copy palette itself to port 3C9h
inc dx
PalLoop:
; Note: Colors in a BMP file are saved as BGR values rather than RGB.
mov al,[si+2] ; Get red value.
shr al,2 ; Max. is 255, but video palette maximal
; value is 63. Therefore dividing by 4.
out dx,al ; Send it.
mov al,[si+1] ; Get green value.
shr al,2
out dx,al ; Send it.
mov al,[si] ; Get blue value.
shr al,2
out dx,al ; Send it.
add si,4 ; Point to next color.
; (There is a null chr. after every color.)

loop PalLoop
ret
endp CopyPal
;==========================================================================================


;==========================================================================================
proc CopyBitmap
; BMP graphics are saved upside-down.
; Read the graphic line by line (200 lines in VGA format),
; displaying the lines from bottom to top.
mov ax, 0A000h
mov es, ax
mov cx,200
PrintBMPLoop:
push cx
; di = cx*320, point to the correct screen line
mov di,cx
shl cx,6    ;*64
shl di,8    ;*256  ;       256+64 = 320
add di,cx
; Read one line to variable ScrLine (buffer)
mov ah,3fh  
mov cx,320
mov dx,offset ScrLine
int 21h
; Copy one line into video memory
cld ; Clear direction flag, for movsb for inc si, inc di
mov cx,320
mov si,offset ScrLine

rep movsb ; Copy line to the screen
 ;rep movsb is same as the following code:
 ;mov es:di, ds:si
 ;inc si
 ;inc di
 ;dec cx
 ;loop until cx=0

pop cx
loop PrintBMPLoop
ret
endp CopyBitmap
;==========================================================================================
;==========================================================================================	
start:
	mov ax, @data
	mov ds, ax
		mov ax, 13h ;grahpic mode
	int 10h
	mov ax,0a000h
	mov es,ax

; --------------------------
; Your code here
; --------------------------

;============================================
;upload your BPM here ! :)
; Process BMP file
call OpenFile
call ReadHeader
call ReadPalette
call CopyPal
call CopyBitmap
;============================================

call blackback


mov ah,0
mov di,(80+27*320)
mov cx,16

lopforli:


push cx
push di
mov cx,16
lopforsqu:

push ax
push [SQU_SIZE]
push di
call squ
add di,320*9 ;squ_size +1 ---> 8+1=9
inc al
loop lopforsqu
pop di
pop cx
add di,9 ;squ_size +1 ---> 8+1=9

loop lopforli


mov ah,00h
int 16h
exit:
	; Back to text mode
mov ah, 0
mov al, 2
int 10h
	mov ax, 4c00h
	int 21h
END start


