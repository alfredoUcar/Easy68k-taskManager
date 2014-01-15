*-----------------------------------------------------------
* Program    : Task manager
* Written by : A. Burguera
* Date       : 2-November-2012
* Description: Basic functionalities of a task manager. The main
*              subroutines are TM_INSTALL, which initializes
*              the data structures and installs the task manager
*              in TRAP #0, and the TM_TRAP0_DISPATCHER, which
*              is the TRAP #0 Exception Service Routine and
*              is in charge of provide the desired functionality
*              depending on the D0.B value.
*-----------------------------------------------------------

************************************************************
*                        CONSTANTS                         *
************************************************************
TM_MAX_TASKS:			EQU	30	; Maximum number of tasks
TM_SHARED_MEMORY_SIZE:		EQU	200	; Shared memory size (in bytes)
TM_TASK_MEMORY_SIZE:		EQU	200	; Each task memory size (in bytes)
TM_TCB_SIZE:			EQU	2+2+1	; Size of the TCB in WORDS. Not a parameter, it MUST NOT be modified.
						; 2 WORDS for Task Entry Point (Pointers require 2 WORD)
						; 2 WORDS for Task Memory Pointer (Pointers require 2 WORD)
						; 1 WORD for Task ID (Just 1 byte required, but using WORD list library)
************************************************************

************************************************************
*                   SOURCE FILE INCLUDES                   *
************************************************************
			INCLUDE	"list.x68"	; List library
			INCLUDE	"dmm.x68"	; Dynamic Memory Manager
			INCLUDE "idpool.x68"	; ID Pool	
************************************************************

************************************************************
*                      MAIN SUBROUTINES                    *
************************************************************

*-----------------------------------------------------------
TM_INSTALL:
* Description : Installs the task manager by doing:
*               1.- Initializing the minimum cycle time (TM_MIN_CYCLE_TIME) to zero.
*               2.- Initializing Dynamic Memory Manager
*               3.- Initializing ID Pool
*               4.- Initializing TCB List
*               5.- Installing the TRAP #0 dispatcher
*               6.- Switching to user mode
* Pre         : --
* Post        : Everything initialized and installed
* Modifies    : Can modify all of the registers if required.
* Note        : When calling this subroutine, the required constants
*               are assumed to have the correct values.
*-----------------------------------------------------------
	clr.l	(TM_MIN_CYCLE_TIME)	; init ciclo a 0
	bsr	DMM_INIT		
	bsr	IDP_INIT	
	move.w	#5, -(A7)		; M = 2+2+1
	move.w	#TM_MAX_TASKS, -(A7)	; N
	move.l	#TM_TCB_LIST, -(A7)	
	bsr 	LS_INIT			; init TCB list
	add.w	#8, A7			; restaura la pila
	move.l	#TM_TRAP0_DISPATCHER, ($80)	; instala el TRAP #0 dispatcher
	move.l	(SP),A0			; guardamos el valor de retorno de la pila de supervisor(SS)
	andi 	#$DFFF, SR		; pasa a modo usuario
	move.l	A0,(SP)			; restaura el valor de retorno en la pila de usuario(US)
	rts
*-----------------------------------------------------------

