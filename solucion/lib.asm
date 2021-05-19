section .data
	format_string: db "%s",0
	format_NULL: db "NULL",0
	format_listaAbrir: db "[",0
	format_listaCerrar: db "]",0
	format_listaVacia: db "[]",0
	format_coma: db ",",0
	format_puntero: db "%p",0
	format_slot: db " = ",0
	format_salto: db 10,0
	format_numberSLot: db '%i',0

section .text

global strLen
global strClone
global strCmp
global strConcat
global strDelete
global strPrint
global listNew
global listAddFirst
global listAddLast
global listAdd
global listDelete
global listPrint
global sorterNew
global sorterAdd
global sorterRemove
global sorterGetSlot
global sorterGetConcatSlot
global sorterCleanSlot
global sorterDelete
global sorterPrint
global fs_sizeModFive
global fs_firstChar
global fs_bitSplit
extern free
extern malloc
extern fprintf
extern listRemoveFirst
extern listRemoveLast
extern listRemove

; Orden de parámetros: rdi, rsi, rdx, rcx, r8, r9
; Registros a mantener: rbx, r12, r13, r14, r15

;*** String ***

; char* strClone(char* a)
; a -> rdi
%define p_char r12
strClone:
	push rbp
	mov rbp,rsp ; stack frame
	push p_char ;
	sub rsp, 8 ; alineo la pila
	mov p_char,rdi ; guardo el puntero al char
	call  strLen
	add rax, 1 ; +1 p/ caracter 0
	mov rdi,rax
	call malloc ; rax=char*	
	mov rsi, rax ; puntero auxiliar 
	
	.ciclo:
	cmp BYTE [p_char],0 ; string vacio?
	jz .fin
	mov dil, [p_char] ; pido el char
	mov [rsi],dil ; lo copio
	add p_char, 1 ;sgte char
	add rsi, 1
	jmp .ciclo
	
	.fin:
	mov BYTE [rsi] ,0
	add rsp, 8
	pop r12
	pop rbp
	ret
; ---------------------------------------------------------------------------------------------------------------------------------
; uint32_t strLen(char* a)
; a -> rdi
strLen:
	push rbp
	mov rbp,rsp
	xor eax, eax ;clean eax/contador 
	.ciclo:
	cmp BYTE [rdi],0
	jz .fin
	add eax, 1
	add rdi, 1
	jmp .ciclo
	
	.fin:
	pop rbp
	ret
; ---------------------------------------------------------------------------------------------------------------------------------
%define a rdi
%define b rsi

strCmp: ; rdi = a, rsi = b
	push rbp
	mov rbp, rsp
	xor eax, eax ;eax en cero
	.ciclo:
		cmp byte [a], 0
		je .finA
		cmp byte [b], 0
		je .finB
		mov dl, [a] ; dl = char a
		mov cl, [b] ; cl = char b
		cmp dl, cl
		jg .aMayoraB
		jl .aMenoraB
		inc a 		;avanzamos punteros
		inc b
		jmp .ciclo

	.finA:
		cmp byte [b], 0 ; llegué al final de b?
		je .fin   ; son iguales

	.aMenoraB:
		mov eax, 1 		; a < b
		jmp .fin

	.finB:
		cmp byte [a], 0 ; llegué al final de a?
		je .fin 	  ; son iguales

	.aMayoraB:
		mov eax, -1 	; b < a
		jmp .fin

	.fin:
		pop rbp
		ret


; ---------------------------------------------------------------------------------------------------------------------------------

%define a r12
%define b r13
%define largo_ab r14d
%define offset_a rcx
%define offset_b rdx

