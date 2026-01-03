extern malloc
extern sleep
extern wakeup
extern create_dir_entry

section .rodata
; Acá se pueden poner todas las máscaras y datos que necesiten para el ejercicio
sleep_name: DB "sleep", 0
wakeup_name: DB "wakeup", 0

section .text
; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

; Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - init_fantastruco_dir
global EJERCICIO_1A_HECHO
EJERCICIO_1A_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - summon_fantastruco
global EJERCICIO_1B_HECHO
EJERCICIO_1B_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

;########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
; Completar las definiciones (serán revisadas por ABI enforcer):
DIRENTRY_NAME_OFFSET EQU 0
DIRENTRY_PTR_OFFSET EQU 16
DIRENTRY_SIZE EQU 24

FANTASTRUCO_DIR_OFFSET EQU 0
FANTASTRUCO_ENTRIES_OFFSET EQU 8
FANTASTRUCO_ARCHETYPE_OFFSET EQU 16
FANTASTRUCO_FACEUP_OFFSET EQU 24
FANTASTRUCO_SIZE EQU 32

; void init_fantastruco_dir(fantastruco_t* card);
global init_fantastruco_dir
init_fantastruco_dir:
	push RBP
	mov rbp, rsp

	push RBX
	push R12
	push R13
	push R14
	push R15
	sub rsp, 24

	mov RBX, RDI ;carta
;primero cambio cantidad de entries a 2
	mov word[RBX+FANTASTRUCO_ENTRIES_OFFSET], 2
;espacio para dir
	mov RDI, 2
	imul RDI, 8
	call malloc
	mov R12, RAX ;puntero a dir entry
	mov [rbx+FANTASTRUCO_DIR_OFFSET], R12
    ;habilidad sleep 
	mov RDI, sleep_name
	mov RSI, sleep
	call create_dir_entry
	mov [R12], RAX
	;habilidad wakeup
	mov RDI, wakeup_name
	mov RSI, wakeup
	call create_dir_entry
	mov [R12+8], RAX
	mov RAX, RBX

	add rsp, 24
	pop R15
	pop R14
	pop R13
	pop R12
	pop RBX
	pop RBP
	ret ;No te olvides el ret!

; fantastruco_t* summon_fantastruco();
global summon_fantastruco
summon_fantastruco:
	push RBP
	mov rbp, rsp

	push RBX
	push R12
	push R13
	push R14
	push R15
	sub rsp, 8

	mov RDI, FANTASTRUCO_SIZE
	call malloc
	mov RDI, RAX
	call init_fantastruco_dir
	mov R12, RAX
	mov byte[R12+FANTASTRUCO_FACEUP_OFFSET], 1
	 
	

	add rsp, 8
	pop R15
	pop R14
	pop R13
	pop R12
	pop RBX
	pop RBP
	ret

