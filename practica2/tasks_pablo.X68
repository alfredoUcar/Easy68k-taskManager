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
TK_INFO_SCREEN_WIDTH            EQU     140
; Task types
TK_TYPE_MENU			EQU	0
TK_TYPE_SCREEN			EQU	1
TK_TYPE_ENEM			EQU	2
TK_TYPE_PLAYER                  EQU     3
TK_TYPE_SHOT                    EQU     4
TK_TYPE_CONTROL                 EQU     5
; Game configuration for each level
;LEVEL 1
TK_EASY_SPEED                   EQU     3
TK_EASY_ENEM                    EQU     25
TK_EASY_POWER                   EQU     20
;LEVEL 2
TK_MEDIUM_SPEED                 EQU     2
TK_MEDIUM_ENEM                  EQU     50
TK_MEDIUM_POWER                 EQU     15  
;LEVEL 3
TK_HARD_SPEED                   EQU     1
TK_HARD_ENEM                    EQU     100
TK_HARD_POWER                   EQU     10                 
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
			move.l	#15, D1
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
T1_STR_COPYRIGHT		dc.b	'�antoil',10,13,'Made by Pablo Riutort & Alfredo Ucendo',0

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
                                ;start the game
                                cmp.b	#1,T1_OPTION(A0)
				beq	T1_START_EASY
				
				cmp.b	#2,T1_OPTION(A0)
				bne     T1_START_HARD
				
				;start on medium mode
				move.w  #TK_MEDIUM_SPEED,TK_VAR_SPEED(A1)
				move.w  #TK_MEDIUM_ENEM,TK_VAR_ENEM(A1)
				move.w  #TK_MEDIUM_POWER,TK_VAR_POWER(A1)
				bra     T1_START_GAME
				
T1_START_EASY:			;start on easy mode
				move.w  #TK_EASY_SPEED,TK_VAR_SPEED(A1)
				move.w  #TK_EASY_ENEM,TK_VAR_ENEM(A1)
				move.w  #TK_EASY_POWER,TK_VAR_POWER(A1)
				bra     T1_START_GAME
				
T1_START_HARD:			;start on hard mode
				move.w  #TK_HARD_SPEED,TK_VAR_SPEED(A1)
				move.w  #TK_HARD_ENEM,TK_VAR_ENEM(A1)
				move.w  #TK_HARD_POWER,TK_VAR_POWER(A1)

T1_START_GAME:                  
			        lea	T4_START, A0
			        move.b	#0, D0
			        trap	#0

                                lea	T5_START, A0
			        move.b	#0, D0
			        trap	#0	
			        
			        ;get current task info
			        move.b  #4,D0
                                trap    #0
		
			        ; remove menu task(itself)
                                move.b  TK_VAR_ID(A0),D1
                                move.b  #1,D0
                                trap    #0
                                ENDI


; End by switching to next task
T1_NEXT:			move.b	#3, D0
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
* ----------------------------------------------------------
************************************************************
*                            TASK 3                        *
************************************************************
; ==========================================================
; Task 3 constants
; ==========================================================
;memory offsets:
T3_X                    EQU     4
T3_Y                    EQU     6
;draw:
T3_PIXEL_SIZE		EQU	4
T3_SPEED                EQU     1
T3_COLOR_1              EQU     $00FF6600
T3_COLOR_2              EQU     $00AA0000

; ==========================================================
; Task 3 functions
; ==========================================================

* ----------------------------------------------------------
T3_START:
* Task 3 entry point.
* An enemy that moves down to reach the ship
* First time:
* - Init position(random)
* Further executions
* - moves down
* Note: This task must be added to Task Manager after all those
*       tasks that paint something on screen
* ----------------------------------------------------------
				cmp.b	#0, TK_VAR_FIRST_TIME(A0)
				beq	T3_INIT
; draw enemy	
				move.b	#T3_PIXEL_SIZE,TK_PIXEL(A1) 	; set global pixel
				; set global color
				move.l	#T3_COLOR_1,TK_VAR_COLOR_1(A1) 	; pixel pen
				move.l	#T3_COLOR_2,TK_VAR_COLOR_2(A1)	        ; pixel fill
				move	T3_X(A0),D0		; set x
				swap	D0
				move	T3_Y(A0),D0 	        ; set y				
				bsr	TK_DRAW_ENEM

; updates position(move down)
                                add     #T3_SPEED,T3_Y(A0)
; End by switching to next task
				move.b	#3, D0
				trap	#0
								