strConcat: ; rdi = a, rsi = b
	push rbp
	mov rbp, rsp
	; conservamos datos a usar
	push a 			;puntero al str a
	push b 			;puntero al str b
	push r14 	;para calcular largo total
	push r15
	mov a, rdi
	mov b, rsi
	call strLen ; eax = largo a
	mov largo_ab, eax
	mov rdi, b
	call strLen ; eax = largo b
	add largo_ab, eax
	inc largo_ab ; tenemos en encuenta el cero al final
	xor rdi, rdi ;limpiamos rdi (en particular parte alta)
	mov edi, largo_ab
	call malloc ; rax = puntero al nuevo string de tamaño a + b + 1
	mov r15, rax ;conservamos el puntero original
	xor offset_a, offset_a ; desplazamientos en cero
	xor offset_b, offset_b
	
	.cicloA: ;recorremos el string a
		cmp byte [a + offset_a], 0 ; terminamos de recorrer a?
		je .cicloB
		mov r8b, [a + offset_a]
		mov [rax], r8b
		inc offset_a ;siguiente char de a
		inc rax 	 ;siguiente char del nuevo string
		jmp .cicloA

	.cicloB: ;recorremos el string b
		cmp byte [b + offset_b], 0 ; terminamos de recorrer b?
		je .verificarStrings
		mov r8b, [b + offset_b]
		mov [rax], r8b
		inc offset_b ;siguiente char de b
		inc rax 	 ;siguiente char del nuevo string
		jmp .cicloB

	.verificarStrings:
		mov byte [rax], 0
		cmp a, b ; son el mismo string?
		je .unicoString
		; si no, son diferentes
		mov rdi, a
		call free ;liberamos el string a
		mov rdi, b
		call free ;liberamos el string b
		jmp .fin

	.unicoString:
		mov rdi, a
		call free

	.fin:
		mov rax, r15
		pop r15
		pop r14
		pop b
		pop a
		pop rbp
		ret


strDelete:
	jmp free


;----------------------------------------------------------------------------------------------------------------------------------- 



;aridad para este caso de fprintf y como recibe los parametros
;fprintf ( FILE * stream, const char * format,a ... );
;FILE -> rdi
;formato -> rsi
;a-> rdx

;void strPrint(char* a, FILE *pFile)
;rdi -> a
;rsi -> *pFile
strPrint:
	push rbp
	mov rbp,rsp
	cmp byte [rdi],0 ; string vacio?
	jz .print_NULL
	mov rdx,rdi ;a-> rdx 
	mov rdi,rsi ;FILE -> rdi
	mov rsi,format_string ; formato -> rsi
	call fprintf
	jmp .fin

	.print_NULL:
	mov rdx,format_NULL ;NULL-> rdx 
	mov rdi,rsi ;FILE -> rdi
	mov rsi,format_string ; formato -> rsi
	call fprintf

	.fin:
	pop rbp
	ret

;*** List *** --------------------------------------------------------------------------------------------------------------------
%define OFFSET_FIRST 0
%define OFFSET_LAST 8
%define MEMORY_LIST 16 

listNew:
	push rbp
	mov rbp,rsp
	mov rdi,MEMORY_LIST
	call malloc
	mov qword [rax+OFFSET_FIRST], 0
	mov qword [rax+OFFSET_LAST], 0
	pop rbp
	ret
; ----------------------------------------------------------------------------------------------------------------------------------
%define OFFSET_DATA 0
%define OFFSET_NEXT 8
%define OFFSET_PREV 16
%define MEMORY_NODO 24
%define list_t r12
%define data rbx
%define newNodo rax
%define NULL 0

; void listAddFirst(list_t* l, void* data)
listAddFirst: ;l->rdi, data->rsi
	push rbp
	mov rbp,rsp
	push r12
	push rbx
	mov list_t,rdi
	mov data, rsi
	mov rdi,MEMORY_NODO
	call malloc ; nuevo nodo
	mov [newNodo+OFFSET_DATA],data ; cargo data
	mov qword [newNodo+OFFSET_PREV],NULL ; nuevo primero de la lista
	cmp qword [list_t+OFFSET_FIRST],NULL
	jz .listVacia
	mov rdi, [list_t+OFFSET_FIRST]; viejo primero
	mov [rdi+OFFSET_PREV],rax ;nuevo anterior del viejo primero
	mov [newNodo+OFFSET_NEXT], rdi ;nuevo sgt del primero
	mov [list_t+OFFSET_FIRST], newNodo ; nuevo primero
	jmp .fin

	.listVacia:
	mov qword [newNodo+OFFSET_NEXT],NULL
	mov [list_t+OFFSET_FIRST],rax
	mov [list_t+OFFSET_LAST],rax

	.fin:
	pop rbx
	pop r12
	pop rbp
	ret

