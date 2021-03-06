************************************************************
*               SCREEN FUNCTIONS AND MACROS                *
************************************************************

*-----------------------------------------------------------
* Macro to set screen resolution.                          
* Parameters: \1: Width (pixels)                          
*             \2: Height (pixels)
* Modifies  : D0, D1
*-----------------------------------------------------------
TK_SET_RES 	MACRO
		move.b	#33, D0
		move.l	#\1*$10000+\2, D1
		trap	#15
		ENDM
		
*-----------------------------------------------------------
* Macro to set windowed mode
* Modifies  : D0, D1
*-----------------------------------------------------------
TK_SET_WINDOWED	MACRO
		move.b	#33, D0
		move.l	#1, D1
		trap	#15
		ENDM
		
*-----------------------------------------------------------
* Macro to set fullscreen mode
* Modifies  : D0, D1
*-----------------------------------------------------------
TK_SET_FULLSCREEN MACRO
		move.b	#33, D0
		move.l	#2, D1
		trap	#15
		ENDM
		
*-----------------------------------------------------------
* Macro to locate the text cursor
* Parameters: \1: X
*             \2: Y
* Modifies  : D0, D1
*-----------------------------------------------------------
TK_LOCATE	MACRO		
		move.b	\1, D1	; Put X coordinate
		lsl.w	#8, D1
		move.b	\2, D1	; Put Y coordinate
		move.b	#11, D0
		trap	#15
		ENDM

*-----------------------------------------------------------
* Macro to set the pen color. 
* Parameters: \1: Color in format $00BBGGRR
* Modifies  : D0, D1
*-----------------------------------------------------------		
TK_SET_PEN	MACRO
		move.l	\1, D1
		move.b	#80, D0
		trap	#15
		ENDM
*-----------------------------------------------------------		

*-----------------------------------------------------------
* Macro to set the fill color. 
* Parameters: \1: Color in format $00BBGGRR
* Modifies  : D0, D1
*-----------------------------------------------------------		
TK_SET_FILL	MACRO
		move.l	\1, D1
		move.b	#81, D0
		trap	#15
		ENDM
*-----------------------------------------------------------		
 		
*-----------------------------------------------------------
* Macro to clear the screen
* Modifies  : D0, D1
*-----------------------------------------------------------
TK_CLEAR	MACRO
		move.b	#11, D0
		move.w	#$FF00, D1
		trap	#15
		ENDM
	
*-----------------------------------------------------------
* Macro to print a string
* Parameters: \1: String address
* Modifies  : D0, A1
*-----------------------------------------------------------
TK_PRINT_STR	MACRO
		lea	\1, A1
		move.b	#14, D0
		trap	#15
		ENDM
		
*-----------------------------------------------------------
* Macro to enable double buffer
* Parameters: 
* Modifies  : D0, D1
*-----------------------------------------------------------
TK_ENABLE_DBUFFER MACRO
		move.b	#17, D1
		move.b	#92, D0
		trap	#15
		ENDM

*-----------------------------------------------------------
* Macro to disable double buffer
* Parameters: 
* Modifies  : D0, D1
*-----------------------------------------------------------
TK_DISABLE_DBUFFER MACRO
		move.b	#16, D1
		move.b	#92, D0
		trap	#15
		ENDM
		
*-----------------------------------------------------------
* Macro to repaint screen (only in double buffer mode)
* Parameters: 
* Modifies  : D0, D1
*-----------------------------------------------------------
TK_REPAINT_SCREEN MACRO
		move.b	#94, D0
		trap	#15
		ENDM		
		
*********************************************************
*		CUSTOM MACROS				*
*********************************************************
*---------------------------------------------------------
* Macro to draw a line
* Parameters: \1: X1
* Parameters: \2: Y1
* Parameters: \3: X2
* Parameters: \4: Y2
* Modifies: D0, D1, D2, D3, D4
*----------------------------------------------------------------------

