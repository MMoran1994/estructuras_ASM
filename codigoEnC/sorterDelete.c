void sorterDelete(sorter_t* sorter, funcDelete_t* fd){
	list_t** slots = sorter->slots;
	uint16_t size = sorter->size;
	for (uint16_t i = 0; i < size; i++)
	{
		listDelete(slots[i], fd);
	}
	free(slots);
	free(sorter);
}