; ----------------------------------------------------------------------------------------------------------------------------------

listAddLast:
	push rbp
	mov rbp,rsp
	push r12
	push rbx
	mov list_t,rdi
	mov data, rsi
	mov rdi,MEMORY_NODO
	call malloc ; nuevo nodo
	mov [newNodo+OFFSET_DATA],data ; cargo data
	mov qword [newNodo+OFFSET_NEXT],NULL
	cmp qword [list_t+OFFSET_FIRST],NULL
	jz .listVacia
	mov rdi, [list_t+OFFSET_LAST]; viejo last
	mov [rdi+OFFSET_NEXT], rax ;nuevo anterior del viejo last
	mov [newNodo+OFFSET_PREV], rdi ;nuevo prev del last
	mov [list_t+OFFSET_LAST], newNodo ; nuevo last
	jmp .fin

	.listVacia:
	mov qword [newNodo+OFFSET_PREV],NULL 
	mov [list_t+OFFSET_FIRST],rax
	mov [list_t+OFFSET_LAST],rax

	.fin:
	pop rbx
	pop r12
	pop rbp
	ret


; ---------------------------------------------------------------------------------------------------------------------------------

%define list r12
%define data r13
%define fc r14
%define nuevo r15
%define actual rbx
%define TRUE 1

listAdd: ; rdi = list, rsi = data, rdx = fc
	push rbp
	mov rbp, rsp
	push list
	push data
	push fc
	push actual
	mov list, rdi
	mov data, rsi
	mov fc, rdx
	cmp qword [list + OFFSET_FIRST], NULL
	je .agregarAlPrincipio
	mov actual, [list + OFFSET_FIRST] ; actual = l->first
	mov rdi, data
	mov rsi, [actual + OFFSET_DATA]
	call fc ; eax = data < actual->data?
	cmp eax, TRUE ; if(data < actual->data)
	jne .ciclo
	;si es vacía o data es menor 
	;al primero, agrego al principio y ya
	.agregarAlPrincipio:
		mov rdi, list
		mov rsi, data
		call listAddFirst ; listAddFirst(l, data)
		jmp .fin

	.ciclo:
		cmp actual, NULL
		je .agregarAlFinal
		; mientras no llegue al final o haya 
		; agregado el nodo sigo recorriendo
		mov rdi, data
		mov rsi, [actual + OFFSET_DATA]
		call fc ; eax = data < actual->data?
		cmp eax, TRUE ; if(data < actual->data)
		jne .siguienteCiclo

	.agregarEntreDos:
		; agregamos el nuevo nodo 
		; entre el actual y su anterior, reencadenandolos
		mov rdi, MEMORY_NODO
		call malloc
		mov nuevo, rax
		mov [nuevo + OFFSET_DATA], data ; nuevo->data = data
		mov rdi, [actual + OFFSET_PREV] ; rdi = actual->prev
		mov [nuevo + OFFSET_PREV], rdi  ; nuevo->prev = actual->prev
		mov [nuevo + OFFSET_NEXT], actual ; nuevo->next = actual
		mov [rdi + OFFSET_NEXT], nuevo  ; actual->prev->next = nuevo
		mov [actual + OFFSET_PREV], nuevo ; actual->prev = nuevo
		jmp .fin

	.siguienteCiclo:
		; avanzamos el puntero y continuamos iterando
		mov actual, [actual + OFFSET_NEXT]
		jmp .ciclo

	.agregarAlFinal:
		; llegamos al final por lo 
		; que agregamos al final
		mov rdi, list
		mov rsi, data
		call listAddLast
		jmp .fin

	.fin:
		pop actual
		pop fc
		pop data
		pop list
		pop rbp
		ret


; ----------------------------------------------------------------------------------------------------------------------------------


;%define list r12
%define fn r14
%define aCopiar r15
%define newList rbx

