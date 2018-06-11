; Richard Bromley 5001075854
; CS218 1001
; Assignment #10

;*******************************************************************************
;   Procedure: getRadii
;	Gets, checks, converts, and returns command line arguments.

;   Procedure spirograph()
;	Plots provided function
;*******************************************************************************

;	MACROS (if any) GO HERE


;*******************************************************************************

section  .data

;*******************************************************************************
;  Define standard constants.

TRUE		equ	1
FALSE		equ	0

SUCCESS		equ	0			; successful operation
NOSUCCESS	equ	1

STDIN		equ	0			; standard input
STDOUT		equ	1			; standard output
STDERR		equ	2			; standard error

SYS_read	equ	0			; code for read
SYS_write	equ	1			; code for write
SYS_open	equ	2			; code for file open
SYS_close	equ	3			; code for file close
SYS_fork	equ	57			; code for fork
SYS_exit	equ	60			; code for terminate
SYS_creat	equ	85			; code for file open/create
SYS_time	equ	201			; code for get time

LF		    equ	10
SPACE		equ	" "
NULL		equ	0
ESC		    equ	27

; -----
;  OpenGL constants

GL_COLOR_BUFFER_BIT	equ	16384
GL_POINTS           equ	0
GL_POLYGON          equ	9
GL_PROJECTION		equ	5889

GLUT_RGB            equ	0
GLUT_SINGLE         equ	0

; -----
;  Define constants.

R1_MIN		equ	1
R1_MAX		equ	250			; FA(16) = 250

R2_MIN		equ	1			; 3(10) = 10(3)
R2_MAX		equ	250			; FA(16) = 250

OP_MIN		equ	1			; 3(10) = 10(3)
OP_MAX		equ	250			; FA(16) = 250

X_OFFSET	equ	320
Y_OFFSET	equ	240

;*******************************************************************************
;  Local variables for getRadii procedure.
;*******************************************************************************

STR_LENGTH	equ	12

ddSixteen	dd	16

errUsage	db	"Usage: SPIRO -r1 <hex number> -r2 <hex number> "
		    db	"-op <hex number> -cl <b/g/r/y/w>"
		    db	LF, NULL

errBadCL	db	"Error, invalid or incomplete command line argument."
		    db	LF, NULL

errR1sp		db	"Error, radius 1 specifier incorrect."
		    db	LF, NULL

errR1value	db	"Error, radius 1 value must be between 1 and FA(16)."
		    db	LF, NULL

errR2sp		db	"Error, radius 2 specifier incorrect."
		    db	LF, NULL

errR2value	db	"Error, radius 2 value must be between 1 and FA(16)."
		    db	LF, NULL

errOPsp		db	"Error, offset position specifier incorrect."
		    db	LF, NULL

errOPvalue	db	"Error, offset position value must be between 1 and FA(16)."
		    db	LF, NULL

errCLsp		db	"Error, color specifier incorrect."
		    db	LF, NULL

errCLvalue	db	"Error, c (color) value must be b, g, r, or w. "
		    db	LF, NULL

;*******************************************************************************
;  Local variables for spirograph routine.
;*******************************************************************************

radii		dq	0               ; tmp location for (radius1+radius2)
t           dq	0.0             ; loop variable
step		dq	0.1             ; step
x           dq	0               ; current x
y          	dq	0               ; current y
offset		dq	0.0

cycle		dq	0.0
rad2        dq  0.0

tmp        	dq	0.0

red         dd	0			; 0-255
green		dd	0			; 0-255
blue		dd	0			; 0-255

section  .text
;*******************************************************************************
; Open GL routines.
;*******************************************************************************

extern glutInit, glutInitDisplayMode, glutInitWindowSize, glutInitWindowPosition
extern glutCreateWindow, glutMainLoop
extern glutDisplayFunc, glutIdleFunc, glutReshapeFunc, glutKeyboardFunc
extern glutSwapBuffers
extern gluPerspective
extern glClearColor, glClearDepth, glDepthFunc, glEnable, glShadeModel
extern glClear, glLoadIdentity, glMatrixMode, glViewport
extern glTranslatef, glRotatef, glBegin, glEnd, glVertex3f, glColor3f
extern glVertex2d, glVertex2i, glColor3ub, glOrtho, glFlush
extern	cos, sin