*-----------------------------------------------------------
TM_TRAP0_DISPATCHER:	
* Description : Exception Service Routine for TRAP #0. Executes
*               the desired functionality according to D0.B. It has to
*               be installed, previously, in TRAP #0 by TM_INSTALL.
* Pre         : D0.B: Desired functionality.
*               Other parameters: Depends on functionality. Check
*               assignment specs.
* Post        : Depends on the functionality. Check assignment specs.
* Modified    : Nothing except output.
* Note        : Nice strategy to provide output parameters in registers
*               while keeping the other registers unchanged (restoring
*               them) without having to track them all the time:
*               - Stack all (used) registers initially
*               - Do whatever you must without taking care of used registers
*               - Modify the stack area corresponding to the register you want
*                 to output
*               - Restore registers at the end.
*               In this implementation, all the registers are saved. The list
*               below shows the position with respect to A7 of the stored
*               values of the registers just after the first movem instruction.
*               For example, register D4.L is stored in 16(A7). Accessing to
*               the copy in stack of D4.W means accessing to 18(A7) and 
*               accessing to the copy of D4.B means accessing to 19(A7).
* Note 2      : 60(A7) contains the copy of the status register, as performed by
*               the 68000 after an exception. 62(A7) contains the return address
*               used when the RTE instruction is reached. 62(A7) is especially
*               useful. Modifying it will make the 68000 to jump wherever you
*               want when RTE is reached.             
*
* Registers in stack after movem.l D0-D7/A0-A6, -(A7)	
* D0.L: 0-3
* D1.L: 4-7
* D2.L: 8-11
* D3.L: 12-15
* D4.L: 16-19
* D5.L: 20-23
* D6.L: 24-27
* D7.L: 28-31
* A0.L: 32-35
* A1.L: 36-39
* A2.L: 40-43
* A3.L: 44-47
* A4.L: 48-51
* A5.L: 52-55
* A6.L: 56-59
* SR.W: 60-61
* PC.L: 62-65
*-----------------------------------------------------------
	; Push registers. Output will be provided by modifying the stack
	; so that the output values will be set when restoring registers 
	; from stack.	
	movem.l	D0-D7/A0-A6, -(A7)	
	
	; Branch to the desired functionality according to D0.B value.
	; Note that OR.B D0, D0 does not modify D0 but modifies flags.
	; Also, note that each SUBQ.B #1, D0 decreases D0 and modifies
	; flags according to the result. For example, if initially D0=4,
	; the zero flag will be set only after 4 SUBQs. This approach
	; avoids the use of CMP operations, which are slower than SUBQ.
	; There are better approaches, such as a table of JUMPS, and can
	; be used, but they lead to a more obfuscated code.
	or.b	D0, D0
	beq	.F0
	subq.b	#1, D0
	beq	.F1
	subq.b	#1, D0
	beq	.F2
	subq.b	#1, D0
	beq	.F3
	subq.b	#1, D0
	beq	.F4
	subq.b	#1, D0
	beq	.F5
	subq.b	#1, D0
	beq	.F6
	subq.b	#1, D0
	beq	.F7
	subq.b	#1, D0
	beq	.F8
	bra	.END
	
	; Function 0: Add new task
.F0:	move.l	32(A7), A1		; Move A0 to A1
	bsr	TM_ADD_NEW_TASK
	move.b	D0, 7(A7)		; Move D0.B to the D1.B place in stack
	bra	.END

	; Function 1: Remove task	
.F1:	move.b	7(A7), D0		; Prepare D0.B
	bsr	TM_REMOVE_TASK
	bra	.END

	; Function 2: Start
.F2:	bsr	TM_GET_TIME
	move.l	D1, (TM_PREVIOUS_TIME)		; guardamos el tiempo actual(inicio de ciclo)
	move.l	#TM_TCB_LIST, -(A7)
	bsr	LS_FIRST
	move.l	(A7)+, A0
	move.l	A0,(TM_CURRENT_TASK) 		; puntero primer TCB
	add	#2,A0				; saltamos la cabecera, A0-> punto de entrada de la tarea
	move.l	(A0), 62(A7)			; cede el control a la tarea
	bsr	TM_CURRENT_TASK_INFO
	move.b	D1, 7(A7)			; guarda la ID en D1.B
	move.l	A1, 32(A7)			; guarda el puntero a la memoria de la tarea en A0
	move.l	#TM_SHARED_MEMORY, 36(A7)
	bra	.END
	
	; Function 3: Switch to next task	
.F3:	bsr	TM_NEXT_TASK			
	move.l	A0,(TM_CURRENT_TASK) 		; puntero primer TCB
	add	#2,A0				; saltamos la cabecera, A0-> punto de entrada de la tarea
	move.l	(A0), 62(A7)			; cede el control a la tarea
	bsr	TM_CURRENT_TASK_INFO
	move.b	D1, 7(A7)			; guarda la ID en D1.B
	move.l	A1, 32(A7)			; guarda el puntero a la memoria de la tarea en A0
	move.l	#TM_SHARED_MEMORY, 36(A7)
	bra	.END
	
	; Function 4: Get current task info
.F4:	bsr	TM_CURRENT_TASK_INFO
	move.b	D1, 7(A7)		; Put task ID
	move.l	A1, 32(A7)		; Put Task Memory Pointer
	move.l	#TM_SHARED_MEMORY, 36(A7) ; Put shared memory pointer
	bra	.END
	
	; Function 5: Get info by ID
