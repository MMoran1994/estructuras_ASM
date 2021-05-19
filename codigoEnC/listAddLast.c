void listAddFirst(list_t *l, void *data){
	listElem_t *nuevo = (listElem_t *) malloc(sizeof(listElem_t));
	nuevo->data = data;
	nuevo->prev = l->first;
	nuevo->next = NULL;
	if(l->last == NULL){
		l->first = nuevo;
	}
	l->last = nuevo;
}