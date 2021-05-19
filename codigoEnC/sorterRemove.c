void sorterRemove(sorter_t* sorter, void* data, funcDelete* fd){
	int32_t slot = sorter->sorterFunction(data);
	listRemove(sorter->slots[slot]);
}