.F5: 	move.b	D1, D0
	bsr	TM_INFO_BY_ID
	move.b	D1, 7(A7)		; Task ID into D1.B
	move.l	A1, 32(A7)		; Task memory pointer
	move.l	#TM_SHARED_MEMORY, 36(A7) ; Shared memory pointer
	bra	.END
	
	; Function 6: Get first task info
.F6:	move.l #TM_TCB_LIST, -(A7) 
	bsr LS_FIRST		; output no son los siguientes
	move.l (A7)+, A0	; pointer to first task
	
	cmp #$FFFFFFFF, A0	
	beq .END		; no hay tareas
	bsr	TM_GET_TASK_INFO
	move.b D1, 7(A7)	;first task index
	move.l A1, 36(A7)	;pointer to the first memory position of the first task
	move.b D2, 11(A7)	;first task ID
	bra	.END

	; Function 7: Get next task info	
.F7:	bsr	TM_INDEX_TO_POINTER	
	move.l	A0,-(A7)
	move.l	#TM_TCB_LIST, -(A7)
	bsr	LS_NEXT
	add	#4, A7
	move.l	(A7)+,A0
	move.b	#$FF, 7(A7)	; resultado por defecto 'no hay más tareas'
	cmp 	#$FFFFFFFF, A0	
	beq 	.END		; termina con el resultado por defecto
	bsr	TM_GET_TASK_INFO
	move.b D1, 7(A7)	;first task index
	move.l A1, 36(A7)	;pointer to the first memory position of the first task
	move.b D2, 11(A7)	;first task ID
	bra	.END

	; Function 8: Define minimum cycle time	
.F8:	move.l	D1, (TM_MIN_CYCLE_TIME)
	
	; Restore registers, possibly modified
.END:	movem.l	(A7)+, D0-D7/A0-A6
	rte
*-----------------------------------------------------------

*-----------------------------------------------------------
TM_ADD_NEW_TASK
* Description : Adds a new task by:
*               1.- Getting an ID
*               2.- Getting Dynamic Memory
*               3.- Including the info in TCB
*               4.- If some step cannot be performed, release previous steps.
* Pre         : A1  : Entry point
* Post        : D0.B: Assigned ID or $FF if no place for more tasks
* Modifies    : A0, D1, A2
* Note        : By using this subroutine to add a new task, each TCB
*               (i.e. each TM_TCB_LIST item) will have this format:
*               +0: WORD: Occupied field (nothing to do with it at this level)
*               +2: LONG: Task Entry Point (pointer)
*               +6: LONG: Task memory pointer
*               +10: WORD: Task ID. Actually, only the second byte is used as
*                          IDs are bytes, not words.
*-----------------------------------------------------------
	; First, get an identifier to assign to the new task
	bsr	IDP_GET_ID
	cmp.b	#$FF, D0
	beq	.END2		; If no ID, just exit
	
	; Next, get the task memory
	bsr	DMM_ALLOCATE
	cmp.l	#$FFFFFFFF, A0
	beq	.END1		; If no memory, release ID and then exit
	
	; Include it into the TCB
	clr.w	D1
	move.b	D0, D1		; Prepare the ID in WORD format
	move.w	D1, -(A7)	; Task ID	
	move.l	A0, -(A7)	; Task Memory Pointer
	move.l	A1, -(A7)	; Task Entry Point	
	move.l	#TM_TCB_LIST, -(A7) ; TCB List pointer
	bsr	LS_PUT		; Include the task
	move.l	(A7), A2	; Item pointer
	add.l	#14, A7		; Restore stack
	cmp.l	#$FFFFFFFF, A2	; Task could be included?
	beq	.END0		; If not, release memory and ID and exit
	rts		
.END0:	bsr	DMM_RELEASE
.END1:	bsr	IDP_RELEASE_ID
	move.b	#$FF, D0
.END2:	rts	
*-----------------------------------------------------------