listClone: ; rdi = list, rsi = fn
	push rbp
	mov rbp, rsp
	push list
	push fn
	push aCopiar
	sub rsp, 8
	mov list, rdi
	mov fn, rsi
	mov aCopiar, [list + OFFSET_FIRST] ; aCopiar = l->first
	call listNew ; rax = newList
	mov newList, rax
	
	.ciclo:
		cmp aCopiar, NULL
		je .fin ;terminé de recorrer la lista?
		mov rdi, [aCopiar + OFFSET_DATA]
		call fn ; rax = dataCopy
		mov rdi, newList
		mov rsi, rax
		call listAddLast ; listAddLast(newList, dataCopy)
		mov aCopiar, [aCopiar+OFFSET_NEXT] ;aCopiar = aCopiar->next
		jmp .ciclo
	.fin:
		mov rax, newList
		add rsp, 8
		pop aCopiar
		pop fn
		pop list
		pop rbp
		ret



; ----------------------------------------------------------------------------------------------------------------------------------

%define list r12
%define fd r13
%define actual r14

listDelete: ; rdi = l, rsi = fd
	push rbp
	mov rbp, rsp
	push list
	push fd
	push actual
	sub rsp, 8
	mov list, rdi
	mov fd, rsi
	mov actual, [list + OFFSET_FIRST] ; actual = l->first
	
	.ciclo:
		;removemos cada nodo de la lista y sus datos
		cmp actual, NULL
		je .fin 	; terminé de recorrer la lista?
		mov rdi, list
		mov rsi, fd
		call listRemoveFirst ; listRemoveFirst(l, fd)
		mov actual, [list + OFFSET_FIRST] ; actual = l->first
		jmp .ciclo

	.fin:
		;liberamos la lista
		mov rdi, list
		call free ; free(l)
		add rsp, 8
		pop actual
		pop fd
		pop list
		pop rbp
		ret

;aridad para este caso de fprintf y como recibe los parametros
;fprintf ( FILE * stream, const char * format,a ... );
;FILE -> rdi
;formato -> rsi
;a-> rdx


; -----------------------------------------------------------------------------------------------------------------------------------

%define pFile r13
%define fp r14
%define listElemen_t r15
; void listPrint(list_t* l, FILE *pFile, funcPrint_t* fp)
listPrint: ; l->rdi, pFile-> rsi,fp->rdx
	push rbp
	mov rbp,rsp
	push r12
	push r13
	push r14
	push r15 
	mov list_t, rdi
	mov pFile, rsi
	mov fp, rdx
	mov rdi, pFile
	mov rsi, format_string
	mov rdx, format_listaAbrir
	call fprintf ; print [
	mov listElemen_t, [list_t+OFFSET_FIRST] ;obtengo el nodo
	cmp qword listElemen_t,0 ; lista vacia?
	jz .finLista
	cmp qword listElemen_t,[list_t+OFFSET_LAST]
	jz .list1Elemento ; lista 1 list1Elemento
	.ciclo:
		cmp fp,0
		jz .imprimirPunt
		mov rdi,[listElemen_t+OFFSET_DATA] 
		mov rsi, pFile
		call fp ; print data c/ fp
		jmp .coma
		.imprimirPunt:
		mov rdi, pFile
		mov rsi,format_puntero
		mov rdx, [listElemen_t+OFFSET_DATA]
		call fprintf ; print puntero
		.coma:
		mov rax,[listElemen_t+OFFSET_NEXT]
		mov listElemen_t,rax ; avanzo al sgt nodo
		cmp listElemen_t,0
		jz .finLista
		mov rdi, pFile
		mov rsi,format_string
		mov rdx,format_coma
		call fprintf ; print coma
		jmp .ciclo
	
	.list1Elemento:
		cmp fp,0
		jz .imprimirPuntero
		mov listElemen_t, [list_t+OFFSET_FIRST]
		mov rdi,[listElemen_t+OFFSET_DATA] ; print data c/ fp
		mov rsi, pFile
		call fp
		jmp .finLista
	
	.imprimirPuntero:
	mov rdi, pFile
	mov rsi,format_puntero
	mov listElemen_t, [list_t+OFFSET_FIRST]
	mov rdx, [listElemen_t+OFFSET_DATA]
	call fprintf ; print puntero
	
	.finLista:
	mov rdi, pFile
	mov rsi, format_string
	mov rdx, format_listaCerrar ; print ]
	call fprintf

	.fin:
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	ret





