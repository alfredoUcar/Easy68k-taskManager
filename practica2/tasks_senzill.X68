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
TK_TYPE_EX1			EQU	0
TK_TYPE_EX2			EQU	1
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


************************************************************
*                    INITIALIZATION ROUTINE                *
************************************************************

* ----------------------------------------------------------
TK_INIT:
* Adds the tasks in the approppriate order into the task
* manager.
* ----------------------------------------------------------
; Define minimum cycle time
			move.l	#500, D1
			move.b	#8, D0
			trap	#0

; Add task 1
			lea	T1_START, A0
			move.b	#0, D0
			trap	#0
; Add task 1
			lea	T1_START, A0
			move.b	#0, D0
			trap	#0
; Add task 1
			lea	T1_START, A0
			move.b	#0, D0
			trap	#0
; Add task 1
			lea	T1_START, A0
			move.b	#0, D0
			trap	#0
; Add task 2
			lea	T2_START, A0
			move.b	#0, D0
			trap	#0
; Add task 2
			lea	T2_START, A0
			move.b	#0, D0
			trap	#0
; Add task 2
			lea	T2_START, A0
			move.b	#0, D0
			trap	#0
; Add task 2
			lea	T2_START, A0
			move.b	#0, D0
			trap	#0
			
			rts
* ----------------------------------------------------------


************************************************************
*                            TASK 1                        *
************************************************************

; ==========================================================
; Task 1 functions
; ==========================================================

* ----------------------------------------------------------
T1_START:
* Task 1 entry point.
* Displays a text and the task ID
* ----------------------------------------------------------
; Task shared memory is set to 0 when task is created. Use
; this to decide whether is the first time or not.
				cmp.b	#0, TK_VAR_FIRST_TIME(A0)
				beq	T1_INIT
; Displays string and ID
				lea	T1_STR_2, A1
				and.l	#$000000FF, D1
				move.b	#17, D0
				trap	#15	
				lea	T1_STR_3, A1
				move.b	#13, D0
				trap	#15							
; End by switching to next task
				move.b	#3, D0
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
				move.b	#TK_TYPE_EX1, TK_VAR_TYPE(A0)				
; Remember that next time will not be the first one
				move.b	#$ff, TK_VAR_FIRST_TIME(A0)
; And display messagge
				lea	T1_STR_1, A1
				move.b	#13, D0
				trap	#15
; Switch to the next task				
				move.b	#3, D0
				trap	#0				
* ----------------------------------------------------------
								
; ==========================================================
; Task 1 strings
; ==========================================================
T1_STR_1			dc.b	'Initializing TASK 1 and screen',0
T1_STR_2			dc.b	'I am TASK 1 and my ID is ',0
T1_STR_3			dc.b	10,13,0

************************************************************
*                            TASK 2                        *
************************************************************

; ==========================================================
; Task 2 functions
; ==========================================================

* ----------------------------------------------------------
T2_START:
* Task 1 entry point.
* Displays a text and the task ID
* ----------------------------------------------------------
; Task shared memory is set to 0 when task is created. Use
; this to decide whether is the first time or not.
				cmp.b	#0, TK_VAR_FIRST_TIME(A0)
				beq	T2_INIT
; Displays string and ID
				lea	T2_STR_2, A1
				and.l	#$000000FF, D1
				move.b	#17, D0
				trap	#15	
				lea	T2_STR_3, A1
				move.b	#13, D0
				trap	#15							
; End by switching to next task
				move.b	#3, D0
				trap	#0																

* ----------------------------------------------------------
T2_INIT:
* Task 2 initialization
* Stores useful info and displays a text.
* ----------------------------------------------------------
; Store task ID. When switching to a task, the ID is in D1, but
; storing in shared memory makes things easier.
				move.b	D1, TK_VAR_ID(A0)
; Store the task type
				move.b	#TK_TYPE_EX2, TK_VAR_TYPE(A0)				
; Remember that next time will not be the first one
				move.b	#$ff, TK_VAR_FIRST_TIME(A0)
; Display messange
				lea	T2_STR_1, A1
				move.b	#13, D0
				trap	#15
; Switch to the next task				
				move.b	#3, D0
				trap	#0				
* ----------------------------------------------------------
								
; ==========================================================
; Task 2 strings
; ==========================================================
T2_STR_1			dc.b	'Initializing TASK 2',0
T2_STR_2			dc.b	'I am TASK 2 and my ID is ',0
T2_STR_3			dc.b	10,13,0










*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~8~
