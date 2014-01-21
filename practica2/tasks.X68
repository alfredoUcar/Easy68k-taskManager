 *-----------------------------------------------------------
* Program    : Main file for game.
* Written by : Pablo Riutort & Alfredo Ucendo
* Date       : December-2013
* List of tasks :
*
*       task 1: main menu
*       task 2: double buffer 
*       task 3: ship(player)
*       task 4: enemy
*       task 5: normal shot
*       task 6: game control
*       task 7: explosion
*       task 8: bomb
*       task 9: freeze
*       task 10: laser
*       task 11: final menu
*------------------------------------------------------------

************************************************************
*                     COMMON CONSTANTS                     *
************************************************************
TK_SCREEN_WIDTH			EQU	640
TK_SCREEN_HEIGHT		EQU	480
TK_INFO_SCREEN_WIDTH            EQU     140
TK_ENEM_GOAL                    EQU     TK_SCREEN_HEIGHT-20
TK_CYCLE                        EQU     2
TK_GAME_WIDTH                   EQU     TK_SCREEN_WIDTH-TK_INFO_SCREEN_WIDTH    ; game window width
; game control
TK_MAX_POWER                    EQU     12                                      ; max energy available for the player(for shots and bonus)
TK_MAX_ENEMIES                  EQU     (TM_MAX_TASKS-TK_MAX_POWER-1-1-1)         ; max number of (task)enemies to launch at same time 
TK_LASER_PW                     EQU     (TK_MAX_POWER/3)                        ; energy needed to use bonus 1
TK_FREEZE_PW                    EQU     (TK_MAX_POWER/3*2)                        ; energy needed to use bonus 2
TK_BOMB_PW                      EQU     TK_MAX_POWER                            ; energy needed to use bonus 3
TK_BEAM_PW                      EQU     1
; Task types
TK_TYPE_MENU			EQU	0
TK_TYPE_SCREEN			EQU	1
TK_TYPE_ENEM			EQU	2
TK_TYPE_PLAYER                  EQU     3
TK_TYPE_SHOT                    EQU     4
TK_TYPE_CONTROL                 EQU     5   
TK_TYPE_EXP                     EQU     6
TK_TYPE_LASER                   EQU     7
TK_TYPE_FREEZE                  EQU     8   
TK_TYPE_BOMB                    EQU     9
TK_TYPE_MENU2                   EQU     10                    
; Variable offsets used for all tasks
TK_VAR_FIRST_TIME		EQU	0
TK_VAR_ID			EQU	1
TK_VAR_TYPE			EQU	2
TK_PIXEL			EQU	3
TK_VAR_COLOR_1			EQU	4
TK_VAR_COLOR_2			EQU	8
TK_VAR_SPEED                    EQU     12
TK_VAR_ENEM                     EQU     14
TK_VAR_POWER                    EQU     16 
TK_VAR_GAME_STATE               EQU     18 ;BYTE
TK_VAR_X                        EQU     20   
TK_VAR_Y                        EQU     22   

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
			move.l	#TK_CYCLE, D1
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
T1_PIXEL		EQU	7
T1_ENEM_COLOR		EQU	8
;draw:
T1_PIXEL_SIZE		EQU	15
; Game configuration for each level
;LEVEL 1
T1_EASY_SPEED                   EQU     1
T1_EASY_ENEM                    EQU     25
T1_EASY_POWER                   EQU     TK_MAX_POWER
;LEVEL 2
T1_MEDIUM_SPEED                 EQU     2
T1_MEDIUM_ENEM                  EQU     50
T1_MEDIUM_POWER                 EQU     TK_MAX_POWER  
;LEVEL 3
T1_HARD_SPEED                   EQU     3
T1_HARD_ENEM                    EQU     100
T1_HARD_POWER                   EQU     TK_MAX_POWER
;colors
T1_COLOR_1		EQU	$00FFFFFF
T1_COLOR_2		EQU	$00000000
T1_COLOR_3		EQU	$00FF6600		
;font 1: menu options
T1_FONT_1		EQU	$04	; lucida console
T1_FONT_1_SIZE		EQU	$12 	; 18
T1_FONT_1_STYLE		EQU	$0001	; bold
T1_FONT_1_PROP		EQU	(T1_FONT_1*$1000000)+(T1_FONT_1_SIZE*$10000)+T1_FONT_1_STYLE		; $040B0001
;font 2: footer message
T1_FONT_2		EQU	$07	; terminal
T1_FONT_2_SIZE		EQU	$09 	
T1_FONT_2_STYLE		EQU	$0001	; bold
T1_FONT_2_PROP		EQU	(T1_FONT_2*$1000000)+(T1_FONT_2_SIZE*$10000)+T1_FONT_2_STYLE		; $040B0001
;font 3: copyright
T1_FONT_3		EQU	$06	; consolas
T1_FONT_3_SIZE		EQU	$08 	
T1_FONT_3_STYLE		EQU	$0001	; bold
T1_FONT_3_PROP		EQU	(T1_FONT_3*$1000000)+(T1_FONT_3_SIZE*$10000)+T1_FONT_3_STYLE		; $040B0001
;strings
T1_STR_1			dc.b	'    EASY    ',0	; option 1
T1_STR_2			dc.b	'   MEDIUM   ',0	; option 2
T1_STR_3			dc.b	'    HARD    ',0	; option 3
T1_STR_4			dc.b	10,13,0
T1_STR_PRESS			dc.b	'Press "enter" to start the game',0
T1_STR_COPYRIGHT		dc.b	'©antoil',10,13,'Made by Pablo Riutort & Alfredo Ucendo',0
                                ds.w    0 ;memory alignment

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
				move.l  A1,A2   ; copy, A1 used for print strings
; draw enemy(decoration)	
				move.b	T1_PIXEL(A0),TK_PIXEL(A1) 	; set global pixel
				; set global color
				move.l	#0,TK_VAR_COLOR_1(A1) 	; pixel pen
				move.l	T1_ENEM_COLOR(A0),TK_VAR_COLOR_2(A1)	; pixel fill
				move	#(TK_SCREEN_WIDTH/2-T1_PIXEL_SIZE),D0		; set x
				swap	D0
				move	#(TK_SCREEN_HEIGHT/3-T1_PIXEL_SIZE*2),D0 	; set y				
				bsr	TK_DRAW_ENEM
				move.l	T1_ENEM_COLOR(A0),D0
				bsr	T1_UPDATE_COLOR
				move.l	D0,T1_ENEM_COLOR(A0)
				move	#$F5,D4
				add.b	#15,D4
; Displays options
				;set font properties
				move.b	#21,D0
				move.l	#T1_COLOR_2,D1
				move.l	#T1_FONT_1_PROP,D2				
				trap	#15
				
; display option 1
				TK_LOCATE 	#((TK_SCREEN_WIDTH/T1_FONT_1_SIZE)/2-3),#((TK_SCREEN_HEIGHT/T1_FONT_1_SIZE)/3)
				cmp.b	#1,T1_OPTION(A0)
				beq	T1_OP1_SELECTED
				; set background color for option 1 as not selected
				TK_SET_FILL	#T1_COLOR_1
				bra	T1_OP1_SHOW
T1_OP1_SELECTED:		; set background color for option 1 as selected
				TK_SET_FILL	#T1_COLOR_3	
T1_OP1_SHOW:			TK_PRINT_STR	T1_STR_1
; display option 2		
				TK_LOCATE 	#((TK_SCREEN_WIDTH/T1_FONT_1_SIZE)/2-3),#(((TK_SCREEN_HEIGHT/T1_FONT_1_SIZE)/3)+1)				
				cmp.b	#2,T1_OPTION(A0)
				beq	T1_OP2_SELECTED
				; set background color for option 1 as not selected
				TK_SET_FILL	#T1_COLOR_1		
				bra	T1_OP2_SHOW
T1_OP2_SELECTED:		; set background color for option 1 as selected
				TK_SET_FILL	#T1_COLOR_3
T1_OP2_SHOW:			TK_PRINT_STR	T1_STR_2
; display option 3		
				TK_LOCATE 	#((TK_SCREEN_WIDTH/T1_FONT_1_SIZE)/2-3),#((TK_SCREEN_HEIGHT/T1_FONT_1_SIZE)/3+2)				
				cmp.b	#3,T1_OPTION(A0)
				beq	T1_OP3_SELECTED
				; set background color for option 1 as not selected
				TK_SET_FILL	#T1_COLOR_1	
				bra	T1_OP3_SHOW
T1_OP3_SELECTED:		; set background color for option 1 as selected
				TK_SET_FILL	#T1_COLOR_3
T1_OP3_SHOW:			TK_PRINT_STR	T1_STR_3
; Displays informative message
                                ;set font properties
				move.b	#21,D0
				move.l	#T1_COLOR_1,D1
				move.l	#T1_FONT_2_PROP,D2				
				trap	#15
				TK_LOCATE 	#10,#22
                                TK_SET_FILL	#T1_COLOR_2
        			TK_PRINT_STR	T1_STR_PRESS
