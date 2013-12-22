*-----------------------------------------------------------
* Program    : Some routines implementing tasks to be used
*              with taskmanager installed on trap #0. See
*              taskmanager.x68 for more details.
* Written by : A. Burguera
* Date       : 14-Dec-2011
* Description: 
*-----------------------------------------------------------
************************************************************
*                     COMMON CONSTANTS                     *
************************************************************
TK_SCREEN_WIDTH			EQU	640
TK_SCREEN_HEIGHT		EQU	480
; Task types
TK_TYPE_MENU			EQU	0
TK_TYPE_SCREEN			EQU	1
TK_TYPE_ENEM			EQU	2
; Variable offsets used for all tasks
TK_VAR_FIRST_TIME		EQU	0
TK_VAR_ID			EQU	1
TK_VAR_TYPE			EQU	2
************************************************************
*                   SOURCE FILE INCLUDES                   *
************************************************************
			INCLUDE "screen.x68" 		; Task manager library
			ds.w	0		  	; Perform memory alignment, just in case.			
			INCLUDE "figuras.x68" 	 	; The tasks
			ds.w	0		  	; Perform memory alignment, just in case.	
************************************************************
*                    INITIALIZATION ROUTINE                *
************************************************************

* ----------------------------------------------------------
TK_INIT:
* Adds the tasks in the approppriate order into the task
* manager.
* ----------------------------------------------------------
; Define minimum cycle time
			move.l	#5, D1
			move.b	#8, D0
			trap	#0

; Add task 1
			lea	T1_START, A0
			move.b	#0, D0
			trap	#0			
; add task 2
			lea	T2_START, A0
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
;memory offsets:
T1_OPTION		EQU	4
T1_UP_KEY		EQU	5
T1_DOWN_KEY		EQU	6
;font:
T1_FONT			EQU	$04	; lucida console
T1_FONT_SIZE		EQU	$12 	; 18
T1_FONT_STYLE		EQU	$0001	; bold
T1_FONT_PROP		EQU	(T1_FONT*$1000000)+(T1_FONT_SIZE*$10000)+T1_FONT_STYLE		; $040B0001
; ==========================================================
; Task 1 functions
; ==========================================================

* ----------------------------------------------------------
T1_START:
* Task 1 entry point.
* show menu options(before start)
* ----------------------------------------------------------
; Task shared memory is set to 0 when task is created. Use
; this to decide whether is the first time or not.
				cmp.b	#0, TK_VAR_FIRST_TIME(A0)
				beq	T1_INIT
; draw enemy(decoration)	
				move	#(TK_SCREEN_WIDTH/2-TK_PIXEL),D0	; set x
				swap	D0
				move	#(TK_SCREEN_HEIGHT/3-TK_PIXEL*3),D0 	; set y				
				bsr	TK_DRAW_ENEM
; Displays options
				;set font properties
				move.b	#21,D0
				move.l	(T1_COLOR_2),D1
				move.l	#T1_FONT_PROP,D2				
				trap	#15
				
; display option 1
				TK_LOCATE 	#((TK_SCREEN_WIDTH/T1_FONT_SIZE)/2-3),#((TK_SCREEN_HEIGHT/T1_FONT_SIZE)/3)
				cmp.b	#1,T1_OPTION(A0)
				beq	T1_OP1_SELECTED
				; set background color for option 1 as not selected
				TK_SET_FILL	(T1_COLOR_1)
				bra	T1_OP1_SHOW
T1_OP1_SELECTED:		; set background color for option 1 as selected
				TK_SET_FILL	(T1_COLOR_3)	
T1_OP1_SHOW:			TK_PRINT_STR	T1_STR_1
; display option 2		
				TK_LOCATE 	#((TK_SCREEN_WIDTH/T1_FONT_SIZE)/2-3),#(((TK_SCREEN_HEIGHT/T1_FONT_SIZE)/3)+1)				
				cmp.b	#2,T1_OPTION(A0)
				beq	T1_OP2_SELECTED
				; set background color for option 1 as not selected
				TK_SET_FILL	(T1_COLOR_1)		
				bra	T1_OP2_SHOW
