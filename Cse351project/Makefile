all: yacc lex
	cc lex.yy.c y.tab.c -o myproject -lfl

yacc: my_project.y
	yacc -d my_project.y

lex: my_project.l
	lex my_project.l
	
clean:
	rm lex.yy.c y.tab.* myproject

