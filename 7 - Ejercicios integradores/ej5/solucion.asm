; Definiciones comunes
TRUE  EQU 1
FALSE EQU 0

; Identificador del jugador rojo
JUGADOR_ROJO EQU 1
; Identificador del jugador azul
JUGADOR_AZUL EQU 2

; Ancho y alto del tablero de juego
tablero.ANCHO EQU 10
tablero.ALTO  EQU 5

; Marca un OFFSET o SIZE como no completado
; Esto no lo chequea el ABI enforcer, sirve para saber a simple vista qué cosas
; quedaron sin completar :)
NO_COMPLETADO EQU -1

extern strcmp

;########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
; Completar las definiciones (serán revisadas por ABI enforcer):
carta.en_juego EQU 0
carta.nombre   EQU 1
carta.vida     EQU 14
carta.jugador  EQU 16
carta.SIZE     EQU 18

tablero.mano_jugador_rojo EQU 0
tablero.mano_jugador_azul EQU 8
tablero.campo             EQU 16
tablero.SIZE              EQU 416

accion.invocar   EQU 0
accion.destino   EQU 8
accion.siguiente EQU 16
accion.SIZE      EQU 24

; Variables globales de sólo lectura
section .rodata

; Marca el ejercicio 1 como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - hay_accion_que_toque
global EJERCICIO_1_HECHO
EJERCICIO_1_HECHO: db TRUE

; Marca el ejercicio 2 como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - invocar_acciones
global EJERCICIO_2_HECHO
EJERCICIO_2_HECHO: db TRUE

; Marca el ejercicio 3 como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - contar_cartas
global EJERCICIO_3_HECHO
EJERCICIO_3_HECHO: db TRUE

section .text

; Dada una secuencia de acciones determinar si hay alguna cuya carta tenga un
; nombre idéntico (mismos contenidos, no mismo puntero) al pasado por
; parámetro.
;
; El resultado es un valor booleano, la representación de los booleanos de C es
; la siguiente:
;   - El valor `0` es `false`
;   - Cualquier otro valor es `true`
;
; ```c
; bool hay_accion_que_toque(accion_t* accion, char* nombre);
; ```
global hay_accion_que_toque
hay_accion_que_toque:
	push RBP
	mov rbp, rsp

	push RBX
	push R12
	push R13
	push R14
	push R15
	sub rsp, 24

	mov RBX, RDI ;PUNTERO a primera accion
	mov R12, RSI ;PUNTERO A NOMBRE DE CARTA BUSCADA
	
buscar_carta_en_acciones:
	cmp RBX, 0
	je no_hay_carta 
	mov R8, [RBX+accion.destino]
	lea R9, [R8+carta.nombre]
	mov RDI, R9
	mov RSI, R12
	call strcmp 
	cmp RAX, 0
	je hay_accion_con_carta
	mov R8, [RBX+accion.siguiente]
	mov RBX, R8
	jmp buscar_carta_en_acciones

no_hay_carta:
	mov RAX, 0
	jmp fin 

hay_accion_con_carta:
	mov RAX, 1
	jmp fin 


fin:
	add rsp, 24
	pop R15
	pop R14
	pop R13
	pop R12
	pop RBX
	pop RBP	

	ret


global invocar_acciones
invocar_acciones:
	push RBP
	mov rbp, rsp

	push RBX
	push R12
	push R13
	push R14
	push R15
	sub rsp, 24

	mov RBX, RDI ;puntero a primera accion
	mov [rsp+8], RSI ;tablero

recorrer_acciones:
	cmp RBX, 0
	je fin_inv
	mov R8, [RBX+accion.destino]
	cmp BYTE[R8+carta.en_juego], FALSE
	je sig_accion
	mov RDI, [rsp+8]
	mov RSI, R8
	mov R9, [RBX+accion.invocar]
	call R9
	;chequeo vida
	mov R8, [RBX+accion.destino]
	cmp word[R8+carta.vida], 0
	je dejar_fuera_de_juego
	jmp sig_accion

dejar_fuera_de_juego:
	mov BYTE[R8+carta.en_juego], FALSE
	jmp sig_accion

sig_accion:
	mov R8, [RBX+accion.siguiente]
	mov RBX, R8
	jmp recorrer_acciones

fin_inv:
	add rsp, 24
	pop R15
	pop R14
	pop R13
	pop R12
	pop RBX
	pop RBP
	ret


global contar_cartas
contar_cartas:
	push RBP
	mov rbp, rsp

	push RBX
	push R12
	push R13
	push R14
	push R15
	sub rsp, 24

	mov RBX,  RDI ; puntero a struct tablero 
	mov [rsp+16], RSI ; puntero a resultado de cant_azules
	mov [rsp+8], RDX ; puntero a resultado de cant_rojas

	xor R12, R12 ; indice
	lea R13, [RBX+tablero.campo] ;direccion a base de array
	xor R14, R14 ;azul
	xor R15, R15 ;rojo
recorrer_tablero:
	cmp R12, 50
	je fin_rec
	mov R8, R12
	imul R8, 8
	cmp qword[R13+R8], 0
	je sig_celda
	mov RDI, [R13+R8]
	call jugador_de_carta
	cmp AL, JUGADOR_AZUL
	je sumar_a_jugador_azul
	cmp AL, JUGADOR_ROJO
	je sumar_a_jugador_rojo

sig_celda: 
	inc R12
	jmp recorrer_tablero

sumar_a_jugador_azul:
	inc R14D
	jmp sig_celda

sumar_a_jugador_rojo:
	inc R15D
	jmp sig_celda


fin_rec:
	mov R8, [rsp+16]
	mov R9, [rsp+8]
	mov dword[R8], R15D
	mov dword[R9], R14D
	add rsp, 24
	pop R15
	pop R14
	pop R13
	pop R12
	pop RBX
	pop RBP
	ret

global jugador_de_carta
jugador_de_carta:
	push RBP
	mov rbp, rsp

	push RBX
	push R12
	push R13
	push R14
	push R15
	sub rsp, 8

	mov RBX, RDI
	mov R8B, BYTE[RBX+carta.jugador]

	mov AL, R8B
	add rsp, 8
	pop R15
	pop R14
	pop R13
	pop R12
	pop RBX
	pop RBP
	ret


