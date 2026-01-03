extern sumar_c
extern restar_c
;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;########### LISTA DE FUNCIONES EXPORTADAS

global alternate_sum_4
global alternate_sum_4_using_c
global alternate_sum_4_using_c_alternative
global alternate_sum_8
global product_2_f
global product_9_f

;########### DEFINICION DE FUNCIONES
; uint32_t alternate_sum_4(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; parametros: 
; x1 --> EDI 32 bits
; x2 --> ESI 32 bits
; x3 --> EDX 32 bits
; x4 --> ECX 32 bits
alternate_sum_4:
  sub EDI, ESI
  add EDI, EDX
  sub EDI, ECX

  mov EAX, EDI
  ret

; uint32_t alternate_sum_4_using_c(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; parametros: 
; x1 --> EDI
; x2 --> ESI
; x3 --> EDX
; x4 --> ECX
alternate_sum_4_using_c:
  ;prologo
  push RBP ;pila alineada
  mov RBP, RSP ;strack frame armado
  push R12
  push R13	; preservo no volatiles, al ser 2 la pila queda alineada

  mov R12D, EDX ; guardo los parámetros x3 y x4 ya que están en registros volátiles
  mov R13D, ECX ; y tienen que sobrevivir al llamado a función

  call restar_c 
  ;recibe los parámetros por EDI y ESI, de acuerdo a la convención, y resulta que ya tenemos los valores en esos registros
  
  mov EDI, EAX ;tomamos el resultado del llamado anterior y lo pasamos como primer parámetro
  mov ESI, R12D
  call sumar_c

  mov EDI, EAX
  mov ESI, R13D
  call restar_c

  ;el resultado final ya está en EAX, así que no hay que hacer más nada

  ;epilogo
  pop R13 ;restauramos los registros no volátiles
  pop R12
  pop RBP ;pila desalineada, RBP restaurado, RSP apuntando a la dirección de retorno
  ret


alternate_sum_4_using_c_alternative:
  ;prologo
  push RBP ;pila alineada
  mov RBP, RSP ;strack frame armado
  sub RSP, 16 ; muevo el tope de la pila 8 bytes para guardar x4, y 8 bytes para que quede alineada

  mov [RBP-8], RCX ; guardo x4 en la pila

  push RDX  ;preservo x3 en la pila, desalineandola
  sub RSP, 8 ;alineo
  call restar_c 
  add RSP, 8 ;restauro tope
  pop RDX ;recupero x3
  
  mov EDI, EAX
  mov ESI, EDX
  call sumar_c

  mov EDI, EAX
  mov ESI, [RBP - 8] ;leo x4 de la pila
  call restar_c

  ;el resultado final ya está en EAX, así que no hay que hacer más nada

  ;epilogo
  add RSP, 16 ;restauro tope de pila
  pop RBP ;pila desalineada, RBP restaurado, RSP apuntando a la dirección de retorno
  ret


; uint32_t alternate_sum_8(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4, uint32_t x5, uint32_t x6, uint32_t x7, uint32_t x8);
;+ ; Calling convention (System V AMD64 ABI):
; x1 -> EDI, x2 -> ESI, x3 -> EDX, x4 -> ECX, x5 -> R8D, x6 -> R9D,
; x7 -> [RBP+16] (stack), x8 -> [RBP+24] (stack)
alternate_sum_8:
	;prologo
  push RBP
  mov  RBP, RSP

  mov EAX, EDI ; +x1
  sub EAX, ESI ;- x2
  add EAX, EDX ; +x3
  sub EAX, ECX ; -x4
  add EAX, R8D ; +x5
  sub EAX, R9D ; -x6
  add EAX, dword [RBP+16]; +x7
  sub EAX, dword [RBP+24]; -x8
  
  pop RBP
	;epilogo
	ret


; SUGERENCIA: investigar uso de instrucciones para convertir enteros a floats y viceversa
;void product_2_f(uint32_t * destination, uint32_t x1, float f1);
;registros: destination[?], x1[?], f1[?]
;dst->RDI, x1->ESI, f1->XMM0
product_2_f:
    mov     eax, esi          ; zero-extend a 64 bits
    cvtsi2ss xmm1, rax        ; xmm1 = (float) x1   (fuente 64b => sin problema de signo)

    mulss   xmm0, xmm1        ; xmm0 = f1 * (float)x1

    ; *** TRUNCAR (no redondear) ***
    cvttss2si rax, xmm0       ; RAX = trunc(xmm0) como int64 (ignora el modo de redondeo)
    mov     [rdi], eax        ; guardar 32 bits bajos como uint32_t
    ret



;extern void product_9_f(double * destination
;, uint32_t x1, float f1, uint32_t x2, float f2, uint32_t x3, float f3, uint32_t x4, float f4
;, uint32_t x5, float f5, uint32_t x6, float f6, uint32_t x7, float f7, uint32_t x8, float f8
;, uint32_t x9, float f9);
;registros y pila: destination[rdi], 
;x1 -> ESI, f1[XMM0], x2[EDX], f2[XMM1], x3[ECX], f3[XMM2], x4[R8D], f4[XMM3]
;, x5[R9D], f5[XMM4], x6[RBX], f6[XMM5], x7[RBP+16], f7[XMM6], x8[RBP+24], f8[XMM7],
;, x9[RBP+32], f9[XMM8]
product_9_f:
	;prologo
	push rbp
	mov rbp, rsp

  cvtss2sd xmm0, xmm0 ; convertimos f1 a double y lo dejamos en xmm0, que es donde vamos a ir acumulando el producto
  cvtss2sd xmm1, xmm1 ; convertimos f2 a double
  mulsd xmm0, xmm1 ; xmm0 *= f2
  cvtss2sd xmm1, xmm2 ; convertimos f3 a double
  mulsd xmm0, xmm1 ; xmm0 *= f3
  cvtss2sd xmm1, xmm3 ; convertimos f4 a double
  mulsd xmm0, xmm1 ; xmm0 *= f4
  cvtss2sd xmm1, xmm4 ; convertimos f5 a double
  mulsd xmm0, xmm1 ; xmm0 *= f5
  cvtss2sd xmm1, xmm5 ; convertimos f6 a double
  mulsd xmm0, xmm1 ; xmm0 *= f6
  cvtss2sd xmm1, xmm6 ; convertimos f7 a double
  mulsd xmm0, xmm1 ; xmm0 *= f7
  cvtss2sd xmm1, xmm7 ; convertimos f8 a double
  mulsd xmm0, xmm1 ; xmm0 *= f8
  cvtss2sd xmm1, dword [rbp+48] ; f9 (en pila, 32-bit)
  mulsd   xmm0, xmm1
	; convertimos los enteros en doubles y los multiplicamos por xmm0.
  cvtsi2sd xmm1, esi           ; x1
  mulsd   xmm0, xmm1
  cvtsi2sd xmm1, edx           ; x2
  mulsd   xmm0, xmm1
  cvtsi2sd xmm1, ecx           ; x3
  mulsd   xmm0, xmm1
  cvtsi2sd xmm1, r8d           ; x4
  mulsd   xmm0, xmm1
  cvtsi2sd xmm1, r9d           ; x5
  mulsd   xmm0, xmm1

  mov     eax, dword [rbp+16]  ; x6
  cvtsi2sd xmm1, eax
  mulsd   xmm0, xmm1

  mov     eax, dword [rbp+24]  ; x7
  cvtsi2sd xmm1, eax
  mulsd   xmm0, xmm1

  mov     eax, dword [rbp+32]  ; x8
  cvtsi2sd xmm1, eax
  mulsd   xmm0, xmm1

  mov     eax, dword [rbp+40]  ; x9
  cvtsi2sd xmm1, eax
  mulsd   xmm0, xmm1

    ; guardar resultado
  movsd   [rdi], xmm0

  pop     rbp
  ret
