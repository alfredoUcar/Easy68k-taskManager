*-----------------------------------------------
*		FIGURAS
*-----------------------------------------------
TK_PIXEL	EQU	3
TK_SCREEN__WIDTH	EQU	640
TK_SCREEN_HEIGHT	EQU	480
*-----------------------------------------------
*		ENEMIGO
*-----------------------------------------------
TK_ENEM_ROWS	EQU	7
TK_ENEM_COLUMNS	EQU	10
TK_ENEM_COLOR1	EQU	$00FF0000
TK_ENEM_COLOR2	EQU	$00FF9999
*-----------------------------------------------
*		NAVE/JUGADOR
*-----------------------------------------------
TK_NAVE_ROWS	EQU	3
TK_NAVE_COLUMNS	EQU	9
TK_NAVE_COLOR	EQU	$00FFFFFF
*-----------------------------------------------
*		EXPLOSIÓN
*-----------------------------------------------
TK_EXP_ROWS	EQU	7
TK_EXP_COLUMNS	EQU	10
TK_EXP_COLOR1	EQU	$000033FF
TK_EXP_COLOR2	EQU	$000066FF
*-----------------------------------------------------------
TK_DRAW_ENEM:
* Description : dibuja un enemigo en la posición indicada
* Pre         : D0.L: coordenadas del centro(W1:X,W2:Y)
* Post        : 
* Modified    : Nothing: all registers are restored.
* Note        : When calling this subroutine, the required constants
*               are assumed to have the correct values.
*-----------------------------------------------------------
		;push
		movem.l	D0-D5/A0,-(A7)
		;paso de parametros
		move.w	#(TK_PIXEL*TK_ENEM_ROWS/2), D1	; height/2
		move.w	#(TK_PIXEL*TK_ENEM_COLUMNS/2), D2	; width/2
		move.l	#TK_ENEM_COLOR1,D3
		move.l	#TK_ENEM_COLOR2,D4		
		move.w	#TK_ENEM_COLUMNS-1, D5
		swap	D5
		move.w	#TK_ENEM_ROWS-1, D5
		lea	TK_ENEM_LIST, A0	; lista de puntos
		;dibuja la figura
		bsr	TK_DRAW_FIG				

.END:		;pop
		movem.l (A7)+, D0-D5/A0
		rts	; dejamos D0 sin modificar
		

*-----------------------------------------------------------
TK_DRAW_NAVE:
* Description : dibuja una nave en la posición indicada
* Pre         : D0.L: coordenadas del centro(W1:X,W2:Y)
* Post        : 
* Modified    : Nothing: all registers are restored.
* Note        : When calling this subroutine, the required constants
*               are assumed to have the correct values.
*-----------------------------------------------------------
		;push
		movem.l	D0-D5/A0,-(A7)
		;paso de parametros
		move.w	#(TK_PIXEL*TK_NAVE_ROWS/2), D1	; height/2
		move.w	#(TK_PIXEL*TK_NAVE_COLUMNS/2), D2	; width/2
		move.l	#TK_NAVE_COLOR,D3
		move.l	#TK_NAVE_COLOR,D4		
		move.w	#TK_NAVE_COLUMNS-1, D5
		swap	D5
		move.w	#TK_NAVE_ROWS-1, D5
		lea	TK_NAVE_LIST, A0	; lista de puntos
		;dibuja la figura
		bsr	TK_DRAW_FIG				

.END:		;pop
		movem.l (A7)+, D0-D5/A0
		rts		
*-----------------------------------------------------------
TK_DRAW_EXP:
* Description : dibuja una explosión en la posición indicada
* Pre         : D0.L: coordenadas del centro(W1:X,W2:Y)
* Post        : 
* Modified    : Nothing: all registers are restored.
* Note        : When calling this subroutine, the required constants
*               are assumed to have the correct values.
*-----------------------------------------------------------
		;push
		movem.l	D0-D5/A0,-(A7)
		;paso de parametros
		move.w	#(TK_PIXEL*TK_EXP_ROWS/2), D1	; height/2
		move.w	#(TK_PIXEL*TK_EXP_COLUMNS/2), D2	; width/2
		move.l	#TK_EXP_COLOR1,D3
		move.l	#TK_EXP_COLOR2,D4		
		move.w	#TK_EXP_COLUMNS-1, D5
		swap	D5
		move.w	#TK_EXP_ROWS-1, D5
		lea	TK_EXP_LIST, A0	; lista de puntos
		;dibuja la figura
		bsr	TK_DRAW_FIG				

