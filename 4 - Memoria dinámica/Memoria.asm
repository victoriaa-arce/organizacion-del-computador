extern malloc
extern free
extern fprintf

section .data

section .text

global strCmp
global strClone
global strDelete
global strPrint
global strLen

; ** String **
;C representa a los strings como una sucesión de char's terminada con el caracter nulo '\0'.
; int32_t strCmp(char* a, char* b)
;falta caso una mayor que la otra

strCmp:
	push RBP 
	mov RBP, RSP
	; puntero de a viene en RDI
	; puntero de b viene en RSI
	; voy a usar pila para guardar los indices
	
recorrido:
	movzx eax, byte[rdi] ;mira char a char
	movzx edx, byte[rsi] 

	cmp eax, edx ; “actualiza flags como si hiciera eax - edx”.
	jne dif ; salta a la etiqueta dif si eax-edx /= 0
	
	test eax, eax
	je igual

	inc rdi
	inc rsi
	jmp recorrido


dif:
	jb a_menorque_b ; eax < edx jump if below, usa las flags que deja cmp
	mov eax, -1 ; eax > edx

	jmp fin

a_menorque_b:
	mov eax, 1
	jmp fin

igual: 
	xor eax, eax
	jmp fin
	
fin:
	pop RBP
	ret

; char* strClone(char* a)
strClone:
	push RBP
	mov RBP, RSP ;PRÓLOGO

	
	push rsi
	push r12
	push r13
	push rdi

	call strLen
	xor r12, r12
	INC EAX
	mov R12D, EAX
	xor RDI, RDI
	mov EDI, EAX
	call malloc ; en RAX me devuelve puntero a direccion de memoria, CALL HACE PUSH RIP Y JMP A LA ETIQUETA DE LA FUNCION


	pop RDI ; MOVIENDO CON INDICE Y PREGUNTO SI ES 0
	XOR r13, r13
ciclo:
; copiar char a char
	cmp  BYTE[rdi+r13], 0
	je termine
	mov R8B, BYTE[rdi + r13]
	mov [rax + r13], R8B
	INC R13
	JMP ciclo



termine:
	mov [rax + r13], byte 0 ; faltaba el final del string
	pop r13 
	pop r12
	pop rsi
	POP RBP
	ret 

    
; void strDelete(char* a)
strDelete:
	call     free
	ret

; void strPrint(char* a, FILE* pFile)
strPrint:
	ret

; uint32_t strLen(char* a)
strLen:
	xor     rax, rax        ; contador = 0 (en rax)
ciclo_len:
	mov     r8b, [rdi + rax] ; dl = s[contador]
	cmp     r8b , 0       ; ¿es '\0'?
    je     end          ; sí => terminamos
    inc     eax             ; contador++
    jmp     ciclo_len

end:
	ret


