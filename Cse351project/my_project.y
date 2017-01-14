%{
	#include <stdio.h>
	#include <string.h>
	#include <stdlib.h>
	#include "linkedlist.h"
	void yyerror(char *);
	int yylex(void);
	extern FILE *yyin;
	extern int linenum;
	FILE *outputFile;
	int my_addr=1000;
	int my_temp_addr=3000;
	char my_temp_buffer[100];
	char my_write_buffer[100];
	char my_branch_label_name='A';
	void write_to_file(char*,FILE*);
%}
%union
{
	char *string;
}
%token <string> INTEGER
%token <string> VARIABLE
%type <string> expression
%token INCLUDE_WORD VOID_WORD STD_WORD IF_WORD RETURN_WORD CHAR_WORD MAIN_WORD INT_WORD ELSE_WORD HASH_WORD OPENPAR CLOSEPAR COMMA ASSIGNOP SEMICOLON OPENCURBRA CLOSECURBRA MINUSOP PLUSOP MULTOP EQUAL_WORD BLT BGT FULL_STOP
%left PLUSOP MINUSOP
%left MULTOP 
%%

program:
	function operations main // kütüphane ve main arasına gelen değişkenler	
	|
	function main // kütüphane ve main arasında bişey yoksa
	;
function:
	HASH_WORD INCLUDE_WORD STD_WORD // kütüphane ekleme
	;

main:
	VOID_WORD MAIN_WORD OPENPAR CLOSEPAR OPENCURBRA operations CLOSECURBRA// void main()
	|
	INT_WORD MAIN_WORD OPENPAR CLOSEPAR OPENCURBRA operations CLOSECURBRA //int main()
	;

operations:	               
	statement // tek statement
	|
	statement operations // birden fazla statement  
        ;
statement:
	define_expression SEMICOLON
	|
	condition // if ve else durumları
	|
	var_assign // değiken atam
	|
	return
	;
define_expression:
	VARIABLE ASSIGNOP expression // var = var or var = smthng
	{
		mystruct *node;
		node=finder($1,head);
		if(node==NULL){
			sprintf(my_temp_buffer, "%d", my_addr);
			my_addr++;
			adder($1,strdup(my_temp_buffer),&head);
			mystruct *temp;
			temp=finder($1,head);
			sprintf(my_write_buffer,"\tLDAA #$%s\n\tSTAA $%s\n",$3, temp->tmpident);
			write_to_file(my_write_buffer,outputFile);
		}
		else{	
			int convert = atoi($3);
			if(convert >= 1000){
				sprintf(my_write_buffer,"\tLDAA $%s\n\tSTAA $%s\n",$3, node->tmpident);
				write_to_file(my_write_buffer,outputFile);
			}
			else
			{
				sprintf(my_write_buffer,"\tLDAA #%s\n\tSTAA $%s\n",$3, node->tmpident);
				write_to_file(my_write_buffer,outputFile);
			}				
			
		}
	}		
	|
	VARIABLE ASSIGNOP INTEGER{// var = 12
		mystruct *node;
		node=finder($1,head);
		if(node==NULL){
			sprintf(my_temp_buffer, "%d", my_addr);
			my_addr++;
			adder($1,strdup(my_temp_buffer),&head);
			mystruct *temp;			
			temp=finder($1,head);
			int convert = atoi($3);
			if(convert >= 1000){
				sprintf(my_write_buffer,"\tLDAA $%s\n\tSTAA $%s\n",$3, temp->tmpident);
				write_to_file(my_write_buffer,outputFile);
			}
			else {
				sprintf(my_write_buffer,"\tLDAA #%s\n\tSTAA $%s\n",$3, temp->tmpident);
				write_to_file(my_write_buffer,outputFile);
			}	
			
		}
		else{
			int convert2 = atoi($3);
			if(convert2 >= 1000){
				sprintf(my_write_buffer,"\tLDAA $%s\n\tSTAA $%s\n",$3, node->tmpident);
				write_to_file(my_write_buffer,outputFile);
			}
			else {
				sprintf(my_write_buffer,"\tLDAA #%s\n\tSTAA $%s\n",$3, node->tmpident);
				write_to_file(my_write_buffer,outputFile);
			}
		}
	}
	; 