;*******************************************************************************
;   Procedure getRadii()
;	Gets radius 1, radius 2, offset position and color code
;	letter from the line argument.

;	Performs error checking, converts ASCII/Hex to integer.
;	Command line format (fixed order):
;	"-r1 <hex number> -r2 <hex number> -op <hex number> -cl <color>"
;*******************************************************************************
;  Arguments:
;	1) ARGC, double-word, value  [rdi]
;	2) ARGV, double-word, address [rsi]
;	3) Radius 1, double-word, address [rdx]
;	4) Radius 2, double-word, address [rcx]
;	5) Position, double-word, address [r8]
;	6) circle color, byte, address [r9]
;*******************************************************************************

global getRadii
getRadii:
push        rbp
mov         rbp, rsp        ;store rsp location

push        rbx             ; save rbx

cmp         rdi, 1
jne         uppercount
mov         rdi, errUsage
call        printString     ; user didn't enter command line arguments
mov         rax,FALSE
jmp         complete

uppercount:
cmp         rdi,9
je          propercount

mov         rdi, errBadCL
call        printString     ; if there aren't nine entries print an error
mov         rax,FALSE
jmp         complete

propercount:
mov         rdi, qword [rsi]        ; load second entry, first being execution
                                ; command

call        parseNext               ; don't care about executable name

mov         eax, dword [rdi]
cmp         eax, 31722dh            ; -r1 director
je          grabR1

mov         rdi, errR1sp
call        printString     ; -r1 entry failure
mov         rax,FALSE
jmp         complete

grabR1:
call        parseNext       ; point to numeric entry
call        getInteger      ; rdi redirected by parseNext

cmp	        al, 0
je	        errorR1
cmp	        al, 0xfa
ja	        errorR1
cmp         ah, SUCCESS
je          loadR1

errorR1:
mov         rdi, errR1value
call        printString     ; -r1 value failure
mov         rax,FALSE
jmp         complete

loadR1:
mov         dword [rdx],eax ;return r1 value

call        parseNext
mov         eax,dword [rdi]
cmp         eax,32722dh
je          grabR2          ; -r2 director

mov         rdi, errR2sp
call        printString     ; -r2 entry failure
mov         rax,FALSE
jmp         complete

grabR2:
call        parseNext       ; point to numeric entry
call        getInteger      ; rdi redirected by parseNext

cmp	        al, 0
je	        errorR2
cmp	        al, 0xfa
ja	        errorR2
cmp         ah, SUCCESS
je          loadR2

errorR2:
mov         rdi, errR2value
call        printString     ; -r1 value failure
mov         rax,FALSE
jmp         complete

loadR2:
mov         dword [rcx],eax ;return r2 value

call        parseNext
mov         eax,dword [rdi]
cmp         eax,706f2dh
je          grabOp          ; check -op director

mov         rdi, errOPsp
call        printString     ; -op entry failure
mov         rax,FALSE
jmp         complete

grabOp:
call        parseNext       ; point to numeric entry
call        getInteger      ; rdi redirected by parseNext

cmp	        al, 0
je	        errorOP
cmp	        al, 0xfa
ja	        errorOP
cmp         ah, SUCCESS
je          loadOp

errorOP:
mov         rdi, errOPvalue
call        printString     ; -r1 value failure
mov         rax,FALSE
jmp         complete

loadOp:
mov         dword [r8],eax  ; return op value

call        parseNext
mov         eax,dword [rdi]
cmp         eax,6c632dh
je          grabCl          ; check for -cl

mov         rdi, errCLsp
call        printString     ; -cl entry failure
mov         rax,FALSE
jmp         complete


grabCl:
call        parseNext       ; point to numeric entry
mov         al, byte [rdi]

