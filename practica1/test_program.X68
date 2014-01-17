*-----------------------------------------------------------
* Program    :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
	ORG	$1000
	OPT	MEX
	
; ================
; Lists parameters
; ================	
TPR_LIST_WORDS_HEADER:		EQU	2	

TPR_LIST_ITEM_SIZE1:		EQU	1	
TPR_LIST_LIST_SIZE1:		EQU	135	
TPR_LIST_WORDS_TOTAL1:		EQU     TPR_LIST_WORDS_HEADER+TPR_LIST_LIST_SIZE1*(TPR_LIST_ITEM_SIZE1+1) 

TPR_LIST_ITEM_SIZE2:		EQU	4	
TPR_LIST_LIST_SIZE2:		EQU	10	
TPR_LIST_WORDS_TOTAL2:		EQU     TPR_LIST_WORDS_HEADER+TPR_LIST_LIST_SIZE2*(TPR_LIST_ITEM_SIZE2+1) 

TPR_LIST_ITEM_SIZE3:		EQU	7	
TPR_LIST_LIST_SIZE3:		EQU	65	
TPR_LIST_WORDS_TOTAL3:		EQU     TPR_LIST_WORDS_HEADER+TPR_LIST_LIST_SIZE3*(TPR_LIST_ITEM_SIZE3+1) 

TPR_LIST_ITEM_SIZE4:		EQU	10
TPR_LIST_LIST_SIZE4:		EQU	150
TPR_LIST_WORDS_TOTAL4:		EQU     TPR_LIST_WORDS_HEADER+TPR_LIST_LIST_SIZE4*(TPR_LIST_ITEM_SIZE4+1)

; ================================
; Include the LIST.X68 to evaluate
; ================================	
				include "list.X68"
				
; --------------------------------------------------
TPR_INIT_LISTS:
; --------------------------------------------------
		movem.l	D0-D7/A0-A6, -(A7)
		; Init the list 1
		move.w	#TPR_LIST_ITEM_SIZE1, -(A7)
		move.w	#TPR_LIST_LIST_SIZE1, -(A7)
		move.l	#TPR_LIST1, -(A7)	
		bsr	LS_INIT
		; Restore stack
		addq.l	#8, A7
		
		; Init the list 2
		move.w	#TPR_LIST_ITEM_SIZE2, -(A7)
		move.w	#TPR_LIST_LIST_SIZE2, -(A7)
		move.l	#TPR_LIST2, -(A7)	
		bsr	LS_INIT
		; Restore stack
		addq.l	#8, A7

		; Init the list 3
		move.w	#TPR_LIST_ITEM_SIZE3, -(A7)
		move.w	#TPR_LIST_LIST_SIZE3, -(A7)
		move.l	#TPR_LIST3, -(A7)	
		bsr	LS_INIT
		; Restore stack
		addq.l	#8, A7
		
		; Init the list
		move.w	#TPR_LIST_ITEM_SIZE4, -(A7)
		move.w	#TPR_LIST_LIST_SIZE4, -(A7)
		move.l	#TPR_LIST4, -(A7)	
		bsr	LS_INIT
		; Restore stack
		addq.l	#8, A7
		movem.l	(A7)+, D0-D7/A0-A6
		rts
; --------------------------------------------------

; --------------------------------------------------
TPR_LIST_ITEM_COUNT:
; --------------------------------------------------
; Input: A0: List pointer
; Output: D0.W: Num occupied items
; Modifies: Nothing except the output register
; --------------------------------------------------
		movem.l	D0-D7/A0-A6, -(A7)
		clr.l	D2		; Counter	
		clr.l	D1
		clr.l	D0
		move.w	(A0)+, D0	; List size
		move.w	(A0)+, D1	; Item size
		lsl.l	#1, D1	
.LOOP:		move.w	(A0)+, D3
		cmp.w	#$FFFF, D3
		bne	.NEXT
		addq.w	#1, D2
.NEXT:		subq.w	#1, D0
		beq	.END
		adda.l	D1, A0
		bra	.LOOP				
.END:		move.w	D2, 2(A7)
 		movem.l	(A7)+, D0-D7/A0-A6
 		rts
; --------------------------------------------------

