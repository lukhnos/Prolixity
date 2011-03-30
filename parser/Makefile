all: lexer.cpp driver.cpp
	g++ -g -o pxcompile lexer.cpp parser.cpp driver.cpp -lstdc++

lemon: lemon.c
	gcc -o $@ $<

lexer.cpp: lexer.l parser.cpp
	flex -o lexer.cpp lexer.l

parser.cpp: lemon parser.y
	./lemon parser.y
	mv parser.c parser.cpp

clean:
	rm -f lemon parser.h parser.cpp lexer.cpp pxcompile *.o *.out