cmp         al, 0x52        ; try upper R if so make lower r
jne         trylowerR
mov         rax,0x72

trylowerR:
cmp         al, 0x72
je          loadCl

cmp         al, 0x47        ; try upper G if so make lower g
jne         trylowerG
mov         rax, 0x67

trylowerG:
cmp         al, 0x67
je          loadCl

cmp         al, 0x42        ; try upper B if so make lower b
jne         trylowerB
mov         rax,0x62

trylowerB:
cmp         al, 0x62
je          loadCl          ; determine if color valid

cmp         al, 0x57        ; try upper w if so make lower w
jne         trylowerW
mov         rax,0x77

trylowerW:
cmp         al, 0x77
je          loadCl          ; determine if color valid

mov         rdi, errCLvalue
call        printString     ; -r1 value failure
mov         rax,FALSE
jmp         complete

loadCl:
mov         byte [r9], al   ;return color value
mov         rax,TRUE

complete:
pop         rbx

mov         rsp, rbp        ;store rsp location
pop         rbp
ret

;*******************************************************************************
;  This function gets an integer from a string in rdi register
;  It returns an dword integer in the eax register
;
;*******************************************************************************
global getInteger
getInteger:

push        rbx

mov         rax, 0
mov         rbx, 0
mov         bl, byte [rdi]

zeroEntry:                  ;ignore leading zeros and spaces
inc         rdi
cmp         bl, 20h             ;space character
je          zeroEntry

call    grabNibble
cmp         bl, 0
je          zeroEntry

mov         ax, bx              ;allow for two nibbles of data

mov         bl, byte [rdi]
cmp         bl, NULL
je          oneNibble
call        grabNibble

shl         al,4
or          ax,bx          ; a NOSUCCESS previous or now is uncompromised

oneNibble:
pop         rbx
ret

;*******************************************************************************
;  Parse the next entry.
; This routine seeks out the next NULL character to pass the next
; string in the rdi register.
;*******************************************************************************
global parseNext
parseNext:

push        rax

findnext:
mov         al, [rdi]
cmp         al, NULL
je          passnext
inc         rdi
jmp         findnext        ; a NULL will exist somewhere even during
                      ; a faulty call

passnext:
inc         rdi

pop         rax
ret

;*******************************************************************************
;   grabNibble
;   Covert ascii value in bl to four bits or a nibble of integer data.
;   return conversion status bh register...
;*******************************************************************************
global grabNibble
grabNibble:

cmp         bl, 40h
ja          alpha

sub         bl, 30h
cmp         bl, 0
jl          error
jmp         done

alpha:
cmp         bl, 60h
ja          lowercase
sub         bl, 37h
cmp         bl, 0fh
ja          error
jmp         done

lowercase:
sub         bl, 57h
cmp         bl, 0fh
ja          error
jmp         done

error:
mov         bh, NOSUCCESS ;anything above F or below 0
jmp         loadresult

done:
mov         bh,SUCCESS   ;The value seems valid

loadresult:
ret

;*******************************************************************************
;   Spirograph Procedure.

;	Plot the following spirograph equations:
;	for (t=0.0; t<360.0; t+=0.1) {
;		x = ( (r1+r2) * cos(t) ) + ( op * cos((r1+r2) * t/r2) );
;		y = ( (r1+r2) * sin(t) ) + ( op * sin((r1+r2) * t/r2) ); }
;	The loop will iterate 3600 times.
;*******************************************************************************
;  Color Code Conversion:
;	'r' -> red=255, green=0, blue=0
;	'g' -> red=0, green=255, blue=0
;	'b' -> red=0, green=0, blue=255
;	'w' -> red=255, green=255, blue=255
;*******************************************************************************
;  Variables Accessed:

common	radius1		1:4			; radius 1, dword, integer value
common	radius2		1:4			; radius 2, dword, integer value
common	position	1:4			; offset position, dword, integer value
common	color		1:1			; color code letter, byte, ASCII value

