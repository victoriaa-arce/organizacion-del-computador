;########### SECCION DE DATOS
section .data

CLT_str: db "CLT"   ; "CLT\0"
RBO_str: db "RBO"   ; "RBO\0"

;########### SECCION DE TEXTO (PROGRAMA)
section .text
extern segmentar_casos
extern memcpy
extern strncmp

extern contar_casos_por_nivel
; Completar las definiciones (serán revisadas por ABI enforcer):
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

ESTADISTICAS_CLT_OFFSET EQU 0
ESTADISTICAS_RBO_OFFSET EQU 0
ESTADISTICAS_KSC_OFFSET EQU 0
ESTADISTICAS_KDT_OFFSET EQU 0
ESTADISTICAS_ESTADO0_OFFSET EQU 0
ESTADISTICAS_ESTADO1_OFFSET EQU 0
ESTADISTICAS_ESTADO2_OFFSET EQU 0
ESTADISTICAS_SIZE EQU 0

global resolver_automaticamente

;void resolver_automaticamente(funcionCierraCasos* funcion, caso_t* arreglo_casos, caso_t* casos_a_revisar, int largo)
resolver_automaticamente:
    push RBP
    mov rbp, rsp

    push RBX
    push R12
    push R13
    push R14
    push R15
    sub rsp, 24
    ;llamo a segmentar casos y laburo desde ahi
    mov RBX, RDI ; funcion
    mov [rsp+8], RSI ; arreglo casos
    mov [rsp+16], RDX ; casos a revisar
    mov R12D, ECX ; int largo
    xor R13, R13
    xor R15, R15 ; puntero en casos_a_revisar
recorrer_casos:
    cmp R13, R12
    je fin
    mov R8, R13
    imul R8, CASO_SIZE
    mov r9, [rsp+8]
    lea R14, [R9+R8]; direccion de memoria de caso a revisar
    mov RDI, R14
    call nivel_del_caso
    mov R8, RAX
    cmp R8, 0
    je copiar_caso_a_revisar
    jae nivel_1_o_2

nivel_1_o_2:
    mov RDI, R14
    call RBX
    mov R8, RAX
    cmp R8, 0
    je caso_funcion_0
    jmp caso_1

caso_funcion_0:
    mov RDI, R14
    call categoria_del_caso
    mov [rsp+24], RAX
    mov RDI, RAX
    mov RSI, CLT_str
    mov RDX, 3
    call strncmp
    cmp RAX, 0
    je caso_clt_o_rbo
    mov RDI, [rsp+24]
    mov RSI, RBO_str
    mov RDX, 3
    call strncmp
    cmp RAX, 0
    je caso_clt_o_rbo
    jmp copiar_caso_a_revisar


caso_1:     
    mov  word [R14+CASO_ESTADO_OFFSET], 1
    jmp sig_caso


caso_clt_o_rbo:
    mov  word [R14+CASO_ESTADO_OFFSET], 2
    jmp sig_caso


copiar_caso_a_revisar:
    mov R8, [rsp+16] ;casos_a_revisar
    mov R9, R15
    imul R9, CASO_SIZE
    lea R10, [r8+r9] ;direccion de memoria para copiar_caso
    mov RSI, R14
    mov RDI, R10
    mov RDX, CASO_SIZE 
    call memcpy
    inc R15 
    jmp sig_caso

sig_caso:
    inc R13
    jmp recorrer_casos


fin:
    add rsp, 24
    pop R15
    pop R14
    pop R13
    pop R12
    pop RBX
    pop RBP
    ret

global nivel_del_caso
nivel_del_caso:
    push RBP
    mov rbp, rsp

    push RBX
    push R12
    push R13
    push R14
    push R15
    sub rsp, 8

    mov RBX, RDI
    mov R12, [RBX+CASO_USUARIO_OFFSET]
    mov R13, [R12+USUARIO_NIVEL_OFFSET]
    mov RAX, R13


    add rsp, 8
    pop R15
    pop R14
    pop R13
    pop R12
    pop RBX
    pop RBP
    ret

global categoria_del_caso_del_caso
categoria_del_caso:
    push rbp
    mov  rbp, rsp

    ; RDI = caso_t*
    lea  rax, [rdi + CASO_CATEGORIA_OFFSET]   ; RAX = &caso->categoria[0]

    pop  rbp
    ret
