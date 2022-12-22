%{
#include <stdio.h>
#include "y.tab.h"
%}
%option noyywrap
%%
"int"|"float"|"char"|"string" {return TIP;}

"main_begin" {return MAIN_BEGIN;}
"main_end" {return MAIN_END;}
"global_begin" {return GLOBAL_BEGIN;}
"global_end" {return GLOBAL_END;}

"if" {return IF;}
"while" {return WHILE;}
"for" {return FOR;}
"<=" {return LEQ;}
"==" {return EQ;}
"!=" {return NEQ;}
"||" {return OR;}
"&&" {return AND;}

[_a-zA-Z][_a-zA-Z0-9]* {return ID;}
"=" {return ASSIGN;}
[0-9]+ {yylval=atoi(yytext); return NR;}
[ \t] ;
\n {yylineno++;}
. {return yytext[0];}

 
