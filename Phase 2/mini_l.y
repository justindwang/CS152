%{

#include <stdio.h>
#include <stdlib.h>

extern int yylex();
extern int yyparse();
extern FILE* yyin;

void yyerror(const char* s);

%}

%token FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY INTEGER ARRAY OF 
%token IF THEN ENDIF ELSE WHILE DO BEGINLOOP ENDLOOP CONTINUE 
%token READ WRITE RETURN AND OR NOT TRUE FALSE 
%token SUB ADD MULT DIV MOD EQ NEQ LT GT LTE GTE 
%token SEMICOLON COLON COMMA L_PAREN R_PAREN L_SQUARE_BRACKET R_SQUARE_BRACKET ASSIGN
%token NUMBER IDENT

%start program

%%

program:    function program {printf("program -> function program\n");} 
            | {printf("program -> epsilon\n");}
            ;

dec_loop:   declaration SEMICOLON dec_loop {printf("dec_loop -> declaration SEMICOLON dec_loop\n");} 
            | {printf("dec_loop -> epsilon\n");}
            ;

stat_loop:  statement SEMICOLON stat_loop {printf("stat_loop -> statement SEMICOLON stat_loop\n");} 
            | {printf("stat_loop -> epsilon\n");}
            ;

id_loop:    COMMA IDENT id_loop {printf("id_loop -> COMMA IDENT id_loop\n");} 
            | {printf("id_loop -> epsilon\n");}
            ;

rel_and_loop: OR rel_and_exp rel_and_loop {printf("rel_and_loop -> OR rel_and_exp rel_and_loop\n");} 
            | {printf("rel_and_loop -> epsilon\n");}
            ;

rel_loop:   AND rel_exp rel_loop {printf("rel_loop -> AND rel_exp rel_loop\n");} 
            | {printf("rel_loop -> epsilon\n");}
            ;

exp_loop:   expression exp_loop_2 {printf("exp_loop -> expression exp_loop_2\n");} 
            | {printf("exp_loop -> epsilon\n");}
            ;

exp_loop_2: COMMA expression exp_loop_2 {printf("exp_loop_2 -> COMMA expression exp_loop\n");} 
            | {printf("exp_loop_2 -> epsilon\n");}
            ;

function:   FUNCTION IDENT SEMICOLON BEGIN_PARAMS dec_loop END_PARAMS BEGIN_LOCALS dec_loop END_LOCALS BEGIN_BODY statement SEMICOLON stat_loop END_BODY {
              printf("function -> FUNCTION IDENT SEMICOLON BEGIN_PARAMS dec_loop END_PARAMS BEGIN_LOCALS dec_loop END_LOCALS BEGIN_BODY statement SEMICOLON stat_loop END_BODY\n");}
            ;

declaration:    IDENT id_loop COLON declaration_2 INTEGER {
                printf("declaration -> IDENT id_loop COLON declaration_2 INTEGER\n");
                }
                ;

declaration_2:  ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF{
                    printf("declaration_2 -> ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF\n");
                }
                | {printf("declaration_2 -> epsilon\n");}
                ;

statement:      stat_1 
                | stat_2 
                | stat_3 
                | stat_4 
                | stat_5 
                | stat_6 
                | CONTINUE{
                    printf("statement -> CONTINUE\n");
                }
                | RETURN expression{
                    printf("statement -> RETURN expression\n");}
		;

stat_1:         var ASSIGN expression{
                printf("statement -> var ASSIGN expression\n");}
                ;

stat_2:         IF bool_exp THEN stat_loop stat_2_1 ENDIF{
                printf("statement -> IF bool_exp THEN stat_loop stat_2_1 ENDIF\n");}
                ;

stat_2_1:       ELSE stat_loop{
                printf("stat_2_1 -> ELSE stat_loop\n");}
                | {printf("stat_2_1 -> epsilon\n");}
                ;

stat_3:         WHILE bool_exp BEGINLOOP stat_loop ENDLOOP{
                printf("statement -> WHILE bool_exp BEGINLOOP stat_loop ENDLOOP\n");}
                ;

