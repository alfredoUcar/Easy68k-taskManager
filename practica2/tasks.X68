*-----------------------------------------------------------
* Program    : Tasks
* Written by : Pablo Riutort & Alfredo Ucendo
* Date       : 21-12-2013
* Description: Las tasks que gestiona el taskmanager para hacer funciona el juego:
**		- T2 (Bad guy): 
*		- T3 (Ship): 
*		- T4 (Shoot):
*		- T5 (Keyboard):
*-----------------------------------------------------------

************************************************************
*		     COMMON CONSTANTS			   *
************************************************************
TK_VAR_FIRST_TIME		EQU	0
<<<<<<< HEAD
=======
TK_VAR_ID			EQU	1
>>>>>>> tasks
************************************************************
*                    INITIALIZATION ROUTINE                *
************************************************************

* ----------------------------------------------------------
TK_INIT:
* Adds the tasks in the approppriate order into the task
* manager.
* ----------------------------------------------------------
;Define minimum cycle time
		move.l	#0, D1
		move.b	#8, D0
		trap	#0

; Add task 3
		lea 	T3_START, A0
		move.b	#0, D0
		trap	#0
		
;Add keyboard manager
		lea	T5_START, A0
		move.b	#0,D0
		trap	#0


* ----------------------------------------------------------


************************************************************
*                            TASK 3                        *
************************************************************

; ==========================================================
; Task 3 constants
; ==========================================================

; ==========================================================
; Task 3 functions
; ==========================================================

* ----------------------------------------------------------
T3_START:
* Task 3 entry point.
* Draws a ship on the bottom of the screen
* ----------------------------------------------------------
; Vemos si es la primera vez que se ha iniciado esta tarea
			cmp.b	#0, TK_VAR_FIRST_TIME(A0)
			beq	T3_INIT
;Si no es la primera vez que se inicializa esta tarea				


* ----------------------------------------------------------
T3_INIT:
* Task 1 initialization
<<<<<<< HEAD
* 
=======
* Pone la nave en las coordenadas indicadas
>>>>>>> tasks
* ----------------------------------------------------------
; Store task ID. When switching to a task, the ID is in D1, but
; storing in shared memory makes things easier.
			move.b D1, TK_VAR_ID(A0)
* ----------------------------------------------------------



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~8~
