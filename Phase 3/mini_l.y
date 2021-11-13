%{
  #include <stdio.h>
  #include <stdlib.h>

  #include <iostream>
  #include <fstream>
  #include <sstream>
  
  #include <map>
  #include <stack>

  #include <string>
  #include <string.h>

  char keyword[27][12] = {"function", "beginparams", "endparams", "beginlocals", "endlocals", "beginbody", "endbody",
  "integer", "array", "of", "if", "then", "endif", "else", "while", "do", "beginloop", "endloop", "continue", "read",
  "write", "and", "or", "not", "true", "false", "return"};

  using namespace std;

  extern FILE *yyin;

  int yylex(void);
  void yyerror(const char *message);
  extern int linenum;

  string new_temp();
  string new_label();

  stack<string> stack_ids; 
  stack<string> stack_vars; 
  stack<string> stack_exps;
  stack<string> stack_params;
  stack<string> stack_labels;

  stringstream temp_buffer;
  ostringstream code_buffer;

  bool main_dec = 0;
  int temp_count = 0;
  int label_count = 0;
  int param_count = 0;
  
  enum id_type {INT, I_ARRAY, FUNC};

  struct Function {
    string name;
    Function(): name() {}
    Function(string n): name(n) {}
  };

  struct Var {
    int value;
    int len;
    string name;
    id_type type; 
    Var(): value(0), len(0), name(), type() {}
    Var(int v, int s, string n, id_type t):value(v), len(s), name(n), type(t) {}
  }; 
  
  map<string, Function> f_table;
  map<string, Var> v_table;
  void push_map_v(Var var);
  void push_map_f(Function func);
  void find_var(string name);
  void find_function(string name);
  void list_decs();

%}

%union{
  char* id;
  int num;

  struct Terminals {
    char name[256];
    char index[256];
    int type;
    int value;
  } terminal;
}

%error-verbose
%token FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY INTEGER ARRAY OF 
%token IF THEN ENDIF ELSE WHILE DO BEGINLOOP ENDLOOP CONTINUE 
%token READ WRITE RETURN AND OR NOT TRUE FALSE 
%token SUB ADD MULT DIV MOD 
%token EQ NEQ LT GT LTE GTE 
%token SEMICOLON COLON COMMA L_PAREN R_PAREN L_SQUARE_BRACKET R_SQUARE_BRACKET ASSIGN
%token IDENT NUMBER

%type <id> IDENT
%type <num> NUMBER

%right ASSIGN NOT
%left OR AND ADD SUB MULT DIV L_SQUARE_BRACKET R_SQUARE_BRACKET L_PAREN R_PAREN

%type<terminal> var expression term declaration statement mult_exp bool_expr relation_and_expr relation_expr rel_expr
%type<id> comp

%start program_start

%%

program_start: program {
      if(main_dec == 0){
        yyerror("ERROR: No main function");
        }
      }
     ;

program: 
       | function program
       | {} //epsilon
       ;

dec_loop:  
                 | declaration SEMICOLON dec_loop
                 | {} //epsilon
                 ;

stat_loop: 
               | statement SEMICOLON stat_loop
               | {} //epsilon
               ;

id_loop: 
            | COMMA IDENT id_loop {
               stack_ids.push($2);
               stack_params.push($2);
              }
            | {} //epsilon
           ;

var_loop:  
         | COMMA var var_loop {
             stack_vars.push($2.name);
            } 
         | {} //epsilon
         ;

exp_loop: COMMA expression exp_loop {
                   stack_exps.push($2.name); 
                 }
               | {} //epsilon
               ;

function: FUNCTION IDENT {
            temp_buffer << "func " << string($2) << endl;
            } 
          SEMICOLON BEGIN_PARAMS dec_loop { 
            while (!stack_params.empty()){
              temp_buffer << "= " << stack_params.top() << ", " << "$" << param_count++ << endl;
              stack_params.pop();
            }
          } 
          END_PARAMS  BEGIN_LOCALS dec_loop END_LOCALS BEGIN_BODY statement SEMICOLON stat_loop END_BODY {
            code_buffer << "endfunc" << endl;
            v_table.clear();
            if (strcmp($2, "main") == 0) {
              main_dec = 1;      
            }
            Function f($2);
            push_map_f(f);
            while (!stack_params.empty()) {
              stack_params.pop();
            }
            param_count = 0;
          }
        ;