stat_4:         DO BEGINLOOP stat_loop ENDLOOP WHILE bool_exp{
                printf("statement -> DO BEGINLOOP stat_loop ENDLOOP WHILE bool_exp\n");}
                ;

stat_5:         READ var var_loop1{
                printf("statement -> READ var var_loop\n");}
                ;

stat_6:         WRITE var var_loop2{
		printf("statement -> WRITE var var_loop\n");}
                ;

var_loop1:   COMMA var var_loop1 {printf("var_loop1 -> COMMA var var_loop1\n");} 
            | {printf("var_loop1 -> epsilon\n");}
            ;

var_loop2:   COMMA var var_loop2 {printf("var_loop2 -> COMMA var var_loop2\n");} 
            | {printf("var_loop2 -> epsilon\n");}
            ;

bool_exp:       rel_and_exp rel_and_loop{
                printf("bool_exp -> rel_and_exp rel_and_loop\n");}
                ;

rel_and_exp:    rel_exp rel_loop{
                printf("rel_and_exp -> rel_exp rel_loop\n");}
                ;

rel_exp:        rel_exp_2{
                printf("rel_exp -> rel_exp_2\n");}
                | NOT rel_exp_2{
                printf("rel_exp -> NOT rel_exp_2\n");}
                ;

rel_exp_2:      expression comp expression{
                printf("rel_exp_2 -> expression comp expression\n");}
                | TRUE {printf("rel_exp_2 -> TRUE\n");}
                | FALSE {printf("rel_exp_2 -> FALSE\n");}
                | L_PAREN bool_exp R_PAREN{
                printf("rel_exp_2 -> L_PAREN bool_exp R_PAREN\n");}
                ;

comp:           EQ {printf("comp -> EQ\n");}
                | NEQ {printf("comp -> NEQ\n");}
                | LT {printf("comp -> LT\n");}
                | GT {printf("comp -> GT\n");}
                | LTE {printf("comp -> LTE\n");}
                | GTE {printf("comp -> GTE\n");}
                ;

expression:     mult_exp expression_2 {printf("expression -> mult_exp expression_2\n");}
                ;

expression_2:   ADD mult_exp expression_2 {printf("expression_2 -> ADD mult_exp expression_2\n");}
                | SUB mult_exp expression_2 {printf("expression_2 -> SUB mult_exp expression_2\n");}
                | {printf("expression -> epsilon\n");}
                ;

mult_exp:       term mult_exp_2 {printf("mult_exp -> term mult_exp_2\n");}
                ;

mult_exp_2:     MULT mult_exp {printf("mult_exp_2 -> MULT mult_exp\n");}
                | DIV mult_exp {printf("mult_exp_2 -> DIV mult_exp\n");}
                | MOD mult_exp {printf("mult_exp_2 -> MOD mult_exp\n");}
                |{printf("mult_exp_2 -> epsilon\n");}
                ;

term:           SUB term_2 {printf("term -> SUB term_2\n");}
                | term_2 {printf("term -> term_2\n");}
                | term_3 {printf("term -> term_3\n");}
                ;

term_2:         var {printf("term_2 -> var\n");}
                | NUMBER {printf("term_2 -> NUMBER\n");}
                | L_PAREN expression R_PAREN {printf("term_2 -> L_PAREN expression R_PAREN\n");}
                ;

term_3:         IDENT L_PAREN exp_loop R_PAREN{
                printf("term_3 -> IDENT L_PAREN exp_loop R_PAREN\n");}
                ;

var:            IDENT {printf("var -> IDENT\n");}
                | IDENT L_SQUARE_BRACKET expression R_SQUARE_BRACKET {
		printf("var -> IDENT L_SQUARE_BRACKET expression R_SQUARE_BRACKET\n");}
                ;


%%

int main() {
  yyin = stdin;

  do {
    printf("Parse.\n");
    yyparse();
  } while(!feof(yyin));
  return 0;
}

void yyerror(const char* s) {
  extern int linenum;
  fprintf(stderr, "Parse error at line %d: %s. Incorrect Expression!\n", linenum, s);
  exit(1);
}