; --------------------------------------------------
TPR_PUT_NITEMS:
; --------------------------------------------------
; Input: 	A0: List pointer
; 		D2.W: Number of items to put
; Output:	A0: Pointer to the last item
; --------------------------------------------------
		movem.l	D0-D7/A1-A6, -(A7)
		clr.l	D0
		clr.l	D1
		move.w	(A0)+, D0	; List size
		move.w	(A0)+, D1	; Item size
		lsl.l	#1, D1
		subq.w	#1, D2
.LOOP:		move.w	#$FFFF, (A0)+	; Put item
		adda.l	D1, A0		; Next item		
		dbra	D2, .LOOP
		suba.l	D1, A0
		suba.l	#2, A0
		movem.l	(A7)+, D0-D7/A1-A6
		rts
; --------------------------------------------------


; --------------------------------------------------
TPR_FIRST_TEST:
; --------------------------------------------------
; Does a LS_FIRST on an empty list
; --------------------------------------------------
; Input: A0: List pointer
;        A2: String pointer if OK
;        A3: String pointer if failure
; --------------------------------------------------
		movem.l	D0-D7/A0-A6, -(A7)
		move.l	A0, -(A7)
		bsr 	LS_FIRST
		move.l	(A7)+, D0
		cmp.l	#$FFFFFFFF, D0
		beq	.OK
		move.l	A3, A1
		bra	.CONT
.OK:		move.l	A2, A1
.CONT:		move.b	#13, D0
		trap	#15
		movem.l	(A7)+, D0-D7/A0-A6
		rts		
; --------------------------------------------------

; --------------------------------------------------
TPR_SECOND_TEST:
; --------------------------------------------------
; Does a LS_NEXT on the last item
; --------------------------------------------------
; Input: A0: List pointer
;	 A1: Last item pointer
;        A2: String pointer if OK
;        A3: String pointer if failure
; --------------------------------------------------
		movem.l	D0-D7/A0-A6, -(A7)
		move.l	A1, -(A7)
		move.l	A0, -(A7)
		bsr 	LS_NEXT
		add.l	#4, A7
		move.l	(A7)+, D0
		cmp.l	#$FFFFFFFF, D0
		beq	.OK
		move.l	A3, A1
		bra	.CONT
.OK:		move.l	A2, A1
.CONT:		move.b	#13, D0
		trap	#15
		movem.l	(A7)+, D0-D7/A0-A6
		rts		
; --------------------------------------------------

; --------------------------------------------------
TPR_THIRD_TEST:
; Checks if first item pointer es returned correctly
; assuming first physical item is occupued
; --------------------------------------------------
; Input: A0: List pointer
;        A2: String pointer if OK
;        A3: String pointer if failure
; --------------------------------------------------
		movem.l	D0-D7/A0-A6, -(A7)
		move.l	A0, -(A7)
		bsr	LS_FIRST
		move.l	(A7)+, A1
		adda.l	#4, A0
		cmp.l	A1, A0
		beq	.OK
		move.l	A3, A1
		bra	.CONT
.OK:		move.l	A2, A1
.CONT:		move.b	#13, D0
		trap	#15
		movem.l	(A7)+, D0-D7/A0-A6
		rts				
; --------------------------------------------------

; --------------------------------------------------
TPR_FOURTH_TEST:
; Does a FIRST, a REMOVE and a FIRST again
; --------------------------------------------------
; Input: A0: List pointer
;        A2: String pointer if OK
;        A3: String pointer if failure
; --------------------------------------------------
		movem.l	D0-D7/A0-A6, -(A7)
		clr.l	D2
		move.w	2(A0), D2	; Item size
		addq.w	#1, D2
		lsl.l	#1, D2		; Item size + occupied in bytes
		move.l	A0, -(A7)
		bsr 	LS_FIRST
		move.l	(A7), D0
		cmp.l	#$FFFFFFFF, D0
		beq	.FAIL0
		bsr	LS_REMOVE
		adda.l	#4, A7	; Restore stack
		move.l	A0, -(A7)
		bsr	LS_FIRST
		move.l	(A7)+, D1
		sub.l	D0, D1
		cmp.l	D1, D2
		bne	.FAIL1
		move.l	A2, A1
		bra	.CONT	
