************************************************************
*                         LIST LIBRARY                     *
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

*-----------------------------------------------------------
LS_INIT:
* Description : Inits a list structure by setting to zero all 
*               the occupied fields and filling the header.
* Pre         : Stack. Specified stack offsets correspond to
*               the stack state at the beginning of the sub-
*               routine.
*               Stack offsets from 0 to 3 contain the return 
*               address.
*		  - Offset 4: LONG: Pointer to the RAM area to 
*                   store the list.
*                 - Offset 8: WORD: List size.
*                 - Offset 10: WORD: Item size (expressed in 
*                   WORDs)
* Post        : All registers are restored to their initial 
*               values.
* Note        : When calling this subroutine, the first
*               parameter (the pointer) must point to a RAM 
*               area with enough space to store the list. 
*-----------------------------------------------------------
		; PUSH registers. Only the parts that may change are stored
		; to improve execution speed. 2 LONGs and 1 WORD is 10 bytes.
		; So, add 10 to the stack offsets.
		movem.l	D1/A0, -(A7)	; Store registers whose 32 bits may change
		move.w	D0, -(A7)	; Store registers whose 16 MSB won't change

		; Prepare registers
		eor.l	D1, D1		; Put all D1 bits to zero. This register is going to be
                                        ; added, later, to an address register (32 bit). So, we
		                        ; have to ensure there is no trash in the 16 MSB.
		                        
		; Access to the stack parameters                        
		move.l	14(A7), A0	; List address
		move.w	18(A7), D0	; List size
		move.w	20(A7), D1	; Item size
		
		; Store list header
		move.w	D0, (A0)+	; Store list size
		move.w	D1, (A0)+	; Store item size
		
		; Prepare registers before loop
		lsl.l	#1, D1		; D1:=D1*2. Required as item size is expressed in WORDs
		sub.w	#1, D0		; Required as DBF loops N+1 times
		
		; Loop through all data blocks and put zeros to the occupied field.
.LOOP:		move.w	#0, (A0)+	; Occupied field:=0
		adda.l	D1, A0		; Go to the next data block
		dbf.w	D0, .LOOP

		; POP registers.		
		move.w	(A7)+, D0
		movem.l	(A7)+, D1/A0
		rts
*-----------------------------------------------------------

*-----------------------------------------------------------
LS_PUT:
* Description : Puts the specified item in the first free 
*               position, if any.
* Pre         : Stack. Specified stack offsets correspond to
*               the stack state at the beginning of the sub-
*               routine.
*               Stack offsets from 0 to 3 contain the return 
*               address.
*		  - Offset 4: LONG: List pointer
*                 - Offset 8: M Words: Data to put in the list
* Post        : All registers are restored to their initial 
*               values.
*               Stack. The stack offsets specified now are
*               based on the same reference that the input ones.
*                 - Offset 4: LONG: Item pointer or $FFFFFFFF
*                   if item could not be included in the list.
*                   The pointer points to the data block. That
*                   is, to the occupied field of the data block.
* Note        : When calling this subroutine, the list is supposed
*               to be properly initialized.  
*-----------------------------------------------------------
		; PUSH registers. 3 LONG + 3 WORD = 18 bytes. Add 18
		; to all stack references
		movem.l	D1/A0-A1, -(A7)
		movem.w	D0/D2-D3, -(A7)

		; Get parameters and prepare registers
		eor.l	D1, D1		; Put all D1 bits to zero		
		move.l	22(A7), A0	; List address
		move.w	(A0)+, D0	; List size
		move.w	(A0)+, D1	; Item size
		move.w	D1, D2		; Copy item size for future use
		lsl.l	#1, D1		; D1:=D1*2 (size is specified in WORDs)
		sub.w	#1, D0		; Required for DBF later
		
		; Search for an empty slot
.LOOP:		move.w	(A0)+, D3	; Occupied field
		or.w	D3, D3
		beq	.SLOT_FOUND	; If not occupied, put item
		adda.l	D1, A0		; If occupued, go to the next item
		dbf.w	D0, .LOOP

		; If no empty slot, output $FFFFFFFF
		move.l	#$FFFFFFFF, 22(A7) ; No place for new item.
		bra	.END
		
		; If slot found, store output pointer
.SLOT_FOUND:	move.l	A0, A1		; A0 points to the area to put the data
		suba.l	#2, A1		; A1 points to the data block, including occupied field
		move.l	A1, 22(A7)	; Store the output pointer
		move.w	#$FFFF, (A1)	; Mark as occupied

		; Prepare registers
		move.l	A7, A1
		adda.l	#26, A1		; Now A1 points to the data in the stack		
		subq.w	#1, D2		; Item size, in words, minus one to use in DBF
		
		; Copy the data
