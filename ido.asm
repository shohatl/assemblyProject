IDEAL
MODEL small
STACK 100h
DATASEG
vel_x db 0
vel_y db 0
apple_pos_x dw 14
apple_pos_y dw 5
score dw 4
body_pos dw 280Eh, 280Eh, 280Eh

CODESEG

proc random_num
    push bp
    mov bp, sp
    push es
    push bx

    mov bx, 40h
    mov es, bx ;setting up access to clock

randomLoop:
    mov bx, [es:6Ch] ;bx holds the clock's reading
    xor bx, [bx]
    and bx, 1111111111b ;bx between 0 and 2047
    cmp bx, 2000
    ja randomLoop ;bx not in range

    shl bx, 1

    mov ax, bx
    mov bx, [bp + 4]
    div bx ; making the rand num in the requested range

    mov [bp+4], dx ;outputting the random number

    pop bx
    pop es
    pop bp
    ret
endp random_num

proc get_apple_pos

    push bp
    mov bp, sp

    push bx
    push di
    push ax

    zero:
    mov di, [bp + 4]
    mov bx, 24
    push bx
    call random_num ; y
    pop dx
    cmp dx, 0
    jz zero
    mov [word ptr di], dx
    mov ax, dx ; getting al to be y

    mov di, [bp + 6]
    mov bx, 79
    push bx
    call random_num ; x
    pop dx
    mov [word ptr di], dx ; getting apple pos using the random proc and saving it to the apple_pos in storage
    mov ah, dl ; getting ah to be x

    mov bx, [bp + 8] ; body_pos
    mov di, [bp + 10] ; score
    add bx, [di] ; body_pos + [score]
    add bx, 2
    check_loop:
    sub bx, 2
    cmp [word ptr bx], ax
    jz zero
    cmp bx, [bp + 8]
    jnz check_loop ; checking that the body isn't colliding with the new apple spawn point

    pop ax
    pop di
    pop bx

    pop bp
    ret 8
endp get_apple_pos

proc draw_apple
    push bp
    mov bp, sp

    push bx
    push cx
    push dx
    mov bx, [bp + 8]
    mov cx, [word ptr bx] ; x
    mov bx, [bp + 10]
    mov bx, [word ptr bx] ; y

    mov dx, 4000h ; fill
    push bx
    push cx
    push dx
    call draw_px ; drawing apple acoording to y and x coords. drawing in red
    
    pop dx
    pop cx
    pop bx

    pop bp
    ret
endp draw_apple

proc clear_screen
    ; uses int 10h to clear the screen. changes no regs
    push ax

    mov ah, 00
    mov al, 02
    int 10h

    pop ax
    ret
endp clear_screen

proc delay
    push ax
    push bx
    push cx

    mov ax, 0300h
    mov bx, 0
    mov cx, 0
    loop1:
    inc bx
    loop2:
    inc cx
    cmp cx, ax
    jnz loop2
    mov cx, 0
    cmp bx, ax
    jnz loop1 ; nested loops - delaying by incrementing bx and cx until they equal the val in ax. change ax to change delay time

    pop cx
    pop bx
    pop ax
    ret
endp delay

proc draw_px
    ;draws a pixel to the screen
    ; input - y, x, fill
    push bp
    mov bp, sp

    push ax
    push bx
    push cx
    push dx ; saving data to not change any regs
    
    mov dx, [bp + 4] ; fill
    mov cx, [bp + 6] ; x
    mov bx, [bp + 8] ; y

    mov ax, 80
    mul bx
    add ax, cx
    mov bx, 2
    mul bx ; doing the calculation - loc = 2*(y*80+x)
    mov di, ax
    pop dx
    mov [word ptr es:di], dx ; moving the data into the selected loc
    pop cx
    pop bx
    pop ax ; repopping the data to not change everything

    pop bp
    ret 6
endp draw_px

proc draw_body
    push bp
    mov bp, sp

    push ax
    push bx
    push cx
    push dx
    push di

    mov di, [bp + 6]

    mov bx, [bp + 4]
    mov ax, bx
    add bx, [di] ; setting up the end and start addresses of the body_pos array

    draw_body_loop:
    push bx
    mov bx, [bx]
    mov cl, bh
    mov bh, 0
    mov ch, 0
    mov dx, 2000h
    push bx
    push cx
    push dx
    call draw_px ; getting x val into cx, y val into bx, and fill val into dx and calling the draw_px
    pop bx
    sub bx, 2
    cmp bx, ax
    jnz draw_body_loop ; going over the entire body (without head) and drawing it

    pop di
    pop dx
    pop cx
    pop bx
    pop ax

    pop bp
    ret
