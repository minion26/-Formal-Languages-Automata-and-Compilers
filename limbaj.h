#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdbool.h>

extern int yylineno;

struct lv { // structura ce retine informatii despre un left value
          char name[50];
          char type[50];
          char value[50];
          char scope[50];
};

struct Variabila{
    char numeVar[100];
    char tipVar[50];
    char valoareVar[50];
    char scopeVar[50];
    int isArray;
    int arraySize;
}var[100];

struct parametru{
    char numeParametru[100];
    char tipParametru[50];
};

struct Functie{
    char numeFunctie[100];
    char tipFunctie[50];
    int nrParametrii;
    struct parametru lista_parametrii[10];
    char funcOrStruct[50];
}func[100];

struct lrValue{
    char nume[100];
    char tip[50];
    char valoare[50];
    char scope[50];
};

int variabilaCount = 0;
int functieCount = 0;

FILE* variabilaTabel;
FILE* functieTabel;

void saveTable(){
    //salvez in tabelul de variabile
    for (int i = 0; i < variabilaCount; i++){
        fprintf(variabilaTabel, "%s \t\t %s \t\t %s \t\t %s \t\t %d \t\t %d\n", var[i].numeVar, var[i].tipVar, var[i].valoareVar, var[i].scopeVar, var[i].isArray , var[i].arraySize);
    }

    //salvez in tabelul de functii
    for (int i = 0; i < functieCount; i++){
        fprintf(functieTabel, "%s \t \t %s \t\t %s \t\t", func[i].numeFunctie, func[i].tipFunctie, func[i].funcOrStruct);
        for (int j = 0; j < func[i].nrParametrii; j++){
            fprintf(functieTabel, "%s  ", func[i].lista_parametrii[j].numeParametru);
        }
        fprintf(functieTabel, "\n");
    }

}

int searchVar(char* nume, char* scope){
    int i = 0; //cautam numele id-ului
    while (i < variabilaCount)
    {    
        while ((strcmp(var[i].numeVar, nume) != 0) && (i < variabilaCount)) i++;

        if (i == variabilaCount) return 0; //nu l-am gasit = not declared
        //l-am gasit, verificam daca si scope-ul e identic, atunci id-ul e declarat deja
        else if (strcmp(var[i].scopeVar, scope) == 0) return 1; 
            //else if(var[i].isArray == array && var[i].arraySize == size) return 1;
                else i++; //avem un id cu acelasi nume, dar scope-ul e diferit
    }
    return 0;
}

void addVar(char* nume, char* tip, char* valoare, char* scope, int isArray, int arraySize){
    //adaug variabila in tabel
    if (searchVar(nume, scope) == 0){
        strcpy(var[variabilaCount].numeVar, nume);
        strcpy(var[variabilaCount].tipVar, tip);
        strcpy(var[variabilaCount].valoareVar, valoare);
        strcpy(var[variabilaCount].scopeVar, scope);
        var[variabilaCount].isArray = isArray;
        var[variabilaCount].arraySize = arraySize;
        variabilaCount++;
    }else{
        printf("Variabila %s a fost declarata anterior in acest scope\n", nume);
        exit(1);
    }
}

void updateVar(char* nume, char* valoare, char* scope){
   //actualizez valoarea unei variabile
   for (int i=0; i < variabilaCount; i++){
        if (strcmp(var[i].numeVar, nume) == 0 && strcmp(var[i].scopeVar, scope) == 0){
            strcpy(var[i].valoareVar, valoare);
            return;
        }
    }
}


int searchFunc(char* nume, struct parametru* lista, int nrParametrii){
    int i = 0; //cautam numele functiei
    while (i < functieCount)
    {    
        while ((strcmp(func[i].numeFunctie, nume) != 0) && (i < functieCount)) i++;

        if (i == functieCount) return 0; //nu l-am gasit = not declared
        //l-am gasit, verificam daca si nr de parametrii e identic, atunci functia e declarata deja
        else if (func[i].nrParametrii == nrParametrii){
            //verificam daca si tipurile parametrilor sunt identice
            int allAreTheSame = 1;
            for (int j = 0; j < nrParametrii; j++){
                if (strcmp(func[i].lista_parametrii[j].tipParametru, lista[j].tipParametru) != 0){
                    allAreTheSame = 0;
                    break;
                }
            }
            if (allAreTheSame == 1) return 1; // functia a mai fost declarata
            else i++; //avem o functie cu acelasi nume, dar parametrii sunt diferiti
            
        }
    }
    return 0;
}