;*** Sorter ***----------------------------------------------------------------------------------------------------------------------

%define sorter_memory 32
%define OFFSET_SIZE 0
%define OFFSET_FUNSORTER 8
%define OFFSET_FUNCOMP 16
%define OFFSET_SLOT 24
%define slots_size r12w
%define fun_sorter r13
%define fun_comp r14
%define sorter_t r15
%define slots_ rbx
; sorter_t* sorterNew(uint16_t slots, funcSorter_t* fs, funcCmp_t* fc)
sorterNew: ; slots->di , rsi=fs ,rdx = fc
	push rbp
	mov rbp,rsp
	push r12
	push r13
	push r14
	push r15
	push rbx
	sub rsp,8
	xor r12,r12
	mov slots_size,di
	mov fun_sorter,rsi
	mov fun_comp,rdx
	mov rdi, sorter_memory
	call malloc ; new sorter_t
	mov sorter_t,rax
	xor rax,rax
	mov ax,8
	mul slots_size
	mov rdi,rax
	call malloc ;new slot
	mov slots_,rax
	mov [sorter_t + OFFSET_SIZE], slots_size
	mov [sorter_t + OFFSET_FUNSORTER], fun_sorter
	mov [sorter_t + OFFSET_FUNCOMP], fun_comp
	mov [sorter_t + OFFSET_SLOT], slots_
	
	.ciclo: ;cargo listas vacias a los slots
		cmp slots_size,0
		jz .fin
		call listNew
		mov [slots_],rax
		sub slots_size, 1
		add slots_,8
		jmp .ciclo

	.fin:
	mov rax,sorter_t
	add rsp,8
	pop rbx
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	ret

; -----------------------------------------------------------------------------------------------------------------------------------
%define sorter_t r12
%define data r13
%define escala_slot 8
%define indice_slot rdx
; void sorterAdd(sorter_t* sorter, void* data)
sorterAdd: ; rdi->sorter, data->rsi
	push rbp
	mov rbp,rsp
	push r12
	push r13
	mov sorter_t, rdi
	mov data,rsi
	mov rax, [sorter_t + OFFSET_FUNSORTER]
	mov rdi, rsi
	call rax ; call funcSorter_t
	xor rdx,rdx 
	mov dx,ax ; rdx = indice del slot
	mov rax,[sorter_t + OFFSET_SLOT] ; obtengo el puntero al slots rax=base_slot
	mov rdi,[rax + indice_slot * escala_slot ] ; obtengo la lista
	mov rsi,data
	mov rdx,[sorter_t+OFFSET_FUNCOMP]
	call listAdd ; agrego el nuevo dato
	pop r13
	pop r12
	pop rbp
	ret



; -----------------------------------------------------------------------------------------------------------------------------------

%define sorter r10
%define data r11
%define funD r12
%define funS r13
%define size_of_list 8

sorterRemove: ;rdi = sorter, rsi = data, rdx = fd
	push rbp
	mov rbp, rsp
	push sorter
	push data
	push funD
	push funS
	mov sorter, rdi
	mov data, rsi
	mov funD, rdx
	mov funS, [sorter + OFFSET_FUNSORTER]
	mov rdi, data
	;sorter->sorterFunction(data)
	call funS 	;eax = slot
	mov eax, eax ;limpiamos parte alta
	mov rdi, [sorter+OFFSET_SLOT] 	;rdi = sorter->slots
	mov rdi, [rdi+rax*size_of_list] ;rdi = sorter->slots[slot]
	mov rsi, data
	mov rdx, [sorter+OFFSET_FUNCOMP]
	mov rcx, funD
	call listRemove ;listRemove(sorter->slots[slot])
	pop funS
	pop funD
	pop data
	pop sorter
	pop rbp
	ret

%define sorter rdi
%define slot rsi
%define fun rdx
;%define funS r13
;%define size_of_list 8

sorterGetSlot: ;rdi = sorter, si = slot, rdx = fn
	push rbp
	mov rbp, rsp
	shl slot, 48
	shr slot, 48 	;limpiamos parte alta
	mov rcx, [sorter + OFFSET_SLOT] ;rcx = sorter->slots
	mov rcx, [rcx + slot * size_of_list] ;rcx = sorter->slots[slot]
	mov rdi, rcx ;rdi = lista a copiar
	mov rsi, fun
	call listClone ; rax = copia
	pop rbp
	ret

