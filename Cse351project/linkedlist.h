#include <string.h>
#include <stdlib.h>
#include <stdio.h>

typedef struct mystruct{
	char *ident;
	char *tmpident;
    struct mystruct *next;
}mystruct;

mystruct *head;
void adder(char *ident,char *tmpident,mystruct **head){
	mystruct *new_node;
	new_node = (mystruct*)malloc(sizeof(mystruct));
	new_node->ident = ident;
	new_node->tmpident = tmpident;
	new_node->next = NULL;
	if(*head == NULL){
		*head = new_node;
	}
	else{
		mystruct *temp;
		temp = *head;
		while(temp->next != NULL){
			temp = temp->next;
		}
		temp->next = new_node;
	}
}

mystruct*finder(char* ident,mystruct *mys){
	while(mys != NULL && (strcmp(ident,mys->ident))){
		mys=mys->next;
	}
	return mys;
}

void write_to_file(char *word,FILE *outputFile){
	fprintf(outputFile,"%s",word);
}


