/*** Definition Section has one variable
which can be accessed inside yylex()
and main() ***/
%{
int c1 = 0;
int c2 = 0;
int c3 = 0;
int c4 = 0;
%}

/*** Rule Section has three rules, first rule
matches with capital letters, second rule
matches with any character except newline and
third rule does not take input after the enter***/
%%
[0-9]+ {printf("NUM %s\n", yytext); c1++;}
\+     {printf("PLUS\n"); c2++;}
\-     {printf("MINUS\n"); c2++;}
\*    {printf("MULT\n"); c2++;}
\/    {printf("DIV\n"); c2++;}
\(    {printf("L_PAREN\n"); c3++;}
\)    {printf("R_PAREN\n");}
=    {printf("EQUAL\n");return 0; c4++;}
%%

/*** Code Section prints the number of
capital letter present in the given input***/
int yywrap(){}
int main(){

// Explanation:
// yywrap() - wraps the above rule section
/* yyin - takes the file pointer
          which contains the input*/
/* yylex() - this is the main flex function
          which runs the Rule Section*/
// yytext is the text in the buffer

// Uncomment the lines below
// to take input from file
// FILE *fp;
// char filename[50];
// printf("Enter the filename: \n");
// scanf("%s",filename);
// fp = fopen(filename,"r");
// yyin = fp;

yylex();
printf("num ints: %d\n", c1);
printf("num ops: %d\n", c2);
printf("num parens: %d\n", c3);
printf("num equals: %d\n", c4);
return 0;
}