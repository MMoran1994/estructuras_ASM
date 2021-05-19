void sorterCleanSlot(sorter_t* sorter, uint16_t slot, funcDelete_t* fd){
	fd(sorter->slots[slot]);
	sorter->slots[slot] = listNew();
}