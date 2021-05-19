char* sorterGetConcatSlot(sorter_t* sorter, uint16_t slot){
	list_t* aRecorrer = sorter->slots[slot];
	uint32_t largoStringConcat = sumaSizeStrings(aRecorrer);
	char* stringFinal = malloc(largoStringConcat*sizeof(char) + 1);
	listElem_t* actual = aRecorrer->first;
	uint32_t i = 0;
	while(actual != NULL){
		for (uint32_t j = 0; j < strLen(actual->data); ++j)
		{ //en Assembler chequeo el caracter nulo
			stringFinal[i] = actual->data[j];
			i++;
		}
		actual = actual->next;
	}
	stringFinal[i] = 0;
	return stringFinal;
}