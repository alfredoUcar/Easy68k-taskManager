*-----------------------------------------------------------
* Program    : Some routines implementing tasks to be used
*              with taskmanager installed on trap #0. See
*              taskmanager.x68 for more details.
* Written by : A. Burguera
* Date       : 11-Dec-2011
* Description: There are four tasks implemented in this file:
*              - T1 (Ball): Plots a ball bouncing on the screen.
*              - T2 (Double buffer): Manages double buffering
*              - T3 (Keyboard): Checks SPACE and creates a new
*                   ball if pressed.
*              - T4 (Mouse): Plots mouse coordinates and checks
*                   if mouse is inside a ball. If so, the ball
*                   color is set to green. Also, if mouse is
*                   clicked, the ball task is killed. This task
*                   is a good example of how a given task can
*                   iterate over all tasks to perform actions
*                   on them.
*-----------------------------------------------------------
	
************************************************************
*                     COMMON CONSTANTS                     *
************************************************************
TK_SCREEN_WIDTH			EQU	640
TK_SCREEN_HEIGHT		EQU	480
; Task types
TK_TYPE_BALL			EQU	0
TK_TYPE_SCREEN			EQU	1
TK_TYPE_KEYBOARD		EQU	2
TK_TYPE_MOUSE			EQU	3
; Variable offsets used for all tasks
TK_VAR_FIRST_TIME		EQU	0
TK_VAR_ID			EQU	1
TK_VAR_TYPE			EQU	2

************************************************************
*                       COMMON MACROS                      *
************************************************************

* ----------------------------------------------------------
TK_SET_RES			MACRO
* Sets graphics to window mode and resolution
* Parameters:	\1 Width, \2 Height
* ----------------------------------------------------------
				move.l	#1, D1
				move.b	#33, D0
				trap	#15
				move.b	#33, D0
				move.l	#\1*$10000+\2, D1
				trap	#15
				ENDM
* ----------------------------------------------------------


* ----------------------------------------------------------
TK_DRAW_ELLIPSE			MACRO
* Just a wrapper for trap #15 task 88. Parameters must
* be previously loaded in registers as explained in task 88
* docs.
* ----------------------------------------------------------
				move.b	#88, D0
				trap	#15
				ENDM
				
* ----------------------------------------------------------
TK_SET_PEN 			MACRO
* Sets the drawing pen color
* Parameters:	\1 Pen color in format $00BBGGRR
* ----------------------------------------------------------
				move.l	\1, D1
				move.b	#80, D0
				trap	#15
				ENDM	
		
* ----------------------------------------------------------
TK_SET_FILL 			MACRO
* Sets the drawing fill color
* Parameters:	\1 fill color in format $00BBGGRR
* ----------------------------------------------------------
				move.l	\1, D1
				move.b	#81, D0
				trap	#15		
				ENDM	

************************************************************
*                    INITIALIZATION ROUTINE                *
************************************************************

* ----------------------------------------------------------
TK_INIT:
* Adds the tasks in the approppriate order into the task
* manager.
* ----------------------------------------------------------
; Define minimum cycle time
			move.l	#0, D1
			move.b	#8, D0
			trap	#0
; Add one ball task				
			lea	T1_START, A0
			move.b	#0, D0
			trap	#0
; Add the double buffer manager
			lea	T2_START, A0
			move.b	#0, D0
			trap	#0
; Add the keyboard manager			
			lea	T3_START, A0
			move.b	#0, D0
			trap	#0
; Add the mouse manager
			lea	T4_START, A0
			move.b	#0, D0
			trap	#0
			rts
* ----------------------------------------------------------


************************************************************
*                            TASK 1                        *
************************************************************

; ==========================================================
; Task 1 constants
; ==========================================================
T1_RADIUS			EQU	20
T1_VAR_X			EQU	4
T1_VAR_Y			EQU	6
T1_VAR_SX			EQU	8
T1_VAR_SY			EQU	10
T1_VAR_COLOR			EQU	12

