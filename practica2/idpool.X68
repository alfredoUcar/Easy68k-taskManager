************************************************************
*                           ID POOL                        *
*==========================================================*
* User subroutines providing the following functionalities:*
* 1.- IDP_INIT  : Inits the ID Pool by putting consecutive IDs.
* 2.- IDP_GET_ID: Outputs the first available ID.
* 3.- IDP_RELEASE_ID: Puts the specified ID into the list of
*                     available IDs.
* Note:
*  + The list library MUST be available (previously included).
*  + The constant TM_MAX_TASKS (maximum number of tasks) must
*    be defined.
*  + Although the list stores 1 WORD per ID, the ID itself
*    is only a BYTE.
************************************************************

*-----------------------------------------------------------
IDP_INIT:
* Description : Inits the ID Pool by doing:
*               1.- Preparing IDP_IDLIST using LS_INIT
*               2.- Putting consecutive numbers as initially available IDs
* Pre         : Nothing.
* Post        : ID Pool initialized. 
* Modified    : Nothing: all registers are restored.
* Note        : When calling this subroutine, the required constants
*               are assumed to have the correct values.
*-----------------------------------------------------------
	move.w		D0, -(A7)		; PUSH registers
	; Prepare the list
	move.w		#1, -(A7)		; Item size (1 WORD)
	move.w		#TM_MAX_TASKS, -(A7)	; List size
	move.l		#IDP_IDLIST, -(A7)	; ID list pointer
	bsr		LS_INIT
	addq.l		#8, A7			; Restore stack
	
	; Put consecutive IDs
	move.w		#TM_MAX_TASKS-1, D0	; Used to iterate with DBF
	move.w		#0, -(A7)		; First ID
	move.l		#IDP_IDLIST, -(A7)	; ID list
.LOOP:	bsr		LS_PUT
	addq.w		#1, 4(A7)		; Next ID
	move.l		#IDP_IDLIST, (A7)
	dbf.w		D0, .LOOP
	
	addq.l		#6, A7			; Restore stack
	move.w		(A7)+, D0		; POP registers
	rts
*-----------------------------------------------------------	
	
*-----------------------------------------------------------	
IDP_GET_ID:
* Description : Provides an available ID. Selects the first item
*               from the list of available IDs.
* Pre         : Nothing.
* Post        : D0.B: The ID or $FF if no ID available
* Modified    : Nothing: all registers are restored.
* Note        : When calling this subroutine, the required constants
*               are assumed to have the correct values.
*-----------------------------------------------------------
	move.l 	A0, -(A7)	; push
	; busca el primero disponible
	move.l	#IDP_IDLIST, -(A7)
	bsr	LS_FIRST
	move.l	(A7)+, A0	; puntero al elemento encontrado
	move.b	#$FF, D0	; inicializacion resultado	
	cmp.l	#$FFFFFF, A0
	beq	.END		; no hay libre
	move.w	#$0000, (A0)+	; marcamos como cogido
	move.w	(A0), D0	; guardamos resultado
.END:	move.l	(A7)+, A0	: pop
	rts	
*-----------------------------------------------------------
		
*-----------------------------------------------------------
IDP_RELEASE_ID:
* Description : Returns the specified ID to the list of available
*               IDs so that they will be available in future calls to
*               IDP_GET_ID
* Pre         : D0.B: ID to release
* Post        : ID released
* Modified    : Nothing: all registers are restored.
* Note        : When calling this subroutine, the required constants
*               are assumed to have the correct values.
*-----------------------------------------------------------
	move.l 	A0, -(A7)	; push
	movem.w	D0-D1, -(A7)
	; busca el primero disponible
	move.l	#IDP_IDLIST, A0
	move.w	(A0)+, D1
	move.w	(A0)+, D1	; M
	add.w	#1, D1		; M+1
	mulu	#2, D1		; bytes por elemento
	and	#$00FF, D0	; limpia el byte 1
	mulu	D0, D1		; (M+1)*ID	
	add.w	D1, A0		; apunta a la ID
	move.w	#$FFFF,(A0)	; libera ID

.END:	movem.w	(A7)+, D0-D1
	move.l	(A7)+, A0	: pop
	rts
*-----------------------------------------------------------
			
************************************************************
*                         VARIABLES                        *
************************************************************
IDP_IDLIST:		ds.w	2+TM_MAX_TASKS*(1+1)	; ID List
************************************************************








*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~8~
