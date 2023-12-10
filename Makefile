CC=gcc
CFLAGS=-Wall -lm

calc: lex.yy.c parser.tab.c
	$(CC) -o calc lex.yy.c parser.tab.c $(CFLAGS) -w 

lex.yy.c: scanner.l
	flex scanner.l

parser.tab.c: parser.y
	bison -d parser.y 

clean:
	rm -f calc lex.yy.c parser.tab.c parser.tab.h