;*******************************************************************************
global spirograph
spirograph:

push        rbp
mov         rbp, rsp        ;store rsp location

mov         rax, 0
mov         eax, dword [radius1]
cvtsi2sd    xmm0, rax             ;convert radius1 to 64 bit float

mov         eax, dword [radius2]
cvtsi2sd    xmm1, rax             ;convert radius2 to 64 bit float
movsd       qword [rad2], xmm1

addsd       xmm0, xmm1
movsd       qword [radii], xmm0   ;load r1+r2 summation

mov         eax, dword[position]
cvtsi2sd    xmm0, rax             ;convert offset position
movsd       qword [offset], xmm0  ; to 64 bit float

mov         al, [color]
cmp         al, 'r'
jne         tryW

mov         rdi, 255
mov         rsi, 0
mov         rdx, 0
jmp         loadColor

tryW:

cmp         al, 'w'
jne         tryG

mov         rdi, 255
mov         rsi, 255
mov         rdx, 255
jmp         loadColor

tryG:
cmp         al, 'g'
jne         tryB

mov         rdi, 0
mov         rsi, 255
mov         rdx, 0
jmp         loadColor

tryB:
mov         rdi, 0
mov         rsi, 0
mov         rdx, 255  ;must be blue

loadColor:
call        glColor3ub


mov         rsi, GL_POINTS
call        glBegin

mov         rcx, 3600             ; loop size
push	    rcx

tumble:
cvtsi2sd    xmm1, rcx             ;convert loop count to float .1 inc.
mulsd       xmm1,qword [step]     ;multiply by inc value
movsd       qword [cycle],xmm1

;solve y
movsd       xmm0, qword [radii]
mulsd       xmm0, qword [cycle]
divsd       xmm0, qword [rad2]
call	    sin

mulsd       xmm0, qword [offset]

movsd       qword [tmp], xmm0

movsd       xmm0, qword [cycle]
call        sin
mulsd       xmm0, qword [radii]
addsd       xmm0, qword [tmp]
movsd       qword [y], xmm0

;solve x
movsd       xmm0, qword [radii]
mulsd       xmm0, qword [cycle]
divsd       xmm0, qword [rad2]
call	    cos

mulsd       xmm0, qword [offset]


movsd       qword [tmp], xmm0

movsd       xmm0, qword [cycle]
call        cos
mulsd       xmm0, qword [radii]
addsd       xmm0, qword [tmp]
movsd       qword [x], xmm0

movsd       xmm1, qword [y]
call        glVertex2d

pop         rcx
loop        tumbler           ;short jump out of range so, work-around
jmp         completed

tumbler:
	        push rcx
            jmp tumble

completed:

call        glEnd
call        glFlush
mov         rsp, rbp
pop         rbp
ret

;*******************************************************************************
;   Generic procedure to display a string to the screen. String must be NULL 
;   terminated.
;
;   Algorithm: Count characters in string (excluding NULL)
;	Use syscall to output characters
;
;   Arguments: address, string rdi with the address...
;   Returns: nothing
;*******************************************************************************

global	printString
printString:
	push	rbp
	mov     rbp, rsp

	push	rbx
	push	rsi
	push	rdi
	push	rdx

; -----
;  Count characters in string.

	mov	rbx, rdi                  ; str addr
	mov	rdx, 0
strCountLoop:
	cmp	byte [rbx], NULL
	je	strCountDone
	inc	rbx
	inc	rdx
	jmp	strCountLoop
strCountDone:

	cmp	rdx, 0
	je	prtDone

; -----
;  Call OS to output string.

	mov	rax, SYS_write		; system code for write()
	mov	rsi, rdi                ; address of characters to write
	mov	rdi, STDOUT             ; file descriptor for standard in
                                	; rdx=count to write, set above
	syscall                     	; system call

; -----
;  String printed, return to calling routine.

prtDone:
	pop	rdx
	pop	rdi
	pop	rsi
	pop	rbx
	pop	rbp
	ret

; ******************************************************************

