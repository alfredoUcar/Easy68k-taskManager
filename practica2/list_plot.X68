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
LP_FONT			EQU	$04	; lucida console
LP_FONT_SIZE		EQU	$0B 	; 12
LP_FONT_STYLE		EQU	$0001	; bold
LP_FONT_PROP		EQU	(LP_FONT*$1000000)+(LP_FONT_SIZE*$10000)+LP_FONT_STYLE		; $040B0001
LP_SHOW_X		EQU	(LP_SCREEN_WIDTH/LP_FONT_SIZE)/2	; posicion en funcion del tamaño de fuente

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
		
		SC_ENABLE_DBUFFER
		
		move.w	#$0107, D1		; Interrupcion 1 cuando se mueve el mouse o se suelta el boton
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
		SC_LOCATE D4, D5	; coloca el cursor	
		
		move.l	20(A7), A0	; guardamos el puntero a la lista
		move.w	(A0)+, D2	; tamaï¿½o de lista (N)
		move.w	(A0)+, D3	; tamaï¿½o de elemento (M)
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
                ;PUSH. 4 long + 4 word = 24 bytes. Add 24 to all stack references
                movem.l	A0-A3, -(A7)
		movem.w	D0-D3, -(A7)
		
		SC_LOCATE #LP_SHOW_X, #0	; coloca el cursor donde se mostrara el contenido

		;coordenadas del mouse
		lea	LP_MOUSE_CX, A0
		lea	LP_MOUSE_CY, A1	

		;saltamos a la subrutina que nos coge el elemento apuntado por la coordenada
		move.w 	(A1),-(A7)
		move.w 	(A0),-(A7)
		jsr 	LP_GET_ELEM
		move.w 	(A7)+, D0 ;D0 contiene el indice del elemento
		add.w 	#2, A7
		;saltamos a la subrutina que nos dice si el elemento que estamos apuntando está en la lista
		move.l	28(A7), A3
		move.w	D0, -(A7)		
		move.l 	A3, -(A7)
		jsr 	LP_CHECK_ELEM
		move.l 	(A7)+, A0 ;PUNTERO AL ELEMENTO
		add.w 	#2, A7  ;RESTAURAR LA PILA
		
		;COMPARAMOS CON FFF PORQUE LA SUBRUTINA ANTERIOR DEVUELVE ESE NÚMERO SI SE DA EL CASO
		;DE QUE ESTUVIERA VACÍO. (A0)+ -> PASAMOS AL SIGUIENTE ELEMENTO DEL PUNTERO QUE NOS APUNTA AL ELEMENTO DE LA LISTA
		;NO PERTENECE A LA LISTA
		cmp 	#$FFFFFFFF, A0 ; 
		beq 	MI_END
		
		;preparamos el contador
		move.l 	28(A7),A2
		add.w 	#2, A2   ;ahora apunta a M
		move.w 	(A2)+, D2  ;D2 = M
		
		btst.b	#0, LP_MOUSE_BUT
		beq	MI_CONTINUA	;si no se ha hecho click pasamos a continuar
		move.l 	A0,-(A7)
		bsr 	LS_REMOVE		;en este punto se ha hecho click, pasamos a eliminar 
		move.l (A7)+,A0
				
MI_CONTINUA:	cmp 	#$FFFF, (A0)+
		bne 	MI_VOID_ELEM	; elemento vacío
		
		SC_SET_FONT #$00000000, #LP_FONT_PROP
		jmp MI_DRAW
MI_VOID_ELEM:   SC_SET_FONT #$00CCCCCC, #LP_FONT_PROP
		
MI_DRAW:        SC_SET_FILL #$00CCCCCC ; color de relleno gris		
		sub.b 	#1, D2
		move.l	D2, D3		; copia
.LOOP:          clr.l	D1
		move.w	(A0)+, D1          ;(A0) = Nº que ha de enseñar
		move.b	#5, D2
		move.b	#20, D0
		trap	#15		; printa el numero
		SC_NEW_LINE
		SC_LOCATE #$00, #$FF	; obtiene la posicion del cursor
		move.b	D1, D0		; guarda la y		
		SC_LOCATE #LP_SHOW_X, D0 ; ajusta la X (y se mantiene igual)
                DBRA D3, .LOOP

MI_END:     	;POP
		movem.w (A7)+, D0-D3
		movem.l	(A7)+, A0-A3
		rts
*-----------------------------------------------------------
;GRIS $00CCCCCC
;VERDE $0000FF00


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
		move.w	D1, (A0)		; guarda la coordenada X
		swap	D1
		move.w	D1, (A1)		; guarda la coordenada Y
		move.l	#LP_MOUSE_BUT, A0
		
		move.b	D0, (A0)	; guarda el estado del boton
		
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
* corresponde una determinada posiciï¿½n(aunque no sea de la lista)
* a partir de una posicion dada.
* Pre:   	-Offset 4: coordenada X
*    		-Offset 6: coordenada Y
*
* Post:  	-Offset 4: resultado. Indice del elemento (empezando en 1) 
*		o #$FFFF si no corresponde a ninguno
*--------------------------------------------------------------
		; 6 WORDS = 12 bytes. Add 12 to al stack references
		movem.w	D0-D5, -(A7) ;push
		
		clr.l	D1
		clr.l	D2
		move.w 	16(A7),D1  	;D1=X
		move.w 	18(A7),D2  	;D2=Y		
		move.w	#$FFFF,16(A7) ; inicializa resultado a 'no encontrado'		
		cmp 	#LP_INITIAL_Y, D2
		ble 	GE_END	; Y<=INITIAL_Y, no puede coincidir nunca con un elemento
		
		sub.w	#LP_INITIAL_Y,D2
		divs	#LP_SQR_SIZE, D2	; fila (0..f-1)
		divs	#LP_SQR_SIZE, D1	; columna (0..c-1)
		move.w	#LP_SCREEN_WIDTH, D3	; width
		divs	#LP_SQR_SIZE, D3	; columnas por fila (z)
		mulu	D2, D3		; z*fila
		add.w	D1, D3		; resultado (0..n-1)
		add.w	#1, D3		; ajuste (rango indice 1..n)

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
		cmp	#$FFFF, D2
		beq	CE_END	; no es un indice válido	
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