endp draw_body

proc draw
    push bp
    mov bp, sp

    push bx
    push cx
    push dx
    mov bx, [bp + 10]
    push bx
    mov bx, [bp + 8]
    push bx
    mov bx, [bp + 6]
    push bx
    mov bx, [bp + 4]
    push bx
    call clear_screen
    call draw_body
    mov bx, [bx]
    mov cl, bh
    mov ch, 0
    mov bh, 0
    mov dx, 3000h
    push bx
    push cx
    push dx
    call draw_px ; head draw and setup
    call draw_apple ; calling the drawing-related procs, and also drawing the head

    pop bx
    pop bx
    pop bx
    pop bx
    pop dx
    pop cx
    pop bx

    pop bp
    ret
endp draw

proc add_new_part
    push bp
    mov bp, sp

    push ax
    push bx
    push di

    mov bx, [bp + 6]
    mov bx, [bx]
    add bx, [bp + 4]
    add bx, 2 ; getting the end loc and adding to to target an empty place
    mov ax, [bx-2]
    mov di, [bp + 8]
    sub ah, [byte ptr di]
    mov di, [bp + 10]
    sub al, [byte ptr di]
    mov [bx], ax
    mov bx, [bp + 6]
    add [word ptr bx], 2 ; moving the new val into the new end loc and updating score by 2

    pop di
    pop bx
    pop ax

    pop bp
    ret 8
endp add_new_part

proc checks
    push bp
    mov bp, sp

    push ax
    push bx
    push cx
    push dx

    ; checking for apple collision
    mov bx, [bp + 8]
    mov cx, [bx]
    mov bx, [bp + 10]
    mov dx, [bx] ; getting apple coords
    mov bx, [bp + 4] ; body_pos
    mov bx, [bx]
    mov al, bh
    mov ah, 0
    mov bh, 0 ; getting the head x into ax and head y into bx
    cmp ax, cx
    jnz not_same_1
    cmp bx, dx
    jnz not_same_1
    mov bx, [bp + 6] ; score
    push bx
    mov bx, [bp + 4] ; body_pos
    push bx
    mov bx, [bp + 8] ; apple_x
    push bx
    mov bx, [bp + 10] ; apple_y
    push bx
    call get_apple_pos
    mov bx, [bp + 14] ; vel_y
    push bx
    mov bx, [bp + 12] ; vel_x
    push bx
    mov bx, [bp + 6] ; score
    push bx
    mov bx, [bp + 4] ; body_pos
    push bx
    call add_new_part ; if x and y are the same, get new apple coords and add a new part to the body
    not_same_1:

    pop dx
    pop cx
    pop bx
    pop ax

    pop bp
    ret
endp checks

proc check_keys
    push bp
    mov bp, sp

    push ax
    push di
    push bx

    mov bx, [bp + 14] ; x vel
    mov di, [bp + 16] ; y vel
    mov ax, [bp + 4]

    cmp al, "w"
    jnz not_w
    cmp [byte ptr di], 1
    jz not_w
    mov [byte ptr bx], 0
    mov [byte ptr di], -1 ; up
    not_w:
    cmp al, "s"
    jnz not_s
    cmp [byte ptr di], -1
    jz not_s
    mov [byte ptr bx], 0
    mov [byte ptr di], 1 ; down
    not_s:
    cmp al, "a"
    jnz not_a
    cmp [byte ptr bx], 1
    jz not_a
    mov [byte ptr bx], -1
    mov [byte ptr di], 0 ; left
    not_a:
    cmp al, "d"
    jnz not_d
    cmp [byte ptr bx], -1
    jz not_d
    mov [byte ptr bx], 1
    mov [byte ptr di], 0 ; right
    not_d: ; changing the vels according to the key values

    pop bx
    pop di
    pop ax
    pop bp
    ret 2
endp check_keys

proc move_body
    push bp
    mov bp, sp

    push ax
    push bx
    mov bx, [bp + 6]
    mov bx, [bx]
    mov ax, [bp + 4]
    add bx, [bp + 4] ; setting up the start and end addresses
    
    move_body_loop:
    mov cx, [bx - 2]
    mov [bx], cx ; looping over the body and making each one's loc change to the one next to it (the one closer to the head)

    sub bx, 2
    cmp bx, ax
    jnz move_body_loop ; subbing bx by 2 since it's word sizes and making it go down the entire snake body. jumping if it reaches the snake head (without changing its loc)
    pop bx
    pop ax

    pop bp
    ret
