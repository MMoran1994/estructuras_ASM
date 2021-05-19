void listAdd(list_t *l, void *data, funcCmp fc){
	listElem_t *actual = l->first;
	if(actual == NULL || fc(data, actual->data)){
		listAddFirst(l, data);
	} else {
		while(actual != NULL){
			if(fc(data, actual->data)){
				listElem_t *nuevo = (listElem_t *) malloc(sizeof(listElem_t));
				nuevo->data = data;
				nuevo->prev = actual->prev;
				nuevo->next = actual;
				actual->prev->next = nuevo;
				actual->prev = nuevo;
				return;
			}
			actual = actual->next;
		}
		listAddLast(l, data);
	}
}