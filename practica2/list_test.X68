*-----------------------------------------------------------
* Program    : Main program to test list and list_plot libraries
* Written by : A. Burguera
* Date       : 17-October-2012
* Description: The program fills a list with some random stuff using
*              the "list" library functions. Then, plots the list and
*              interacts with used using the "list_plot" libraries.
*              Everything that depends on list size, items, etc...
*              (including the code in the libraries) MUST refer to
*              the constants defined here.
*              Note that EVERYTHING must work if TST_LIST_ITEM_SIZE or
*              TST_LIST_LIST_SIZE change. 
*              The files included are:
*              + SCREEN.X68: Includes some useful macros for graphics and
*                            text display.
*              + LIST.X68: The list library. It MUST provide, at least, 
*                          the interface functions.
*              + LIST_PLOT.X68: The list plot library. It MUST provide, 
*                          at least, the interface functions.
*-----------------------------------------------------------
			ORG	$1000
			OPT	MEX		; Explicitly expands the macros. Useful for debugging.
************************************************************
*                        CONSTANTS                         *
************************************************************
TST_LIST_ITEM_SIZE:		EQU	5	; How many data words has a data block (excluding occupied field)
TST_LIST_LIST_SIZE:		EQU	144	; How many items has the list
TST_LIST_WORDS_HEADER:		EQU	2	; How many header words (unchangeable, this is fixed for all lists)
TST_LIST_WORDS_TOTAL:		EQU     TST_LIST_WORDS_HEADER+TST_LIST_LIST_SIZE*(TST_LIST_ITEM_SIZE+1) ; Total size, in words, of the list
************************************************************

************************************************************
*                   SOURCE FILE INCLUDES                   *
************************************************************
			INCLUDE "screen.x68"	; Screen management macros
			INCLUDE "list_plot.x68" ; User interaction library
			INCLUDE "taskmanager.x68"
************************************************************

************************************************************
*                       MAIN PROGRAM                       *
************************************************************
START:		; Fill list with some random stuff.
		bsr	IDP_INIT		
		
		; Install user interface (basically, install mouse and prepare screen)
		bsr 	LP_INSTALL
						
		; PUSH the list pointer so that next function can access it.
		move.l	#IDP_IDLIST, -(A7)
		
		; Typical double buffer operation:
		; 1.- Clear screen
		; 2.- Plot things and interact with user
		; 3.- Repaint screen
.LOOP:		SC_CLEAR			; Clear screen
		bsr	LP_PLOT_LIST
		bsr	LP_MOUSE_INTERACTION
		SC_REPAINT_SCREEN
		bra	.LOOP
		
		; Restore stack. Actually not needed here, as the program
		; will never reach this line (previous is infinite loop).
		; However, it is here just to remember that, if an exit condition
		; is put to the loop, then restoring the stack will be necessary.
		addq.l	#4, A7			; Restore stack
			
		MOVE.B	#9,D0
		TRAP	#15		
*-----------------------------------------------------------

************************************************************
*                       AUXILIARY SUBROUTINES              *
************************************************************
*-----------------------------------------------------------
TST_FILL_LIST:
* Puts some stuff in the list
* Pre: 
* Post: 
* Modifies: Nothing
*-----------------------------------------------------------
		movem.l	D0-D7/A0-A6, -(A7)
		; Init the list
		move.w	#TST_LIST_ITEM_SIZE, -(A7)
		move.w	#TST_LIST_LIST_SIZE, -(A7)
		move.l	#TST_LIST, -(A7)	
		bsr	LS_INIT
		; Restore stack
		addq.l	#8, A7

		; Put consecutive values in the first 110 items
		move.w	#109, D0
		clr.w	D1
		
.LOOP:		move.w	#TST_LIST_ITEM_SIZE-1, D2
.LOOP0:		move.w	D1, -(A7)
		addq.w	#1, D1		
		dbf.w	D2, .LOOP0
		move.l	#TST_LIST, -(A7)
		bsr	LS_PUT
		add.l	#TST_LIST_ITEM_SIZE*2+4, A7	; Restore stack		
		dbf	D0, .LOOP
		
		; Remove one each two items, from second onward
		move.l	#TST_LIST, -(A7)
		bsr	LS_FIRST			; Get first item
		move.l	(A7)+, A0
		
		move.b	#$FF, D0			; Flag used to alternate
.LOOP2:		move.l	A0, -(A7)
		move.l	#TST_LIST, -(A7)
		bsr	LS_NEXT				; Next item
		addq.l	#4, A7
		move.l	(A7)+, A0
		cmp.l	#$FFFFFFFF, A0			; If last item, end
		beq	.END
		eor.b	#$FF, D0			; Negate flag
		beq	.REMOVE
		bra	.LOOP2
.END:		movem.l	(A7)+, D0-D7/A0-A6
		rts
.REMOVE:	move.l	A0, -(A7)
		bsr	LS_REMOVE			; If necessary, remove item
		addq.l	#4, A7
		bra	.LOOP2		
*-----------------------------------------------------------
			
		
************************************************************
*                         VARIABLES                        *
************************************************************
TST_LIST:	ds.w	TST_LIST_WORDS_TOTAL
************************************************************
	END	START		; last line of source














*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~8~
