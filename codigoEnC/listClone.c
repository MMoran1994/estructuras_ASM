list_t* listClone(list_t* l, funcDup_t* fn){
	listElem_t* aCopiar = l->first;
	list_t* nuevaLista = listNew();
	while(aCopiar != NULL){
		void* dataCopy = fn(aCopiar->data);
		listAddLast(nuevaLista, dataCopy);
	}
	return nuevaLista;
}