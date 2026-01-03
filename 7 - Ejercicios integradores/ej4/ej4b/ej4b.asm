extern strcmp
global invocar_habilidad

; Completar las definiciones o borrarlas (en este ejercicio NO serán revisadas por el ABI enforcer)
DIRENTRY_NAME_OFFSET EQU 0
DIRENTRY_PTR_OFFSET EQU 16
DIRENTRY_SIZE EQU 24

FANTASTRUCO_DIR_OFFSET EQU 0
FANTASTRUCO_ENTRIES_OFFSET EQU 8
FANTASTRUCO_ARCHETYPE_OFFSET EQU 16
FANTASTRUCO_FACEUP_OFFSET EQU 24
FANTASTRUCO_SIZE EQU 32

section .rodata
; Acá se pueden poner todas las máscaras y datos que necesiten para el ejercicio

section .text

; void invocar_habilidad(void* carta, char* habilidad);
invocar_habilidad:	
	push RBP
	mov RBP, rsp

	push RBX
	push R12
	push R13
	push R14
	push R15
	sub rsp, 24

	mov [rsp+8], RDI ;carta
	mov [rsp+16], RSI ;habilidad
	mov R12, [rdi+FANTASTRUCO_DIR_OFFSET] ;direccion de comienzo de array de PUNTEROS
	xor R13, R13
	mov RBX, [rdi+FANTASTRUCO_ENTRIES_OFFSET]; cantidad de habilidades
buscar_habilidad:
	cmp R13, RBX
	je buscar_en_arquetipo
	mov R9, R13
	imul R9, 8
	mov R14, [R12+r9] ;PUNTERO A HABILIDAD
	lea R10, [R14+DIRENTRY_NAME_OFFSET]
	mov RDI, R10
	mov RSI, [rsp+16]
	call strcmp
	cmp RAX, 0
	je habilidad_encontrada
	inc R13
	jmp buscar_habilidad
buscar_en_arquetipo:
	mov R8, [rsp+8]
	mov R9, [R8+FANTASTRUCO_ARCHETYPE_OFFSET]
	cmp R9, 0
	je FIN
	mov RDI, R9
	mov RSI, [rsp+16]
	call invocar_habilidad
	jmp FIN
habilidad_encontrada:
	mov R8, [R14+DIRENTRY_PTR_OFFSET]
	mov RDI, [rsp+8]
	call R8
	jmp FIN

FIN:
	add rsp, 24
	pop R15
	pop R14
	pop R13
	pop R12
	pop RBX
	pop RBP
	ret