*-----------------------------------------------------------
TM_REMOVE_TASK:
* Description : Removes the specified task
* Pre         : D0.B: ID to search and remove
* Post        : Task removed
* Modifies    : A0, D0, A1
*-----------------------------------------------------------
	; Search the task to remove
	bsr	TM_SEARCH_BY_ID
	cmp	#$FFFFFFFF, A0
	beq	.NOTFOUND
	
	; If found, return its ID to the ID Pool
	bsr	IDP_RELEASE_ID		; Return the ID to the ID Pool
	move.l	A0, A1
	; Get the shared memory address and release it
	move.l	6(A1), A0
	bsr	DMM_RELEASE		; Release memory 
	
	; Now, remove the TCB from the TCB list
	move.l	A1, -(A7)		; Item found	
	bsr	LS_REMOVE		; Remove the item from TCB
	add.l	#4, A7			; Restore stack			
.NOTFOUND: rts	
*-----------------------------------------------------------
	
*-----------------------------------------------------------
TM_CURRENT_TASK_INFO:
* Description : Provides information about the current task
* Pre         : --
* Post        : A1: Task Memory Pointer, D1: Task ID
* Modifies    : A0
*-----------------------------------------------------------
	move.l	(TM_CURRENT_TASK), A0
	addq.l	#6, A0			; Skip occupied and task entry point
	move.l	(A0)+, A1		; Task memory pointer
	move.w	(A0), D1		; Task ID
	rts
*-----------------------------------------------------------

*-----------------------------------------------------------
TM_INFO_BY_ID:
* Description : Provides info about the task specified by its ID
* Pre         : D0.B: ID of the item to search
* Post        : A1: Task Memory Pointer, D1: Task ID
* Modifies    : 
*-----------------------------------------------------------
	bsr	TM_SEARCH_BY_ID
	cmp.l	#$FFFFFFFF, A0
	beq	.END			; If task not found, output $FF as ID
	addq.l	#6, A0			; Skip occupied and task entry point
	move.l	(A0)+, A1		; Task memory pointer
	move.w	(A0), D1		; Task ID
	rts
.END:	move.b	#$FF, D1
	rts
*-----------------------------------------------------------


************************************************************
*                    AUXILIARY SUBROUTINES                 *
************************************************************

*-----------------------------------------------------------
TM_SEARCH_BY_ID:
* Description : Given a task ID, searches the TCB with this
*               ID.
* Pre         : D0.B: ID to search
* Post        : A0: Item pointer or $FFFFFFFF if not found
* Modifies    : D0
*-----------------------------------------------------------
	; Get the first TCB in TCB list
	move.l	#TM_TCB_LIST, -(A7)
	bsr	LS_FIRST		
	move.l	(A7)+, A0		; Get item pointer
	
	; Check if this TCB has the desired ID. If not, go
	; to the next TCB and loop.
.LOOP:	cmp.l	#$FFFFFFFF, A0
	beq	.END			; Invalid pointer means the end of TCB list has been reached without finding the TCB
	cmp.b	11(A0), D0		; 11(A0) is the ID (5 data Words+1 occupied field WORD)*2=12. Last byte is 11.
	beq	.END			; If ID found, exit.
	
	; Go to next item
	move.l	A0, -(A7)		; Current item pointer
	move.l	#TM_TCB_LIST, -(A7) 	; List pointer
	bsr	LS_NEXT			; Next item
	move.l	4(A7), A0		; Get item
	addq.l	#8, A7			; Restore stack
	bra	.LOOP
	
.END:	rts				; Just exit. A0 is the answer.	
*-----------------------------------------------------------

*-----------------------------------------------------------
TM_POINTER_TO_INDEX:
* Description : Given a pointer to a TCB, it outputs the zero-based index
*               of this item in the list.
* Pre         : A0: Pointer to the task in the TCB
* Post        : D1.B: Index
* Modifies    : D0
*-----------------------------------------------------------
	move.l	A0, D0
	sub.l	#TM_TCB_LIST+4, D0	; Bytes from first item to the specified one
	divu	#12, D0			; (TM_TCB_SIZE+1)*2=12
	move.b	D0, D1			; Pick the 8 LSB bits of the quotient
	rts
*-----------------------------------------------------------

