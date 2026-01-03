extern malloc

section .rodata
; Acá se pueden poner todas las máscaras y datos que necesiten para el ejercicio

section .text
; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

; Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - optimizar
global EJERCICIO_2A_HECHO
EJERCICIO_2A_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - contarCombustibleAsignado
global EJERCICIO_2B_HECHO
EJERCICIO_2B_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Marca el ejercicio 1C como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - modificarUnidad
global EJERCICIO_2C_HECHO
EJERCICIO_2C_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

;########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
; Completar las definiciones (serán revisadas por ABI enforcer):
ATTACKUNIT_CLASE EQU 0
ATTACKUNIT_COMBUSTIBLE EQU 12
ATTACKUNIT_REFERENCES EQU 14
ATTACKUNIT_SIZE EQU 16

global optimizar
global optimizar
extern free        ; opcional, si querés liberar instancias



global optimizar
optimizar:
	;prólogo
    push RBP
	mov RBP, RSP

	push RBX ; guardo registros callee
	push R12
	push R13
	push R14
	push R15

	mov RBX, RDI ;MAPA
	mov R12, RSI ;UNIDAD COMPARTIDA
	mov R13, RDX ;FUNCION HASH

	;debo guardar hash(unidad_compartida) EN LA PILA
	sub RSP, 8
	mov RDI, R12
	call R13
	mov dword[rsp], EAX

	;recorrido prep
	xor R14, R14 ; indice para recorrer mapa

recorrido:
	cmp R14, 65025
	jae fin ; si recorri todo el array 
	mov R15, [RBX + R14*8] 
	test  r15, r15
    je    next         
	;comparo para ver si ya apuntan al mismo lugar
	cmp R15, R12 
	je next
	;calculo hash de mapa[index]
	mov RDI, R15
	call R13
	mov R9D, EAX
	;comparo el res
	cmp R9D, dword[rsp]
	;salto si es distinto
	je cambiar
	jmp next

next:
	INC R14
	JMP recorrido
	
cambiar:
	;1° restar ref 
	lea   r10, [r15 + ATTACKUNIT_REFERENCES]  ; calcula dirección
	sub   byte [r10], 1                       ; especificar tamaño: byte
	;cambio puntero en el mapa 
	mov [RBX + R14*8], R12
	;me falto sumar a referencias de unidad compartida
	movzx   rdx, byte [r12 + ATTACKUNIT_REFERENCES]
	inc dl
	mov     byte [r12 + ATTACKUNIT_REFERENCES], dl
	cmp byte[R10], 0
	je borrar_referencia
	jmp next

borrar_referencia:
	;debo liberar la memoria 
	;
	mov RDI, R15
	call free
	jmp next
	
fin:
	add     rsp, 8
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    pop     rbp
    ret



global contarCombustibleAsignado
contarCombustibleAsignado:
	; RDI = mapa_t           mapa
	; RSI = uint16_t*        fun_combustible(char*)
	
	;prólogo
	push RBP
	mov RBP, RSP

	;guardo algunos regs callee-saved
	push RBX
	push R12
	push R13
	push R14
	push R15
	sub RSP, 8

	;muevo los argumentos a regs callee
	mov RBX, RDI ; mapa
	mov R12, RSI ; funcion combustible

	XOR R13, R13 ; indice
	XOR R14D, R14D ; combustible asignado 
rec: 
	cmp		R13, 65025
	;chequeo si llegué al final
	jae		term 
	;
	mov 	R15, [RBX + R13*8] ; UNIDAD DE ATAQUE
	test  	r15, r15
    je    	sig 
	mov 	RDI, R15
	call 	R12
	movzx 	R9D, AX ; combustible base
	movzx 	R8D, word[R15+ATTACKUNIT_COMBUSTIBLE] ;combustible total

	sub 	R8D, R9D
	add 	R14D, R8D
	jmp 	sig 
sig:
	inc 	R13
	jmp		rec
term:
	add 	rsp, 8
	mov   	EAX, R14D
	pop		R15
	pop		R14
	pop		R13
	pop		R12
	pop		RBX
	pop		RBP
	ret

global modificarUnidad
modificarUnidad:
	; RDI = mapa_t           mapa
	; RSI  = uint8_t          x
	; RDX  = uint8_t          y
	; RCX  = void*            fun_modificar(attackunit_t*)

	;recorrer funcion hasta llegar hasta el elem buscado ?
	;debo considerar aquellos que comparten punteros !!!!
	;cuando accedo al elem me fijo en refs si es igual a 1 todo tranqui sino
	;resto y ahi cambio el puntero, copio el struct y hago memcpy?

	;prólogo
	push RBP 
	mov RBP, RSP

	;guardo regs callee-saved
	push RBX
	push R12
	push R13
	push R14
	push R15

	;guardo args en regs no volatiles
	mov RBX, RDI
	movzx R12, SIL
	movzx R13, DL
	mov R14, RCX
acceder_a_elem:
	;guardo elem en R9
	imul    rax, r13, 255
    add     rax, r12

	lea     r8, [rbx + rax*8]       ; r9 = &mapa[y][x]
    mov     r15, [r8] 

	test R15, R15
	je finfin

	mov R9, [R8 + ATTACKUNIT_REFERENCES]
	cmp R9, 1
	jg	cambiar_ref
llamar_funcion:
	mov RDI, R8
	;call R14
	jmp finfin

cambiar_ref:
	;cambio la ref

	;salto a llamar funcion 
	jmp llamar_funcion 

	
finfin:

	pop R15
	pop R14
	pop R13
	pop R12
	pop RBX 
	pop RBP
	ret
