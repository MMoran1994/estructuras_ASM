void listAddFirst(list_t *l, void *data){
	listElem_t *nuevo = (listElem_t *) malloc(sizeof(listElem_t));
	nuevo->data = data;
	nuevo->prev = NULL;
	nuevo->next = l->first;
	if(l->first == NULL){
		l->last = nuevo;
	}
	l->first = nuevo;
}