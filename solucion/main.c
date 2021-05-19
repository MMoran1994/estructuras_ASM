#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>
#include <math.h>

#include "lib.h"

void test_lista(FILE *pfile){
    
}

void test_sorter(FILE *pfile){
    
}

int main (void){
    FILE *pfile = fopen("salida.caso.propios.txt","w");
   	//1-Caso list
    fprintf(pfile,"===== 1-Caso list\n");
    list_t* l=listNew();
    for (int i = 0; i < 10; ++i)
    {   
        char* strings[10] = {"aa","bb","dd","ff","00","zz","cc","ee","gg","hh"};
        listAddFirst(l,strClone(strings[i]));
    }
    listPrint(l,pfile,(funcPrint_t*)&strPrint);
    listDelete(l,(funcDelete_t*)&strDelete);
    fprintf(pfile,"\n");
    //2-Caso sorter
    fprintf(pfile,"===== 2-Caso sorter\n");
    sorter_t* s = sorterNew(5, (funcSorter_t*)&fs_sizeModFive , (funcCmp_t*)&strCmp);
     for (int i = 0; i < 10; ++i)
    {   
        char* strings[10] = {"a","bb","ddd","ffff","00000","zzzzzz","ccccccc","eeeeeeee","ggggggggg","hhhhhhhhhh"};
        sorterAdd(s,strClone(strings[i]));
    }
    sorterPrint(s, pfile, (funcPrint_t*)&strPrint);
    sorterDelete(s, (funcDelete_t*)&strDelete);
    fclose(pfile);
    return 0;
}