declaration: IDENT id_loop COLON INTEGER {
               stack_ids.push($1);
               stack_params.push($1);
               while(!stack_ids.empty()) {
                 string temp = stack_ids.top();
                 Var var(0,0,temp,INT); 
                 push_map_v(var);
                 temp_buffer << ". " << temp << endl;
                 stack_ids.pop(); 
               }
             }
           | IDENT id_loop COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER {
               stack_ids.push($1);
               stack_params.push($1);
               while(!stack_ids.empty()) {
                 string temp = stack_ids.top();
                 Var var(0,$6,temp, I_ARRAY);
                 push_map_v(var);
                 temp_buffer << ".[] " << temp << ", " << $6 << endl;
                 stack_ids.pop(); 
               }
             }
           ;

statement: var ASSIGN expression {
             if ($1.type == 0) {
                 temp_buffer << "= " << const_cast<char*>($1.name) << ", " << const_cast<char*>($3.name) << endl;
              
             }
             else { 
                 temp_buffer << "[]= " << const_cast<char*>($1.name) << ", " << const_cast<char*>($1.index) << ", " << const_cast<char*>($3.name) << endl;
             } 
             code_buffer << temp_buffer.rdbuf();
             temp_buffer.clear();
             temp_buffer.str(" ");
          }
         | IF bool_expr THEN statement SEMICOLON stat_loop optional_else ENDIF {
            //TODO
           }
          | WHILE bool_expr BEGINLOOP statement SEMICOLON stat_loop ENDLOOP {
              //TODO
           }
          | DO BEGINLOOP statement SEMICOLON stat_loop ENDLOOP WHILE bool_expr {
             //TODO
           }
          | READ var var_loop {
             stack_vars.push($2.name);
             while (!stack_vars.empty()) {
                if ($2.type == 0) {
                    temp_buffer << ".< " << stack_vars.top() << endl;
                    stack_vars.pop();
                }
                else {
                    temp_buffer << ".[]< " << stack_vars.top() << ", "  <<  const_cast<char*>($2.index) << endl;
                    stack_vars.pop();
                }
             }
             code_buffer << temp_buffer.rdbuf();
             temp_buffer.clear();
             temp_buffer.str(" ");
          } 
         | WRITE var var_loop {
            stack_vars.push($2.name);
            while (!stack_vars.empty()) {
                if ($2.type == 0) {
                    temp_buffer << ".> " << stack_vars.top() << endl;
                    stack_vars.pop();
                }
                else {
                    temp_buffer << ".[]> " << stack_vars.top() << ", "  <<  const_cast<char*>($2.index) << endl;
                    stack_vars.pop();
                }
            }
            code_buffer << temp_buffer.rdbuf();
            temp_buffer.clear();
            temp_buffer.str(" ");
         }
         | CONTINUE {
             //TODO
           }
         | RETURN expression {
            $$.value = $2.value;
             strcpy($$.name,$2.name);
             temp_buffer << "ret " << const_cast<char*>($2.name) << endl;
             code_buffer << temp_buffer.rdbuf();
             temp_buffer.clear();
             temp_buffer.str(" ");
         }
         ;

optional_else: statement SEMICOLON stat_loop {
            //TODO
          }          
          ;

bool_expr: bool_expr OR relation_and_expr {
             //TODO
           }
         | relation_and_expr {
             //TODO
           }
         ;

relation_and_expr: relation_and_expr AND relation_expr {
                    //TODO
                   }
                 | relation_expr {
                      //TODO
                    }
                 ;

relation_expr: rel_expr {
                    //TODO
                } 
             | NOT rel_expr {
                   //TODO
                }
             ;

rel_expr: expression comp expression {
          //TODO
            }
        | TRUE {
            //TODO
          }
        | FALSE {
            //TODO
          }
        | L_PAREN bool_expr R_PAREN {
                //TODO
          }
        ;

comp: EQ { $$ = const_cast<char*>("=="); } 
    | NEQ { $$ = const_cast<char*>("!="); }
    | LT { $$ = const_cast<char*>("<"); }
    | GT { $$ = const_cast<char*>(">"); }
    | LTE { $$ = const_cast<char*>("<="); }
    | GTE { $$ = const_cast<char*>(">="); }
    ;

expression: expression ADD mult_exp {
              string temp = new_temp();
              temp_buffer << ". " << temp << endl;
              temp_buffer << "+ " << temp << ", " << const_cast<char*>($1.name) << ", " << const_cast<char*>($3.name) << endl;
              strcpy($$.name, temp.c_str());
            }
          | expression SUB mult_exp {
              string temp = new_temp();
              temp_buffer << ". " << temp << endl;
              temp_buffer << "- " << temp << ", " << const_cast<char*>($1.name) << ", " << const_cast<char*>($3.name) << endl;
              strcpy($$.name, temp.c_str());
            }
          |  mult_exp {
              strcpy($$.name,$1.name);
              $$.type = $1.type;
             }
          ;