; Displays copyright message
                                ;set font properties
				move.b	#21,D0
				move.l	#T1_COLOR_1,D1
				move.l	#T1_FONT_3_PROP,D2				
				trap	#15
				TK_LOCATE 	#1,#(128-3)
                                TK_SET_FILL	#T1_COLOR_2
        			TK_PRINT_STR	T1_STR_COPYRIGHT

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
				beq	T1_CHECK_INTRO
				cmp.b	#$FF,D1		
				beq	T1_CHECK_INTRO
				;before=FF,now=00 then move up
				cmp.b	#1,T1_OPTION(A0)			
         			beq	T1_GOTO_LAST		; ...first, go back to last option
         			sub.b	#1,T1_OPTION(A0)	; move up
         			bra	T1_CHECK_INTRO	
T1_GOTO_LAST:			move.b	#3,T1_OPTION(A0)

T1_CHECK_INTRO:                 ;check for intro key
                                move.b	#19, D0
				move.l	#$D<<24+$D<<16+$D<<8+$D,D1
				trap	#15
				
				BTST.L #24,D1     ; test for 'intro'
                                IF <NE> THEN      ; if 'intro'
                                move.l  A2,A1     ; restore shared memory pointer
                                ;start the game
                                cmp.b	#1,T1_OPTION(A0)
				beq	T1_START_EASY
				
				cmp.b	#2,T1_OPTION(A0)
				bne     T1_START_HARD
				
				;start on medium mode
				move.w  #T1_MEDIUM_SPEED,TK_VAR_SPEED(A1)
				move.w  #T1_MEDIUM_ENEM,TK_VAR_ENEM(A1)
				move.w  #T1_MEDIUM_POWER,TK_VAR_POWER(A1)
				bra     T1_START_GAME
				
T1_START_EASY:			;start on easy mode
				move.w  #T1_EASY_SPEED,TK_VAR_SPEED(A1)
				move.w  #T1_EASY_ENEM,TK_VAR_ENEM(A1)
				move.w  #T1_EASY_POWER,TK_VAR_POWER(A1)
				bra     T1_START_GAME
				
T1_START_HARD:			;start on hard mode
				move.w  #T1_HARD_SPEED,TK_VAR_SPEED(A1)
				move.w  #T1_HARD_ENEM,TK_VAR_ENEM(A1)
				move.w  #T1_HARD_POWER,TK_VAR_POWER(A1)

T1_START_GAME:                  		
			        lea	T6_START, A0
			        move.b	#0, D0
			        trap	#0	
			        
			        lea     T3_START, A0
			        move.b  #0,D0
			        trap    #0
			        
			        ;get current task info
			        move.b  #4,D0
                                trap    #0
		
			        ; remove menu task(itself)
                                move.b  TK_VAR_ID(A0),D1
                                move.b  #1,D0
                                trap    #0
                                ENDI      

; End by switching to next task
T1_NEXT:						        
                                move.b	#3, D0
				trap	#0
				

*----------------------------------------------------------
T1_UPDATE_COLOR:
* Update the color according to this sequence:
*				R	G	B
*			1)	FF	00	00
*			2)	FF	FF	00
*			3)	00	FF	00
*			4)	00	FF	FF
*			5)	00	00	FF
*			6)	FF	00	FF --> 1) ...	
* There's always a value 00 and FF while the other one vary between 00~FF	
* Pre:	D0.L color to be updated
* Post:	D0.L color updated
* Modifies: nothinh
*----------------------------------------------------------
				movem.w	D1-D3,-(A7); push
				
				;get RGB values
				move.b	D0,D1	; red
				lsr.l	#8,D0
				move.b	D0,D2	; green
				lsr.l	#8,D0
				move.b	D0,D3	; blue
				
				cmp.b	#$FF,D1
				bne	.T1_CHECK_R	; R<FF G=?? B=??
				;R=FF G=?? B=??
				cmp.b	#0,D3
				bne	.T1_DEC_B	; R=FF G=00 B>00
				;R=FF G=?? B=00
				cmp.b	#$FF,D2
				beq	.T1_DEC_R	; R=FF G=FF B=00
				;R=FF G<FF B=00
				bra	.T1_INC_G
				
.T1_CHECK_R:			; R<FF G=?? B=??
				cmp.b	#0,D1
				bne	.T1_CHECK_G		; 00<R<FF G=?? B=??
				; R=00 G=?? B=??
				cmp.b	#$FF,D2
				bne	.T1_CHECK_B	; R=00 G<FF B=??
				; R=00 G=FF B=??
				cmp.b	#$FF,D3
				beq	.T1_DEC_G	; R=00 G=FF B=FF
				; R=00 G=FF B<FF
				bra	.T1_INC_B
				
.T1_CHECK_G:			; 00<R<FF G=?? B=??
				cmp.b	#0,D2
				bne	.T1_DEC_R	; 00<R<FF G=FF B=00
				; 00<R<FF G=00 B=FF
				bra	.T1_INC_R
				
.T1_CHECK_B:			; R=00 G<FF B=??
				cmp.b	#0,D2
				bne	.T1_DEC_G	; R=00 G<FF B=FF
				; R=00 G=00 B=FF
				bra	.T1_INC_R				
				
.T1_INC_R:			add.b	#1,D1	; increase Red
				bra	.T1_END
				
.T1_DEC_R:			sub.b	#1,D1	; decrease Red
				bra	.T1_END
				
.T1_INC_G:			add.b	#1,D2	; increase Green
				bra	.T1_END
				
.T1_DEC_G:			sub.b	#1,D2	; decrease Green
				bra	.T1_END
				
.T1_INC_B:			add.b	#1,D3	; increase Blue
				bra	.T1_END
				
.T1_DEC_B:			sub.b	#1,D3	; decrease Blue
				bra	.T1_END
				
.T1_END:			;set new RGB values
				move.b	D3,D0	; blue
				lsl.l	#8,D0
				move.b	D2,D0	; green
				lsl.l	#8,D0
				move.b	D1,D0	; red
				
				movem.w	(A7)+,D1-D3 ; pop
				rts
																
			
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
; init properties for decorative enemy
				move.l	#$000000FF,T1_ENEM_COLOR(A0) ; red
				move.b	#T1_PIXEL_SIZE, T1_PIXEL(A0) ; set pixel size to 15
; Switch to the next task				
				move.b	#3, D0
				trap	#0				
* ----------------------------------------------------------							

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

************************************************************
*                            TASK 3                        *
************************************************************

; ==========================================================
; Task 3 constants
; ==========================================================
SHIP_SIZE	EQU	20
T3_VAR_X	EQU	4
T3_VAR_SX	EQU	6
T3_SPACE_KEY    EQU     7
;draw:
T3_PIXEL_SIZE   EQU	4
T3_SPEED        EQU     6
; ==========================================================
; Task 3 functions
; ==========================================================

* ----------------------------------------------------------
T3_START:
* Task 5 entry point.
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
                                  cmp #(TK_INFO_SCREEN_WIDTH+((TK_NAVE_COLUMNS*T3_PIXEL_SIZE)/2)), T3_VAR_X(A0)
                                  IF <LE> THEN
                                        add     #T3_SPEED,T3_VAR_X(A0)
                                  ENDI
                                ENDI
                                BTST.L #16,D1     ; test for right arrow
                                IF <NE> THEN      ; if 'right'
                                  add #T3_SPEED, T3_VAR_X(A0)
                                  cmp #(TK_SCREEN_WIDTH-((TK_NAVE_COLUMNS*T3_PIXEL_SIZE)/2)), T3_VAR_X(A0)
                                  IF <GE> THEN
                                        sub     #T3_SPEED,T3_VAR_X(A0)
                                  ENDI
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
			
* ----------------------------------------------------------
************************************************************
*                            TASK 4                        *
************************************************************
; ==========================================================
; Task 4 constants
; ==========================================================
;memory offsets:
T4_X                    EQU     4
T4_Y                    EQU     6
;draw:
T4_PIXEL_SIZE		EQU	4
T4_ENEMY_WIDTH_SPACE    EQU     (TK_ENEM_COLUMNS*T4_PIXEL_SIZE+20)
T4_ENEMS_BY_ROW         EQU     3 ;TK_GAME_WIDTH/T4_ENEMY_WIDTH_SPACE
T4_SPEED                EQU     1
T4_COLOR_1              EQU     $00FF6600
T4_COLOR_2              EQU     $00AA0000
; ==========================================================
; Task 4 functions
; ==========================================================

* ----------------------------------------------------------
T4_START:
* Task 4 entry point.
* An enemy that moves down to reach the ship
* First time:
* - Init position(random)
* Further executions
* - moves down
* Note: This task must be added to Task Manager after all those
*       tasks that paint something on screen
* ----------------------------------------------------------
				cmp.b	#0, TK_VAR_FIRST_TIME(A0)
				beq	T4_INIT
