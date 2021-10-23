%{

#include <stdio.h>
#include <stdlib.h>

extern int yylex();
extern int yyparse();
extern FILE* yyin;
int c1 = 0;
int c2 = 0;
int c3 = 0;
int c4 = 1;
void yyerror(const char* s);
%}

%token NUMBER
%token EQUAL
%left PLUS MINUS
%left MULT DIV
%precedence NEG 
%left L_PAREN R_PAREN
%start line 

%%

line expr EQUAL
    |
;

expr: NUMBER      {c1++;}
    | expr PLUS expr    {$$ = $1 + $3; c2++;}
    | expr MINUS expr    {$$ = $1 - $3; c2++;}
    | expr MULT expr    {$$ = $1 * $3; c2++;}
    | expr DIV expr    {$$ = $1 / $3; c2++;}
    | MINUS expr %prec NEG    {$$ = -$2; c2++;}
    | L_PAREN expr R_PAREN    {$$ = $2; c3++;}
;

%%

int main() {
  yyin = stdin;

  do {
    printf("Parse.\n");
    yyparse();
  } while(!feof(yyin));
  printf("Expression works!\n");
  printf("num ints: %d\n", c1);
  printf("num ops: %d\n", c2);
  printf("num parens: %d\n", c3);
  printf("num equals: %d\n", c4);
  return 0;
}

void yyerror(const char* s) {
  fprintf(stderr, "Parse error: %s. Incorrect Expression!\n", s);
  exit(1);
}