endp move_body

proc move
    push bp
    mov bp, sp
    ; moving the head of the snake acoording to the vel
    push ax
    push bx
    push cx
    push dx ; pushing vals as to not change them
    push di

    mov di, [bp + 4]

    mov ah, 0
    mov si, [bp + 12]
    mov al, [byte ptr si]
    cmp al, -1
    jnz is_neg_x
    mov bx, [di]
    sub bx, 100h
    mov [di], bx
    mov ax, 0 ; checking if the vel_x is neg, in which case we'll sub 100h to sub 1 from the x
    jmp end_x

    is_neg_x:
    push cx
    mov cx, 100h
    mul cx
    add [di], ax
    div cx
    pop cx  ; multiplying the vel by 100h so that it can be added to the x loc

    end_x:
    mov ah, 0
    mov si, [bp + 14]
    mov al, [byte ptr si] 
    cmp al, -1
    jnz is_neg_y
    mov bx, [di]
    dec bx
    mov [di], bx
    mov ax, 0 ;doing the same thing as neg x values earlier
    jmp end_y

    is_neg_y:
    add [di], ax ; adding the vel to cx if it isn't neg

    end_y:
    pop di
    pop dx
    pop cx
    pop bx
    pop ax ; popping vals back

    pop bp
    ret
endp move

proc update ; calls the procs procs related to updating the game
    push bp
    mov bp, sp

    push bx
    mov bx, [bp + 14] ; vel_y
    push bx
    mov bx, [bp + 12] ; vel_x
    push bx
    mov bx, [bp + 10] ; apple_y
    push bx
    mov bx, [bp + 8] ; apple_x
    push bx
    mov bx, [bp + 6] ; score
    push bx
    mov bx, [bp + 4] ; body_pos
    push bx
    push bx ; redundant
    call get_keys
    call check_keys
    call check_bounds
    call move_body
    call move
    call delay
    call clear_screen
    call checks
    call body_collision
    pop bx
    pop bx
    pop bx
    pop bx
    pop bx
    pop bx
    pop bx

    pop bp
    ret
endp update

proc body_collision
    ; checks to see if any part of the snake is colliding with the body
    push bp
    mov bp, sp
    push ax
    push bx

    mov bx, [bp + 4]
    mov bx, [bx]
    mov ax, bx
    mov bx, [bp + 6]
    mov bx, [bx]
    cmp bx, 4
    jz start_of_game
    add bx, [bp + 4] ; setting up the addresses for the loop

    collision_check_loop:
    cmp [bx], ax
    jnz not_exit
    call jmp_exit
    not_exit:
    sub bx, 2
    cmp bx, [bp + 4]
    jnz collision_check_loop ; looping and comparing body locs to head loc. If true, jmp to exit
    start_of_game:
    pop bx
    pop ax
    pop bp
    ret
endp body_collision   

proc get_keys
    push bp
    mov bp, sp
    push bx
    mov  ah, 0Bh
    int  21h
    cmp  al, 0 ; checking to see if any key is pressed
    je noInput ; add if you want it to refresh a lot
    mov ah,1h
    int 21h
    cmp al, "Q" ; checking if the exit key is pressed
    jnz noInput
    call jmp_exit ;Collecting input and saving it to cl to store it later
    noInput:
    mov [bp + 4], ax
    pop bx
    pop bp
    ret
endp get_keys

proc check_bounds
    ; checks if the head of the snake is touching the bounds
    push bp
    mov bp, sp

    push ax
    push bx

    mov bx, [bp + 4]
    mov ax, [bx]
    cmp al,0
    jnz lvl2
    mov bx, [bp + 14]
    cmp [byte ptr bx], -1
    jz exit
    lvl2:
    cmp ah, 0
    jnz lvl22
    mov bx, [bp + 12]
    cmp [byte ptr bx], -1
    jz exit
    lvl22:
    cmp al, 25
    jz exit
    cmp ah, 80
    jz exit ; checking the x and y coords to see if they touch the bounds

    pop bx
    pop ax

    pop bp
    ret
endp check_bounds
proc jmp_exit
    jmp exit
    ret
endp jmp_exit
start:
    mov ax, @data
    mov ds, ax
    mov ax, 0b800h
    mov es, ax
    push offset vel_y
    push offset vel_x
    push offset apple_pos_y
    push offset apple_pos_x
    push offset score
    push offset body_pos
    shloop:
    call update
    call draw

    jmp shloop

exit:
    mov si, 100h
    call clear_screen
    mov ax, 4c00h
    int 21h
END start