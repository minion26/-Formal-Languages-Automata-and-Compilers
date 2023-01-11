lex limbaj.l
yacc -d limbaj.y
gcc  lex.yy.c y.tab.c 
./a.out input.txt