/*** Definition Section has two variables to track the cursor
***/
%{
#include <string.h>
int linenum = 1;
int colnum = 1;
%}

/*** Rule Section begins with comments, followed by keywords, followed by symbols,
followed by errors, followed by idenifiers and numbers, followed by whitespace,
followed by extra symbols***/

%%

##.*\n    {linenum += 1; colnum = 1;}

function {printf("FUNCTION\n"); colnum += 8;}
beginparams {printf("BEGIN_PARAMS\n"); colnum += 11;}
endparams   {printf("END_PARAMS\n"); colnum += 9;}
beginlocals   {printf("BEGIN_LOCALS\n"); colnum += 11;}
endlocals   {printf("END_LOCALS\n"); colnum += 9;}
beginbody   {printf("BEGIN_BODY\n"); colnum += 9;}
endbody   {printf("END_BODY\n"); colnum += 7;}
integer   {printf("INTEGER\n"); colnum += 7;}
array   {printf("ARRAY\n"); colnum += 5;}
of  {printf("OF\n"); colnum += 2;}
if   {printf("IF\n"); colnum += 2;}
then {printf("THEN\n"); colnum += 4;}
endif {printf("ENDIF\n"); colnum += 5;}
else {printf("ELSE\n"); colnum += 4;}
while {printf("WHILE\n"); colnum += 5;}
do {printf("DO\n"); colnum += 2;}
beginloop {printf("BEGINLOOP\n"); colnum += 9;}
endloop {printf("ENDLOOP\n"); colnum += 7;}
continue {printf("CONTINUE\n"); colnum += 8;}
read  {printf("READ\n"); colnum += 4;}
write {printf("WRITE\n"); colnum += 5;}
and {printf("AND\n"); colnum += 3;}
or {printf("OR\n"); colnum += 2;}
not {printf("NOT\n"); colnum += 3;}
true {printf("TRUE\n"); colnum += 4;}
false {printf("FALSE\n"); colnum += 5;}
return {printf("RETURN\n"); colnum += 6;}

\+     {printf("ADD\n"); colnum += 1;}
\-     {printf("SUB\n"); colnum += 1;}
\*    {printf("MULT\n"); colnum += 1;}
\/    {printf("DIV\n"); colnum += 1;}
%     {printf("MOD\n"); colnum += 1;}

"=="     {printf("EQ\n"); colnum += 2;}
"<>"     {printf("NEQ\n"); colnum += 2;}
"<="     {printf("LTE\n"); colnum += 2;}
">="     {printf("GTE\n"); colnum += 2;}
"<"     {printf("LT\n"); colnum += 1;}
">"     {printf("GT\n"); colnum += 1;}

":="    {printf("ASSIGN\n"); colnum += 2;}
";"     {printf("SEMICOLON\n"); colnum += 1;}
":"     {printf("COLON\n"); colnum += 1;}
","     {printf("COMMA\n"); colnum += 1;}
"("     {printf("L_PAREN\n"); colnum += 1;}
")"     {printf("R_PAREN\n"); colnum += 1;}
"["     {printf("L_SQUARE_BRACKET\n"); colnum += 1;}
"]"     {printf("R_SQUARE_BRACKET\n"); colnum += 1;}

[a-zA-Z][_a-zA-Z0-9]*_  {printf("Error at line %d , column %d: identifier \"%s\" cannot end with an underscore\n", linenum, colnum, yytext); return 1;}
[0-9]+[_a-zA-Z]+     {printf("Error at line %d , column %d: identifier \"%s\" must begin with a letter\n", linenum, colnum, yytext); return 1;}

[0-9]+     {printf("NUMBER %s\n", yytext); colnum += strlen(yytext);}
[a-zA-Z][_a-zA-Z0-9]*[a-zA-Z0-9] {printf("IDENT %s\n", yytext); colnum += strlen(yytext);}
[a-zA-Z]   {printf("IDENT %s\n", yytext); colnum += 1;}

[ \t] {colnum += 1; }
[\n\r]    {linenum += 1; colnum = 1;}
.        {printf("Error at line %d , column %d: unrecognized symbol \"%s\"\n", linenum, colnum, yytext); return 1;}

%%

/*** Code Section calls yylex ***/
int yywrap(){}
int main(){

// Explanation:
// yywrap() - wraps the above rule section
/* yyin - takes the file pointer
          which contains the input*/
/* yylex() - this is the main flex function
          which runs the Rule Section*/
// yytext is the text in the buffer

yylex();
return 0;
}