.LOOP2:		move.w	(A1)+, (A0)+	; Copy data from stack to data block
		dbf.w	D2, .LOOP2
				
		; POP registers
.END:		movem.w	(A7)+, D0/D2-D3
		movem.l	(A7)+, D1/A0-A1

		rts		
*-----------------------------------------------------------
		
*-----------------------------------------------------------
LS_REMOVE:
* Description : Removes the specified data block by putting
*               a zero in the occupied field.
* Pre         : Stack. Specified stack offsets correspond to
*               the stack state at the beginning of the sub-
*               routine.
*               Stack offsets from 0 to 3 contain the return 
*               address.
*		  - Offset 4: LONG: Pointer to the data block to remove.
* Post        : All registers are restored to their initial 
*               values.
* Note        : When calling this subroutine, the pointer is
*               supposed to point to an item.
*-----------------------------------------------------------
		move.l 	A0, -(A7) 	; Push

		move.l 	(A7),A0  	;tenemos el puntero del elemento a borrar
		clr.w	(A0)
	
		move.l 	(A7)+, A0 	; Pop
		rts				
*-----------------------------------------------------------

*-----------------------------------------------------------
LS_FIRST:
* Description : Outputs a pointer to the first occupied item
*               or $FFFFFFFF if empty list.
* Pre         : Stack. Specified stack offsets correspond to
*               the stack state at the beginning of the sub-
*               routine.
*               Stack offsets from 0 to 3 contain the return 
*               address.
*		  - Offset 4: LONG: List pointer.
* Post        : All registers are restored to their initial 
*               values.
*               Stack. The stack offsets specified now are
*               based on the same reference that the input ones.
*                 - Offset 4: LONG: Item pointer or $FFFFFFFF
*                   if empty list.
*                   The pointer points to the data block. That
*                   is, to the occupied field of the data block.
* Note        : When calling this subroutine, the pointer is
*               supposed to point to a properly initialized list.
*-----------------------------------------------------------

		; PUSH registers. 1 LONG + 2 WORD = 8 bytes. Add 8
		; to all stack references
		movem.l	A0, -(A7)
		movem.w	D1-D2, -(A7)		

		move.l	12(A7), A0	; guardamos el puntero a la lista
		move.w	(A0)+, D1	; tama�o de lista (N)
		move.w	(A0)+, D2	; tama�o de elemento (M)
		; nota: A0 apunta al primer elemento de la lista

		movem.w	D1-D2, -(A7)	; paso de parametros
		movem.l	A0, -(A7)
		jsr 	LS_ULTIMO_ELEMENTO		
		add.w	#4, A7 		; POP de los parametros

	; nota: (A7) contiene el resultado de la anterior subrutina
	; y se mantiene en la pila(sin hacer POP) para usarlo como parametro
	; en la siguiente subrutina
		
		move.l	A0, -(A7) 	;paso de parametros
		move.w	D2, -(A7)
		jsr 	LS_BUSCA_OCUPADO
		move.l	8(A7), A0 	; guarda resultado
		add.w	#6, A7 		; POP de los parametros
		
		move.l	A0, 12(A7) 	;guarda el resultado en la pila

		; restaura los registros
		movem.w	D1-D2, -(A7)
		movem.l	A0, -(A7)		
		rts
*-----------------------------------------------------------
		
