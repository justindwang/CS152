/*** Definition Section has one variable
which can be accessed inside yylex()
and main() ***/
%{
#define YY_DECL int yylex()
#include "calc.tab.h"
%}

/*** Rule Section has three rules, first rule
matches with capital letters, second rule
matches with any character except newline and
third rule does not take input after the enter***/
%%
[0-9]+ { return NUMBER; }
\+     { return PLUS; }
\-     { return MINUS;}
\*    { return MULT;}
\/    { return DIV;}
\(    { return L_PAREN;}
\)    {return R_PAREN;}
=    { return EQUAL;}
%%

/*** Code Section prints the number of
capital letter present in the given input***/
int yywrap(){}
