global segmentar_casos
global contar_casos_por_nivel
extern malloc
extern memcpy

; --- Offsets ---
USUARIO_ID_OFFSET       EQU 0
USUARIO_NIVEL_OFFSET    EQU 4
USUARIO_SIZE            EQU 8

CASO_CATEGORIA_OFFSET   EQU 0
CASO_ESTADO_OFFSET      EQU 4
CASO_USUARIO_OFFSET     EQU 8
CASO_SIZE               EQU 16

SEGMENTACION_CASOS0_OFFSET EQU 0
SEGMENTACION_CASOS1_OFFSET EQU 8
SEGMENTACION_CASOS2_OFFSET EQU 16
SEGMENTACION_SIZE          EQU 24

; ---------------------------------------------------------------------------
; int contar_casos_por_nivel(caso_t* arreglo_casos, int largo, int nivel)
; RDI = arreglo, RSI = largo, EDX = nivel
; ---------------------------------------------------------------------------

;-----------------------------------------
; RBX: arreglo_casos                      |                  
; R12: largo                              |
; R13: nivel                              |
; R14: puntero a arreglo casos_nivel      |
; R15: indice casos                       |
; R8: indice en nuevo arreglo             |
; R9                                      |
; R10                                     |
; R11                                     |
; RCX                                     |
; RDX                                     |
; RSP+8: struct seg                       |
;                                         |
;-----------------------------------------

global segmentar_casos
segmentar_casos:
    push RBP
    mov rbp, rsp

    push RBX
    push R12
    push R13
    push R14
    push R15
    sub rsp, 24

    xor R12, R12
    mov RBX, RDI 
    mov R12D, ESI
    mov RDI, 24
    call malloc
    mov R13, RAX
    mov [rsp+8], R13
    xor R13, R13

contar_casos:
    cmp R13, 3
    je fin 
    mov RDI, RBX
    mov RSI, R12
    mov RDX, R13
    call contar_casos_por_nivel
    cmp RAX, 0
    je nivel_vacio
    mov RDI, RAX
    imul RDI, CASO_SIZE
    call malloc
    mov R14, RAX

    mov R9, [rsp+8]
    lea R10, [r9+R13*8]
    mov [R10], R14
    xor R15, R15
    xor R8, R8 
rec:
    cmp R15D, R12D
    je proximo_nivel
    mov RCX, R15
    imul RCX, CASO_SIZE
    lea R9, [RBX+RCX]
    mov R10, [R9+CASO_USUARIO_OFFSET]
    mov R11, [R10+USUARIO_NIVEL_OFFSET]
    cmp R11, R13
    je copiar_caso
    jmp siguiente_caso
copiar_caso:
    mov RAX, R8
    imul RAX, CASO_SIZE
    lea RDI, [R14+RAX]
    mov RSI, R9 
    mov RDX, CASO_SIZE
    mov [rsp+16], R8
    call memcpy
    mov R8, [rsp+16]
    inc R8
    jmp siguiente_caso

nivel_vacio:
    mov R9, [rsp+8]
    lea R10, [r9+R13*8]
    mov R14, 0
    mov [R10], R14
    jmp proximo_nivel

siguiente_caso:
    inc R15D
    jmp rec

proximo_nivel:
    inc R13
    jmp contar_casos

fin:
    mov RAX, [rsp+8]
    add rsp, 24
    pop R15
    pop R14
    pop R13
    pop R12
    pop RBX
    pop RBP
    ret













global contar_casos_por_nivel
contar_casos_por_nivel:
    push RBP
    mov rbp, rsp

    push RBX
    push R12
    push R13
    push R14
    push R15
    sub rsp, 8

    mov RBX, RDI ;puntero a arreglo
    mov R12, RSI ; largo arreglo
    mov R15, RDX ; nivel buscado
    xor R13, R13
    xor R14, R14 ;contador
recorrer:
    cmp R13, R12
    je fin_contar
    mov RCX, R13
    imul RCX, CASO_SIZE
    lea R8, [RBX + RCX]          ; R8 = &arreglo_casos[i]
    mov r9, [r8+CASO_USUARIO_OFFSET]

    mov R10D, dword[R9+USUARIO_NIVEL_OFFSET]
    cmp R10, R15
    jne siguiente
    inc R14
    jmp siguiente
siguiente:
    inc R13
    jmp recorrer
fin_contar:
    mov RAX, R14
    add rsp, 8
    pop R15
    pop R14
    pop R13
    pop R12
    pop RBX
    pop RBP
    ret