.FAIL0:		adda.l	#4, A7
.FAIL1:		move.l	A3, A1		
.CONT:		move.b	#13, D0
		trap	#15
		movem.l	(A7)+, D0-D7/A0-A6
		rts				
; --------------------------------------------------


; --------------------------------------------------
TPR_FIFTH_TEST:
; Check if stack is restored correctly
; --------------------------------------------------
; Input: A0: List pointer
;        A2: String pointer if OK
;        A3: String pointer if failure
; --------------------------------------------------
		movem.l	D0-D7/A0-A6, -(A7)
		move.l	A0, -(A7)
		move.l	A7, A4
		bsr 	LS_FIRST
		move.l	A7, A5		; A4 and A5 should be the same
		bsr	LS_REMOVE
		move.l	A7, A6		; A5 and A6 should be the same
		adda.l	#4, A7
		cmp.l	A4, A5
		bne	.FAIL
		cmp.l	A5, A6
		bne	.FAIL
		move.l	(A6), -(A7)
		move.l	A0, -(A7)
		move.l	A7, A4
		bsr	LS_NEXT
		move.l	A7, A5
		adda.l	#8, A7
		cmp.l	A4, A5
		bne	.FAIL
		move.l	A2, A1
		bra	.CONT
.FAIL:		move.l	A3,A1
.CONT		move.b	#13, D0
		trap	#15		
		movem.l	(A7)+, D0-D7/A0-A6
		rts				