; ==========================================================
; Task 1 functions
; ==========================================================

* ----------------------------------------------------------
T1_START:
* Task 1 entry point.
* Draws a ball bouncing on the screen
* ----------------------------------------------------------
; Task shared memory is set to 0 when task is created. Use
; this to decide whether is the first time or not.
				cmp.b	#0, TK_VAR_FIRST_TIME(A0)
				beq	T1_INIT
; If this is not the first time, move the ball
; First check X boundary
				cmp	#TK_SCREEN_WIDTH-T1_RADIUS, T1_VAR_X(A0)
				bgt	T1_BOUNCE_X
				cmp	#T1_RADIUS, T1_VAR_X(A0)
				blt	T1_BOUNCE_X
; Next, check Y boundary				
				cmp	#TK_SCREEN_HEIGHT-T1_RADIUS, T1_VAR_Y(A0)
				bgt	T1_BOUNCE_Y
				cmp	#T1_RADIUS, T1_VAR_Y(A0)
				blt	T1_BOUNCE_Y
; Then update ball position
T1_UPDATE_POSITION:		move.w	T1_VAR_SX(A0), D1
				add.w	D1, T1_VAR_X(A0)	; X=X+SX
				move.w	T1_VAR_SY(A0), D1
				add.w	D1, T1_VAR_Y(A0)	; Y=Y+SY
; Finally, plot the ball	
				TK_SET_PEN	#$00FFFFFF	; White border
				TK_SET_FILL	T1_VAR_COLOR(A0) ; Fill color
			
				move.w	T1_VAR_X(A0), D1
				sub.w	#T1_RADIUS, D1		; D1=X-Radius
				move.w	T1_VAR_Y(A0), D2
				sub.w	#T1_RADIUS, D2		; D2=Y-Radius
				move.w	T1_VAR_X(A0), D3
				add.w	#T1_RADIUS, D3		; D3=X+Radius
				move.w	T1_VAR_Y(A0), D4
				add.w	#T1_RADIUS, D4		; D4=Y+Radius
				
				TK_DRAW_ELLIPSE
				
; End by switching to next task
				move.b	#3, D0
				trap	#0												
				
; Simple bouncing: just change sign of speed								
T1_BOUNCE_X:			neg.w	T1_VAR_SX(A0)
				bra	T1_UPDATE_POSITION
T1_BOUNCE_Y:			neg.w	T1_VAR_SY(A0)
				bra	T1_UPDATE_POSITION				


* ----------------------------------------------------------
T1_INIT:
* Task 1 initialization
* Sets initial ball coordinates
* ----------------------------------------------------------
; Store task ID. When switching to a task, the ID is in D1, but
; storing in shared memory makes things easier.
				move.b	D1, TK_VAR_ID(A0)
; Store the task type
				move.b	#TK_TYPE_BALL, TK_VAR_TYPE(A0)				
; Remember that next time will not be the first one
				move.b	#$ff, TK_VAR_FIRST_TIME(A0)
; Set coordinates to center of the screen
				move.w	#TK_SCREEN_WIDTH/2, T1_VAR_X(A0)
				move.w	#TK_SCREEN_HEIGHT/2, T1_VAR_Y(A0)
; Set speeds to 1
				move.w	#1, T1_VAR_SX(A0)
				move.w	#1, T1_VAR_SY(A0)	
; Set color to red
				move.l	#$000000FF, T1_VAR_COLOR(A0)			
; End by switching to next task
				move.b	#3, D0
				trap	#0				
* ----------------------------------------------------------
								
; ==========================================================
; Task 2 functions
; ==========================================================

* ----------------------------------------------------------
T2_START:
* Task 2 entry point.
* Does the double buffer thing
* First time:
* - Init double buffer
* - Clears hidden buffer
* Further executions
* - Shows graphics
* Note: This task must be added to Task Manager after all those
*       tasks that paint something on screen
* ----------------------------------------------------------
				cmp.b	#0, TK_VAR_FIRST_TIME(A0)
				beq	T2_INIT
