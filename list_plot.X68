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
LP_SQR_SIZE		EQU	32
LP_INITIAL_Y		EQU	200
LP_SCREEN_WIDTH		EQU	640
LP_SCREEN_HEIGHT	EQU	480
************************************************************
			;INCLUDE "screen.x68"	; Screen management macros
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
		; PUSH registers. 1 LONG + 6 WORD = 16 bytes. Add 16
		; to all stack references
		movem.l	A0, -(A7)
		movem.w	D0-D5, -(A7)
		
		SC_SET_PEN #$00FFFFFF	; fija el color del borde a blanco
		
		clr	D4
		move.w	#0,D4	; X inicial
		clr	D5
		move.w	#LP_INITIAL_Y,D5	; Y inicial		
		
		move.l	20(A7), A0	; guardamos el puntero a la lista
		move.w	(A0)+, D2	; tama�o de lista (N)
		move.w	(A0)+, D3	; tama�o de elemento (M)
		lsl.w	#1, D3		; M*2 (bytes)
		
		; pinta cada elemento(N..1)
PL_LOOP:	cmp	#1, D2	; miramos si quedan elementos
		blt	PL_END		
		cmp  	#$FFFF,(A0)+ 	;mira si esta ocupado
		beq  	.OCUPADO
;LIBRE:		fija el color de relleno a negro
		movem.w	D0-D1, -(A7) ; push
		SC_SET_FILL #$00000000
		movem.w (A7)+, D0-D1 ; pop
		bra	.DIBUJA
.OCUPADO:	;fija el color de relleno a azul
		SC_SET_FILL #$00FF0000
.DIBUJA:	movem.w	D0-D4, -(A7) ; push
		SC_DRAW_SQUARE D4, D5, LP_SQR_SIZE
		movem.w (A7)+, D0-D4 ; pop	
.NEXT_ELEM:	; actualiza la posicion de dibujo
		move.w	D0, -(A7) ; push
		SC_NEXT_POSITION D4, D5, LP_SQR_SIZE,LP_SCREEN_WIDTH
		move.w	(A7)+, D0 ; pop
		sub.w	#1, D2	; decrementa contador
		add.W	D3, A0	; apuntamos al siguiente elemento
		jmp	PL_LOOP
		; restaura los registros
PL_END:		movem.w	(A7)+, D0-D5
		movem.l	(A7)+, A0
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

;               TODO: Hacer el push, dependiendo de lo que midan los registros y direcciones del push
;                       sumar el número de bytes correspondientes a todas las referencias a A7.
;                       p.ej: Si los registros que se han guardado valen 16 bytes: 16 + 4(offset) = 20,
;		       para coger el parámetro deseado de la pila haremos 20(A7),A0
		       
                ;PUSH
                move.l 4(A7),A0         ;Obtenemos el list pointer
                
                eor.w	D1, D1
                
		move.b	#11, D0
		trap	#15		;Put text cursor to 0,0
		
		;lea	A0, A1          ;En A1 poner los elementos de la lista
		;falta capturar el elemento de la lista que nos interese, 
		;saltando al elemento deseado --> saltar los campos de la lista y por cada
		;elemento de la lista, iterar sobre la función que printa por pantalla 
		;(semejante a la que printa el cursor en la posición indicada por el mouse)
		
		move.b	#14, D0
		trap	#15		; Print "X: "
		
		move.l	D3, D1
		move.b	#4, D2
		move.b	#20, D0
		trap	#15		; Print the first number

		
		;printa la coordenada Y
                lea	.STR_Y, A1
                
		move.b	#14, D0
		trap	#15		; Print "Y: "
		
		move.l	D4, D1
		move.b	#4, D2
		move.b	#20, D0
		trap	#15		; Print the second number

		
		;Falta implementar el click, que borra la lista a la que esté apuntando
		
		;POP
		rts
		
