/*** Definition Section has two variables to track the cursor
***/
%{
#define YY_DECL int yylex()
#include <string.h>
#include "y.tab.h"
int linenum = 1;
int colnum = 1;
%}

/*** Rule Section begins with comments, followed by keywords, followed by symbols,
followed by errors, followed by idenifiers and numbers, followed by whitespace,
followed by extra symbols***/

%%

##.*\n    {linenum += 1; colnum = 1;}

function { return FUNCTION ; colnum += 8;}
beginparams {return BEGIN_PARAMS; colnum += 11;}
endparams   {return END_PARAMS; colnum += 9;}
beginlocals   {return BEGIN_LOCALS; colnum += 11;}
endlocals   {return END_LOCALS; colnum += 9;}
beginbody   {return BEGIN_BODY; colnum += 9;}
endbody   {return END_BODY; colnum += 7;}
integer   {return INTEGER; colnum += 7;}
array   {return ARRAY; colnum += 5;}
of  {return OF; colnum += 2;}
if   {return IF; colnum += 2;}
then {return THEN; colnum += 4;}
endif {return ENDIF; colnum += 5;}
else {return ELSE; colnum += 4;}
while {return WHILE; colnum += 5;}
do {return DO; colnum += 2;}
beginloop {return BEGINLOOP; colnum += 9;}
endloop {return ENDLOOP; colnum += 7;}
continue {return CONTINUE; colnum += 8;}
read  {return READ; colnum += 4;}
write {return WRITE; colnum += 5;}
and {return AND; colnum += 3;}
or {return OR; colnum += 2;}
not {return NOT; colnum += 3;}
true {return TRUE; colnum += 4;}
false {return FALSE; colnum += 5;}
return {return RETURN; colnum += 6;}

\+     {return ADD; colnum += 1;}
\-     {return SUB; colnum += 1;}
\*    {return MULT; colnum += 1;}
\/    {return DIV; colnum += 1;}
%     {return MOD; colnum += 1;}

"=="     {return EQ; colnum += 2;}
"<>"     {return NEQ; colnum += 2;}
"<="     {return LTE; colnum += 2;}
">="     {return GTE; colnum += 2;}
"<"     {return LT; colnum += 1;}
">"     {return GT; colnum += 1;}

":="    {return ASSIGN; colnum += 2;}
";"     {return SEMICOLON; colnum += 1;}
":"     {return COLON; colnum += 1;}
","     {return COMMA; colnum += 1;}
"("     {return L_PAREN; colnum += 1;}
")"     {return R_PAREN; colnum += 1;}
"["     {return L_SQUARE_BRACKET; colnum += 1;}
"]"     {return R_SQUARE_BRACKET; colnum += 1;}

[a-zA-Z][_a-zA-Z0-9]*_  {printf("Error at line %d , column %d: identifier \"%s\" cannot end with an underscore\n", linenum, colnum, yytext); return 1;}
[0-9]+[_a-zA-Z]+     {printf("Error at line %d , column %d: identifier \"%s\" must begin with a letter\n", linenum, colnum, yytext); return 1;}

[0-9]+     {return NUMBER; colnum += strlen(yytext);}
[a-zA-Z][_a-zA-Z0-9]*[a-zA-Z0-9] {printf("ident -> IDENT %s\n", yytext); return IDENT; colnum += strlen(yytext);}
[a-zA-Z]   {printf("ident -> IDENT %s\n", yytext); return IDENT; colnum += 1;}

[ \t] {colnum += 1; }
[\n\r]    {linenum += 1; colnum = 1;}
.        {printf("Error at line %d , column %d: unrecognized symbol \"%s\"\n", linenum, colnum, yytext); return 1;}

%%