; draw enemy	
				move.b	#T4_PIXEL_SIZE,TK_PIXEL(A1) 	; set global pixel
				; set global color
				move.l	#T4_COLOR_1,TK_VAR_COLOR_1(A1) 	; pixel pen
				move.l	#T4_COLOR_2,TK_VAR_COLOR_2(A1)	        ; pixel fill
				move	T4_X(A0),D0		; set x
				swap	D0
				move	T4_Y(A0),D0 	        ; set y				
				bsr	TK_DRAW_ENEM

; updates position(move down)
                                move    TK_VAR_SPEED(A1),D0
                                add     D0,T4_Y(A0)
; End by switching to next task
				move.b	#3, D0
				trap	#0
								
* ----------------------------------------------------------
T4_RANDOM:
* return a random number between two limits
* the function use two dynamic values to 
* calculate it: the current timestamp and the task ID
* pre:  A0 task memory pointer
*       D0.W min limit 
*       D1.W max limit
* post: D0.W result
* ----------------------------------------------------------
                movem.l D1-D4,-(A7)             ; push
                
                move    D1,D2                   ; copy
                move    D0,D4
                move.b  #8,D0
		trap    #15                     ; get time
		move    D4,D0
                clr     D3
		move.b  TK_VAR_ID(A0),D3
		add     #1,D3                   ; [1..31] avoid case ID=0 for next operations
		and.l   #$0000FFFF,D1
		and.l   #$0000FFFF,D3
		divu    D3,D1
		and.l   #$0000FFFF,D1
		;at this point D1.W contains a random number, let's adjust it to desired range
		sub     D0,D2                   ; max-min
		and.l   #$0000FFFF,D2		
                divu    D2,D1                   
		swap    D1
		add     D1,D0
		and.l   #$0000FFFF,D0           ; clear high word
		
		movem.l (A7)+,D1-D4             ; pop
                rts
		
* ----------------------------------------------------------
T4_INIT:
* Task 4 initialization
* ----------------------------------------------------------
; Store task ID. When switching to a task, the ID is in D1, but
; storing in shared memory makes things easier.
				move.b	D1, TK_VAR_ID(A0)
; Store the task type
				move.b	#TK_TYPE_ENEM, TK_VAR_TYPE(A0)				
; Remember next time will not be the first one
				move.b	#$ff, TK_VAR_FIRST_TIME(A0)				
; Set initial position and size
T4_SET_POS:                     move.b  #4,D0                                           ; get current task info (restore)
                                trap    #0                                              ; values may be changed during loop
                                
                                clr.l   D0
                                clr.l   D1
                                move    #((TK_ENEM_ROWS*T4_PIXEL_SIZE)/2),T4_Y(A0)      ; set y
                                move    #(TK_SCREEN_WIDTH-TK_INFO_SCREEN_WIDTH),D0      ; game window width
                                move    #(TK_ENEM_COLUMNS*T4_PIXEL_SIZE+20),D1          ; width needed by enemy
                                divu    D1,D0                                           ; max enemies by row
                                move    D1,D2                                           ; copy
                                move    D0,D1
                                move    #1,D0
                                bsr     T4_RANDOM                                       ; random between 1 and enems_by_row
                                move    #TK_INFO_SCREEN_WIDTH,D1
                                sub     #1,D0
                                mulu    D2,D0
                                divu    #2,D2
                                add     D2,D0
                                add     D1,D0
                                move    D0,T4_X(A0)                                     ; set x
; check if there's another enemy for that position
                                move.b  TK_VAR_ID(A0),D4                                ; save current task ID
                                move.b  #6,D0                                           ; get first task info
                                trap    #0
                                
T4_CHECK_REPEAT:                cmp.b   D4,D2
                                beq     T4_CHECK_NEXT                                   ; it's current task, next
                                cmp.b   #TK_TYPE_ENEM, TK_VAR_TYPE(A1)                  ;it's enemy?
                                bne     T4_CHECK_NEXT                                   ;no
                                ; it's enemy... check position
                                
                                move    T4_Y(A0),D3
                                cmp     T4_Y(A1),D3
                                bne     T4_CHECK_NEXT                                   ; distinct Y, no coincidence
                                move    T4_X(A0),D3
                                cmp     T4_X(A1),D3
                                beq     T4_SET_POS                                      ; same Y, distinct X                      
                                
T4_CHECK_NEXT:                  move.b  #7,D0                                           ; get next task info
                                trap    #0
                                cmp.b   #$FF,D1
                                bne     T4_CHECK_REPEAT                                 ; not last task
                                
; End by switching to next task
				move.b	#3, D0
				trap	#0

************************************************************
*                            TASK 5                        *
************************************************************

; ==========================================================
; Task 5 constants
; ==========================================================
T5_VAR_X	EQU	4
T5_VAR_Y        EQU     6
;draw:
T5_PIXEL_SIZE	EQU	8
T5_SPEED        EQU     4
T5_COLOR        EQU     $0000AAFF
; ==========================================================
; Task 5 functions
; ==========================================================

* ----------------------------------------------------------
T5_START:
* Task 5 entry point.
* Draws a shot from the position of the ship
* ----------------------------------------------------------
; Vemos si es la primera vez que se ha iniciado esta tarea
				cmp.b	#0, TK_VAR_FIRST_TIME(A0)
				beq	T5_INIT
				
; if not first time
; draw beam
;set colors and draw
                                TK_SET_PEN  #T5_COLOR	
                                TK_SET_FILL #T5_COLOR
                                
                                move    T5_VAR_X(A0),D1
                                sub     #T5_PIXEL_SIZE/2,D1
                                move    T5_VAR_Y(A0),D2
                                sub     #T5_PIXEL_SIZE/2,D2

                                TK_DRAW_BALL D1, D2, #T5_PIXEL_SIZE/2
;uptdate beam position
                                sub   #T5_SPEED,T5_VAR_Y(A0)

;look if an enemy is around

                                move    T5_VAR_X(A0),D3
                                move    T5_VAR_Y(A0),D4
                                move.l  A1,A2                   ;copy shared memory pointer
;check the enemies task
                                move.b  #6,D0
                                trap    #0
                                
T5_CHECK_ALIEN:                 move.b  D1,D5           ;copy index to current task
                                cmp.b   #TK_TYPE_ENEM, TK_VAR_TYPE(A1)
                                bne     T5_CHECK_NEXT
                                ;at this point, we know that it's an enemy
                                move    T4_Y(A1),D1
                                move    T4_X(A1),D0
                                bsr     T5_CHECK_CONTACT
                                cmp     #0,D0
                                beq     T5_CHECK_NEXT
                                
                                ;we're now preparing to kill
                                move    T4_X(A1),D2
                                move    T4_Y(A1),D6
                                move.b  TK_VAR_ID(A1),D7
                                ;add explosion
                                lea     T7_START, A0
                                move.b  #0,D0
                                trap    #0
                                
                                move.b  #5,D0
                                trap    #0
                                ;asign same position
                                move    D2,T7_X(A0)
                                move    D6,T7_Y(A0)
                                ;remove the enemy task
                                sub     #1,TK_VAR_ENEM(A2)
                                move.b  D7,D1
			        move.b	#1, D0
			        trap	#0 
			        bra     T5_END

T5_CHECK_NEXT:                  move.b  D5,D1
                                move.b  #7,D0
                                trap    #0
                                cmp.b   #$FF,D1
                                bne     T5_CHECK_ALIEN
                                
                                ;check if beam has arrived to the end of the screen
                                move.b  4,D0
                                trap    #0
                                cmp     #0,T5_VAR_Y(A0)   
                                bgt     T5_SWITCH       ; if shot hasn't reached the top then scape from death claws and switch to next task to live another day (mygod!!)
                                 ;kill task if it has
                                ;get current task info
T5_END:			        move.b  #4,D0
                                trap    #0
                                
                                ;restore the energy spended on the beam
                                add #TK_BEAM_PW,TK_VAR_POWER(A1)
		
			        ; remove task
                                move.b  TK_VAR_ID(A0),D1
                                move.b  #1,D0
                                trap    #0

; switch
T5_SWITCH:			move.b	#3,D0
			        trap	#0

* ----------------------------------------------------------
T5_INIT:
; Store task ID. When switching to a task, the ID is in D1, but
; storing in shared memory makes things easier.
				move.b	D1, TK_VAR_ID(A0)
; Store the task type
				move.b	#TK_TYPE_SHOT, TK_VAR_TYPE(A0)				
; Remember next time will not be the first one
				move.b	#$FF, TK_VAR_FIRST_TIME(A0)
                                
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
                        ;Y de la nave
                        move	#((TK_SCREEN_HEIGHT-T3_PIXEL_SIZE-3)-(TK_NAVE_ROWS*T3_PIXEL_SIZE)/2),T5_VAR_Y(A0)
                        
                        sub     #TK_BEAM_PW,TK_VAR_POWER(A1)          ; consume energy