* ----------------------------------------------------------
T3_RANDOM:
* return a random number between two limits
* pre:  D0.W min limit 
*       D1.W max limit
* post: D0.W result
* ----------------------------------------------------------
                movem.w D1-D3,-(A7)             ; push
                
                move    D1,D2                   ; copy
                move    D0,D4
                move.b  #8,D0
		trap    #15                     ; get time
		move    D4,D0
                clr     D3
		move.b  TK_VAR_ID(A0),D3
		add     #1,D3                   ; avoid case ID=0 for next operations
		;mulu    TK_VAR_POWER(A1),D3     ; (my ID)*(current power)
		and.l   #$0000FFFF,D1
		and.l   #$0000FFFF,D3
		divu    D3,D1
		sub     D0,D2                   ; max-min
		and.l   #$0000FFFF,D2
		divu    D2,D1                   
		swap    D1
		add     D1,D0
		and.l   #$0000FFFF,D0           ; clear high word
		
		movem.w (A7)+,D1-D3             ; pop
                rts
		
* ----------------------------------------------------------
T3_INIT:
* Task 2 initialization
* ----------------------------------------------------------
; Store task ID. When switching to a task, the ID is in D1, but
; storing in shared memory makes things easier.
				move.b	D1, TK_VAR_ID(A0)
; Store the task type
				move.b	#TK_TYPE_SCREEN, TK_VAR_TYPE(A0)				
; Remember next time will not be the first one
				move.b	#$ff, TK_VAR_FIRST_TIME(A0)				
; Set initial position and size
                                move    #((TK_ENEM_ROWS*T3_PIXEL_SIZE)/2),T3_Y(A0)      ; set y
                                move    #(TK_SCREEN_WIDTH-TK_INFO_SCREEN_WIDTH),D0      ; game window width
                                move    #(TK_ENEM_COLUMNS*T3_PIXEL_SIZE+20),D1          ; width needed by enemy
                                divu    D1,D0                                           ; max enemies by row
                                move    D1,D2                                           ; copy
                                move    D0,D1
                                move    #1,D0
                                bsr     T3_RANDOM                                       ; random between 1 and enems_by_row
                                move    #TK_INFO_SCREEN_WIDTH,D1
                                sub     #1,D0
                                mulu    D2,D0
                                divu    #2,D2
                                add     D2,D0
                                add     D1,D0
                                move    D0,T3_X(A0)                                     ; set x
; End by switching to next task
				move.b	#3, D0
				trap	#0				
* ----------------------------------------------------------
************************************************************
*                            TASK 4                        *
************************************************************
; ==========================================================
; Task 4 constants
; ==========================================================
T4_COLOR        EQU     $00FFFFFF
;memory offsets:
; ==========================================================
; Task 4 functions
; ==========================================================
* ----------------------------------------------------------
T4_START:
* Task 4 entry point.
* Manage game: add enemies, pause/resume game...
* First time:
* - Init double buffer
* - Clears hidden buffer
* Further executions
* - Shows graphics
* ----------------------------------------------------------
				cmp.b	#0, TK_VAR_FIRST_TIME(A0)
				beq	T4_INIT
				
				TK_SET_PEN      #T4_COLOR
				TK_DRAW_LINE    #TK_INFO_SCREEN_WIDTH,#0,#TK_INFO_SCREEN_WIDTH,#TK_SCREEN_HEIGHT       
				
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
				move.b	#TK_TYPE_SCREEN, TK_VAR_TYPE(A0)				
; Remember next time will not be the first one
				move.b	#$ff, TK_VAR_FIRST_TIME(A0)
				
				move        #3,D2               ; number of enemies to add

; @FIXME: ENTRY POINT OF ALL TASKS!!
T4_ADD_ENEM:			lea         T3_START, A0
			        move.b	    #0, D0
        			trap	    #0
        			dbra        D2,T4_ADD_ENEM 

; End by switching to next task
				move.b	#3, D0
				trap	#0		
				
************************************************************
*                            TASK 5                        *
************************************************************

; ==========================================================
; Task 5 constants
; ==========================================================
SHIP_SIZE	EQU	20
T5_VAR_X	EQU	4
T5_VAR_SX	EQU	6
;draw:
T5_PIXEL_SIZE		EQU	4
T5_COLOR_1              EQU     $00AAAA00
T5_COLOR_2              EQU     $00AAAA00
; ==========================================================
; Task 5 functions
; ==========================================================

* ----------------------------------------------------------
T5_START:
* Task 5 entry point.
* Draws a ship on the bottom of the screen
* ----------------------------------------------------------
; Vemos si es la primera vez que se ha iniciado esta tarea

				cmp.b	#0, TK_VAR_FIRST_TIME(A0)
				beq	T5_INIT
