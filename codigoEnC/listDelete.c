void listDelete(list_t* l, funcDelete_t* fd){
	listElem_t* actual = l->first;
	while(actual != NULL){
		listRemoveFirst(l, fd);
		actual = l->first;
	}
	free(l);
}