*                        clr.b   T5_STATE(A0)                            ; set state to 'laser' 
; End by switching to next task
				move.b	#3, D0
				trap	#0		
* ----------------------------------------------------------

			
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
; At this point, D0=abs(XBeam-XEnem) and D1=abs(YBeam-YEnem)
T5_CONT_Y:                      cmp     #((T4_PIXEL_SIZE*TK_ENEM_COLUMNS)/2+T5_PIXEL_SIZE/2),D0
                                bgt     T5_NO_CONTACT
                                cmp     #((T4_PIXEL_SIZE*TK_ENEM_ROWS)/2+T5_PIXEL_SIZE/2),D1
                                bgt     T5_NO_CONTACT
                                ;contact
                                move    #$FFFF,D0
                                rts
T5_NO_CONTACT:                  clr     D0
                                rts


* ----------------------------------------------------------
************************************************************
*                            TASK 6                        *
************************************************************
; ==========================================================
; Task 6 constants
; ==========================================================
;memory offsets:
T6_LASER_KEY_STATE      EQU     4 
T6_FREEZE_KEY_STATE     EQU     5 
T6_BOMB_KEY_STATE       EQU     6
T6_BEAM_KEY_STATE       EQU     7
T6_GAME_POINTS          EQU     8 ;LONG
;bonus keys
T6_LASER_KEY            EQU     'X' 
T6_FREEZE_KEY           EQU     'Z' 
T6_BOMB_KEY             EQU     'C' 
T6_BEAM_KEY             EQU     $20
; energy bar
T6_ENERGY_BOX_WIDTH     EQU     (TK_INFO_SCREEN_WIDTH*90/100)   ;90% of info screen
T6_ENERGY_BOX_HEIGHT    EQU     25
T6_ENERGY_LEFT          EQU     (TK_INFO_SCREEN_WIDTH*5/100)    
T6_ENERGY_BOTTOM        EQU     (TK_SCREEN_HEIGHT-20)
T6_ENERGY_TOP           EQU     (T6_ENERGY_BOTTOM-T6_ENERGY_BOX_HEIGHT)
T6_ENERGY_POINT         EQU     T6_ENERGY_BOX_WIDTH/TK_MAX_POWER
T6_COLOR_1              EQU     $000000FF       ; first slot
T6_COLOR_2              EQU     $0000FFFF       ; second slot
T6_COLOR_3              EQU     $0000FF00       ; third slot
T6_COLOR_4              EQU     $00000000       ; not available energy
;font
T6_FONT 		EQU	$01	; courier new
T6_FONT_COLOR           EQU     $00FFFFFF ;white
T6_FONT_SIZE		EQU	$09 	
T6_FONT_STYLE		EQU	$0000	; bold
T6_FONT_PROP		EQU	(T1_FONT_2*$1000000)+(T1_FONT_2_SIZE*$10000)+T1_FONT_2_STYLE		; $040B0001
;constants
T6_BONUS                dc.b    ' BONUS ',0
T6_LASER_CHAR           dc.b    T6_LASER_KEY,0
T6_FREEZE_CHAR          dc.b    T6_FREEZE_KEY,0
T6_BOMB_CHAR            dc.b    T6_BOMB_KEY,0
;debugging
T6_DEBUG_TASKS          dc.b     'Tasks: ',0
T6_DEBUG_ENEMS          dc.b     'Enems: ',0
T6_DEBUG_SHOTS          dc.b     'Shots: ',0
; ==========================================================
; Task 6 functions
; ==========================================================
* ----------------------------------------------------------
T6_START:
* Task 6 entry point.
* Manage game
* First time:
* - add player
* - add first enemies
* Further executions
* - add enemies randomly and manage game state
* ----------------------------------------------------------
				cmp.b	#0, TK_VAR_FIRST_TIME(A0)
				beq	T6_INIT
				
				bsr     T6_CHECK_ENEMS
				IF.B #$FF <EQ> D0 THEN
				;some enemy has reached the goal or the player destroyed all the enemies
                                        bsr     T6_END_GAME
                                        bra     T6_NEXT          ; next task should be task 11
				ELSE
				        IF.W #0 <LT> D1 THEN    ; can add D1 enems (D1>0)
                                                sub     #1,D1
				                move    D1,D2
				                ;add D2 enemies
T6_NEW_ENEM:			                lea     T4_START, A0
			                        move.b	#0, D0
        			                trap	#0
        			                dbra    D2,T6_NEW_ENEM 
                                        ENDI 
				ENDI
				move    #4,D0
				trap    #0
				bsr     T6_ENEM_COUNTER ; show a counter of remaining enemies
				bsr     T6_SHOW_ENERGY  ; show available energy
				bsr     T6_CHECK_BONUS  ; launch bonuses
				bsr     T6_SHOW_CLOCK   
				bsr     T6_DRAW_BONUS
				;draw a line which delimits the game space
				TK_SET_PEN      #$00FFFFFF
				TK_DRAW_LINE    #TK_INFO_SCREEN_WIDTH,#0,#TK_INFO_SCREEN_WIDTH,#TK_SCREEN_HEIGHT
                                ;draw a line which marks the enemy goal
				TK_SET_PEN      #$00FFFFFF
				TK_DRAW_LINE    #TK_INFO_SCREEN_WIDTH,#TK_ENEM_GOAL,#TK_SCREEN_WIDTH,#TK_ENEM_GOAL  
                                bsr     T6_DEBUG
				
; End by switching to next task
T6_NEXT:			move.b	#3, D0
				trap	#0		
								

* ----------------------------------------------------------
T6_INIT:
* Task 6 initialization
* ----------------------------------------------------------
; Store task ID. When switching to a task, the ID is in D1, but
; storing in shared memory makes things easier.
				move.b	D1, TK_VAR_ID(A0)
; Store the task type
				move.b	#TK_TYPE_CONTROL, TK_VAR_TYPE(A0)				
; Remember next time will not be the first one
				move.b  #$ff, TK_VAR_FIRST_TIME(A0)
				      			        
      			        ; set keys as not pressed
				move.b  #0,T6_LASER_KEY_STATE(A0)
				move.b  #0,T6_FREEZE_KEY_STATE(A0)
				move.b  #0,T6_BOMB_KEY_STATE(A0)
				
				move    #3,D2               ; number of enemies to add
				sub     #1,D2               ; loop 0..N-1
				
T6_ADD_ENEM:			lea         T4_START, A0
			        move.b	    #0, D0
        			trap	    #0
        			dbra        D2,T6_ADD_ENEM

; End by switching to next task
				move.b	#3, D0
				trap	#0
*----------------------------------------------------------
T6_END_GAME:
* Remove all tasks(but double buffer) and then add a final menu
*----------------------------------------------------------
                move.b  #6,D0                   ; get first task info
                trap    #0
                
T6_REMOVE_TASK: move.b  D2,D1
                move.b  #1,D0
                trap    #0
                
                move.b  #7,D0                   ; get next task info
                trap    #0
                cmp.b   #$FF,D1
                bne     T6_REMOVE_TASK
                ;At this point all task have been removed, also T6
                
                ;restore double buffer task
                lea         T2_START, A0
                move.b	    #0, D0
        	trap	    #0
                ;add final menu task
                lea         T11_START, A0
                move.b	    #0, D0
        	trap	    #0
                
                rts
*----------------------------------------------------------
T6_DEBUG:
*----------------------------------------------------------
                move.b  #6,D0                   ; get first task info
                trap    #0
                
                clr     D3
                clr     D4
                clr     D5
T6_DEBUG_TASK:  add     #1,D3
                cmp.b  #TK_TYPE_ENEM,TK_VAR_TYPE(A1)
                beq	T6_DBG_ENEM
                cmp.b  #TK_TYPE_SHOT,TK_VAR_TYPE(A1)
                beq	T6_DBG_SHOT
                
T6_DEBUG_NEXT:  move.b  #7,D0                   ; get next task info
                trap    #0
                cmp.b   #$FF,D1
                bne     T6_DEBUG_TASK
                bra     T6_DBG_DISPLAY
                
T6_DBG_ENEM:    add     #1,D4
                bra     T6_DEBUG_NEXT
T6_DBG_SHOT:    add     #1,D5
                bra     T6_DEBUG_NEXT
                
T6_DBG_DISPLAY: 
                TK_LOCATE 	#0,#0       
                lea	T6_DEBUG_TASKS, A1
		clr.l	D1
		move	D3, D1
		move.b	#17, D0
		trap	#15
                
                TK_LOCATE 	#0,#1
                lea	T6_DEBUG_ENEMS, A1
		clr.l	D1
		move	D4, D1
		move.b	#17, D0
		trap	#15
                
                TK_LOCATE 	#0,#2
                lea	T6_DEBUG_SHOTS, A1
		clr.l	D1
		move	D5, D1
		move.b	#17, D0
		trap	#15             

                rts
