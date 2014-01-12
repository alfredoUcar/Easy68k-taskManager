*-----------------------------------------------------------
* Program    : Tasks
* Written by : Pablo Riutort & Alfredo Ucendo
* Date       : 21-12-2013
* Description: Tasks managed by Taskmanager that makes the game work:
*		task 1: main menu *
*               task 2: doble buffer *
*               task 3: ship
*               task 4: enemy
*               task 5: beam
*               task 6: game control
*               task 7: explosion 
*-----------------------------------------------------------

*-----------------------------------------------------------
* Program    : Some routines implementing tasks to be used
*              with taskmanager installed on trap #0. See
*              taskmanager.x68 for more details.
* Written by : A. Burguera
* Date       : 14-Dec-2011
* Description: 
*-----------------------------------------------------------
************************************************************
*                            TASK 3                        *
************************************************************

; ==========================================================
; Task 3 constants
; ==========================================================
SHIP_SIZE	EQU	20
T3_VAR_X	EQU	4
T3_VAR_SX	EQU	6
T3_SPACE_KEY       EQU     7
;draw:
T3_PIXEL_SIZE		EQU	4
T3_SPEED        EQU     2
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
; if not first time
; draw ship
				move.b #T3_PIXEL_SIZE,TK_PIXEL(A1)
;set colors and draw
				move	T3_VAR_X(A0),D0	;set X
				bsr	TK_DRAW_NAVE
				
				

;capturamos del teclado		
                                ;teclas de movimiento		
                                MOVE.B #19,D0     

                                MOVE.L #$25<<24+$27<<16,D1 ; check for keypress (left, right)

                                TRAP   #15
                                BTST.L #24,D1     ; test for left arrow
                                IF <NE> THEN      ; if 'left'
                                  sub #T3_SPEED, T3_VAR_X(A0)
                                  cmp #(TK_INFO_SCREEN_WIDTH+((TK_NAVE_COLUMNS*T3_PIXEL_SIZE)/2)), T5_VAR_X(A0)
                                  IF <EQ> THEN
                                        add     #T3_SPEED,T5_VAR_X(A0)
                                  ENDI
                                ENDI
                                BTST.L #16,D1     ; test for right arrow
                                IF <NE> THEN      ; if 'right'
                                  add #T3_SPEED, T3_VAR_X(A0)
                                  cmp #(TK_SCREEN_WIDTH-((TK_NAVE_COLUMNS*T3_PIXEL_SIZE)/2)), T5_VAR_X(A0)
                                  IF <EQ> THEN
                                        sub     #T3_SPEED,T3_VAR_X(A0)
                                  ENDI
                                ENDI
                                
                                ;teclas de disparo
                                MOVE.B #19,D0     

                                MOVE.L #$20<<24+$27<<16+$20<<8+'F',D1 ; check for keypress (space,z,x,c)

                                TRAP   #15
                                BTST.L #24,D1     ; test for space
                                IF <NE> THEN      ; if 'space'
                                    ; get last state
*				        move.b	T5_SPACE_KEY(A0),D2
*	            			; save new state
*		        		move.b	D1,T5_SPACE_KEY(A0)
	    			
	            			;check for DOWN state
*		               		cmp.b 	#$FF,D2
*				        beq	T5_SWITCH
*				        cmp.b	#$FF,D1		
*				        bne	T5_SWITCH
                                        ;before FF, now 00 = shoot 1 beam
                                        lea	T5_START, A0 ;new laser beam task
			                move.b	#0, D0
			                trap	#0
                                ENDI
                                BTST.L #16,D1     ; test for z
                                IF <NE> THEN      ; if 'z'
*                                  disparo 'z'
                                ENDI
                                BTST.L #8,D1     ; test for x
                                IF <NE> THEN      ; if 'x'
*                                  disparo 'x'
                                ENDI
                                BTST.L #8,D1     ; test for c
                                IF <NE> THEN      ; if 'c'
*                                  disparo 'c'
                                ENDI
; switch
T3_SWITCH:		move.b	#3,D0
			trap	#0

* ----------------------------------------------------------
T3_INIT:
* Task 3 initialization
* 
* Pone la nave en las coordenadas indicadas
* ----------------------------------------------------------
; Store task ID. When switching to a task, the ID is in D1, but
; storing in shared memory makes things easier.
			move.b	D1, TK_VAR_ID(A0)
; store the task type
			move.b #TK_TYPE_PLAYER, TK_VAR_TYPE(A0)
; la siguiente vez que volvamos a esta task, no sera la primera
			move.b	#$FF, TK_VAR_FIRST_TIME(A0)
; set initial position of the ship
			move    #((TK_SCREEN_WIDTH-TK_INFO_SCREEN_WIDTH)/2+TK_INFO_SCREEN_WIDTH),T3_VAR_X(A0)      ; game window width

; switch
			move.b	#3,D0
			trap	#0
			
				
************************************************************
*                            TASK 5                        *
************************************************************

; ==========================================================
; Task 5 constants
; ==========================================================
T5_VAR_Y	EQU	4
T5_VAR_X        EQU     6
;draw:
T5_PIXEL_SIZE		EQU	8
T5_SPEED                EQU     2
; ==========================================================
; Task 5 functions
; ==========================================================

* ----------------------------------------------------------
T5_START:
* Task 5 entry point.
* Draws a laser beam from the position of the ship
* ----------------------------------------------------------
; Vemos si es la primera vez que se ha iniciado esta tarea
				cmp.b	#0, TK_VAR_FIRST_TIME(A0)
				beq	T5_INIT
				
