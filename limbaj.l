%{
#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"
#include <string.h>

%}
TIP "int"|"float"|"char"|"string"|"bool"
IF "if"
ELSE "else"
FOR "for"
WHILE "while"
PRINT "print"
ID [a-zA-Z][a-zA-Z0-9]*
INTEGER 0|[-]?[1-9][0-9]*
FLOAT [-]?([0][.][0-9][1-9]*)|[-]?([1-9][0-9]*[.][0-9]*)
ARRAY {ID}([\[]{INTEGER}[\]])+
STRING (["].*["])
BOOL "true"|"false"
SPACE (" ")+
LOGIC "&&"|"||"|"<="|">="|"=="|"!="|"<"|">"
MATH1 "+"|"-"
MATH2 "*"|"/"
%option noyywrap
%%
"return" {return RETURN;}
"const" {return CONST;}
{IF} {return IF;}
{ELSE} {return ELSE;}
{FOR} {return FOR;}
{WHILE} {return WHILE;}
{TIP} {yylval.strval = strdup(yytext); return TIP;}
{PRINT} {return PRINT;}

"global_begin" {return GLOBAL_BEGIN;}
"global_end" {return GLOBAL_END;}
"func_begin" {return FUNC_BEGIN;}
"func_end" {return FUNC_END;}
"stuct_begin" {return STRUCT_BEGIN;}
"struct" {return STRUCT;}
"stuct_end" {return STRUCT_END;}
"main_begin" {return MAIN_BEGIN;}
"main_end" {return MAIN_END;}
"typeOf" {return TYPEOF;}

{BOOL} {yylval.strval = strdup(yytext); return BOOL;}

{ID}([.]{ID})* {yylval.strval = strdup(yytext); return ID;}

{ARRAY} {yylval.strval = strdup(yytext); return ARRAY;}

"=" {return ASSIGN;}
{INTEGER} {yylval.strval = strdup(yytext); return INTEGER;}
{FLOAT} {yylval.strval = strdup(yytext); return FLOAT;}
{STRING} {yylval.strval = strdup(yytext); return STRING;}

{MATH1} {yylval.strval = strdup(yytext);return MATH1;}
{MATH2} {yylval.strval = strdup(yytext);return MATH2;}
{LOGIC} {yylval.strval = strdup(yytext);return LOGIC;}
"++" {yylval.strval = strdup(yytext); return INC;}
"--" {yylval.strval = strdup(yytext);return DEC;}

[ \t] ;
\n {yylineno++;}
. {return yytext[0];}

 