*----------------------------------------------------------
T6_SHOW_CLOCK:
*----------------------------------------------------------
                                move.b	#2,TK_PIXEL(A1) 	; set global pixel
				move	#30,D0		; set x
				swap	D0
				move	#50,D0 	        ; set y				
				bsr	TK_DRAW_CLOCK
                                rts
* ----------------------------------------------------------
T6_CHECK_ENEMS:
* post:  D0.B -> 0, game goes on
*        D0.B -> $FF, some enemy has reached the goal(the player lose)
*               or the player killed all enemies(the player win)
*        D1.W -> max. number of enemies to add (ignored if D0=FF)
* ----------------------------------------------------------
                movem.l D2/D4/A0-A1, -(A7)       ; push
                
                move.l  A1,A0                   ; copy shared memory pointer
                cmp     #0,TK_VAR_ENEM(A0)
                beq     T6_GAME_END             ; all enemies are dead(player wins)                
                move.b  #6,D0                   ; get first task info
                trap    #0                
                
                clr     D3                      ; enemies counter (just for enemies on screen)
                clr     D4                      ; prepare boolean (FF if some enemy on the top)
                ;loop all the tasks seeking enemies
T6_CHECK:       cmp.b   #TK_TYPE_ENEM,TK_VAR_TYPE(A1)
                bne     T6_GET_NEXT             ; not enemy, check next task
                
                ; At current iteration we found an enemy task (and A1 points to his memory)
                add     #1,D3                   ;count enemy
                ; all current enemies must be lower enough(higher Y) 
                ; so that the top is clear to add a new row of enemies
                cmp.b   #$FF,D4         
                beq     .CONT                   ; some enemy is still on the top
                move    #((TK_ENEM_ROWS*T4_PIXEL_SIZE)*3),D4        ; Y limit
                cmp     T4_Y(A1),D4
                blt     .CONT
                ; cannot add more enemies
                move.b  #$FF,D4                   
.CONT:          cmp     #TK_ENEM_GOAL,T4_Y(A1)
                bge     T6_GAME_END           ; the enemy has reached the goal                
                
T6_GET_NEXT:    move.b  #7,D0                   ; get next task info
                trap    #0
                cmp.b   #$FF,D1
                bne     T6_CHECK
                
                ;At this point any enemy has reached the goal and D3 contains current playing enemies                
                cmp.b   #$FF,D4         ; the top is clear?
                bne     T6_MAX_ADD      ; enemies can be added, lets calculate how many    
                ;still can not add more enemies
                clr     D1
                bra     T6_CE_END
                
T6_MAX_ADD:     move    TK_VAR_ENEM(A0),D4
                sub     D3,D4                   ; D4 = remaining enemies to kill - enemies on screen (remaining to add)
                ; adjust top limit
                move    #TK_MAX_ENEMIES,D1
                sub     D3,D1                   ; D1=MAX_SCREEN-CURRENT_SCREEN               
                cmp     #T4_ENEMS_BY_ROW,D1
                ble     T6_MA_CONT              
                move    #T4_ENEMS_BY_ROW,D1     ; D1 = [1..T4_ENEMS_BY_ROW]
T6_MA_CONT:     ; At this point D4 contains remaining enemies to add and D1 contains
                ; max number of enemies that can be added to game right now
                cmp     D4,D1      
                ble     T6_CE_END
                move    D4,D1
                bra     T6_CE_END
     
T6_GAME_END:   move.b  #$FF,D0                 ; save result 'GAME END'

T6_CE_END:      movem.l (A7)+, D2/D4/A0-A1       ; pop   
                rts
* ----------------------------------------------------------
T6_ENEM_COUNTER:
* outputs number of remaining enemies to kill
* pre: A1 pointer to shared memory
* ----------------------------------------------------------
                movem.l D0-D1/A1,-(A7) ;push
                
                TK_SET_FILL     #$00000000
                ;set font properties
		move.b	#21,D0
		move.l	#T6_FONT_COLOR,D1
		move.l	#T6_FONT_PROP,D2				
		trap	#15
                TK_LOCATE #7,#10
                
		;print counter
                clr.l   D1
                move    TK_VAR_ENEM(A1),D1
                move.b  #3,D0
                trap    #15
                ;draw an enemy
                move.b	#T4_PIXEL_SIZE,TK_PIXEL(A1) 	; set global pixel
		move.l	#T4_COLOR_1,TK_VAR_COLOR_1(A1) 	; pixel pen
		move.l	#T4_COLOR_2,TK_VAR_COLOR_2(A1)	        ; pixel fill
		move	#50,D0		; set x
		swap	D0
		move	#155,D0 	        ; set y				
		bsr	TK_DRAW_ENEM   
                
                movem.l (A7)+,D0-D1/A1
                rts
* ----------------------------------------------------------
T6_CHECK_BONUS:
* check bonuses state
* pre: A0 pointer to task memory
* post: D0.b    0 => do nothing
*               1 => do the laser
*               2 => do the freeze
*               3 => do the bomb
* ----------------------------------------------------------
                move.l  D1,-(A7) ; push                                
; Check for bonus keys	
				move.b	#19, D0
				move.l	#T6_LASER_KEY<<24+T6_FREEZE_KEY<<16+T6_BOMB_KEY<<8+T6_BEAM_KEY,D1
				trap	#15
				
				move    TK_VAR_POWER(A1),D2     ; current energy
				
				IF.W #(TK_BEAM_PW) <LE> D2 THEN
				      ; enough energy for beam
                                      BTST.L #0,D1     ; test for beam
                                      IF <NE> THEN      ; if beam pressed
                                          ; save state 'pressed'
				          move.b	#$FF,T6_BEAM_KEY_STATE(A0)
                                      ELSE    ;check if released
                                          IF.B   #$FF <EQ> T6_BEAM_KEY_STATE(A0) THEN
                                               ; do the beam thing
                                               move.b #0,T6_BEAM_KEY_STATE(A0)         
                                               lea	T5_START, A0
                                               move.b	#0, D0
                                               trap	#0
                                           ENDI
                                       ENDI				        
				  ENDI
				
				IF.W #(TK_LASER_PW) <LE> D2 THEN
				; enough energy for laser
				        BTST.L #24,D1     ; test for laser
                                        IF <NE> THEN      ; if laser pressed
                                                ; save state 'pressed'
				                move.b	#$FF,T6_LASER_KEY_STATE(A0)
                                                bra T6_CB_END
                                        ELSE    ;check if released
                                                IF.B   #$FF <EQ> T6_LASER_KEY_STATE(A0) THEN
                                                 ; do the laser thing
                                                 move.b #0,T6_LASER_KEY_STATE(A0)
                                                 lea	T10_START, A0
                                                 move.b	#0, D0
                                                 trap	#0  
                                                 bra T6_CB_END
                                                ENDI
                                        ENDI
				        IF.W #(TK_FREEZE_PW) <LE> D2 THEN
				        ; enough energy for freeze
				                BTST.L #16,D1     ; test for freeze 
                                                IF <NE> THEN      ; if freeze pressed
                                                        ; save state 'pressed'
				                        move.b	#$FF,T6_FREEZE_KEY_STATE(A0)
                                                        bra T6_CB_END
                                                ELSE    ;check if released
                                                        IF.B   #$FF <EQ> T6_FREEZE_KEY_STATE(A0) THEN
                                                        ; do the freeze thing
                                                        move.b	#0,T6_FREEZE_KEY_STATE(A0)
                                                        lea	T9_START, A0
                                                        move.b	#0, D0
                                                        trap	#0                                                        
                                                        bra T6_CB_END
                                                        ENDI
                                                ENDI
				                IF.W #(TK_BOMB_PW) <LE> D2 THEN
				                ; enough energy for bomb
                                                        BTST.L #8,D1     ; test for bomb
                                                        IF <NE> THEN      ; if bomb pressed
                                                                ; save state 'pressed'
				                                move.b	#$FF,T6_BOMB_KEY_STATE(A0)
                                                                bra T6_CB_END
                                                        ELSE    ;check if released
                                                                IF.B   #$FF <EQ> T6_BOMB_KEY_STATE(A0) THEN
                                                                ; do the bomb thing
                                                                move.b #0,T6_BOMB_KEY_STATE(A0)                                                                
                                                                lea	T8_START, A0
                                                                move.b	#0, D0
                                                                trap	#0
                                                                bra T6_CB_END
                                                                ENDI
                                                        ENDI    
				                ENDI    
				        ENDI 
				ENDI			
				
T6_CB_END:		        move.l  (A7)+,D1		
				rts