%define slot rsi
%define sorter r11
%define actual r12
%define aRecorrer r13
%define stringFinal r15
%define i r11

%define size_of_char 1

sorterGetConcatSlot: ;rdi = sorter, si = slot
	push rbp
	mov rbp, rsp
	push sorter
	push actual
	push aRecorrer
	push stringFinal
	mov sorter, rdi
	shl slot, 48
	shr slot, 48 ; limpiamos parte alta
	mov rdi, [sorter + OFFSET_SLOT] ;rdi = sorter->slots
	mov aRecorrer, [rdi + slot*size_of_list] ;aRecorrer = sorter->slots[slot]
	mov rdi, aRecorrer
	;sumaSizeStrings(aRecorrer)
	call sumaSizeStrings ;eax = largoStringConcat
	mov eax, eax ;limpiamos parte alta
	inc eax ; incrementamos para el cero
	mov rdi, rax ; rdi = memoria a reservar
	call malloc ; rax = puntero a stringFinal
	mov stringFinal, rax
	mov actual, [aRecorrer + OFFSET_FIRST] ;actual = aRecorrer->first
	xor i, i ; i = 0
	.ciclo:
		cmp actual, NULL
		je .fin
		mov rdi, [actual+OFFSET_DATA] ;rdi = actual->data
		.cicloFor:
			mov sil, [rdi] ;sil = actual->data[j]
			cmp sil, 0 ; fin string?
			je .finFor
			mov [stringFinal+i*size_of_char], sil ; stringFinal[i] = actual->data[j]
			inc rdi ;siguiente char
			inc i
			jmp .cicloFor
		.finFor:
			mov actual, [actual+OFFSET_NEXT] ;actual = actual->next
			jmp .ciclo
	.fin:
		mov byte [stringFinal+i*size_of_char], 0
		mov rax, stringFinal
		pop stringFinal
		pop aRecorrer
		pop actual
		pop sorter
		pop rbp
		ret

%define sorter r11
%define pSlot r12
%define slot r13

sorterCleanSlot: ;rdi = sorter, si = slot, rdx = fd
	push rbp
	mov rbp, rsp
	push sorter
	push pSlot
	push slot
	sub rsp, 8
	mov sorter, rdi
	mov slot, rsi
	shl slot, 48
	shr slot, 48 ; limpiamos parte alta
	mov pSlot, [sorter+OFFSET_SLOT] ;rdi=sorter->slots
	mov rdi, [pSlot+slot*size_of_list] ;rdi=sorter->slots[slot]
	mov rsi, rdx
	call listDelete
	call listNew ;rax = nueva lista
	mov [pSlot+slot*size_of_list], rax ; sorter->slots[slot] = listNew();
	add rsp, 8
	pop slot
	pop pSlot
	pop sorter
	pop rbp
	ret

%define sorter r11
%define pSlots r12
%define fd r13
%define size r14
%define i r15

sorterDelete: ;rdi = sorter, rsi = fd
	push rbp
	mov rbp, rsp
	push sorter
	push pSlots
	push fd
	push size
	push i
	sub rsp, 8
	mov sorter, rdi
	mov fd, rsi
	mov pSlots, [sorter+OFFSET_SLOT] ;pSlots=sorter->slots
	mov size, [sorter+OFFSET_SIZE] ;size=sorter->size
	shl size, 48
	shr size, 48	;limpiamos parte alta
	xor i, i
	.ciclo:
		;recorremos los slots, eliminando 
		;cada lista y sus datos
		cmp i, size
		je .fin
		mov rdi, [pSlots+i*size_of_list] ;rdi=slots[i]
		mov rsi, fd
		call listDelete
		inc i
		jmp .ciclo
	.fin:
		;liberamos los slots
		mov rdi, pSlots
		call free
		;liberamos el sorter
		mov rdi, sorter
		call free
		add rsp, 8
		pop i
		pop size
		pop fd
		pop pSlots
		pop sorter
		pop rbp
		ret



