%{
#include <stdio.h>
extern FILE* yyin;
extern char* yytext;
extern int yylineno;
%}
%token ID TIP MAIN_BEGIN MAIN_END GLOBAL_BEGIN GLOBAL_END ASSIGN NR IF WHILE FOR LEQ GEQ NEQ EQ AND OR PRINT

%start progr

%left '+' '-'
%left '*' '/'
%right ASSIGN
%%
progr: global_section declaratii bloc {printf("program corect sintactic\n");}
     ;

global_section: GLOBAL_BEGIN global_var GLOBAL_END
global_var : global_var_types 
               | global_var global_var_types
               ;

global_var_types : TIP ID ';'
               | TIP ID ASSIGN NR ';'
               ;

declaratii :  declaratie ';'
	   | declaratii declaratie ';'
	   ;
declaratie : TIP ID 
           | TIP ID '(' lista_param ')'
           | TIP ID '(' ')'
           ;
lista_param : param
            | lista_param ','  param 
            ;
            
param : TIP ID
      ; 
      
/* bloc */
bloc : MAIN_BEGIN list MAIN_END 
     ;
     
/* lista instructiuni */
list :  statement ';' 
     | list statement ';'
     ;

/* instructiune */
statement: ID ASSIGN ID
         | ID ASSIGN exp  		 
         | ID '(' lista_apel ')'
         | PRINT '(' exp ')'
         ;

exp : NR
     | ID
     | exp '+' exp {$$ = $1 + $3; printf("adunare: %d\n", $1 + $3);}
     | exp '-' exp {$$ = $1 - $3; printf("scadere: %d\n", $$);}
     | exp '*' exp {$$ = $1 * $3; printf("inmultire: %d\n", $$);}
     | exp '/' exp {$$ = $1 / $3; printf("impartire: %d\n", $$);}
     | exp '+' '+' {$$ = $1 + 1; printf("++: %d\n", $$);}
     ;
        
lista_apel : NR
           | lista_apel ',' NR
           ;
%%

int yyerror(char * s){
printf("eroare: %s la linia:%d\n",s,yylineno);
}

int main(int argc, char** argv){
yyin=fopen(argv[1],"r");
yyparse();
} 