; Show hidden buffer
				move.b	#94, D0
				trap	#15
; Clear hidden buffer and exit
				bra	T2_CLEAR_HIDDEN
								

* ----------------------------------------------------------
T2_INIT:
* Task 2 initialization
* ----------------------------------------------------------
; Store task ID. When switching to a task, the ID is in D1, but
; storing in shared memory makes things easier.
				move.b	D1, TK_VAR_ID(A0)
; Store the task type
				move.b	#TK_TYPE_SCREEN, TK_VAR_TYPE(A0)				
; Remember next time will not be the first one
				move.b	#$ff, TK_VAR_FIRST_TIME(A0)				
; Set resolution
				TK_SET_RES	TK_SCREEN_WIDTH, TK_SCREEN_HEIGHT				
; Init double buffer
				move.b	#92, D0
				move.b	#17, D1
				trap	#15
; Clear hidden buffer (make it black)
T2_CLEAR_HIDDEN:		TK_SET_PEN	#$00000000
				TK_SET_FILL	#$00000000
				move.w	#0, D1
				move.w	#0, D2
				move.w	#TK_SCREEN_WIDTH, D3
				move.w	#TK_SCREEN_HEIGHT, D4
				move.b	#87, D0
				trap	#15
; End by switching to next task
				move.b	#3, D0
				trap	#0				
* ----------------------------------------------------------

; ==========================================================
; Task 3 constants
; ==========================================================
T3_VAR_SPACE			EQU	4


; ==========================================================
; Task 3 functions
; ==========================================================

* ----------------------------------------------------------
T3_START:
* Task 3 entry point
* Checks for [SPACE]. If so, creates a new ball task
* ----------------------------------------------------------
				cmp.b	#0, TK_VAR_FIRST_TIME(A0)
				beq	T3_INIT
; Check SPACE
				move.b	#19, D0
				move.l	#' '<<24+' '<<16+' '<<8+' ',D1
				trap	#15
				
				and.b	#$01, D1		; Just change FF to 01 to
								; avoid sign problems
				
				move.b	D1, D2			; Remember space state
				sub.b	T3_VAR_SPACE(A0), D1	; Possible results:
								; If D1=0, prev=0 -> 0
								; If D1=0, prev=1 -> -1
								; If D1=1, prev=0 -> 1
								; If D1=1, prev=1 -> 0
				cmp.b	#1, D1
				bne	T3_SPACE_END
				
; At this point, space is pressed and it was not previously, so create a new ball task
				move.b	D2, T3_VAR_SPACE(A0)

				lea	T1_START, A0
				move.b	#0, D0
				trap	#0

; End by switching to next task
				move.b	#3, D0
				trap	#0				

T3_SPACE_END:			move.b	D2, T3_VAR_SPACE(A0)	; Store space state
; End by switching to next task
				move.b	#3, D0
				trap	#0				

* ----------------------------------------------------------
T3_INIT:
* Task 3 initialization
* ----------------------------------------------------------
; Store task ID. When switching to a task, the ID is in D1, but
; storing in shared memory makes things easier.
				move.b	D1, TK_VAR_ID(A0)
; Store the task type
				move.b	#TK_TYPE_KEYBOARD, TK_VAR_TYPE(A0)				
; Remember next time will not be the first one
				move.b	#$ff, TK_VAR_FIRST_TIME(A0)				
; Assuming that prior to execution SPACE was not pressed				
				clr.b	T3_VAR_SPACE(A0)
; End by switching to next task
				move.b	#3, D0
				trap	#0				
* ----------------------------------------------------------

; ==========================================================
; Task 4 constants
; ==========================================================
T4_VAR_MOUSEX			EQU	4
T4_VAR_MOUSEY			EQU	6
T4_VAR_MOUSEB			EQU	8

; ==========================================================
; Task 4 functions
; ==========================================================