expression:	
	
	VARIABLE{ 
		mystruct *node;
		node=finder($1,head);
		if(node==NULL){
			printf("variable hatası\n");
			exit(0);
		}
		else{
			$$=node->tmpident;			
		}
	}
	|
	INTEGER{
		$$=$1;
	}
	| 
	expression PLUSOP expression{
		sprintf(my_temp_buffer,"%d",my_temp_addr);
		my_temp_addr++;
		int convert = atoi($1);
		if(convert >= 1000){
			sprintf(my_write_buffer,"\tLDAA $%s\n",$1);
			write_to_file(my_write_buffer,outputFile);		
		}
		else{
			sprintf(my_write_buffer,"\tLDAA #%s\n",$1);
			write_to_file(my_write_buffer,outputFile);	
		}
		int convert2 = atoi($3);
		if(convert2 >= 1000){
			sprintf(my_write_buffer,"\tADDA $%s\n\tSTAA $%s\n",$3,my_temp_buffer);
			write_to_file(my_write_buffer,outputFile);	
		}
		else{
			sprintf(my_write_buffer,"\tADDA #%s\n\tSTAA $%s\n",$3,my_temp_buffer);
			write_to_file(my_write_buffer,outputFile);	
		}
		$$=strdup(my_temp_buffer);
	}	
	|
	expression MINUSOP expression{
		sprintf(my_temp_buffer,"%d",my_temp_addr);
		my_temp_addr++;
		int convert = atoi($1);
		if(convert >= 1000){
			sprintf(my_write_buffer,"\tLDAA $%s\n",$1);
			write_to_file(my_write_buffer,outputFile);		
		}
		else{
			sprintf(my_write_buffer,"\tLDAA #%s\n",$1);
			write_to_file(my_write_buffer,outputFile);	
		}
		int convert2 = atoi($3);
		if(convert2 >= 1000){
			sprintf(my_write_buffer,"\tSUBA $%s\n\tSTAA $%s\n",$3,my_temp_buffer);
			write_to_file(my_write_buffer,outputFile);	
		}
		else{
			sprintf(my_write_buffer,"\tSUBA #%s\n\tSTAA $%s\n",$3,my_temp_buffer);
			write_to_file(my_write_buffer,outputFile);	
		}
		$$=strdup(my_temp_buffer);
	}	
	|
	expression MULTOP expression{
		sprintf(my_temp_buffer,"%d",my_temp_addr);
		my_temp_addr++;
		int convert = atoi($1);
		if(convert >= 1000){
			sprintf(my_write_buffer,"\tLDAA $%s\n",$1);
			write_to_file(my_write_buffer,outputFile);		
		}
		else{
			sprintf(my_write_buffer,"\tLDAA #%s\n",$1);
			write_to_file(my_write_buffer,outputFile);	
		}
		int convert2 = atoi($3);
		if(convert2 >= 1000){
			sprintf(my_write_buffer,"\tLDAB $%s\n\tMUL\n\tSTAA $%s\n",$3,my_temp_buffer);
			write_to_file(my_write_buffer,outputFile);	
		}
		else{
			sprintf(my_write_buffer,"\tLDAB #%s\n\tMUL\n\tSTAA $%s\n",$3,my_temp_buffer);
			write_to_file(my_write_buffer,outputFile);	
		}
		$$=strdup(my_temp_buffer);
		
	}
	|
	expression ASSIGNOP expression
	{
		mystruct *node;
		node=finder($1,head);
		if(node==NULL){
			sprintf(my_temp_buffer, "%d", my_addr);
			my_addr++;
			adder($1,strdup(my_temp_buffer),&head);
			mystruct *temp;
			temp=finder($1,head);
			int convert = atoi($1);
			if(convert >= 1000){
				sprintf(my_write_buffer,"\tLDAA $%s\n\tSTAA $%s\n",$3, temp->tmpident);
				write_to_file(my_write_buffer,outputFile);
			}
			else{
				sprintf(my_write_buffer,"\tLDAA #%s\n\tSTAA $%s\n",$3, temp->tmpident);
				write_to_file(my_write_buffer,outputFile);
			}
		}
		else{
			int convert2 = atoi($3);
			if(convert2 >= 1000){
				sprintf(my_write_buffer,"\tLDAA $%s\n\tSTAA $%s\n",$3, node->tmpident);
				write_to_file(my_write_buffer,outputFile);
			}
			else{
				sprintf(my_write_buffer,"\tLDAA #%s\n\tSTAA $%s\n",$3, node->tmpident);
				write_to_file(my_write_buffer,outputFile);
			}
		}
	}
	|
	expression BGT expression{
		int convert = atoi($1);
		if(convert >= 1000){
			sprintf(my_write_buffer,"\tLDAA $%s\n",$1);
			write_to_file(my_write_buffer,outputFile);
		}
		else{
			sprintf(my_write_buffer,"\tLDAA #%s\n",$1);
			write_to_file(my_write_buffer,outputFile);
		}
		int convert2 = atoi($3);
		if(convert2 >= 1000){
			sprintf(my_write_buffer,"\tCMPA $%s\n",$3);
			write_to_file(my_write_buffer,outputFile);
		}
		else{
			sprintf(my_write_buffer,"\tCMPA #%s\n",$3);
			write_to_file(my_write_buffer,outputFile);
		}
		sprintf(my_write_buffer,"\tBGT %c\n", my_branch_label_name);
		write_to_file(my_write_buffer,outputFile);
		sprintf(my_write_buffer,"%c:", my_branch_label_name);
		write_to_file(my_write_buffer,outputFile);
		my_branch_label_name++;
	}
	|
	expression BLT expression{
		int convert = atoi($1);
		if(convert >= 1000)
		{
			sprintf(my_write_buffer,"\tLDAA $%s\n",$1);
			write_to_file(my_write_buffer,outputFile);
		}
		else
		{
			sprintf(my_write_buffer,"\tLDAA #%s\n",$1);
			write_to_file(my_write_buffer,outputFile);
		}

		int convert2 = atoi($3);
		if(convert2 >= 1000){
			sprintf(my_write_buffer,"\tCMPA $%s\n",$3);
			write_to_file(my_write_buffer,outputFile);
		}
		else{
			sprintf(my_write_buffer,"\tCMPA #%s\n",$3);
			write_to_file(my_write_buffer,outputFile);
		}
		sprintf(my_write_buffer,"\tBGT %c\n", my_branch_label_name);
		write_to_file(my_write_buffer,outputFile);
		sprintf(my_write_buffer,"%c:", my_branch_label_name);
		write_to_file(my_write_buffer,outputFile);
		my_branch_label_name++;
	}		
	|
	OPENPAR expression CLOSEPAR{
		$$ = strdup($2);
	}	
	;