; --------------------------------------------------





	
START:		
		move.b	#13, D0
		move.l	#TPR_STR_HEADER, A1
		trap	#15

		move.b	#13, D0
		move.l	#TPR_STR_SEP, A1
		trap	#15
		
		; Init lists	
		bsr	TPR_INIT_LISTS
		
		; =================================
		; First tests: FIRST on empty lists
		; =================================
		; List 1		
		move.l	#TPR_LIST1, A0
		move.l	#TPR_STR_T1L1OK, A2
		move.l	#TPR_STR_T1L1KO, A3
		bsr	TPR_FIRST_TEST
		; List 2
		move.l	#TPR_LIST2, A0
		move.l	#TPR_STR_T1L2OK, A2
		move.l	#TPR_STR_T1L2KO, A3
		bsr	TPR_FIRST_TEST
		; List 3
		move.l	#TPR_LIST3, A0
		move.l	#TPR_STR_T1L3OK, A2
		move.l	#TPR_STR_T1L3KO, A3
		bsr	TPR_FIRST_TEST
		; List 4
		move.l	#TPR_LIST4, A0
		move.l	#TPR_STR_T1L4OK, A2
		move.l	#TPR_STR_T1L4KO, A3
		bsr	TPR_FIRST_TEST
		
		move.b	#13, D0
		move.l	#TPR_STR_SEP, A1
		trap	#15
		

		; =================================
		; Second tests: NEXT on last item
		; =================================		
		; List 1
		move.l	#TPR_LIST1, A0		
		move.w	#TPR_LIST_LIST_SIZE1-5, D2
		bsr 	TPR_PUT_NITEMS
		move.l	A0, A1
		move.l	#TPR_LIST1, A0
		move.l	#TPR_STR_T2L1OK, A2
		move.l	#TPR_STR_T2L1KO, A3
		bsr	TPR_SECOND_TEST
		; List 2
		move.l	#TPR_LIST2, A0		
		move.w	#TPR_LIST_LIST_SIZE2-5, D2
		bsr 	TPR_PUT_NITEMS
		move.l	A0, A1
		move.l	#TPR_LIST2, A0
		move.l	#TPR_STR_T2L2OK, A2
		move.l	#TPR_STR_T2L2KO, A3
		bsr	TPR_SECOND_TEST
		; List 3
		move.l	#TPR_LIST3, A0		
		move.w	#TPR_LIST_LIST_SIZE3-5, D2
		bsr 	TPR_PUT_NITEMS
		move.l	A0, A1
		move.l	#TPR_LIST3, A0
		move.l	#TPR_STR_T2L3OK, A2
		move.l	#TPR_STR_T2L3KO, A3
		bsr	TPR_SECOND_TEST
		; List 4
		move.l	#TPR_LIST4, A0		
		move.w	#TPR_LIST_LIST_SIZE4-5, D2
		bsr 	TPR_PUT_NITEMS
		move.l	A0, A1
		move.l	#TPR_LIST4, A0
		move.l	#TPR_STR_T2L4OK, A2
		move.l	#TPR_STR_T2L4KO, A3
		bsr	TPR_SECOND_TEST

		move.b	#13, D0
		move.l	#TPR_STR_SEP, A1
		trap	#15

		
		; =================================
		; Third test: FIRST if first occupied
		; =================================
		; List 1				
		move.l	#TPR_LIST1, A0
		move.l	#TPR_STR_T3L1OK, A2
		move.l	#TPR_STR_T3L1KO, A3
		bsr	TPR_THIRD_TEST
		; List 2				
		move.l	#TPR_LIST2, A0
		move.l	#TPR_STR_T3L2OK, A2
		move.l	#TPR_STR_T3L2KO, A3
		bsr	TPR_THIRD_TEST
		; List 3				
		move.l	#TPR_LIST3, A0
		move.l	#TPR_STR_T3L3OK, A2
		move.l	#TPR_STR_T3L3KO, A3
		bsr	TPR_THIRD_TEST
		; List 4				
		move.l	#TPR_LIST4, A0
		move.l	#TPR_STR_T3L4OK, A2
		move.l	#TPR_STR_T3L4KO, A3
		bsr	TPR_THIRD_TEST

		move.b	#13, D0
		move.l	#TPR_STR_SEP, A1
		trap	#15


		; =================================
		; Fourth test: FIRST + REMOVE + TEST
		; =================================
		; List 1						
		move.l	#TPR_LIST1, A0
		move.l	#TPR_STR_T4L1OK, A2
		move.l	#TPR_STR_T4L1KO, A3
		bsr	TPR_FOURTH_TEST
		; List 2						
		move.l	#TPR_LIST2, A0
		move.l	#TPR_STR_T4L2OK, A2
		move.l	#TPR_STR_T4L2KO, A3
		bsr	TPR_FOURTH_TEST
		; List 3						
		move.l	#TPR_LIST3, A0
		move.l	#TPR_STR_T4L3OK, A2
		move.l	#TPR_STR_T4L3KO, A3
		bsr	TPR_FOURTH_TEST
		; List 4						
		move.l	#TPR_LIST4, A0
		move.l	#TPR_STR_T4L4OK, A2
		move.l	#TPR_STR_T4L4KO, A3
		bsr	TPR_FOURTH_TEST

		move.b	#13, D0
		move.l	#TPR_STR_SEP, A1
		trap	#15


		; =================================
		; Fifth test: Stack recovery
		; =================================
		; List 1						
		move.l	#TPR_LIST1, A0
		move.l	#TPR_STR_T5L1OK, A2
		move.l	#TPR_STR_T5L1KO, A3
		bsr	TPR_FIFTH_TEST
		; List 2						
		move.l	#TPR_LIST2, A0
		move.l	#TPR_STR_T5L2OK, A2
		move.l	#TPR_STR_T5L2KO, A3
		bsr	TPR_FIFTH_TEST
		; List 3						
		move.l	#TPR_LIST3, A0
		move.l	#TPR_STR_T5L3OK, A2
		move.l	#TPR_STR_T5L3KO, A3
		bsr	TPR_FIFTH_TEST
		; List 4						
		move.l	#TPR_LIST4, A0
		move.l	#TPR_STR_T5L4OK, A2
		move.l	#TPR_STR_T5L4KO, A3
		bsr	TPR_FIFTH_TEST
		
		move.b	#13, D0
		move.l	#TPR_STR_SEP, A1
		trap	#15
		
		
		
		
		



		
		
	


	MOVE.B	#9,D0
	TRAP	#15		; halt simulator

* Variables and Strings

TPR_LIST1:	ds.w	TPR_LIST_WORDS_TOTAL1
TPR_LIST2:	ds.w	TPR_LIST_WORDS_TOTAL2
TPR_LIST3:	ds.w	TPR_LIST_WORDS_TOTAL3
TPR_LIST4:	ds.w	TPR_LIST_WORDS_TOTAL4

TPR_STR_HEADER: dc.b 'Report',0
TPR_STR_SEP:	dc.b '===============================================',0

