.286 
.model small
.stack 100h
.data
.code

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; draw a single pixel specific to Mode 13h (320x200 with 1 byte per color)

drawPixel:
	color EQU ss:[bp+4] 
	x1 EQU ss:[bp+6]
	y1 EQU ss:[bp+8]

	push	bp
	mov	bp, sp
				; using ax but not pushing it
	push	bx
	push	cx
	push	dx
	push	es ; extra segment register

	; set ES as segment of graphics frame buffer ~ in the extra segment, put the starting address of the video buffer to Mode 13h
	mov	ax, 0A000h ; a000:000
	mov	es, ax ; cannot use immediate directly


	; BX = ( y1 * 320 ) + x1
	mov	bx, x1 ; move the value of x1 into bx
	mov	cx, 320 ; move 320 into cx
	xor	dx, dx ; set dx to 0
	mov	ax, y1 ; move the value of y1 into ax
	mul	cx ; multiply cx by what is in ax and store it in ax = 320 * y1 ~ DX:AX AX is 16 bits = 64k = 65536 
	add	bx, ax ; add bx and ax and store it in bx

	; DX = color
	mov	dx, color ; dx is made up of dh and dl ~ color is dl because the lower is filled first

	; plot the pixel in the graphics frame buffer
	mov	BYTE PTR es:[bx], dl ; starting from the address of the es ; move dl to address of bx ;  BYTE PTR is specify the type being moved

	pop	es
	pop	dx
	pop	cx
	pop	bx

	pop	bp

	ret	6 ; pushed 3 arguements which are word sized ~ 6 bytes

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

start:
	; initialize data segment
	mov ax, @data
	mov ds, ax

	; set video mode - 320x200 256-color mode
	mov ax, 4F02h
	mov bx, 13h
	int 10h

	;;;;;; Code to draw pixels ;;;;;

	push 125 ; y
	push 25 ; x
	push 02h ; color
    call drawPixel

	push 190 ; y
	push 25 ; x
	push 03h ; color
	call drawPixel
	
	push 125 ; y
	push 25  ; x
	push 04h ; color
	call drawPixel

	push 125 ; y
	push 225 ; x
	push 05h ; color
	call drawPixel

	push 125 ; y 
	push 25 ; x
	push 06h ; color
	call drawPixel

	push 25 ; y
	push 125 ; x
	push 07h ; color
	call drawPixel

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End of Program ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	; prompt for a key ~ take as input a character ~ make a pause ~ wait for character input
	mov ah, 0 
	int 16h

	; switch back to text mode
	mov ax, 4f02h
	mov bx, 3
	int 10h
	; exit the program
	mov ax, 4C00h
	int 21h
	; end the program
END start