; if not first time
; draw beam
;set colors and draw
                                TK_SET_PEN #$00FFFFFF	; fija el color del borde a blanco
                                TK_SET_FILL #$0000AAFF
                                
                                move    T5_VAR_X(A0),D1
                                sub     #T5_PIXEL_SIZE,D1
                                move    T5_VAR_Y(A0),D2
                                sub     #T5_PIXEL_SIZE,D2

                                TK_DRAW_SQUARE D1, D2, #T6_PIXEL_SIZE
;uptdate beam position
                                sub     #T5_SPEED,T5_VAR_Y(A0)

;look if an enemy is around
                                move.b  #6,D0                                           ; get first task info
                                trap    #0
                                
T5_CHECK_ALIEN:                 cmp.b   #TK_TYPE_ENEM, TK_VAR_TYPE(A1)                  ;it's alien?
                                beq    T5_GET_ALIEN
                                move.b  #7,D0                                           ; get next task info
                                trap    #0
                                cmp.b   #$FF,D1
                                bne     T5_CHECK_ALIEN ;????

;smash the aliens!
                                ;get coordenates
T5_GET_ALIEN:                   move.l  A1,A2   ;save actual state
                                move.b  #4,D0
                                trap    #0
                                ;brace ourselves, the compares are coming
                                move.w  T4_X(A2),D0
                                move.w  T4_Y(A2),D1
                                ;now the X,Y of the beam
                                move.w  T5_VAR_X(A0),D3
                                move.w  T5_VAR_Y(A0),D4
                                
                                bsr     T5_CHECK_CONTACT
                                
                                cmp     #$FFFF,D0
                                bne     T5_CHECK_LIMITS
                                
                                move    T4_X(A2),D2
                                move    T4_Y(A2),D6
                                move.b  TK_VAR_ID(A1),D7
                                ; add explosion
                                lea	T7_START, A0
			        move.b	#0, D0
			        trap	#0
			        move.b  #5,D0
			        trap    #0
			        ; asign same position of killed enemy
			        move    D2,T4_X(A0)
			        move    D6,T4_Y(A0)
			        ; remove enemy
			        move.b  D7,D1
			        move.b	#1, D0
			        trap	#0  
			                                   
T5_CHECK_LIMITS:                ;check if beam has arrived to the end of the screen
                                ;kill task if it has
                                ;get current task info
			        move.b  #4,D0
                                trap    #0
		
			        ; remove task
                                move.b  TK_VAR_ID(A0),D1
                                move.b  #1,D0
                                trap    #0

; switch
T5_SWITCH:			move.b	#3,D0
			        trap	#0

* ----------------------------------------------------------
T5_INIT:
* Task 5 initialization
* 
* Mueve el disparo por el eje Y de la pantalla de juego
* ----------------------------------------------------------
; Store task ID. When switching to a task, the ID is in D1, but
; storing in shared memory makes things easier.
			move.b	D1, TK_VAR_ID(A0)
; store the task type
			move.b #TK_TYPE_SCREEN, TK_VAR_TYPE(A0)
; la siguiente vez que volvamos a esta task, no sera la primera
			move.b	#$FF, TK_VAR_FIRST_TIME(A0)
; set initial position of the ship

                        move.b  #6,D0                                           ; get first task info
                        trap    #0
                                
T5_CHECK:               cmp.b   #TK_TYPE_PLAYER, TK_VAR_TYPE(A1)                  ;it's ship?
                        beq     T5_GET_DATA
                        move.b  #7,D0                                           ; get next task info
                        trap    #0
                        cmp.b   #$FF,D1
                        bne     T5_CHECK
                        
T5_GET_DATA:            ;recuperamos la info de la task actual
                        move.l  A1,A2   ;salvamos
                        move.b  #4,D0
                        trap    #0
                        ; coger la X de la nave
                        move    T3_VAR_X(A2),T5_VAR_X(A0)
                         ;Y DE LA NAVE
                        move	#((TK_SCREEN_HEIGHT-T5_PIXEL_SIZE-3)-(TK_NAVE_ROWS*T5_PIXEL_SIZE)/2),T5_VAR_Y(A0)  

; switch
			move.b	#3,D0
			trap	#0
			
* ----------------------------------------------------------
T5_CHECK_CONTACT:
* indicates if the enemy with position D0=X,D1=Y touch the circle on D3=X, D4=Y(return $FFFF)
* modifies: D0,D1
*---------------------------------------------------------------------------

				sub     D3,D0
				bge     T5_CONT_X
				neg     D0
T5_CONT_X:			sub     D4,D1
				bge     T5_CONT_Y
				neg     D1
; At this point, D0=abs(XBomb-XEnem) and D1=abs(YBomb-YEnem)
                                move    #((T5_PIXEL_SIZE*TK_NAVE_COLUMNS)/2),D2
                                add     #((T4_PIXEL_SIZE*TK_ENEM_COLUMNS)/2),D2
T5_CONT_Y:                      cmp     D2,D0
                                bgt     T5_NO_CONTACT
                                move    #((T5_PIXEL_SIZE*TK_NAVE_ROWS)/2),D2
                                add     #((T4_PIXEL_SIZE*TK_ENEM_ROWS)/2),D2
                                cmp     D2,D1
                                bgt     T5_NO_CONTACT
                                ;contact
                                move    #$FFFF,D0
                                rts
T5_NO_CONTACT:                  clr     D0
                                rts




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~8~
