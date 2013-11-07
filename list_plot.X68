************************************************************
*                     LIST PLOT LIBRARY                    *
*==========================================================*
* LIST FORMAT DESCRIPTION:                                 *
* A list is composed of:                                   *
* - Header                                                 *
*   + 1 WORD : List size (N)                               *
*   + 1 WORD : Item size (M)                               *
* - N data blocks, each one composed of:                   *
*   + 1 WORD : Occupied field                              *
*   + M WORDs : The data                                   *
*                                                          *
* The "occupied" field has two possible values:            *
*   + $0000 : The data block is empty and can be used to   *
*             put data                                     *
*   + $FFFF : The data block is occupied and has data      *
************************************************************

************************************************************
*                        CONSTANTS                         *
************************************************************
LP_INITIAL_Y		EQU	200
LP_SCREEN_WIDTH		EQU	640
LP_SCREEN_HEIGHT	EQU	480
************************************************************

*-----------------------------------------------------------
LP_INSTALL:
* Description : Installs the mouse interrupt at ISR 1
* Pre         : 
* Post        : All registers are restored to their initial 
*               values.
*-----------------------------------------------------------
		move.l	#LP_ISR_MOUSE_MOVE, ($64)	; Associate ISR to level 1 interrupt
		
		move.w	#$0106, D1		; Interrupcion 1 cuando se mueve el mouse o se suelta el boton
		move.b	#60, D0
		trap	#15			; habilita la interrupcion

		rts
*-----------------------------------------------------------

*-----------------------------------------------------------
LP_PLOT_LIST:
* Description : Plots the list items, each as a 32x32 rectangle.
*               If the item exists, the rectangle is plot filled.
*               Otherwise, not filled.
* Pre         : Stack. Specified stack offsets correspond to
*               the stack state at the beginning of the sub-
*               routine.
*               Stack offsets from 0 to 3 contain the return 
*               address.
*		  - Offset 4: LONG: List pointer
* Post        : All registers are restored to their initial 
*               values.
* Note        : When calling this subroutine, the first
*               parameter (the pointer) must point to a RAM 
*               area with enough space to store the list. 
*-----------------------------------------------------------



		rts
*-----------------------------------------------------------


*-----------------------------------------------------------
LP_MOUSE_INTERACTION:
* Description : Prints the item to which the mouse is poiting,
*               or nothing is mouse is not pointing to an item,
*               or if the item is empty. Also, if the mouse is
*               clicked on an occupued item, it is cleared.
* Pre         : Stack. Specified stack offsets correspond to
*               the stack state at the beginning of the sub-
*               routine.
*               Stack offsets from 0 to 3 contain the return 
*               address.
*		  - Offset 4: LONG: List pointer
* Post        : All registers are restored to their initial 
*               values.
* Modifies    : Nothing
*-----------------------------------------------------------

		rts
*-----------------------------------------------------------

************************************************************
*                               ISRs                       *
************************************************************
*-----------------------------------------------------------
LP_ISR_MOUSE_MOVE:
* This ISR is called when a MOUSE MOVE event is produced.
* Pre: 
* Post: (LP_MOUSE_CX).W: X coordinate
*       (LP_MOUSE_CY).W: Y coordinate
*       (LP_MOUSE_BUT).B: Mouse button state
* Modifies: Nothing except the Output variables. All registers
*           are restored.
*-----------------------------------------------------------
		movem.l	A0-A1, -(A7)	; push
		movem.w	D0-D1, -(A7)
		
		move.b	#61, D0		; lectura del mouse
		clr.b	D1
		trap	#15
		
		move.l	#LP_MOUSE_CX, A0
		move.l	#LP_MOUSE_CY, A1	
		move.w	D1, A0		; guarda la coordenada X
		swap	D1
		move.w	D1, A0		; guarda la coordenada Y
		move.l	#LP_MOUSE_BUT, A0
		move.b	D0, A0		; guarda el estado del boton
		
		movem.w	(A7)+, D0-D1	; pop
		movem.l	(A7)+, A0-A1
		
		rte		
*-----------------------------------------------------------	

************************************************************
*                         VARIABLES                        *
************************************************************
LP_MOUSE_CX:	ds.w	1
LP_MOUSE_CY:	ds.w	1
LP_MOUSE_BUT:	ds.b	1
		ds.w	0		; Memory alignment
************************************************************	






*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~8~