; Static data specific to this function		
.STR_Y:		dc.b	', Y: ',0
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
		clr	D1
		move.b	D0, D1
		move.w	D1, A0		; guarda el estado del boton
		
		movem.w	(A7)+, D0-D1	; pop
		movem.l	(A7)+, A0-A1
		
		rte		
*-----------------------------------------------------------
************************************************************
*                   Custom subrutines                     *
************************************************************
*-------------------------------------------------------------
LP_GET_ELEM:
* Subrutina de biblioteca que calcula a que elemento al que 
* corresponde una determinada posici�n(aunque no sea de la lista)
* a partir de una posicion dada.
* Pre:   	-Offset 4: coordenada X
*    		-Offset 6: coordenada Y
*
* Post:  	-Offset 4: resultado. Indice del elemento (empezando en 1) 
*		o #$FFFF si no corresponde a ninguno
*--------------------------------------------------------------
		; 6 WORDS = 12 bytes. Add 12 to al stack references
		movem.w	D0-D5, -(A7) ;push
		
		move.w 	16(A7),D1  	;D0=X
		move.w 	18(A7),D2  	;D1=Y		
		move.w	#$FFFF,16(A7) ; inicializa resultado a 'no encontrado'		
		cmp 	#LP_INITIAL_Y, D2
		blt 	GE_END	; Y<INITIAL_Y, no puede coincidir nunca con un elemento
				
		move.w	#1,D3	; elemento a comprobar, inicialmente el 1
		move.w	#LP_SQR_SIZE, D4 ; x actual
		move.w	#LP_SQR_SIZE+LP_INITIAL_Y, D5 ; y actual
		; si x>=X & y>=Y entonces es este
GE_LOOP:	cmp	D1,D4	; comprueba la coordenada X
		ble	.NEXT 	; no es, prueba el siguiente elemento
		cmp	D2,D5	; continua, comprueba la coordenada Y
		bgt	GE_FOUND	; X,Y corresponden al elemento D2
.NEXT:		SC_NEXT_POSITION D4, D5, LP_SQR_SIZE,LP_SCREEN_WIDTH
		add.w	#1, D3 ; siguiente elemento
		jmp	GE_LOOP

GE_FOUND:		move.w	D3,16(A7) ; guarda el resultado
GE_END:    	movem.w	(A7)+, D0-D5	; pop
		rts

*-------------------------------------------------------------
LP_CHECK_ELEM:
* Subrutina de biblioteca que comprueba si el indice pertenece
* a un elemento de la lista (libre o ocupado)
* Pre:   	-Offset 4: list pointer
*    		-Offset 8: indice del elemento (word)
*
* Post:  	-Offset 4: resultado. Puntero al elemento o 
*		#$FFFFFFFF si no corresponde a ninguno
*--------------------------------------------------------------
		;PUSH. 1 long + 4 words = 12 bytes
		move.l	A0,-(A7)
		movem.w D0-D3,-(A7)		
		
		move.l	16(A7), A0	;puntero a la lista
		move.w	(A0)+, D0	; N
		move.w	(A0)+, D1	; M
		move.w	20(A7), D2	; indice del elemento
		; A0 apunta al primer elemento
		move.l	#$FFFFFFFF,16(A7)	; guarda resultado por defecto 'no encontrado'		
		cmp	D0,D2
		bgt	CE_END	; indice > N, no puede coincidir nunca				
		lsl	#1, D1	; D1=2*M
		add.w	#2, D1	; D1=2(M+1), bytes que ocupa un elemento		
.LOOP:		add.w	#1,D3	; elemento actual
		cmp	D2,D3
		beq	.FOUND	; elemento actual = indice
		; no encontrado
		add.w	D1,A0	; apuntamos al siguiente elemento
		jmp	.LOOP
.FOUND:		move.l	A0,16(A7)	;guarda el resultado				
CE_END:		;POP
		movem.w (A7)+,D0-D3
		move.l	(A7)+,A0				
		rts

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
