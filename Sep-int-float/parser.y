%{
/* Preamble */
#include <stdio.h>
#include <stdlib.h>

/* Function declarations */
void yyerror(const char *s);
%}

/* Token declarations */
%union{
  int ival;
  double dval;
}

%token <ival> INT
%token <dval> FLOAT
%type <dval> expr term factor

%token ADD SUBTRACT
%token NEWLINE
%token MULTIPLY
%token DIVIDE
%token LPAREN RPAREN
%token EQUAL
%token MODULO

%left ADD SUBTRACT
%left MULTIPLY DIVIDE  

%%

/* Grammar rules with semantic actions */

/* Ensure \n are handled as well responsible for printing result*/
lines: /* empty */
     | lines expr NEWLINE {
              if($2 == (double)((int)$2)){           
                printf("Result: %d\n", (int)$2);
              }else{
                printf("Result: %.3f\n", $2);
              }           
     }
     | lines error NEWLINE {yyerrok;}
     ;

/* Addition rule */
expr: expr ADD term { $$ = $1 + $3;}
    | expr SUBTRACT term {$$ = $1 - $3;}
    | term
    ;

term: term DIVIDE factor  {$$ = $1 / $3;} 
    | term MULTIPLY factor {$$ = $1 * $3;} 
    | factor;

factor: INT   {$$ = (double)$1;} 
      | FLOAT {$$ = $1;}
      | LPAREN expr RPAREN {$$ = $2;}
      ;


%%

/* Additional C code */
int main(int argc, char **argv) {
    // Call the parser
    return yyparse();
}

/* Error handle */
void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}


