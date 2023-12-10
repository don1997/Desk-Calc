/* 

Donald McLaughlin 

Parser for Desk Calculator
FALL 2023 PPL

OS: Linux Mint

Files Provided
-----------------

* parser.y
* scanner.l
* Makefile

*/

/* 

Make Usage
----------
If system can run make files run the following commands for compilation. 
If not consult manual compilation steps.
1. $ make

Running and usage

If have a file for testing name input.txt for example
2. $ ./calc < input.txt

To clean out generated files
3. $ make clean  
*/



/* 

Manual Compilation Steps
-----------------------

1. $ bison -d parser.y
2. $ flex scanner.l
3. $ gcc -o calc lex.yy.c parser.tab.c -Wall -lm -w 

4. Running and Testing
If have a file for testing name input.txt for example
5. $ ./calc < input.txt


*/

%{
/* Preamble */
#include <stdio.h>
#include <stdlib.h>

#include <math.h> /* fmod(), NAN, isnan()*/

/* Used to silence warning  with yylex*/
int yylex(void);

/* Array to store variable values, 'a' to 'f' */
double variables[6]; 

/* Check to verify value is integer for apply with integer modulus */
int operands_are_integers(double a, double b) {
    return (a == floor(a)) && (b == floor(b));
}

/* Error Handle */
void report_error(const char *error_type, const char *detail) {
    fprintf(stderr, "ERROR [%s]: %s\n", error_type, detail);
}

/* Error Handle */
void yyerror(const char *s) {
    report_error("SYNTAX ERROR", s);
}

/* Store values into var */
void store_var(char* var, double value) {
    if (var[0] >= 'a' && var[0] <= 'f') {
        variables[var[0] - 'a'] = value;
    }
}

/* Retrieve char val */
double get_var(char* var) { 

    int index = var[0] - 'a';
    if (index >= 0 && index < 6) {
        if (isnan(variables[index])) {
            report_error("Variable Retrieval ERROR","Uninitialized variable");
            return NAN; // Or another appropriate error value
        }
        return variables[index];
    }
    yyerror("Invalid variable name");
    return NAN; // Or another appropriate error value

}

/* Operator Types */
typedef enum{
  OP_ADD, OP_SUBTRACT, OP_MULTIPLY, OP_DIVIDE, OP_MODULO, OP_INVALID
} operation_type;


/* Read expression for apply*/
operation_type eval(double op1, double op2, char operator){
  if (isnan(op1) || isnan(op2)){
    
    report_error("Evaluation ERROR","Uninitialized variable in expression");
    return OP_INVALID;
  }

  switch(operator){
    case '+':return OP_ADD;
    case '-':return OP_SUBTRACT;
    case '*':return OP_MULTIPLY;
    case '/':
            if(op2 == 0){
              report_error("Evaluation ERROR","DIVISION BY ZERO");
              return OP_INVALID;
            } else {
              return OP_DIVIDE;
            }
    case '%':return OP_MODULO;
    default: return OP_INVALID;
  }

}

/* Apply operator to operands */
double apply(operation_type op, double op1, double op2){

  switch(op){
    case OP_ADD:return op1 + op2;
    case OP_SUBTRACT:return op1 - op2;
    case OP_MULTIPLY:return op1 * op2;
    case OP_DIVIDE:return op1 / op2;
    case OP_MODULO:    
      if (operands_are_integers(op1, op2)) {
        return (int)op1 % (int)op2;
      } else {
        return fmod(op1, op2);
      }

    default:
      report_error("Application Error", "Invalid Operation");
      return NAN;
  }

}

/* Reads expression (eval) and then applies operator to expression (apply)
   Then returns result
*/
double eval_apply(double op1, double op2, char operator){
  

  operation_type op_type = eval(op1, op2, operator);
  
  if(op_type == OP_INVALID){
    return NAN;
  }

  double result = apply(op_type, op1,op2);

  return result;
}

/* Used for handling output of vars and expressions without ID token*/
typedef enum{
  OUTPUT_TYPE_ASSIGN,
  OUTPUT_TYPE_EXPR
} OutputType;

/* Parser Output */
void print_output(double value, OutputType outputType, const char* varName){
  if(isnan(value)){
    report_error("Output_Warning", "Undefined Value in Output");
  } else if (outputType == OUTPUT_TYPE_ASSIGN){
    if(value ==  (double)((int) value)){
      printf("%s = %d\n", varName, (int) value);
    } else {
      printf("%s = %.3f\n", varName, value);
    }
  }
  //Output Type Expr
  else{
    if (value == (double)((int)value)){
      printf("Result: %d\n", (int)value); 
    } else {
      printf("Result: %.3f\n", value);
    }
  }
}


%}

/* Token declarations */ 

/* Special Tokens and types */
%union{ double dval; char* sval;}

/* Handle integer values as float*/
%token <dval> INT FLOAT

%token <sval> ID

%type <dval> modulo_expr expr term factor  
%type <sval> assign

/* Tokens */
%token ADD SUBTRACT
%token NEWLINE
%token MULTIPLY
%token DIVIDE
%token OP CP
%token EQUAL
%token MODULO

/* Precedence */
%left ADD SUBTRACT
%left MULTIPLY DIVIDE MODULO 


%%
/* Grammar rules with semantic actions */

program:
    | program lines
    ;

lines: /* empty */
    | lines NEWLINE /* handle blank line in input file */
    | lines expr NEWLINE {print_output($2, OUTPUT_TYPE_EXPR, NULL);}              
    | lines assign NEWLINE
    | lines error NEWLINE {yyerrok;}
    ;

/* VAR Assignment*/
assign: ID EQUAL expr {
      store_var($1, $3);
      print_output($3, OUTPUT_TYPE_ASSIGN, $1);
      
      free($1); /* free after usign strdup*/
    }
    ;

modulo_expr: expr MODULO expr {$$ = eval_apply($1, $3, '%');};
/* Expression */
expr:expr ADD term { $$ = eval_apply($1,$3,'+');}
    | expr SUBTRACT term {$$ = eval_apply($1,$3,'-');}
    | term
    |modulo_expr
    | ID { $$ = get_var($1); }
    |error {$$ = NAN;}
    ;

/* Term */
term: term DIVIDE factor{$$ = eval_apply($1, $3, '/');} 
    | term MULTIPLY factor {$$ = eval_apply($1,$3,'*');} 
    | factor
    ;
/* Factor */
factor: INT   {$$ = $1;} 
    | FLOAT {$$ = $1;} 
    | ID { $$ = get_var($1); }
    | OP expr CP {$$ = $2;}
    ;


%%

int main(int argc, char **argv) {
  /* Init variables to NAN */
  for (int i = 0; i < 6; ++i) {
  
    variables[i] = NAN;
  
  } 
    // Call the parser
    return yyparse();
}
