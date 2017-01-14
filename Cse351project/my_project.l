digit	[0-9]
letter	[a-zA-Z]
CM \/\/
%{
#include <stdio.h>
#include <string.h>
#include "y.tab.h"
int linenum=1;
%}
%%
"include" return INCLUDE_WORD;
"void" return VOID_WORD;
"if" return IF_WORD;
"return" return RETURN_WORD;
"char" return CHAR_WORD;
"main" return MAIN_WORD;
"int" return INT_WORD;
"else" return ELSE_WORD;
"<stdio.h>" return STD_WORD;
"#" return HASH_WORD;
{letter}({letter}|{digit})* {yylval.string = strdup(yytext);return VARIABLE;}
"(" return OPENPAR;
")" return CLOSEPAR;
"," return COMMA;
"==" return IF_WORD;
"=" return ASSIGNOP; 
";" return SEMICOLON;
"{" return OPENCURBRA;
"}" return CLOSECURBRA;
"<" return BLT;
">" return BGT;
"." return FULL_STOP;
[0-9]+ {yylval.string = strdup(yytext); return INTEGER;}
\-	return MINUSOP;
\+	return PLUSOP;
\*	return MULTOP;
\n	linenum++;
.|\n
%%