%define slot_size r13w
%define indice_slot r14
%define base_slot r12
%define escala_slot 8
%define pFile r15
%define fp rbx
; void sorterPrint(sorter_t* sorter, FILE *pFile, funcPrint_t* fp)
sorterPrint: ; sorter->rdi, pFile -> rsi, fp->rdx
	push rbp
	mov rbp,rsp
	push r12
	push r13
	push r14
	push r15
	push rbx
	sub rsp, 8
	xor r13, r13
	mov fp, rdx
	mov pFile,rsi
	mov slot_size,[rdi + OFFSET_SIZE]
	xor indice_slot,indice_slot ; arranco indice en 0
	mov base_slot,[rdi + OFFSET_SLOT]	
	
	.ciclo:
	cmp slot_size,0
	jz .fin
	mov rdi, pFile
	mov rsi, format_numberSLot
	mov rdx, indice_slot
	call fprintf  ; print numero de slot
	mov rdi, pFile
	mov rsi, format_string
	mov rdx, format_slot
	call fprintf ; print "="
	lea rax, [base_slot + indice_slot * escala_slot] ; obtengo la lista
	mov rdi, [rax]
	mov rsi, pFile
	mov rdx, fp
	call listPrint ; imprimo la lista
	mov rdi, pFile
	mov rsi, format_string
	mov rdx, format_salto
	call fprintf ; print salto de linea
	inc indice_slot
	dec slot_size
	jmp .ciclo
	
	.fin:
	add rsp,8
	pop rbx
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	ret


;*** aux Functions ***

fs_sizeModFive:
	push rbp
	mov rbp, rsp
	call strLen
	.ciclo:
	cmp eax,5
	jl .fin
	sub eax,5
	jmp .ciclo
	.fin:
	pop rbp
	ret

fs_firstChar: ;rdi = s
	push rbp
	mov rbp, rsp
	mov al, [rdi]
	shl rax, 56
	shr rax, 56 ;limpiamos bits mas significativos
	pop rbp
	ret

%define primerChar di

fs_bitSplit: ;rdi = s
	push rbp
	mov rbp, rsp
	call fs_firstChar ;ax = primerChar
	mov primerChar, ax
	cmp primerChar, 0x00
	je .caracterNulo
	mov ax, 7
	cmp primerChar, 0x01
	je .aLaCero
	cmp primerChar, 0x02
	je .aLaUno
	cmp primerChar, 0x04
	je .aLaDos
	cmp primerChar, 0x08
	je .aLaTres
	cmp primerChar, 0x10
	je .aLaCuatro
	cmp primerChar, 0x20
	je .aLaCinco
	cmp primerChar, 0x40
	je .aLaSeis
	cmp primerChar, 0x80
	je .fin
	mov ax, 9
	jmp .fin
	.caracterNulo:
		mov ax, 8
		jmp .fin
	.aLaCero:
		dec ax
	.aLaUno:
		dec ax
	.aLaDos:
		dec ax
	.aLaTres:
		dec ax
	.aLaCuatro:
		dec ax
	.aLaCinco:
		dec ax
	.aLaSeis:
		dec ax
	.fin:
		pop rbp
		ret

;*** aux Functions Nuestras ***

%define list r11
%define actual r12
%define suma r13d

; uint32_t sumaSizeStrings(list_t* l)

; Devuelve la suma de los largos 
; de todos los strings de la lista

sumaSizeStrings: ;rdi = list
	push rbp
	mov rbp, rsp
	push list
	push actual
	push r13
	sub rsp, 8
	mov list, rdi
	mov actual, [list+OFFSET_FIRST] ;actual=list->first
	xor suma, suma ; suma = 0
	.ciclo:
		cmp actual, NULL
		je .fin
		mov rdi, [actual+OFFSET_DATA] ;rdi = actual->data
		call strLen ; eax = largo string
		add suma, eax ; suma = suma + largoString
		mov actual, [actual + OFFSET_NEXT] ; actual = actual->next
		jmp .ciclo
	.fin:
		mov eax, suma
		add rsp, 8
		pop r13
		pop actual
		pop list
		pop rbp
		ret