; if not first time
; draw ship
				move.b #T5_PIXEL_SIZE,TK_PIXEL(A1)
;set colors and draw
*				move.l	#T5_COLOR_1,TK_VAR_COLOR_1(A1)
*				move.l	#T5_COLOR_2,TK_VAR_COLOR_2(A1)
				move	T5_VAR_X(A0),D0	;set X
				bsr	TK_DRAW_NAVE
; uptade ship position
*				move.w	T5_VAR_Y(A0), D1
*				add.w	D1, T5_VAR_Y(A0)	; Y=Y+SY	
				
;capturamos del teclado
				
				; Check for up/down keys	
				move.b	#19, D0
				move.l	#$26<<24+$26<<16+$28<<8+$28,D1
				trap	#15
								
T5_CHECK_INTRO:                 ;check for intro key
                                move.b	#19, D0
				move.l	#$D<<24+$D<<16+$D<<8+$D,D1
				trap	#15
				
				BTST.L #24,D1     ; test for 'intro'
                                IF <NE> THEN      ; if 'intro'
                                                  ;start the game
                                bsr	T6_START
				
T5_LIMLEFT:		move    #(TK_SCREEN_WIDTH-TK_INFO_SCREEN_WIDTH),D0
			bsr	TK_DRAW_NAVE
			
T5_LIMRIGHT:		move    #(TK_SCREEN_WIDTH-SHIP_SIZE),D0
			bsr	TK_DRAW_NAVE


* ----------------------------------------------------------
T5_INIT:
* Task 5 initialization
* 
* Pone la nave en las coordenadas indicadas
* ----------------------------------------------------------
; Store task ID. When switching to a task, the ID is in D1, but
; storing in shared memory makes things easier.
			move.b	D1, TK_VAR_ID(A0)
; store the task type
			move.b #TK_TYPE_SCREEN, TK_VAR_TYPE(A0)
; la siguiente vez que volvamos a esta task, no sera la primera
			move.b	#$FF, TK_VAR_FIRST_TIME(A0)
; set initial position of the ship
			move    #((TK_ENEM_ROWS*T5_PIXEL_SIZE)/2),T5_VAR_X(A0)      ; set y
			move    #(TK_SCREEN_WIDTH-TK_INFO_SCREEN_WIDTH),D0      ; game window width
                       	move    #(TK_ENEM_COLUMNS*T5_PIXEL_SIZE+20),D1        ; width needed by enemy
                       	move    #TK_INFO_SCREEN_WIDTH,D1
                        sub     #1,D0
                        mulu    D2,D0
                        divu    #2,D2
                        add     D2,D0
                        add     D1,D0
                        move    D0,T5_VAR_X(A0)

; switch
			move.b	#3,D0
			trap	#0
			
				
************************************************************
*                            TASK 6                        *
************************************************************

; ==========================================================
; Task 6 constants
; ==========================================================
T6_VAR_Y	EQU	4
TY_VAR_SY	EQU	6
;draw:
T6_PIXEL_SIZE		EQU	4
; ==========================================================
; Task 6 functions
; ==========================================================

* ----------------------------------------------------------
T6_START:
* Task 5 entry point.
* Draws a laser beam from the position of the ship
* ----------------------------------------------------------
; Vemos si es la primera vez que se ha iniciado esta tarea
				cmp.b	#0, TK_VAR_FIRST_TIME(A0)
				beq	T6_INIT
; if not first time
; draw ship
				move.b #T6_PIXEL_SIZE,TK_PIXEL(A1)
;set colors and draw
				move	T5_VAR_X(A0),D0	;set X = ship's X
				bsr	TK_DRAW_DISPARO
; uptade beam position
*				move.w	T6_VAR_Y(A0), D1
*				add.w	D1, T6_VAR_Y(A0)	; Y=Y+SY	
				
* ----------------------------------------------------------
T6_INIT:
* Task 6 initialization
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
			move    #((TK_ENEM_ROWS*T5_PIXEL_SIZE)/2),T5_VAR_X(A0)      ; set y
			move    #(TK_SCREEN_WIDTH-TK_INFO_SCREEN_WIDTH),D0      ; game window width
                       	move    #(TK_ENEM_COLUMNS*T5_PIXEL_SIZE+20),D1        ; width needed by enemy
                       	move    #TK_INFO_SCREEN_WIDTH,D1
                        sub     #1,D0
                        mulu    D2,D0
                        divu    #2,D2
                        add     D2,D0
                        add     D1,D0
                        move    D0,T6_VAR_Y(A0)

; switch
			move.b	#3,D0
			trap	#0

















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~8~