.END:		;pop
		movem.l (A7)+, D0-D5/A0
		rts
*-----------------------------------------------------------
TK_DRAW_FIG:
* Description : dibuja una figura en la posición indicada
* Pre         : D0.L: coordenadas del centro(W1:X,W2:Y)
*		D1.W: height/2
*		D2.W: width/2
*		D3.L: color 1
*		D4.L: color 2
*		D5.L: (COL-1,ROW-1)
*		A0:	puntero a la lista de puntos
* Post        : 
* Modified    : Nothing: all registers are restored.
* Note        : When calling this subroutine, the required constants
*               are assumed to have the correct values.
*-----------------------------------------------------------
		;push
		movem.l	D0-D6/A0,-(A7)
		movem.l D0-D1,-(A7)
TK_
		TK_SET_FILL	D4
		movem.l (A7)+,D0-D1
		
		move.w	D0, D3		; Y del centro
		swap	D0
		move.w	D0, D4		; X del centro
		
		sub	D2,D4		; x inicial
		sub	D1,D3		; y inicial
		move.w	D4,D6		; copia de x	
		;se ha comprobado que se puede dibujar en esas coordenadas
		;d4 y d3 contienen las coordenadas donde se empieza a dibujar
		move.w	D5, D1		; filas-1
		swap	D5
		move.w	D5, D2		; columnas-1
		;bucle que pinta los puntos de la lista
.FOR:		cmp.b   #0,(A0)
		beq	.FOR_NEXT	; no hay que pintar
		movem.l	D0-D6,-(A7)
		move.w	D4, D0
		move.w	D3, D6
		TK_DRAW_SQUARE D0,D6,TK_PIXEL
		movem.l (A7)+, D0-D6
.FOR_NEXT:	add.w	#TK_PIXEL, D4	; siguiente 'pixel' de la fila
		add	#1,A0		; siguiente punto de la lista
		dbra	D2,.FOR		; para cada columna..		
		move.w	D5, D2		; reinicia el contador de columnas
		add.w	#TK_PIXEL, D3	; siguiente fila
		move.w	D6, D4		; reinica la x
		dbra	D1,.FOR		; para cada fila..

.END:		;pop
		movem.l (A7)+, D0-D6/A0
		rts


************************************************************
*                         VARIABLES                        *
************************************************************
***** ENEMIGO *******
*0,0,1,0,0,0,0,1,0,0,
*0,1,1,1,1,1,1,1,1,0,
*1,1,0,0,1,1,0,0,1,1,
*1,1,0,0,1,1,0,0,1,1,
*1,1,1,1,1,1,1,1,1,1,
*0,1,0,0,0,0,0,0,1,0,
*0,0,1,1,0,0,1,1,0,0
*********************
TK_ENEM_LIST:	dc.b 0,0,1,0,0,0,0,1,0,0,0,1,1,1,1,1,1,1,1,0,1,1,0,0,1,1,0,0,1,1,1,1,0,0,1,1,0,0,1,1,1,1,1,1,1,1,1,1,1,1,0,1,0,0,0,0,0,0,1,0,0,0,1,1,0,0,1,1,0,0
*** NAVE/JUGADOR ****
*0,1,0,0,0,0,0,1,0,
*1,1,1,0,0,0,1,1,1,
*1,1,1,1,1,1,1,1,1
*********************
TK_NAVE_LIST:	dc.b 0,1,0,0,0,0,0,1,0,1,1,1,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1
*** EXPLOSIÓN ****
*0,1,0,0,0,0,0,0,1,0,
*0,0,1,0,0,0,0,1,0,0,
*0,0,0,1,0,0,1,0,0,0,
*1,1,0,0,0,0,0,0,1,1,
*0,0,0,1,0,0,1,0,0,0,
*0,0,1,0,0,0,0,1,0,0,
*0,1,0,0,0,0,0,0,1,0
*********************
TK_EXP_LIST:	dc.b 0,1,0,0,0,0,0,0,1,0,0,0,1,0,0,0,0,1,0,0,0,0,0,1,0,0,1,0,0,0,1,1,0,0,0,0,0,0,1,1,0,0,0,1,0,0,1,0,0,0,0,0,1,0,0,0,0,1,0,0,0,1,0,0,0,0,0,0,1,0
		ds.w	0		; Memory alignment
************************************************************



	











*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~8~