TPR_STR_T1L1OK: dc.b '[+] First on empty list 1 OK',0
TPR_STR_T1L2OK: dc.b '[+] First on empty list 2 OK',0
TPR_STR_T1L3OK: dc.b '[+] First on empty list 3 OK',0
TPR_STR_T1L4OK: dc.b '[+] First on empty list 4 OK',0
TPR_STR_T1L1KO: dc.b '[-] First on empty list 1 FAILED',0
TPR_STR_T1L2KO: dc.b '[-] First on empty list 2 FAILED',0
TPR_STR_T1L3KO: dc.b '[-] First on empty list 3 FAILED',0
TPR_STR_T1L4KO: dc.b '[-] First on empty list 4 FAILED',0

TPR_STR_T2L1OK: dc.b '[+] Next on last item list 1 OK',0
TPR_STR_T2L2OK: dc.b '[+] Next on last item list 2 OK',0
TPR_STR_T2L3OK: dc.b '[+] Next on last item list 3 OK',0
TPR_STR_T2L4OK: dc.b '[+] Next on last item list 4 OK',0
TPR_STR_T2L1KO: dc.b '[-] Next on last item list 1 FAILED',0
TPR_STR_T2L2KO: dc.b '[-] Next on last item list 2 FAILED',0
TPR_STR_T2L3KO: dc.b '[-] Next on last item list 3 FAILED',0
TPR_STR_T2L4KO: dc.b '[-] Next on last item list 4 FAILED',0

TPR_STR_T3L1OK: dc.b '[+] LS_FIRST if first occupued on list 1 OK',0
TPR_STR_T3L2OK: dc.b '[+] LS_FIRST if first occupued on list 2 OK',0
TPR_STR_T3L3OK: dc.b '[+] LS_FIRST if first occupued on list 3 OK',0
TPR_STR_T3L4OK: dc.b '[+] LS_FIRST if first occupued on list 4 OK',0
TPR_STR_T3L1KO: dc.b '[-] LS_FIRST if first occupued on list 1 FAILED',0
TPR_STR_T3L2KO: dc.b '[-] LS_FIRST if first occupued on list 2 FAILED',0
TPR_STR_T3L3KO: dc.b '[-] LS_FIRST if first occupued on list 3 FAILED',0
TPR_STR_T3L4KO: dc.b '[-] LS_FIRST if first occupued on list 4 FAILED',0

TPR_STR_T4L1OK: dc.b '[+] LS_FIRST + LS_REMOVE + LS_FIRST on list 1 OK',0
TPR_STR_T4L2OK: dc.b '[+] LS_FIRST + LS_REMOVE + LS_FIRST on list 2 OK',0
TPR_STR_T4L3OK: dc.b '[+] LS_FIRST + LS_REMOVE + LS_FIRST on list 3 OK',0
TPR_STR_T4L4OK: dc.b '[+] LS_FIRST + LS_REMOVE + LS_FIRST on list 4 OK',0
TPR_STR_T4L1KO: dc.b '[-] LS_FIRST + LS_REMOVE + LS_FIRST on list 1 FAILED',0
TPR_STR_T4L2KO: dc.b '[-] LS_FIRST + LS_REMOVE + LS_FIRST on list 2 FAILED',0
TPR_STR_T4L3KO: dc.b '[-] LS_FIRST + LS_REMOVE + LS_FIRST on list 3 FAILED',0
TPR_STR_T4L4KO: dc.b '[-] LS_FIRST + LS_REMOVE + LS_FIRST on list 4 FAILED',0

TPR_STR_T5L1OK: dc.b '[+] Stack recovery on list 1 OK',0
TPR_STR_T5L2OK: dc.b '[+] Stack recovery on list 2 OK',0
TPR_STR_T5L3OK: dc.b '[+] Stack recovery on list 3 OK',0
TPR_STR_T5L4OK: dc.b '[+] Stack recovery on list 4 OK',0
TPR_STR_T5L1KO: dc.b '[-] Stack recovery on list 1 FAILED',0
TPR_STR_T5L2KO: dc.b '[-] Stack recovery on list 2 FAILED',0
TPR_STR_T5L3KO: dc.b '[-] Stack recovery on list 3 FAILED',0
TPR_STR_T5L4KO: dc.b '[-] Stack recovery on list 4 FAILED',0






	END	START		; last line of source





*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~8~