*-----------------------------------------------------------
T6_DRAW_BONUS:
*-----------------------------------------------------------
                        move    TK_VAR_POWER(A1),D7     ; current energy
                        
                        move.b          #93,D0
                        move.b          #2,D1
                        trap            #15  
                        ;draw bonus box
                        TK_SET_PEN      #$00FFFFFF
                        TK_SET_FILL     #$00000000
                        TK_DRAW_RECTANGLE  #10,#200,#130,#340
                        
			TK_DRAW_LINE    #10,#230,#130,#230
                        
                        TK_LOCATE 	#2,#14
                        TK_SET_FILL	#$00000000
        	        TK_PRINT_STR	T6_BONUS
				
		        IF.W #(TK_BOMB_PW) <LE> D7 THEN
		                ; set green color (available)
		                move.l  #T6_COLOR_3,D1
		        ELSE    ;set default color (not available)
		                move.l  #T6_FONT_COLOR,D1
		        ENDI
		        ;set font properties
			move.b	#21,D0
			move.l	#T6_FONT_PROP,D2				
			trap	#15
        	        ;write bomb key
        	        TK_LOCATE 	#7,#16
                        TK_SET_FILL	#$00000000
        	        TK_PRINT_STR	T6_BOMB_CHAR
                        ;draw bomb symbol
                        TK_SET_PEN      #$000000FF
                        TK_DRAW_CIRCLE  #50,#250,#10
                        
                        IF.W #(TK_FREEZE_PW) <LE> D7 THEN
		                ; set green color (available)
		                move.l  #T6_COLOR_3,D1
		        ELSE    ;set default color (not available)
		                move.l  #T6_FONT_COLOR,D1
		        ENDI
		        ;set font properties
			move.b	#21,D0
			move.l	#T6_FONT_PROP,D2				
			trap	#15
                        ;write freeze key
                        TK_LOCATE 	#7,#19
                        TK_SET_FILL	#$00000000
        	        TK_PRINT_STR	T6_FREEZE_CHAR
                        ;draw freeze symbol
                        TK_SET_PEN      #$00CC6600
                        TK_SET_FILL     #$00FF9900
                        TK_DRAW_SQUARE  #40,#280,#20
                        
                        IF.W #(TK_BEAM_PW) <LE> D7 THEN
		                ; set green color (available)
		                move.l  #T6_COLOR_3,D1
		        ELSE    ;set default color (not available)
		                move.l  #T6_FONT_COLOR,D1
		        ENDI
		        ;set font properties
			move.b	#21,D0
			move.l	#T6_FONT_PROP,D2				
			trap	#15
                        ;write laser key
                        TK_LOCATE 	#7,#21
                        TK_SET_FILL	#$00000000
        	        TK_PRINT_STR	T6_LASER_CHAR
                        ;draw laser symbol
                        TK_SET_PEN      #T10_COLOR
			TK_DRAW_LINE    #40,#320,#60,#320
			
			move.b          #93,D0
                        move.b          #1,D1
                        trap            #15
                        
                        rts
* ----------------------------------------------------------
T6_SHOW_ENERGY:
* show energy bar
* ----------------------------------------------------------
                        movem.l D0-D4,-(A7)     ; push
                        
                        move.b  #4,D0   ;get current task info
                        trap    #0
                        
                        TK_SET_PEN      #$00FFFFFF
                        TK_SET_FILL     #T6_COLOR_2
                        
                        clr     D5      ; counter (0..MAX_POWER-1)
.DRAW_POINT:            move    TK_VAR_POWER(A1),D1
                        cmp     D5,D1
                        bgt     .C1
                        move.l  #T6_COLOR_4,D1
                        bra     .FILL
.C1                     cmp     #(TK_LASER_PW-1),D5   
                        bgt     .C2
                        move.l  #T6_COLOR_1,D1
                        bra     .FILL
.C2:                    cmp     #(TK_FREEZE_PW-1),D5
                        bgt     .C3
                        move.l  #T6_COLOR_2,D1
                        bra     .FILL
.C3:                    move.l  #T6_COLOR_3,D1
.FILL:                  TK_SET_FILL     D1
                        move    D5,D1
                        mulu    #T6_ENERGY_POINT,D1
                        add     #T6_ENERGY_LEFT,D1              ;left x
                        move    D1,D3
                        add     #T6_ENERGY_POINT,D3             ;right x
                        move    #T6_ENERGY_TOP,D2               ;upper y
                        move    #T6_ENERGY_BOTTOM,D4            ;lower y
                        TK_DRAW_RECTANGLE D1,D2,D3,D4
                        add     #1,D5
                        cmp     #TK_MAX_POWER,D5
                        bne     .DRAW_POINT

                        movem.l (A7)+,D0-D4     ; pop
                        rts
* ----------------------------------------------------------
************************************************************
*                            TASK 7                        *
************************************************************
; ==========================================================
; Task 7 constants
; ==========================================================
;memory offsets:
T7_X                    EQU     4
T7_Y                    EQU     6
T7_TIMEOUT              EQU     8 
;draw:
T7_PIXEL_SIZE           EQU	4
T7_DELAY                EQU     40    ; one second 
; ==========================================================
; Task 7 functions
; ==========================================================
* ----------------------------------------------------------
T7_START:
* Task 5 entry point.
* Explosion
* First time:
* - set time lived to 0
* Further executions
* - paint an explosion
* ----------------------------------------------------------
				cmp.b	#0, TK_VAR_FIRST_TIME(A0)
				beq	T7_INIT
				
				cmp     #0,T7_TIMEOUT(A0)
				beq     T7_DEAD                         ; life time expired
				
				move.b  #8,D0
				trap    #15
				move.l  D1,D2
				
				move.b	#T4_PIXEL_SIZE,TK_PIXEL(A1) 	; set global pixel
				;set position
				move    T7_X(A0),D0
				swap    D0
                                move    T7_Y(A0),D0
                                
                                bsr     TK_DRAW_EXP
T7_UPDATE:                      
                                sub     #1,T7_TIMEOUT(A0)                ; updates life time( in cycles)
                                bra     T7_NEXT                             
                                
T7_DEAD:                        move.b  TK_VAR_ID(A0),D1                ;remove itself
                                move.b  #1,D0
                                trap    #0

				
; End by switching to next task
T7_NEXT:			move.b	#3, D0
				trap	#0		
								

* ----------------------------------------------------------
T7_INIT:
* Task 5 initialization
* ----------------------------------------------------------
; Store task ID. When switching to a task, the ID is in D1, but
; storing in shared memory makes things easier.
				move.b	D1, TK_VAR_ID(A0)
; Store the task type
				move.b	#TK_TYPE_EXP, TK_VAR_TYPE(A0)				
; Remember next time will not be the first one
				move.b	#$ff, TK_VAR_FIRST_TIME(A0)
				; set time lived to 0
                                move    #(T7_DELAY/TK_CYCLE),T7_TIMEOUT(A0) ; cycles timeout  

; End by switching to next task
				move.b	#3, D0
				trap	#0		
* ----------------------------------------------------------
************************************************************
*                            TASK 8                        *
************************************************************
; ==========================================================
; Task 8 constants
; ==========================================================
;memory offsets
T8_STATE        EQU     4
T8_MOUSE_STATE  EQU     5
T8_SMALL_RADIUS EQU     6
T8_X            EQU     8
T8_Y            EQU     10
T8_TIMEOUT      EQU     12 ;LONG
;draw
T8_RADIUS       EQU     75
T8_DELAY        EQU     500 ; 5 seconds
T8_ANIM_STEP    EQU     T8_RADIUS/20
T8_COLOR        EQU     $000000FF
; ==========================================================
; Task 8 functions
; ==========================================================
* ----------------------------------------------------------
T8_START:
* Task 8 entry point.
* Bonus 1: shows a circle on mouse position and kills
* every enemy in his radius by clicking
* First time:
* - set state to 0(awaiting the click)
* Further executions
* - state 1: kill
* - state 2: timeout
* - paint an explosion
* ----------------------------------------------------------
				cmp.b	#0, TK_VAR_FIRST_TIME(A0)
				beq	T8_INIT
				cmp.b   #1,T8_STATE(A0)
				beq     T8_KILL
				cmp.b   #2,T8_STATE(A0)
				beq     T8_RESTORE
				
				clr     D1
				move.b  #61,D0
				trap    #15
				move    D1,T8_X(A0)        ; X
				swap    D1
				move    D1,T8_Y(A0)        ; Y
				
				and.b   #1,D0
				cmp.b   #0,D0
				beq     T8_CHECK_RELEASE                ; not pressed, check if released
				move.b  #$FF,T8_MOUSE_STATE(A0)         ; save pressed state
				bra     T8_WAIT_CLICK
T8_CHECK_RELEASE:               cmp.b   #0,T8_MOUSE_STATE(A0)
                                beq     T8_WAIT_CLICK
                                move.b  #1,T8_STATE(A0)               ; click, next time will kill
				
T8_WAIT_CLICK:			TK_SET_PEN      #T8_COLOR
                                TK_DRAW_CIRCLE  T8_X(A0),T8_Y(A0),#T8_RADIUS
                                
                                bra     T8_NEXT
                                
