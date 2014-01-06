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
TK_VAR_FIRST_TIME	EQU	0
TK_VAR_ID		EQU	1
TK_SCREEN_WIDTH		EQU	640
TK_SCREEN_HEIGHT	EQU	480	
************************************************************

************************************************************
*                    INITIALIZATION ROUTINE                *
************************************************************

************************************************************
*                   SOURCE FILE INCLUDES                   *
************************************************************
			INCLUDE "screen.x68"
			ds.w	0
			INCLUDE	"figuras.x68"	; List library
			ds.w	0
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
SHIP_SIZE	EQU	20
T3_VAR_Y	EQU	4
T3_VAR_SY	EQU	6
; ==========================================================
; Task 3 functions
; ==========================================================
;Dibuja la nave en la última posición válida
T3_EDGE:			FG_DRAW_NAVE
* ----------------------------------------------------------
T3_START:
* Task 3 entry point.
* Draws a ship on the bottom of the screen
* ----------------------------------------------------------
; Vemos si es la primera vez que se ha iniciado esta tarea
				cmp.b	#0, TK_VAR_FIRST_TIME(A0)
				beq	T3_INIT
; Si no es la primera vez que se inicializa esta tarea
; Miramos si colisiona con el límite de la pantalla				
				cmp	#TK_SCREEN_HEIGHT-SHIP_SIZE, T3_VAR_Y(A0)
				bgt	T3_EDGE
				cmp	#SHIP_SIZE, T3_VAR_Y(A0)
				blt	T3_EDGE
; actualizamos la posición de la nave
				move.w	T3_VAR_SY(A0), D1
				add.w	D1, T3_VAR_Y(A0)	; Y=Y+SY
; dibujamos la nave		
				FG_DRAW_NAVE
				
;capturamos del teclado
				move.b	#19, D0
				move.l	#$26<<24+$26<<16+$28<<8+$28,D1
				trap	#15


* ----------------------------------------------------------
T3_INIT:
* Task 1 initialization
* 
* Pone la nave en las coordenadas indicadas
* ----------------------------------------------------------
; Store task ID. When switching to a task, the ID is in D1, but
; storing in shared memory makes things easier.
			move.b	D1, TK_VAR_ID(A0)
; la siguiente vez que volvamos a esta task, no será la primera
			move.b	#$FF, TK_VAR_FIRST_TIME(A0)
;pintamos la nave en el centro (parte baja) de la pantalla
			move.w	TK_SCREEN_HEIGHT, D0
			move.w	TK_SCREEN_WEIGHT, D0
*			move.w	TK_SCREEN_HEIGHT, (A0)+
*			move.w	TK_SCREEN_WEIGHT, (A0)+
			FG_DRAW_NAVE
; switch
			move.b	#3,D0
			trap	#0
* ----------------------------------------------------------

; ==========================================================
; Task 5 constants
; ==========================================================
T5_VAR_SPACE			EQU	4
T5_VAR_Z			EQU	6
T5_VAR_X			EQU	8
T5_VAR_C			EQU	10
T5_VAR_LEFT			EQU	12
T5_VAR_RIGHT			EQU	14

; ==========================================================
; Task 5 functions
; ==========================================================

* ----------------------------------------------------------
T5_START:
* Task 5 entry point
* Checks for [SPACE]. If so, creates a new shoot task
* ----------------------------------------------------------
				cmp.b	#0, TK_VAR_FIRST_TIME(A0)
				beq	T5_INIT
; Check SPACE
				move.b	#19, D0
				move.l	#' '<<24+' '<<16+' '<<8+' ',D1
				trap	#15
				
				and.b	#$01, D1		; Just change FF to 01 to
								; avoid sign problems
				
				move.b	D1, D2			; Remember space state
				sub.b	T5_VAR_SPACE(A0), D1	; Possible results:
								; If D1=0, prev=0 -> 0
								; If D1=0, prev=1 -> -1
								; If D1=1, prev=0 -> 1
								; If D1=1, prev=1 -> 0
				cmp.b	#1, D1
				bne	T5_SPACE_END
				
; Se ha pulsado la tecla espacio, creamos una tarea de disparo (T4)
				move.b	D2, T3_VAR_SPACE(A0)

				lea	T4_START, A0
				move.b	#0, D0
				trap	#0

; Pasamos a la siguiente Task
				move.b	#3, D0
				trap	#0				

T3_SPACE_END:			move.b	D2, T5_VAR_SPACE(A0)	; Guardamos el estado de la tecla
; Pasamos a la siguiente task
				move.b	#3, D0
				trap	#0				

* ----------------------------------------------------------
T5_INIT:
* Task 5 initialization
* ----------------------------------------------------------
; Store task ID. When switching to a task, the ID is in D1, but
; storing in shared memory makes things easier.
				move.b	D1, TK_VAR_ID(A0)				
; Remember next time will not be the first one
				move.b	#$ff, TK_VAR_FIRST_TIME(A0)				
; Assuming that prior to execution SPACE was not pressed				
				clr.b	T5_VAR_SPACE(A0)
; End by switching to next task
				move.b	#3, D0
				trap	#0				
* ----------------------------------------------------------






*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~8~