void addFunc(char* nume, char* tip, int nrParametrii, struct parametru* lista, char* funcOrStruct)
{
    //adaug functia in tabel daca nu a mai fost declarata
    if (searchFunc(nume, lista, nrParametrii)== 0)
    {
        strcpy(func[functieCount].numeFunctie, nume);
        strcpy(func[functieCount].tipFunctie, tip);
        strcpy(func[functieCount].funcOrStruct, funcOrStruct);
        func[functieCount].nrParametrii = nrParametrii;
        for (int i = 0; i < nrParametrii; i++){
            strcpy(func[functieCount].lista_parametrii[i].numeParametru, lista[i].numeParametru);
            strcpy(func[functieCount].lista_parametrii[i].tipParametru, lista[i].tipParametru);
        }
        functieCount++;
    }
    else{
        saveTable();
        printf("Functia %s a mai fost declarata anterior\n", nume);
        exit(1);
    }
}

char* checkTypeOfValue(char* value){
    //verific daca valoarea este de tip int, float, char, string
    if (value[0] == '\''){
        return "char";
    }
    if (value[0] == '"'){
        return "string";
    }
    if (strchr(value, '.') != NULL){
        return "float";
    }
    if (strcmp(value, "true") == 0 || strcmp(value, "false") == 0){
        return "bool";
    }
    return "int";
}

struct lv* getVarTypeAndValue(char* nume, char* scope){
    int i = 0;
    //printf("[HEADER] sunt in functie %d, %d\n", i, variabilaCount);
    while (i < variabilaCount){
        if ( strcmp(var[i].numeVar, nume) == 0 && strcmp(var[i].scopeVar, scope) == 0){

           struct lv* lrVal;
           lrVal = (struct lv*)malloc(sizeof(struct lv));
            
           strcpy(lrVal->type, var[i].tipVar);
           strcpy(lrVal->value, var[i].valoareVar);
           strcpy(lrVal->scope, var[i].scopeVar);
           strcpy(lrVal->name, var[i].numeVar);
           
           return lrVal;
           
        }
        i++;
    }
    saveTable();
    if(strcmp(scope, "const") != 0)
    {
        printf("Variabila %s e constanta si nu poate fi modificata! (linia %d)\n", nume, yylineno);
        exit(1);
    }
    printf("[HEADER]Variabila %s nu exista! (linia %d)\n", nume, yylineno);
    exit(1);
}

char* getType(char* nume, char* scope){
    int i = 0;
    while (i < variabilaCount){
        // printf("sunt in typeof\n");
        if ( strcmp(var[i].numeVar, nume) == 0 && strcmp(var[i].scopeVar, scope) == 0){
            return var[i].tipVar;
        }
        i++;
    }
    saveTable();
    printf("Variabila %s nu exista! (linia %d)\n", nume, yylineno);
    exit(1);
}

char* getTypeFunc(char* nume, struct parametru* lista, int nrParametrii)
{
    int i = 0;
    while (i < functieCount)
    {
        while ((strcmp(func[i].numeFunctie, nume) != 0) && (i < functieCount)) i++;

        if (i == functieCount){
            saveTable();
            printf("Variabila %s nu exista! (linia %d)\n", nume, yylineno);
            exit(1);
        }
        else if (func[i].nrParametrii == nrParametrii){
            int allAreTheSame = 1;
            for (int j = 0; j < nrParametrii; j++){
                if (strcmp(func[i].lista_parametrii[j].tipParametru, lista[j].tipParametru) != 0){
                    allAreTheSame = 0;
                    break;
                }
            }
            if (allAreTheSame == 1) return func[i].tipFunctie;
            else i++;
        }
    }
    saveTable();
    printf("Variabila %s nu exista! (linia %d)\n", nume, yylineno);
    exit(1);
}

