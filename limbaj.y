%{
#include <stdio.h>
#include "stdbool.h"
#include <string.h>
#include <stdlib.h>
#include "limbaj.h"

extern FILE* yyin;
extern char* yytext;
extern int yylineno;

struct parametrii { // structura ce retine parametrii unei functii
          char type[50];
          char name[50];
     };

     struct lv { // structura ce retine informatii despre un left value
          char name[50];
          char type[50];
          char value[50];
          char scope[50];
     };

     enum node_types {operator, numar, identifcator, array}; // enumeratie ce retine tipurile de noduri din arborele AST: operator, numar, id, array, other

     struct noduri// structura ce retine informatii despre un nod din arborele AST
     {
          enum node_types type;
          char value[50];
          struct node* left;
          struct node* right;
     };

int nrVariabileOld = 0;
int nrParametriiOld = 0;

extern FILE* variabilaTabel;
extern FILE* functieTabel;
%}
%union{
     int intval;
     char* strval;
     struct lv* lvalue;
     struct parametrii* p;
     struct parametrii* lista_parametrii[10];
     struct parametrii* function_decl;
     struct noduri* node_pointer;

}

%token MAIN_BEGIN MAIN_END GLOBAL_BEGIN GLOBAL_END 
     ASSIGN IF ELSE WHILE FOR FUNC_BEGIN FUNC_END PRINT LOGIC
     STRUCT_BEGIN STRUCT_END STRUCT

%token <strval>ID
%token <strval>TIP
%token <strval>ARRAY
%token <strval>INTEGER
%token <strval>FLOAT
%token <strval>BOOL
%token <strval>STRING
%token <strval>INC
%token <strval>DEC
%token <strval>MATH1
%token <strval>MATH2
%start progr

%type <strval> statement
%type <strval> declaratie
%type <strval> lista_apel
%type <strval> inc_dec_op
%type <p> param
%type <lista_parametrii> lista_param
%type <function_decl> functie_decl
%type <lvalue> rvalue
%type <lvalue> lvalue
%type <lvalue> alfa_numeric
// %type <noduri> math_statement
// %type <noduri> math_val


%left '+' '-'
%left '*' '/'
%%
progr: global_section func_section bloc {printf("program corect sintactic\n");}
     ;

global_section: GLOBAL_BEGIN  global_var GLOBAL_END
               ;
global_var : global_var_types 
          | global_var global_var_types
          ;
global_var_types : TIP ID ';' {addVar($2, $1, "NULL", "global", 0, 0);}
               | TIP ID ASSIGN rvalue ';' {
                    
                    addVar($2, $1, $4->value, "global", 0, 0);}
               | TIP ID ASSIGN math_statement ';'
               | TIP ARRAY ';' {
                    char* numeArray = strtok($2, "[]"); 
                    char* indexArray = strtok(NULL, "[]");
                    int index = atoi(indexArray);

                    addVar(numeArray, $1, NULL, "global", 1, index);     

               }
               ;


func_section : FUNC_BEGIN functii FUNC_END
               ;
functii : {} functii_type 
          | functii {} functii_type
          | struct_declarations
          | functii struct_declarations
          ;
functii_type : TIP ID functie_decl 
               {

                    addFunc($2, $1, 0, 0, "functie");
                    // parametrii = 0;
               }
          ;
functie_decl : '(' ')' '{' list '}' { $$ = NULL;}
               | '(' lista_param ')' '{' list '}' 
               { 
                    // $$ = $2;
               }
          ;
lista_param : param
               // {
               //      strcpy($$[parametrii].type, $1.type);
               //      strcpy($$[parametrii].name, $1.name);
               //      parametrii++;

               // }
            | lista_param ','  param 
               // {
               //      strcpy($$[parametrii].type, $1.type);
               //      strcpy($$[parametrii].name, $1.name);
               //      parametrii++;
               // }
            ;
            
param : TIP ID 
          // {
          //      strcpy($$.type, $1);
          //      strcpy($$.name, $2);
          // }
     | TIP ARRAY
          // {
          //      strcpy($$.type, $1);
          //      strcpy($$.name, $2);
          // }
      ; 

// struct_section: STRUCT_BEGIN struct STRUCT_END
//                ;
// struct : struct_declarations
//      | struct struct_declarations
     // ;
struct_declarations : STRUCT ID '{' body_structure '}' ID ';' 
                    {
                         addFunc($2, "struct", 0, 0, "struct");
                    }
                    | STRUCT ID '{' body_structure '}' ';'
                    {
                         addFunc($2, "struct", 0, 0, "struct");
                    }
                    ;
body_structure: body_structure_types
               | body_structure body_structure_types
               ;
body_structure_types : TIP ID ';'
                    | TIP ID ASSIGN rvalue ';'
                    | TIP ID ASSIGN math_statement ';'
                    | TIP ARRAY ';'
                    ;
/* bloc */
bloc : MAIN_BEGIN  list MAIN_END 
     ;
     
/* lista instructiuni */
list :  statement ';' 
     | list statement ';'
     | declaratie ';'
     | list declaratie ';'
     | control ';'
     | list control ';'
     | deal_struct ';'
     | list deal_struct ';'
     ;

