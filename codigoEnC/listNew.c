list_t* listNew(){
	list_t* nueva = (list_t *) malloc(sizeof(list_t));
	nueva->first = NULL;
	nueva->last = NULL;
	return nueva;
}