*-----------------------------------------------------------
LS_NEXT:
* Description : Given an item, outputs a pointer to the next 
*               occupied item or $FFFFFFFF if empty list.
* Pre         : Stack. Specified stack offsets correspond to
*               the stack state at the beginning of the sub-
*               routine.
*               Stack offsets from 0 to 3 contain the return 
*               address.
*		  - Offset 4: LONG: List pointer.
*                 - Offset 8: LONG: Current item pointer
* Post        : All registers are restored to their initial 
*               values.
*               Stack. The stack offsets specified now are
*               based on the same reference that the input ones.
*                 - Offset 8: LONG: Next item pointer or $FFFFFFFF
*                   if empty list.
*                   The pointer points to the data block. That
*                   is, to the occupied field of the data block.
* Note        : When calling this subroutine, the list pointer is
*               supposed to point to a properly initialized list.
*-----------------------------------------------------------

		; PUSH registers. 1 LONG + 2 WORD = 8 bytes. Add 8
		; to all stack references
		movem.l	A0, -(A7)
		movem.w	D1-D2, -(A7)		

		move.l	12(A7), A0	; guardamos el puntero a la lista
		move.w	(A0)+, D1	; tama�o de lista (N)
		move.w	(A0)+, D2	; tama�o de elemento (M)
		move.l	16(A7), A0	; A0 = puntero elemento actual
		add.w	D2, A0	
		add.w	#1, A0		; A0 = elemento siguiente

		movem.w	D1-D2, -(A7)	; paso de parametros
		movem.l	A0, -(A7)
		jsr 	LS_ULTIMO_ELEMENTO		
		add.w	#4, A7 		; POP de los parametros

	; nota: (A7) contiene el resultado de la anterior subrutina
	; y se mantiene en la pila(sin hacer POP) para usarlo como parametro
	; en la siguiente subrutina
		
		move.l	A0, -(A7) 	;paso de parametros
		move.w	D2, -(A7)
		jsr 	LS_BUSCA_OCUPADO
		move.l	8(A7), A0 	; guarda resultado
		add.w	#6, A7 		; POP de los parametros
		
		move.l	A0, 12(A7) 	;guarda el resultado en la pila

		; restaura los registros
		movem.w	D1-D2, -(A7)
		movem.l	A0, -(A7)		
		rts	
*-------------------------------------------------------------


**************************************************************
****		   SUBRUTINAS AUXILIARES		  ****
**************************************************************

*-------------------------------------------------------------
LS_ULTIMO_ELEMENTO:
* Subrutina de libreria para buscar el ultimo elemento de una lista.
* Pre:		Stack. Specified stack offsets correspond to
*               the stack state at the beginning of the sub-
*               routine.
*               Stack offsets from 0 to 3 contain the return 
*               address.
*		  - Offset 4: 	puntero al primer elemento de la lista
*		  - Offset 8: 	tama�o de la lista (N)
*		  - Offset 10:	tama�o de los elementos en words (M)
*
* Post:		El resultado se guarda en la misma posicion donde se
*		guardaba el puntero a la lista(Offset 4).
*--------------------------------------------------------------

		; PUSH registers. 1 LONG + 2 WORD = 8 bytes. Add 8
		; to all stack references
		movem.l	D3, -(A7)
		movem.w	D1-D2, -(A7)

		move.w	18(A7), D1 	; tama�o de elemento (M)
		add.w	#1, D1 		; D1 = M+1
		move.w	16(A7), D2 	; tama�o de la lista (N)
		sub.w	#1, D2 		; D2 = N-1
		move.l	12(A7), D3 	; puntero al primer elemento
		lsl.l	D2, D3 		; D3 = (N-1)*(M+1), ultimo elemento | que pasa si N-1=0 ??????
		move.l	D3,12(A7) 	; guarda el resultado en la pila	
		
		; POP registers
		movem.w	(A7)+, D1-D2
		movem.l	(A7)+, D3
		
		rts
*--------------------------------------------------------------


*-------------------------------------------------------------
LS_BUSCA_OCUPADO:
* Subrutina de biblioteca para buscar el primer el elemento ocupado de una lista
* a partir de una posicion dada.
* Pre:   	-Offset 4: tama�o de los elementos en words (M)
*    		-Offset 6: puntero al elemento a partir del cual se busca
*    		-Offset 10: puntero al ultimo elemento de la lista
*
* Post:  	-Offset 6: resultado. Puntero al elemento o #$FFFFFFFF
*		si no lo ha encontrado.
*--------------------------------------------------------------

		; PUSH registers. 1 LONG + 2 WORD = 8 bytes. Add 8
		; to all stack references
		movem.l	A1-A2, -(A7)
		movem.w	D0, -(A7)
		
		move.l 	6(A7),A1  	;elemento actual
		move.l 	10(A7),A2  	;elemento final
		move.w	4(A7),D0 	;tama�o de los elementos (M)	
		move.l  #$FFFFFFFF,6(A7) ;inicializa resultado a 'no encontrado'
.LOOP:		cmp  	A1,A2  		;A2<A1 => ha llegado al final de la lista sin encontrar nada
		blt   	.END  		;no encontrado
		cmp  	#$FFFF,(A1) 	;mira si est? ocupado
		beq  	.ENCONTRADO
		add.w  	D0,A1 		; A1+M => A1
		add.w  	#1,A1 		; A1 = M+1
		bra  	.LOOP
.ENCONTRADO:	move.l  A1,6(A7) 	;guarda la posici?n encontrada

.END:    	; restaura los registros		
		movem.w	(A7)+, D0
		movem.l	(A7)+, A1-A2

		rts





*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~8~
