%{
#include <stdio.h>
#include <stdlib.h>
#include "parser.tab.h"
%}

FLOAT [0-9]*\.?[0-9]+([eE][-+]?[0-9]+)? 
HEX 0[xX][0-9a-fA-F]+  
OCTAL 0[0-7]+
DECIMAL [1-9][0-9]*
/* Section 2 Rules */
%%

{OCTAL}            {yylval.ival = strtol(yytext, NULL, 8); return INT;}
{HEX}              {yylval.ival = strtol(yytext, NULL, 16); return INT;}
{DECIMAL}          {yylval.ival = strtol(yytext, NULL, 10); return INT;}
{FLOAT}            {yylval.dval = atof(yytext); return FLOAT; }

\+                 { return ADD;}
\-                 { return SUBTRACT; }
\*                 { return MULTIPLY; }
\/                 { return DIVIDE; }
\%                 { return MODULO; }
=                  { return EQUAL; }

[a-f]              { printf("ID\n"); }
\(                 { return LPAREN; }
\)                 { return RPAREN; }

\n                 { return NEWLINE;}
[ \t]            { /* ignore whitespace */ }
.                  { printf("Unknown character\n"); }

%%

/* Section 3 User Code */
int yywrap() {
  return 1;
}
