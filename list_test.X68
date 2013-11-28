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
			INCLUDE	"list.x68"	; List library
			INCLUDE "list_plot.x68" ; User interaction library
************************************************************

************************************************************
*                       MAIN PROGRAM                       *
************************************************************
START:		; Fill list with some random stuff.
		;bsr	TST_FILL_LIST		
		
		; Install user interface (basically, install mouse and prepare screen)
		bsr 	LP_INSTALL		
				
		;move.w	#TST_DEF_ELEM, -(A7)	; PUSH del elemento que se quiere guardar en la lista
		;move.l	#TST_LIST, -(A7) 	; PUSH the list pointer so that next function can access it.
		move.l	#TST_LIST_SAMPLE, -(A7) 	; PUSH the list pointer so that next function can access it.
		
		;jsr LS_PUT
		
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

*-----------------------------------------------------------
TST_CLEAR_DB:
* Pone a 0 la variable 'TST_DATA_BLOK'
* Pre: 
* Post: 
* Modifies: Nothing
*-----------------------------------------------------------
		move.w	D0, -(A7)	; push
		move.l	A0, -(A7)	
		
		clr.w	D0		; contador ascendente desde 0
.LOOP:		clr.w	(A0)+	
		add.w 	#1, D0		; contador++
		cmp.w	#TST_LIST_ITEM_SIZE, D0
		bne	.LOOP		; si (contador = M) fin
		
		move.l	(A7)+, A0	; pop
		move.w (A7)+, D0
		rts
*-----------------------------------------------------------


************************************************************
*                         VARIABLES                        *
************************************************************
TST_LIST:	ds.w	TST_LIST_WORDS_TOTAL
TST_DATA_BLOK	ds.w	TST_LIST_ITEM_SIZE
TST_DEF_ELEM	dc.w	1,3,2,4,6	;elemento de ejemplo
TST_LIST_SAMPLE dc.w	21,1,$0000,1,$FFFF,2,$FFF0,3,$FFFF,4,$FFFF,5,$FFFF,6,$0000,7,$FFFF,8,$FFFF,9,$FFFF,10,$FFFF,1,$FFFF,2,$FFFF,3,$0000,4,$FFFF,5,$FFFF,6,$0000,7,$FFFF,8,$FFFF,9,$FFFF,10,$FFFF,10
************************************************************
	END	START		; last line of source




















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~8~
