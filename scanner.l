/* 

Donald McLaughlin 

Lexer for Desk Calculator
FALL 2023 PPL

Updated version for parser integration

*/


/* 
  CHANGELOG
-------------
* error handling via flag
* \n handling
* %nonunput
* yylval
* Return of tokens
* double values (dval) for numbers
* string values (sval) for ID

*/

%{
#include <stdio.h>
#include <stdlib.h>
#include "parser.tab.h"

/* Err handle for lexer */
void report_lexical_error(const char* detail);
/* Illegal char flag set to off */
/* flag used to prevent illegal token from triggering warning for each indiv character and handles line by line*/
int illegal_char_flag = 0;
%}

/* Used to silence warning with nounput*/
%option nounput

FLOAT [0-9]*\.?[0-9]+([eE][-+]?[0-9]+)? 
HEX 0[xX][0-9a-fA-F]+  
OCTAL 0[0-7]+
DECIMAL [1-9][0-9]*
/* Section 2 Rules */
%%

{OCTAL}            {yylval.dval = strtol(yytext, NULL, 8); return INT;}
{HEX}              {yylval.dval = strtol(yytext, NULL, 16); return INT;}
{DECIMAL}          {yylval.dval = strtol(yytext, NULL, 10); return INT;}
{FLOAT}            {yylval.dval = atof(yytext); return FLOAT; }

\+                 { return ADD;}
\-                 { return SUBTRACT; }
\*                 { return MULTIPLY; }
\/                 { return DIVIDE; }
\%                 { return MODULO; }
=                  { return EQUAL; }

[a-f]              { yylval.sval = strdup(yytext); return ID; }
\(                 { return OP; }
\)                 { return CP; }

\n                 {if(illegal_char_flag){
                      report_lexical_error("Illegal character encountered"); 
                      illegal_char_flag=0;
                    } 
                    return NEWLINE;} /* illegal character is detected set flag back to OFF and move to \n*/
[ \t]              { /* ignore whitespace */ }
.                  { illegal_char_flag=1; } /* Illegal token triggers flag to be turned on */


%%

/* Section 3 User Code */
int yywrap() {
  return 1;
}

void report_lexical_error(const char* detail){
  fprintf(stderr, "ERROR [Lexical error]: %s\n", detail);
}