T8_KILL:                        
                                ; save bomb position
                                move    T8_X(A0),D3
                                move    T8_Y(A0),D4
                                move.l  A1,A2           ;save shared memory pointer
; check if there's enemies to kill
                                move.b  #6,D0                                           ; get first task info
                                trap    #0                                
                                
T8_KILL_CHECK:                  move.b  D1,D5                                           ; copy index of current task for T8_CHECK_NEXT
                                cmp.b   #TK_TYPE_ENEM, TK_VAR_TYPE(A1)                  ;it's enemy?
                                bne     T8_CHECK_NEXT                                   ;no, next task
                                ; it's enemy... check distance                                
                                move    T4_Y(A1),D1
                                move    T4_X(A1),D0                                
                                bsr     T8_CHECK_CONTACT
                                cmp     #0,D0
                                beq     T8_CHECK_NEXT                                   ; doesn't touch the enemy                                
; kill the enemy
                                move    T4_X(A1),D2
                                move    T4_Y(A1),D6
                                move.b  TK_VAR_ID(A1),D7
                                sub     #1,TK_VAR_ENEM(A2)                              ; updates remaining enemies
                                ; add explosion
                                lea	T7_START, A0
			        move.b	#0, D0
			        trap	#0
			        move.b  #5,D0
			        trap    #0
			        ; asign same position of killed enemy
			        move    D2,T7_X(A0)
			        move    D6,T7_Y(A0)
			        ; remove enemy
			        move.b  D7,D1
			        move.b	#1, D0
			        trap	#0                               
                                                       
                                
T8_CHECK_NEXT:                  move.b  D5,D1                                           ; restore index
                                move.b  #7,D0                                           ; get next task info
                                trap    #0
                                cmp.b   #$FF,D1
                                bne     T8_KILL_CHECK                                   ; not last task
                                
                                move.b  #4,D0
                                trap    #0                      ; restore info
                                
T8_ANIM:
                                add     #T8_ANIM_STEP,T8_SMALL_RADIUS(A0)
                                TK_SET_PEN      #T8_COLOR
                                TK_DRAW_CIRCLE  T8_X(A0),T8_Y(A0),T8_SMALL_RADIUS(A0)
                                cmp     #T8_RADIUS,T8_SMALL_RADIUS(A0)
                                ble     T8_ANIM
                                
				move.b  #2,T8_STATE(A0)         ; set state 'timeout'				
T8_RESTORE:                     cmp     #0,T8_TIMEOUT(A0)
                                beq     T8_END
                                sub     #1,T8_TIMEOUT(A0)
                                bra     T8_NEXT
T8_END:                         add     #TK_BOMB_PW,TK_VAR_POWER(A1) ; restore energy
                                ;remove itself                                
                                move.b  #1,D0
                                trap    #0

; End by switching to next task
T8_NEXT:      			move.b	#3, D0
				trap	#0
* ----------------------------------------------------------
T8_CHECK_CONTACT:
* indicates if the enemy with position D0=X,D1=Y touch the circle on D3=X, D4=Y(return $FFFF)
* modifies: D0,D1
*---------------------------------------------------------------------------

				sub     D3,D0
				bge     T8_CONT_X
				neg     D0
T8_CONT_X:			sub     D4,D1
				bge     T8_CONT_Y
				neg     D1
; At this point, D0=abs(XBomb-XEnem) and D1=abs(YBomb-YEnem)
T8_CONT_Y:                      cmp     #(T8_RADIUS+((T4_PIXEL_SIZE*TK_ENEM_COLUMNS)/2)),D0
                                bgt     T8_NO_CONTACT
                                cmp     #(T8_RADIUS+((T4_PIXEL_SIZE*TK_ENEM_ROWS)/2)),D1
                                bgt     T8_NO_CONTACT
                                ;contact
                                move    #$FFFF,D0
                                rts
T8_NO_CONTACT:                  clr     D0
                                rts
* ----------------------------------------------------------
T8_INIT:
* Task 8 initialization
* ----------------------------------------------------------
; Store task ID. When switching to a task, the ID is in D1, but
; storing in shared memory makes things easier.
				move.b	D1, TK_VAR_ID(A0)
; Store the task type
				move.b	#TK_TYPE_BOMB, TK_VAR_TYPE(A0)				
; Remember next time will not be the first one
				move.b	#$ff, TK_VAR_FIRST_TIME(A0)
				
				sub     #TK_BOMB_PW,TK_VAR_POWER(A1)    ; consume energy
				move.b  #0,T8_STATE(A0)                 ; set state 'wait'
                                move.b  #0,T8_SMALL_RADIUS(A0)		; set start for animation
		                move    #(T8_DELAY/TK_CYCLE),T8_TIMEOUT(A0) ; cycles before restore the energy  

; End by switching to next task
				move.b	#3, D0
				trap	#0		
* ----------------------------------------------------------
************************************************************
*                            TASK 9                        *
************************************************************
; ==========================================================
; Task 9 constants
; ==========================================================
;memory offsets
T9_SPEED        EQU     4
T9_TIMEOUT      EQU     6
T9_STATE        EQU     8
;time
T9_DELAY        EQU     400 ; 4 seconds
; ==========================================================
; Task 9 functions
; ==========================================================
* ----------------------------------------------------------
T9_START:
* Task 9 entry point.
* freezes all enemies for a certain time
* First time:
* - save speed used for enemies and set it to 0
* Further executions
* - state 0: if timeout then restores enemies speed
* - state 1(FF): if timeout' then restores energy
* ----------------------------------------------------------
				cmp.b	#0, TK_VAR_FIRST_TIME(A0)
				beq	T9_INIT			
				
				cmp     #0,T9_TIMEOUT(A0)
				beq     T9_CHECK_STATE
				sub     #1,T9_TIMEOUT(A0)       ; updates timeout
				bra     T9_NEXT
				;time expired
T9_CHECK_STATE: 		cmp.b   #0,T9_STATE(A0)
				bne     T9_RESTORE
				;phase 1
T9_DEFROST:			move    T9_SPEED(A0),TK_VAR_SPEED(A1)   ; restore speed
                                move.b  #$FF,T9_STATE(A0)               ; set state to 'restore energy'
                                move    #(T9_DELAY/TK_CYCLE),T9_TIMEOUT(A0)     ;reset timeout
                                bra     T9_NEXT
                                ;phase 2
T9_RESTORE:                     add     #TK_FREEZE_PW,TK_VAR_POWER(A1)          ; restore energy                                
				;remove itself
				move    #1,D0
				trap    #0

; End by switching to next task
T9_NEXT:        		move.b	#3, D0
				trap	#0		
* ----------------------------------------------------------
* ----------------------------------------------------------
T9_INIT:
* Task 9 initialization
* ----------------------------------------------------------
; Store task ID. When switching to a task, the ID is in D1, but
; storing in shared memory makes things easier.
				move.b	D1, TK_VAR_ID(A0)
; Store the task type
				move.b	#TK_TYPE_FREEZE, TK_VAR_TYPE(A0)				
; Remember next time will not be the first one
				move.b	#$ff, TK_VAR_FIRST_TIME(A0)
                                
                                move    TK_VAR_SPEED(A1),T9_SPEED(A0)           ; save speed
                                clr     TK_VAR_SPEED(A1)                        ; set speed to 0
                                move    #(T9_DELAY/TK_CYCLE),T9_TIMEOUT(A0)     ;set timeout
                                sub     #TK_FREEZE_PW,TK_VAR_POWER(A1)          ; consume energy
                                clr.b   T9_STATE(A0)                            ; set state to 'freeze'
; End by switching to next task
				move.b	#3, D0
				trap	#0		
* ----------------------------------------------------------
************************************************************
*                            TASK 10                        *
************************************************************
; ==========================================================
; Task 10 constants
; ==========================================================
;memory offsets
T10_TIMEOUT     EQU     4
T10_X           EQU     6
T10_Y           EQU     8    
T10_STATE       EQU     10
;time
T10_DELAY       EQU     50 ; 0.5 seconds
;draw
T10_COLOR       EQU     $00FF33CC
; ==========================================================
; Task 10 functions
; ==========================================================
* ----------------------------------------------------------
T10_START:
* Task 10 entry point.
* launch a laser beam which destroys each enmey on his way
* First time:
* - get x,y from ship
* Further executions
* - state 0: if timeout then paint laser line
* - state 1(FF): if timeout' then restores energy
* ----------------------------------------------------------
				cmp.b	#0, TK_VAR_FIRST_TIME(A0)
				beq	T10_INIT
				
                                cmp     #0,T10_TIMEOUT(A0)
				beq     T10_CHECK_STATE
				sub     #1,T10_TIMEOUT(A0)       ; updates timeout
				
				cmp.b   #0,T10_STATE(A0)
				beq     T10_LASER
				bra     T10_NEXT
				
				;time expired
T10_CHECK_STATE: 		cmp.b   #0,T10_STATE(A0)
				bne     T10_RESTORE
				bra     T10_LASER_END
				
