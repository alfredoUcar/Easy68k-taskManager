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