* ----------------------------------------------------------
T4_START:
* Task 4 entry point
* ----------------------------------------------------------
				cmp.b	#0, TK_VAR_FIRST_TIME(A0)
				beq	T4_INIT
; Get the mouse coordinates
				bsr	T4_GET_MOUSE
; Put text cursor on top left (0,0)				
				clr.w	D1
				move.b	#11, D0
				trap	#15
; Display mouse position				
				lea	T4_STR_X, A1
				clr.l	D1
				move.w	T4_VAR_MOUSEX(A0), D1
				move.b	#17, D0
				trap	#15				

				lea	T4_STR_Y, A1
				clr.l	D1
				move.w	T4_VAR_MOUSEY(A0), D1
				move.b	#17, D0
				trap	#15
				
; Now, loop for all tasks
; First, get first task info
				move.b	#6, D0
				trap	#0
; Is this task a ball task?				
T4_START_LOOP:			move.b	D2, D4		; Store ID for future use
				cmp.b	#TK_TYPE_BALL, TK_VAR_TYPE(A1)
				bne	T4_START_NEXT
; If it is a ball get current ball X and Y
				move.w	T1_VAR_X(A1), D2
				move.w	T1_VAR_Y(A1), D3
; Check if mouse is inside (let's assume a square ball... ehem...)
				sub.w	T4_VAR_MOUSEX(A0), D2
				bge	T4_START_CONTX
				neg.w	D2
T4_START_CONTX:			sub.w	T4_VAR_MOUSEY(A0), D3
				bge	T4_START_CONTY
				neg	D3
; At this point, D2=abs(Xball-Xmouse) and D3=abs(Yball-Ymouse)
T4_START_CONTY:			cmp.w	#T1_RADIUS, D2
				bgt	T4_START_NEXT
				cmp.w	#T1_RADIUS, D3
				bgt	T4_START_NEXT
; If inside, change color to green
				move.l	#$0000FF00, T1_VAR_COLOR(A1)
; If left button is pressed kill the task
				btst.b	#0, T4_VAR_MOUSEB(A0)
				beq	T4_START_NEXT
				
				move.b	D1, D5		; Store index to iterate
				move.b	D4, D1		; Restore ID
				move.b	#1, D0
				trap	#0		; Kill task
				move.b	D5, D1		; Restore index
	
; Switch to next task				
T4_START_NEXT:			move.b	#7, D0
				trap	#0
; Is this the last task?
				cmp.b	#$FF, D1
				bne	T4_START_LOOP				
; End by switching to next task
				move.b	#3, D0
				trap	#0				

* ----------------------------------------------------------
T4_INIT:
* Task 4 initialization
* ----------------------------------------------------------
; Store task ID. When switching to a task, the ID is in D1, but
; storing in shared memory makes things easier.
				move.b	D1, TK_VAR_ID(A0)
; Store the task type
				move.b	#TK_TYPE_MOUSE, TK_VAR_TYPE(A0)				
; Remember next time will not be the first one
				move.b	#$ff, TK_VAR_FIRST_TIME(A0)				
; Get the mouse coordinates
				bsr	T4_GET_MOUSE				
; End by switching to next task
				move.b	#3, D0
				trap	#0				

* ----------------------------------------------------------
T4_GET_MOUSE:
* Read the mouse coordinates and stores them in the task
* memory.
* Modifies D0 and D1.
* ----------------------------------------------------------
				move.b	#61, D0
				clr.b	D1
				trap	#15
				
				move.w	D1, T4_VAR_MOUSEX(A0)
				swap	D1
				move.w	D1, T4_VAR_MOUSEY(A0)
				move.b	D0, T4_VAR_MOUSEB(A0)
				
				rts

; ==========================================================
; Task 4 strings
; ==========================================================
T4_STR_X			dc.b	'X: ',0
T4_STR_Y			dc.b	$0A,$0D,'Y: ',0







*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~8~
