#include "lib.h"

/** STRING **/

void hexPrint(char* a, FILE *pFile) {
    int i = 0;
    while (a[i] != 0) {
        fprintf(pFile, "%02hhx", a[i]);
        i++;
    }
    fprintf(pFile, "00");
}

/** Lista **/

void listRemove(list_t* l, void* data, funcCmp_t* fc, funcDelete_t* fd){
	listElem_t* actual = l->first;
	listElem_t* temp;
	while(actual != NULL){
		temp = actual->next;
		if(fc(actual->data, data) == 0){
			if(actual == l->first) {
				listRemoveFirst(l, fd);
			} else if(actual == l->last){
				listRemoveLast(l, fd);
			} else {
				actual->prev->next = actual->next;
				actual->next->prev = actual->prev;
				if(fd != NULL){
					fd(actual->data);
				}
				free(actual);
			}
		}
		actual = temp;
	}
}

void listRemoveFirst(list_t* l, funcDelete_t* fd){
	if(l->first != NULL){
		listElem_t* aEliminar = l->first;
		if(l->first == l->last){
			l->first = NULL;
			l->last = NULL;
		} else {
			aEliminar->next->prev = NULL;
			l->first = aEliminar->next;
		}
		if(fd != NULL){
			fd(aEliminar->data);
		}
		free(aEliminar);
	}
}

void listRemoveLast(list_t* l, funcDelete_t* fd){
	if(l->last != NULL){
		listElem_t* aEliminar = l->last;
		if(l->first == l->last){
			l->first = NULL;
			l->last = NULL;
		} else {
			aEliminar->prev->next = NULL;
			l->last = aEliminar->prev;
		}
		if(fd != NULL){
			fd(aEliminar->data);
		}
		free(aEliminar);
	}
}