*-----------------------------------------------------------
TM_INDEX_TO_POINTER:
* Description : Given the zero-based index of a TCB in the TCB list,
*               it outputs the pointer of this item.
* Pre         : D1.B: Index
* Post        : A0: Pointer to the task in the TCB
* Modifies    : D0
*-----------------------------------------------------------
	clr.l	D0
	move.b	D1, D0
	mulu	#12, D0
	add.l	#TM_TCB_LIST+4, D0
	movea.l	D0, A0
	rts
*-----------------------------------------------------------
************************************************************
*                   CUSTOM SUBRUTINES                      *
************************************************************
TM_GET_TASK_INFO:
* Description : Given the pointer to the task in the TCB list,
*               it outputs the information of this item.
* Pre         : A0: Pointer to the task in the TCB
* Post        : D1.B: task index
*		D2.B: task ID
*		A1: task memory pointer		
* Modifies    : A0
*-----------------------------------------------------------
	bsr TM_POINTER_TO_INDEX
	addq.l	#6, A0			; Skip occupied and task entry point
	move.l	(A0)+, A1		; Task memory pointer
	move.w	(A0), D2		; Task ID
	rts
*-----------------------------------------------------------
TM_FINISH_CICLE:
* Description : Given the pointer to the task in the TCB list,
*               it outputs the information of this item.
* Pre         : A0: Pointer to the task in the TCB
* Post        : D1.B: task index
*		D2.B: task ID
*		A1: task memory pointer		
* Modifies    : A0
*-----------------------------------------------------------
	movem.l	D0-D1,-(A7)	; push
	bsr	TM_GET_TIME
	move.l	(TM_PREVIOUS_TIME),D0
	sub.l	D0,D1		; tiempo transcurrido del ciclo actual
	move.l	D1,D0
	move.l	(TM_MIN_CYCLE_TIME),D1
	cmp.l	D0,D1
	ble	.END		; T de ciclo <= T transcurrido
	; esperamos el tiempo que falta
	sub.l	D0, D1		; tiempo que falta para completar el ciclo
	bsr	TM_DELAY
.END:	bsr	TM_GET_TIME         ; guardamos el tiempo actual(inicio de ciclo)	
	move.l	D1, (TM_PREVIOUS_TIME)		
	movem.l (A7)+,D0-D1	; pop
	rts
*-----------------------------------------------------------
TM_NEXT_TASK:
* Description : search next task in TCB list
* Post        : A0: new TM_CURRENT_TASK
*		A1: task memory pointer		
* Modifies    : nothing
*-----------------------------------------------------------
	move.l	(TM_CURRENT_TASK), -(A7)	
	move.l	#TM_TCB_LIST, -(A7)
	bsr	LS_NEXT
	add	#4, A7				; restaura parte de la pila
	move.l	(A7)+, A0
	cmp.l	#$FFFFFFFF,A0
	bne	.END				; no ha llegado a la última tarea			
	;ha llegado al final de la lista
	;establece la primera tarea como la actual
	bsr	TM_FINISH_CICLE	; espera hasta que finaliza el ciclo de tiempo	
	move.l	#TM_TCB_LIST, -(A7)
	bsr	LS_FIRST
	move.l	(A7)+, A0	; new TM_CURRENT_TASK
.END	rts

*---------------------
TM_GET_TIME:
*Devuelve el tiempo (en centésimas) pasado desde medianoche
*Modifica: 	D1.L: resultado
*		D0.W
*---------------------
		move.w	#8, D0
		trap	#15
		rts
**---------------------
TM_DELAY:
*Espera una cierta cantidad de tiempo
*Parámetros. 	D1 : tiempo de espera en centésimas
*Modifica: 	D1.L
*		D0.W
*---------------------
		move.w	#23, D0
		trap	#15
		rts
************************************************************
*                         VARIABLES                        *
************************************************************
TM_SHARED_MEMORY:	ds.b	TM_TASK_MEMORY_SIZE	 	; Shared memory
TM_TCB_LIST:		ds.w	2+TM_MAX_TASKS*(TM_TCB_SIZE+1) 	; TCB List
TM_CURRENT_TASK:	ds.l	1				; Pointer to the current TCB
TM_MIN_CYCLE_TIME:	ds.l	1				; Minimum cycle time (units: 1/100 of second)
TM_PREVIOUS_TIME:	ds.l	1				; Last time stamp used to measure cycle time
************************************************************


























*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~8~