T1_OP2_SELECTED:		; set background color for option 1 as selected
				TK_SET_FILL	(T1_COLOR_3)
T1_OP2_SHOW:			TK_PRINT_STR	T1_STR_2
; display option 3		
				TK_LOCATE 	#((TK_SCREEN_WIDTH/T1_FONT_SIZE)/2-3),#((TK_SCREEN_HEIGHT/T1_FONT_SIZE)/3+2)				
				cmp.b	#3,T1_OPTION(A0)
				beq	T1_OP3_SELECTED
				; set background color for option 1 as not selected
				TK_SET_FILL	(T1_COLOR_1)	
				bra	T1_OP3_SHOW
T1_OP3_SELECTED:		; set background color for option 1 as selected
				TK_SET_FILL	(T1_COLOR_3)
T1_OP3_SHOW:			TK_PRINT_STR	T1_STR_3

; Check for up/down keys	
				move.b	#19, D0
				move.l	#$26<<24+$26<<16+$28<<8+$28,D1
				trap	#15
								
				; get last state
				move.b	T1_UP_KEY(A0),D2
				swap	D2
				move.b	T1_DOWN_KEY(A0),D2
				; save new state
				move.b	D1,T1_DOWN_KEY(A0)
				swap	D1
				move.b	D1,T1_UP_KEY(A0)
				swap	D1
				
				;check for DOWN state
				cmp.b 	#$FF,D2
				bne	T1_CHECK_UP
				cmp.b	#$FF,D1		
				beq	T1_CHECK_UP
				;before=FF,now=00 then move down
				cmp.b	#3,T1_OPTION(A0)			
         			beq	T1_GOTO_FIRST		; ...last, go back to first option
         			add.b	#1,T1_OPTION(A0)	;move down
         			bra	T1_CHECK_UP
T1_GOTO_FIRST:			move.b	#1,T1_OPTION(A0)
T1_CHECK_UP:			;check for UP state
				swap	D1
				swap	D2
				cmp.b 	#0,D2
				beq	T1_NEXT
				cmp.b	#$FF,D1		
				beq	T1_NEXT
				;before=FF,now=00 then move up
				cmp.b	#1,T1_OPTION(A0)			
         			beq	T1_GOTO_LAST		; ...first, go back to last option
         			sub.b	#1,T1_OPTION(A0)	; move up
         			bra	T1_NEXT	
T1_GOTO_LAST:			move.b	#3,T1_OPTION(A0)	

; End by switching to next task
T1_NEXT:			move.b	#3, D0
				trap	#0																

* ----------------------------------------------------------
T1_INIT:
* Task 1 initialization
* Stores useful info and displays a text.
* ----------------------------------------------------------
; Store task ID. When switching to a task, the ID is in D1, but
; storing in shared memory makes things easier.
				move.b	D1, TK_VAR_ID(A0)
; Store the task type
				move.b	#TK_TYPE_MENU, TK_VAR_TYPE(A0)				
; Remember that next time will not be the first one
				move.b	#$ff, TK_VAR_FIRST_TIME(A0)
; set option 2 as default
				move.b	#2, T1_OPTION(A0)
; set up/down keys as not pressed
				move.b	#0, T1_UP_KEY(A0)
				move.b	#0, T1_DOWN_KEY(A0)
; Switch to the next task				
				move.b	#3, D0
				trap	#0				
* ----------------------------------------------------------
								
; ==========================================================
; Task 1 strings
; ==========================================================
T1_STR_1			dc.b	'    EASY    ',0	; option 1
T1_STR_2			dc.b	'   MEDIUM   ',0	; option 2
T1_STR_3			dc.b	'    HARD    ',0	; option 3
T1_STR_4			dc.b	10,13,0
T1_STR_PRESS			dc.b	'Press "enter" to start the game',0
T1_STR_COPYRIGHT		dc.b	'©antoil',10,13,'Made by Pablo Riutort & Alfredo Ucendo',0
T1_COLOR_1			dc.l	$00FFFFFF
T1_COLOR_2			dc.l	$00000000
T1_COLOR_3			dc.l	$00FF6600

************************************************************
*                            TASK 2                        *
************************************************************
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















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~8~
