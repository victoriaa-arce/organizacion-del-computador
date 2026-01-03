

;########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
; Completar las definiciones (serán revisadas por ABI enforcer):
NODO_OFFSET_NEXT EQU 0
NODO_OFFSET_CATEGORIA EQU 8
NODO_OFFSET_ARREGLO EQU 16
NODO_OFFSET_LONGITUD EQU 24 	
NODO_SIZE EQU 32
PACKED_NODO_OFFSET_NEXT EQU 0
PACKED_NODO_OFFSET_CATEGORIA EQU 8
PACKED_NODO_OFFSET_ARREGLO EQU 9
PACKED_NODO_OFFSET_LONGITUD EQU 17
PACKED_NODO_SIZE EQU 21
LISTA_OFFSET_HEAD EQU 0
LISTA_SIZE EQU 8
PACKED_LISTA_OFFSET_HEAD EQU 0
PACKED_LISTA_SIZE EQU 8

;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;########### LISTA DE FUNCIONES EXPORTADAS
global cantidad_total_de_elementos
global cantidad_total_de_elementos_packed

;########### DEFINICION DE FUNCIONES
;extern uint32_t cantidad_total_de_elementos(lista_t* lista);
;registros: lista[?]
cantidad_total_de_elementos: ; el puntero viene en RDI 
; necesito guardar en algun registro la direccion para el proximo nodo 
	; lista puede ser NULL: manejarlo
    test    rdi, rdi
    jz      fin
	XOR R8D, R8D ; limpio para guardar el tamaño de los arrays 
	mov     rdi, [rdi + LISTA_OFFSET_HEAD] ; cargo el primer nodo
ciclo: 
	test rdi, rdi
	jz fin
	add R8D, dword [RDI + NODO_OFFSET_LONGITUD] ; sumo la longitud del arreglo
	mov RDI, [RDI + NODO_OFFSET_NEXT] ; cargo el siguiente nodo
	jmp ciclo 
fin: 
	mov EAX, R8D
	ret

;extern uint32_t cantidad_total_de_elementos_packed(packed_lista_t* lista);
;registros: lista[?]
cantidad_total_de_elementos_packed:
	; necesito guardar en algun registro la direccion para el proximo nodo 
	; lista puede ser NULL: manejarlo
    test    rdi, rdi
    jz      end
	XOR R8D, R8D ; limpio para guardar el tamaño de los arrays 
	mov     rdi, [rdi + PACKED_LISTA_OFFSET_HEAD] ; cargo el primer nodo
loop: 
	test rdi, rdi
	jz end 
	add R8D, dword [RDI + PACKED_NODO_OFFSET_LONGITUD] ; sumo la longitud del arreglo
	mov RDI, [RDI + PACKED_NODO_OFFSET_NEXT] ; cargo el siguiente nodo
	jmp loop
end: 
	mov EAX, R8D
	ret

