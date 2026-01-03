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
;   - es_indice_ordenado
global EJERCICIO_1A_HECHO
EJERCICIO_1A_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - indice_a_inventario
global EJERCICIO_1B_HECHO
EJERCICIO_1B_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

;########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
; Completar las definiciones (serán revisadas por ABI enforcer):
ITEM_NOMBRE EQU 0
ITEM_FUERZA EQU 20
ITEM_DURABILIDAD EQU 24
ITEM_SIZE EQU 28

;; La funcion debe verificar si una vista del inventario está correctamente 
;; ordenada de acuerdo a un criterio (comparador)

;; bool es_indice_ordenado(item_t** inventario, uint16_t* indice, uint16_t tamanio, comparador_t comparador);

;; Dónde:
;; - `inventario`: Un array de punteros a ítems que representa el inventario a
;;   procesar.
;; - `indice`: El arreglo de índices en el inventario que representa la vista.
;; - `tamanio`: El tamaño del inventario (y de la vista).
;; - `comparador`: La función de comparación que a utilizar para verificar el
;;   orden.
;; recorro  inventario segun el indice, indexando en el y comparo el actual con el siguiente

; bool es_indice_ordenado(item_t** inventario, uint16_t* indice,
;                         uint16_t tamanio, comparador_t comparador)


global es_indice_ordenado
es_indice_ordenado:
    ; RDI = item_t**   inventario
    ; RSI = uint16_t*  indice
    ; RDX = uint16_t   tamanio
    ; RCX = comparador_t

    ; Prólogo
    push    rbp
    mov     rbp, rsp
    push    rbx              ; callee-saved
    push    r12
    push    r13
    push    r14
    push    r15

    ; Bases
    mov     rbx, rdi         ; base inventario (item_t**)
    mov     r12, rsi         ; base indice (uint16_t*)
    mov     r15, rcx         ; comparador_t

    ; tamanio en r13 (límite = tamanio - 1)
    movzx   r13, dx          ; r13 = tamanio (0..65535)
    cmp     r13, 1
    jbe     .ordenado        ; 0 o 1 elemento -> ordenado
    dec     r13              ; r13 = limite = tamanio - 1

    xor     r14, r14         ; i = 0

.loop:
    ; if (i >= limite) return true;
    cmp     r14, r13
    jae     .ordenado

    ; idx_i = indice[i] (uint16_t)
    movzx   eax, word [r12 + r14*2]
    ; a = inventario[idx_i] (item_t*)
    mov     rdi, [rbx + rax*8]

    ; idx_{i+1} = indice[i+1]
    movzx   eax, word [r12 + r14*2 + 2]
    ; b = inventario[idx_{i+1}]
    mov     rsi, [rbx + rax * 8]

    ; comparador(a, b)
    ; 
	sub RSP, 8
    call    r15
	add rsp, 8
    ; si comparador(a,b) == false -> no ordenado
    test    eax, eax
    je      .no_ordenado

    inc     r14
    jmp     .loop

.no_ordenado:
    mov    eax, 0       ; return false (0)
.epilogo:
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    pop     rbp
    ret

.ordenado:
    mov     eax, 1           ; return true (1)
    jmp     .epilogo

;; Dado un inventario y una vista, crear un nuevo inventario que mantenga el
;; orden descrito por la misma.

;; La memoria a solicitar para el nuevo inventario debe poder ser liberada
;; utilizando `free(ptr)`.

;; item_t** indice_a_inventario(item_t** inventario, uint16_t* indice, uint16_t tamanio);

;; Donde:
;; - `inventario` un array de punteros a ítems que representa el inventario a
;;   procesar.
;; - `indice` es el arreglo de índices en el inventario que representa la vista
;;   que vamos a usar para reorganizar el inventario.
;; - `tamanio` es el tamaño del inventario.
;; 
;; Tenga en consideración:
;; - Tanto los elementos de `inventario` como los del resultado son punteros a
;;   `ítems`. Se pide *copiar* estos punteros, **no se deben crear ni clonar
;;   ítems**

global indice_a_inventario
indice_a_inventario:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits o 8 bits.
	;
	; RDI = item_t**  inventario
	; RSI = uint16_t* indice
	; RDX = uint16_t  tamanio

	push RBP 
	mov RBP, RSP

	;guardo registros callee-saved
	push rbx
	push r12
	push r13

	; Guardar bases y tamaño **antes** de pisar registros volátiles
    mov     rbx, rdi        ; rbx = base inventario
    mov     r12, rsi        ; r12 = base indice
    movzx   r13, dx         ; r13 = tamanio (0..65535)

    ; size = tamanio * 8  → en RDI para malloc
    mov     rdi, r13
    shl     rdi, 3
	;alinear pila
	sub     rsp, 8
    call    malloc          ; RAX = puntero al nuevo array (item_t**)
    add     rsp, 8
	mov rdi, rax
	test r13, r13 ; para saber si el tamaño es 0
	jz end
	xor rcx, rcx

lpp:
	cmp 	rcx, r13
	jae end
	movzx 	eax, word[r12 + rcx*2]
	mov     r8, [rbx + rax*8]
	mov [RDI+RCX*8], R8
	INC RCX
	jmp lpp

end:
	mov rax, rdi ; IMPORTANE DEVOLVER EL PUNTERO AL COMIENZO DEL ARRAY 
	;prologo
	pop R13
	pop R12
	pop RBX
	pop RBP

	ret