condition:
	if 
	|
	else	
	;

if:
	IF_WORD OPENPAR expression CLOSEPAR operations // if (x > y) x=y gibi // 
	|
	IF_WORD OPENPAR expression CLOSEPAR OPENCURBRA operations CLOSECURBRA operations// if (x > y){x=y; x+5;} 
	;

else:
	
	ELSE_WORD operations // tek else tek satır durumu
	|
	ELSE_WORD IF_WORD OPENPAR expression CLOSEPAR operations // else if (x < y) x+y;
	|
	ELSE_WORD IF_WORD OPENPAR expression CLOSEPAR OPENCURBRA operations CLOSECURBRA operations // else if(x < y){x++; y+5}
	|
	ELSE_WORD OPENCURBRA operations CLOSECURBRA operations // else{x++;y++}
	;

var_assign:
	integer_var_assign // integer tanımlama bloğu
	
	;

integer_var_assign:
	INT_WORD int_lister SEMICOLON // tek ya da birden çok integer tanımlama: int a=1 veya int a=1, b=2 gibi
	;


int_lister:
	atama_int // inti atama
	|
	int_lister COMMA atama_int // coklu int atama
	
	;


atama_int:
	
	VARIABLE // int a;
	{
		sprintf(my_temp_buffer,"%d",my_addr);
		
		my_addr++;
		sprintf(my_write_buffer,"\tLDAA #%s\n\tSTAA $%s\n","0",my_temp_buffer);
		write_to_file(my_write_buffer,outputFile);
		adder($1,strdup(my_temp_buffer),&head);
	}
	|
	VARIABLE ASSIGNOP INTEGER // var1 =5 ;
	{
		sprintf(my_temp_buffer,"%d",my_addr);
		
		my_addr++;
		sprintf(my_write_buffer,"\tLDAA #%s\n\tSTAA $%s\n",$3,my_temp_buffer);
		write_to_file(my_write_buffer,outputFile);
		adder($1,strdup(my_temp_buffer),&head);
	}	
	;
return:
	RETURN_WORD INTEGER SEMICOLON{// return 0;
	
		sprintf(my_write_buffer,"\t.end");
		write_to_file(my_write_buffer,outputFile);
	}
	;
%%

void yyerror(char *s)
{
	fprintf(stderr, "%s\n ++++ %d\n", s,linenum);
}

int yywrap()
{
	return 1;
}


int main(int argc, char *argv[])
{
/* Call the lexer, then quit. */
	
	outputFile = fopen("output.asm", "w");
	yyin=fopen(argv[1],"r");

	yyparse();
	//fclose(yyin);
	fclose(outputFile);

	//printList(head);

	return 0;
}


     