mult_exp: mult_exp MULT term {
                       string temp = new_temp();
                       temp_buffer << ". " << temp << endl;
                       temp_buffer << "* " << temp << ", " << const_cast<char*>($1.name) << ", " << const_cast<char*>($3.name) << endl;
                       strcpy($$.name, temp.c_str());
                     }
                   | mult_exp DIV term {
                       string temp = new_temp();
                       temp_buffer << ". " << temp << endl;
                       temp_buffer << "/ " << temp << ", " << const_cast<char*>($1.name) << ", " << const_cast<char*>($3.name) << endl;
                       strcpy($$.name, temp.c_str());
                    }
                   | mult_exp MOD term {
                       string temp = new_temp();
                       temp_buffer << ". " << temp << endl;
                       temp_buffer << "% " << temp << ", " << const_cast<char*>($1.name) << ", " << const_cast<char*>($3.name) << endl;
                       strcpy($$.name, temp.c_str());
                    }
                   | term{
                       strcpy($$.name,$1.name);
                       $$.type = $1.type;
                     }
                   ;

term: SUB var {
        $$.value = $2.value*-1;
        $$.type = $2.type;
        if ($2.type == 0) {
          string temp1 = new_temp();
          string temp2 = new_temp();
          temp_buffer << ". " << temp1 << endl;
          temp_buffer << "= " << temp1 << ", " << "0" << endl;
          temp_buffer << ". " << temp2 << endl;
          temp_buffer << "= " << temp2 << ", " << const_cast<char*>($2.name) << endl;
          strcpy($$.name, new_temp().c_str());
          temp_buffer << ". " << const_cast<char*>($$.name) << endl;
          temp_buffer << "- " << const_cast<char*>($$.name) <<  ", " << temp1 << ", " << temp2 << endl;
         }        
        else if ($2.type == 1) {
          string temp1 = new_temp();
          string temp2 = new_temp();
          temp_buffer << ". " << temp1 << endl;
          temp_buffer << "= " << temp1 << ", " << "0" << endl;
          temp_buffer << ". " << temp2 << endl;
          temp_buffer << ". " << temp2 << endl;
          temp_buffer << "=[] " << temp2 << ", " << const_cast<char*>($2.name) <<  ", " << const_cast<char*>($2.index) << endl;
          strcpy($$.name, new_temp().c_str());
          temp_buffer << ". " <<  const_cast<char*>($$.name)<< endl;
          temp_buffer << "- " << const_cast<char*>($$.name) << ", " << temp1 <<  ", " << temp2 << endl;
        }
      }
    | var {
        $$.value = $1.value;
        $$.type = $1.type;
        if ($1.type != 1) {
          strcpy($$.name, new_temp().c_str());
          strcpy($$.index, $$.name);
          temp_buffer << ". " << const_cast<char*>($$.name) << endl;
          temp_buffer << "= " << const_cast<char*>($$.name) <<  ", " << const_cast<char*>($1.name) << endl;
        }
        else if ($1.type == 1) { 
          strcpy($$.name, new_temp().c_str());
          temp_buffer << ". " <<  const_cast<char*>($$.name)<< endl;
          temp_buffer << "=[] " << const_cast<char*>($$.name) << ", " << const_cast<char*>($1.name) << ", " << const_cast<char*>($1.index) << endl;
        }

      }
    | SUB NUMBER {
        $$.value = $2*-1;
        $$.type = 0;
        string temp1 = new_temp();
        string temp2 = new_temp();
        temp_buffer << ". " << temp1 << endl;
        temp_buffer << "= " << temp1 << ", " << "0" << endl;
        temp_buffer << ". " << temp2 << endl;
        temp_buffer << "= " << temp2 << ", " << $2 << endl;

        strcpy($$.name, new_temp().c_str());
        temp_buffer << ". " << const_cast<char*>($$.name) << endl;
        temp_buffer << "- " << const_cast<char*>($$.name) <<  ", " << temp1 << ", "<< temp2 << endl;
     }
    | NUMBER  {
        $$.value = $1;
        $$.type = 0;

        strcpy($$.name, new_temp().c_str());
        strcpy($$.index, $$.name);
        temp_buffer << ". " << const_cast<char*>($$.name) << endl;
        temp_buffer << "= " << const_cast<char*>($$.name) <<  ", " << $$.value << endl;
      }
     | SUB L_PAREN expression R_PAREN {

       string temp1 = new_temp();

       temp_buffer << ". " << temp1 << endl;
       temp_buffer << "= " << temp1 << ", " << "0"<< endl;
        
       strcpy($$.name, new_temp().c_str());
       temp_buffer << ". " << const_cast<char*>($$.name) << endl;
       temp_buffer << "- " << const_cast<char*>($$.name) <<  ", " << temp1 << ", "<< const_cast<char*>($3.name) << endl;
      }
    | L_PAREN expression R_PAREN {
        strcpy($$.name, $2.name);
    }
    | IDENT L_PAREN expression exp_loop R_PAREN {
        find_function(const_cast<char*>($1));
        stack_exps.push($3.name); 
        while (!stack_exps.empty()){
          temp_buffer << "param " << stack_exps.top() << endl;
          stack_exps.pop();
        }
        string temp = new_temp();
        temp_buffer << ". " << temp << endl;
        temp_buffer << "call " << const_cast<char*>($1) << ", " << temp << endl;
        strcpy($$.name, temp.c_str());
      }
    | IDENT L_PAREN R_PAREN {
        find_function(const_cast<char*>($1));
        string temp = new_temp();
        temp_buffer << ". " << temp << endl;
        temp_buffer << "call " << const_cast<char*>($1) << ", " << temp << endl;
        strcpy($$.name, temp.c_str());
      }
    ;