/* instructiune */
statement : lvalue ASSIGN rvalue 
     {
          // if(strcmp($1->type, $3->type) == 0){
          //      if($3->value != NULL){
          //           updateVar($1->name, $3->value, "main");
          //      }
          // }else{
          //      saveTable();
          //      printf("Id %s type %s does not match %s type %s! (line %d)\n", $1->name, $1->type, $3->name, $3->type, yylineno);
          //      exit(1);
          // }
   
     }
         | lvalue ASSIGN math_statement
         | ID '(' lista_apel ')'
         | ID '(' ')'
         {
               // if (!searchFunc($1, NULL, 0)){
               //      saveTable();
               //      printf("Function %s does not exist or the number of parametrs are wrong! (line %d)\n", $1, yylineno);
               //      exit(1);
               // }
         }
         | print_functie
         | lvalue inc_dec_op
         {
          printf("type %s\n", $1->type);
          // if (strcmp($1->type, "int") == 0) {
          //           int result=atoi($1->value);
          //           printf("result %d\n", result);
          //           if(strcmp($2,"--")==0){
          //                sprintf($1->value,"%d",--result);
          //           }
          //           else{
          //                sprintf($1->value,"%d",++result);
          //           }   

          //           updateVar($1->name, $1->value, $1->scope);

          //           }

          // else
          // {
          //      printf("Cannot increment/decrement a non integer type value. (line %d)\n", yylineno);
          // }
          }
         
         ;

declaratie : TIP ID 
          {
               addVar($2, $1, "NULL", "main", 0,0);
          }
          | TIP ID ASSIGN rvalue
          {
               if (strcmp($1, $4->type) != 0) {
                    saveTable();
                    printf("Id %s type does not match %s type! (line %d)\n", $2, $4->name, yylineno);
                    exit(1);
               }
               addVar($2, $1, $4->value, "main", 0,0);
          }
          | TIP ID ASSIGN math_statement
          | TIP ARRAY
          {
               char* numeArray = strtok($2, "[]"); 
               char* indexArray = strtok(NULL, "[]");
               int index = atoi(indexArray);

               addVar(numeArray, $1, NULL, "global", 1, index);
          }
          ;

lvalue : ID
     | ARRAY
     ;

rvalue : lvalue {$$ = $1;}
     | alfa_numeric { $$=$1; }
     | ID '(' ')'
     | ID '(' lista_apel ')'
     ;

        
lista_apel : rvalue
          | lista_apel ',' rvalue
          | math_statement
          | lista_apel ',' math_statement
           ;

print_functie : PRINT '(' STRING ',' rvalue ')'
             | PRINT '(' STRING  ',' math_statement')'
             ;

inc_dec_op : INC
          | DEC
          ;

math_statement : math_statement MATH1 math_val
              | math_statement MATH2 math_val
              | math_val MATH1 math_statement
              | math_val MATH2 math_statement
              | math_val MATH1 math_val
              | math_val MATH2 math_val
              | math_statement MATH1 math_statement
              | math_statement MATH2 math_statement
              | lvalue inc_dec_op
              | '(' math_statement ')'
              ;

alfa_numeric : INTEGER 
            {   
               struct lv* temp = malloc(sizeof(struct lv));
               strcpy(temp->name, $1);
               strcpy(temp->type, "int");
               strcpy(temp->value, $1);
               $$ = temp;
            }
            | FLOAT
            {
               struct lv* temp = malloc(sizeof(struct lv));
               strcpy(temp->name, $1);
               strcpy(temp->type, "float");
               strcpy(temp->value, $1);
               $$ = temp;
            }
            | STRING
            {
               struct lv* temp = malloc(sizeof(struct lv));
               strcpy(temp->name, $1);
               strcpy(temp->type, "string");
               strcpy(temp->value, $1);
               $$ = temp;
            }
            | BOOL
            {
               struct lv* temp = malloc(sizeof(struct lv));
               strcpy(temp->name, $1);
               strcpy(temp->type, "bool");
               strcpy(temp->value, $1);
               $$ = temp;
            }
            ;

math_val : lvalue
          | INTEGER
          | FLOAT
          | ID '(' ')'
          | ID '(' lista_apel ')'
          ;

control : IF '(' conditii ')' '{' list '}'
       | IF '(' conditii ')' '{' list '}'  ELSE  '{'list '}'
       | WHILE '(' conditii ')' '{' list '}'
       | FOR '(' for_assign ';' conditii ';' for_stop ')' '{' list '}'
       ;

conditii : rvalue LOGIC rvalue
          | '(' conditii ')' LOGIC '(' conditii ')'
          | '(' conditii ')' LOGIC rvalue
          | rvalue LOGIC '(' conditii ')'
          | '(' math_statement ')' LOGIC rvalue
          | rvalue LOGIC '(' math_statement ')'
          ;

for_assign : TIP ID ASSIGN rvalue
          | TIP ARRAY ASSIGN rvalue
          | lvalue ASSIGN rvalue
          ;
for_stop : lvalue inc_dec_op
          | lvalue ASSIGN math_statement
          ;

deal_struct : ID '.' ID ASSIGN rvalue
           | ID '.' ID ASSIGN math_statement
           | ID '.' ID inc_dec_op
           ;
%%

int yyerror(char * s){
     printf("eroare: %s la linia:%d\n",s,yylineno);
}

int main(int argc, char** argv){
     variabilaTabel = fopen("symbol_table.txt", "w");
     fprintf(variabilaTabel, "Nume \t Tip \t Valoare \t Scope \t Array? \t DimensiuneArray \n");
     functieTabel = fopen("symbol_table_functions.txt", "w");
     fprintf(functieTabel, "Nume \t Return \t Tip \t ListaParametrii \n");
     yyin=fopen(argv[1],"r");
     yyparse();
     saveTable();
     fclose(variabilaTabel);
     fclose(functieTabel);
} 