T10_LASER:                      ;draw a line
				TK_SET_PEN      #T10_COLOR
				TK_DRAW_LINE    T10_X(A0),T10_Y(A0), T10_X(A0),#0 
				move.l  A1,A2                                           ; save shared memory pointer
				
			        ; check if there's enemies to kill
                                move.b  #6,D0                                           ; get first task info
                                trap    #0                                
                                
T10_KILL_CHECK:                 move.b  D1,D5                                           ; copy index of current task for T10_CHECK_NEXT
                                cmp.b   #TK_TYPE_ENEM, TK_VAR_TYPE(A1)                  ;it's enemy?
                                bne     T10_CHECK_NEXT                                   ;no, next task
                                ; it's enemy... check distance                                 
                                move    T4_X(A1),D0                                
                                bsr     T10_CHECK_CONTACT
                                cmp     #0,D0
                                beq     T10_CHECK_NEXT                                   ; doesn't touch the enemy                                
; kill the enemy
                                move    T4_X(A1),D2
                                move    T4_Y(A1),D6
                                move.b  TK_VAR_ID(A1),D7
                                ; add explosion
                                sub     #1,TK_VAR_ENEM(A2)                              ; updates remaining enemies
                                lea	T7_START, A0
			        move.b	#0, D0
			        trap	#0
			        move.b  #5,D0
			        trap    #0
			        ; asign same position of killed enemy
			        move    D2,T7_X(A0)
			        move    D6,T7_Y(A0)
			        ; remove enemy
			        move.b  D7,D1
			        move.b	#1, D0
			        trap	#0
                                
T10_CHECK_NEXT:                 move.b  D5,D1                                           ; restore index
                                move.b  #7,D0                                           ; get next task info
                                trap    #0
                                cmp.b   #$FF,D1
                                bne     T10_KILL_CHECK                                   ; not last task
                                
                                move.b  #4,D0
                                trap    #0                      ; restore info   
                                bra     T10_NEXT
                                
				;end phase 1
T10_LASER_END:			move.b  #$FF,T10_STATE(A0)                              ; set state to 'restore energy'
                                move    #(T10_DELAY*8/TK_CYCLE),T10_TIMEOUT(A0)           ;reset timeout
                                bra     T10_NEXT                                         
                                ;phase 2
T10_RESTORE:                     add     #TK_LASER_PW,TK_VAR_POWER(A1)                  ; restore energy                                
				;remove itself
				move.b  #4,D0
				trap    #0
				move.b  #1,D0
				trap    #0
		

; End by switching to next task
T10_NEXT:        		move.b	#3, D0
				trap	#0		
* ----------------------------------------------------------
* ----------------------------------------------------------
T10_CHECK_CONTACT:
* indicates if the enemy with position D0=X,D1=Y touch the beam on D3=X(return $FFFF)
* modifies: D0,D1
*---------------------------------------------------------------------------

				sub     D3,D0
				bge     T10_CONT_X
				neg     D0
T10_CONT_X:			
; At this point, D0=abs(XBeam-XEnem)
                                move    #((T4_PIXEL_SIZE*TK_ENEM_COLUMNS)/2),D1         ; 1/2 of enemy width 
                                ;add     T10_X(A0),D1
                                cmp     D1,D0
                                bgt     T10_NO_CONTACT
           
                                ;contact
                                move    #$FFFF,D0
                                rts
T10_NO_CONTACT:                 clr     D0
                                rts
* ----------------------------------------------------------
T10_INIT:
* Task 10 initialization
* ----------------------------------------------------------
; Store task ID. When switching to a task, the ID is in D1, but
; storing in shared memory makes things easier.
				move.b	D1, TK_VAR_ID(A0)
; Store the task type
				move.b	#TK_TYPE_LASER, TK_VAR_TYPE(A0)				
; Remember next time will not be the first one
				move.b	#$ff, TK_VAR_FIRST_TIME(A0)
                                
                        move.b  #6,D0                                           ; get first task info
                        trap    #0
                                
T10_CHECK:              cmp.b   #TK_TYPE_PLAYER, TK_VAR_TYPE(A1)                  ;it's ship?
                        beq     T10_GET_DATA
                        move.b  #7,D0                                           ; get next task info
                        trap    #0
                        cmp.b   #$FF,D1
                        bne     T10_CHECK
                        
T10_GET_DATA:            ;recuperamos la info de la task actual
                        move.l  A1,A2   ;salvamos
                        move.b  #4,D0
                        trap    #0
                        ; coger la X de la nave
                        move    T3_VAR_X(A2),T10_X(A0)
                        ;Y de la nave
                        move	#((TK_SCREEN_HEIGHT-T3_PIXEL_SIZE-3)-(TK_NAVE_ROWS*T3_PIXEL_SIZE)/2),T10_Y(A0)
                        
                        move    #(T10_DELAY/TK_CYCLE),T10_TIMEOUT(A0)     ;set timeout
                        sub     #TK_LASER_PW,TK_VAR_POWER(A1)          ; consume energy
                        clr.b   T10_STATE(A0)                            ; set state to 'laser' 
; End by switching to next task
				move.b	#3, D0
				trap	#0		
* ----------------------------------------------------------
************************************************************
*                            TASK 11                       *
************************************************************
; ==========================================================
; Task 11 constants
; ==========================================================
T11_FONT 		EQU	$07	; terminal   
T11_FONT_COLOR          EQU     $00FFFFFF ;white
T11_FONT_SIZE		EQU	$09 	
T11_FONT_STYLE		EQU	$0001	; bold
T11_FONT_PROP		EQU	(T11_FONT*$1000000)+(T11_FONT_SIZE*$10000)+T11_FONT_STYLE		; $040B0001
T11_COLOR		EQU	$00FFFFFF   ;constants
T11_FONT_2_SIZE		EQU	$12 	; 18
T11_FONT_2_STYLE	EQU	$0001	; bold
T11_FONT_2_COLOR        EQU     $00FF6600

;happy end strings
T11_STRING              dc.b    'Congratulations!!! You saved the day by killing:',0
T11_STRING_2            dc.b    ' poor innocent aliens...',0
T11_STRING_3            dc.b    ' Not cool, men', 0
;bad end strings
T11_BAD_STRING          dc.b    'You are dead', 0
T11_BAD_STRING_2        dc.b    'The aliens will invade the earth and kill everyone', 0
T11_BAD_STRING_3        dc.b    'Well.. at least you would not see it', 0
                        ds.w    0 ;word align

; ==========================================================
; Task 11 functions
; ==========================================================
* ----------------------------------------------------------
T11_START:
* Task 11 entry point.
* launches the final game sceen
* ----------------------------------------------------------
		cmp.b	#0, TK_VAR_FIRST_TIME(A0)
		beq	T11_INIT
                ;set font properties
		move.b	#21,D0
		move.l	#T11_FONT_COLOR,D1
		move.l	#T11_FONT_PROP,D2				
		trap	#15
                TK_LOCATE #2,#10
		
		cmp     #0, TK_VAR_ENEM(A1)
		beq     T11_BAD
		
		;print strings
		lea     T11_STRING,A1
		move.b  #13,D0
		trap    #15
		
		;print number of aliens killed
		TK_LOCATE #20,#11
		
		clr.l     D1
		move.b  #1,D2
		move.w  TK_VAR_ENEM(A1),D1
		move.b  #4,D2
		move.b  #20,D0
		trap    #15
		TK_LOCATE #2,#13

		;print the last strings
		lea     T11_STRING_2,A1
		move.b  #13,D0
		trap    #15
		TK_LOCATE #2,#15

                lea     T11_STRING_3,A1
                move.b  #14,D0
                trap    #15
                ;jump to draw explosion
                bra     T11_EXP
                
T11_BAD:        ;print strings
		lea     T11_BAD_STRING,A1
		move.b  #13,D0
		trap    #15
		TK_LOCATE #2,#11

		;print the last strings
		lea     T11_BAD_STRING_2,A1
		move.b  #13,D0
		trap    #15
		TK_LOCATE #2,#14

                lea     T11_BAD_STRING_3,A1
                move.b  #14,D0
                trap    #15

T11_EXP:        

                ;draw explosion, to make more dramatic
                
; End by switching to next task
		move.b	#3, D0
		trap	#0
* ----------------------------------------------------------
T11_INIT:
* Task 11 initialization
* ----------------------------------------------------------
; Store task ID. When switching to a task, the ID is in D1, but
; storing in shared memory makes things easier.
				move.b	D1, TK_VAR_ID(A0)
; Store the task type
				move.b	#TK_TYPE_MENU2, TK_VAR_TYPE(A0)				
*; Remember next time will not be the first one
				move.b	#$ff, TK_VAR_FIRST_TIME(A0)

				TK_SET_FILL	#T11_COLOR
*                                
*; End by switching to next task
				move.b	#3, D0
				trap	#0		



































*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~8~