var: IDENT {
       find_var($1);
       if(v_table[$1].type == I_ARRAY) {
         yyerror("ERROR: Forgot to specify array index for array variable");
       }
       else {
         strcpy($$.name,$1);
         $$.type = 0;
       }
     }
   | IDENT L_SQUARE_BRACKET expression R_SQUARE_BRACKET {
       find_var($1);
       if(v_table[$1].type == INT) {
         yyerror("ERROR: Specified index for int variable");
       }
       else {
         if ($3.type == 1) {
           string temp = new_temp();
           $$.type = 1;
           strcpy($$.index, temp.c_str());
           strcpy($$.name, $1);

           temp_buffer << ". " << temp << endl; 
           temp_buffer << "=[] " << temp << ", " << const_cast<char*>($3.name) << ", " << const_cast<char*>($3.index) << endl;
         }
         else {
           strcpy($$.name, $1);
           $$.type = 1;
           strcpy($$.index, $3.name);
         }
       }
     }
   ;

%%

void push_map_v(Var s) {
  if (v_table.find(s.name) == v_table.end()) {
    v_table[s.name] = s;
  }
  else {
    string temp = "ERROR: Identifier already declared: " + s.name;
    yyerror(temp.c_str());
  }
}

void push_map_f(Function f) {
  if (f_table.find(f.name) == f_table.end()) {
    f_table[f.name] = f;
  }
  else {
    string temp = "ERROR: Function already declared: " + f.name;
    yyerror(temp.c_str());
  }
}

void find_var(string name) {
  if(v_table.find(name) == v_table.end()) {
    string temp = "ERROR: Identifier not declared: " + name;
    yyerror(temp.c_str());
  }
  int flag=0,i;
   for(i = 0; i < 27; i++) {
      if(strcmp(name.c_str(),keyword[i])==0) {
         flag=1;
      }
   }
   if(flag==1){
      yyerror("ERROR: Using keyword as variable name");}
}

void find_function(string name) {
  if(f_table.find(name) == f_table.end()) {
    string temp = "ERROR: Function not declared: " + name;
    yyerror(temp.c_str());
  }
}

void list_decs() {
  for(map<string,Var>::iterator i = v_table.begin(); i!=v_table.end();i++){
    if (i->second.type == INT) {
      temp_buffer << ". " << i->second.name << endl;
    }
    else {
      temp_buffer << ".[] " << i->second.name << ", " << i->second.len << endl;
    }
  }
}

string new_temp() {
  stringstream ss;
  ss << temp_count++;
  string temp = "__temp__" + ss.str();
  return temp;
}

string new_label() {
  stringstream ss;
  ss << label_count++;
  string temp = "__label__" + ss.str();
  return temp;
}

void yyerror(const char *message) {
  printf("Error on line %d: \"%s\" \n", linenum, message);
}

void yyerror(string message) {
  cout << "Error on line " << linenum << ": " << message << endl;
}

int main (int argc, char **argv) {
  if (argc > 1) {
    yyin = fopen(argv[1], "r");
    if (yyin == NULL) {
      printf("syntax: %s filename\n", argv[0]);
    }
  }
  yyparse();
  ofstream file;
  file.open("to_copy.mil");
  file << code_buffer.str();
  file.close();
  return 0;
}