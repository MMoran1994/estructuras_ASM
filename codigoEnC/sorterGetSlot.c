list_t* sorterGetSlot(sorter_t* sorter, uint16_t slot, funcDup_t* fn){
	list_t* copia = fn(sorter->slots[slot]);
	return copia;
}