TK_DRAW_LINE    MACRO
		move.w	\1, D1
		move.w	\2, D2
		move.w	\3, D3
		move.w	\4, D4
		move.b	#84, D0
		trap	#15
		ENDM

*---------------------------------------------------------
* Macro to draw a rectangle
* Parameters: \1: Left X
* Parameters: \2: Upper Y
* Parameters: \3: Right X
* Parameters: \4: Lower Y
* Modifies: D0, D1, D2, D3, D4
*----------------------------------------------------------------------

TK_DRAW_RECTANGLE MACRO
		move.w	\1, D1
		move.w	\2, D2
		move.w	\3, D3
		move.w	\4, D4
		move.b	#87, D0
		trap	#15
		ENDM

*---------------------------------------------------------
* Macro to draw a square
* Parameters: \1: Left X
* Parameters: \2: Upper Y
* Parameters: \3: Side size [constant]
* Modifies: D0, D1, D2, D3, D4
*----------------------------------------------------------------------

TK_DRAW_SQUARE MACRO
		move.w	\1, D1
		move.w	\2, D2
		move.w	\1, D3
		move.w	\2, D4
		add.w	\3, D3
		add.w	\3, D4
		move.b	#87, D0
		trap	#15
		ENDM
*---------------------------------------------------------
* Macro to draw a empty circle
* Parameters: \1: Left X
* Parameters: \2: Upper Y
* Parameters: \3: radius
* Modifies: D0, D1, D2, D3, D4, D5
*----------------------------------------------------------------------

TK_DRAW_CIRCLE MACRO                
		move.w	\1, D1
		move.w	\2, D2
		move.w	\1, D3
		move.w	\2, D4
		move.w	\3, D5                
                sub     D5,D1
                sub     D5,D2
                add     D5,D3
                add     D5,D4
		move.b	#91, D0
		trap	#15
		ENDM

*---------------------------------------------------------
* Macro to draw a filled ball
* Parameters: \1: Left X
* Parameters: \2: Upper Y
* Parameters: \3: radius
* Modifies: D0, D1, D2, D3, D4, D5
*----------------------------------------------------------------------

TK_DRAW_BALL MACRO                
		move.w	\1, D1
		move.w	\2, D2
		move.w	\1, D3
		move.w	\2, D4
		move.w	\3, D5                
                sub     D5,D1
                sub     D5,D2
                add     D5,D3
                add     D5,D4
		move.b	#88, D0
		trap	#15
		ENDM
		
*---------------------------------------------------------
* Macro to calculate next(upper left) element position
* Parameters: \1: current upper left X (not D0)
* Parameters: \2: current upper left Y (not D0)
* Parameters: \3: element size (supposed to be square) [constant]
* Parameters: \4: screen width	[constant]
* Modifies: \1, \2 (set up to the new position) and D0
*----------------------------------------------------------------------	
TK_NEXT_POSITION MACRO
		add.w	#\3, \1 ; incrementa la X
		move.w	#\4, D0 ; d0 = screen width
		sub.w	#\3, D0 ; d0 = (screen width - element size)
		cmp	D0, \1 ; compara (WIDTH-SIZE) con X
		ble	END\@ ; X <= LIMITE
		;ha llegado al borde derecho, siguiente fila
		clr	\1 ; X=0
		add	#\3, \2 ;incrementa la Y			
END\@		
		ENDM	
*----------------------------------------------
* Salto de linea
*----------------------------------------------
TK_NEW_LINE	MACRO
		movem.w	D0-D1, -(A7)
		clr	D1
		clr	D0
		trap	#15
		movem.w	(A7)+, D0-D1
		ENDM

*------------------------------------------
* Establece el color y el tipo de fuente
* Parameters: \1: color
* Parameters: \2: estilo, tama�o y fuente
*------------------------------------------
TK_SET_FONT	MACRO
		movem.w	D0-D2, -(A7)
		move.l	\1, D1
		move.l	\2, D2
		move	#21, D0
		trap	#15
		movem.w	(A7)+, D0-D2
		ENDM
		





*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~8~
