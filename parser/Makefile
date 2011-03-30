all: parser.cpp driver.cpp
	g++ -g -o pxcompile lexer.cpp parser.cpp driver.cpp -lstdc++

lemon: lemon.c
	gcc -o $@ $<

lexer.cpp: lexer.l parser.c
	flex -o lexer.cpp lexer.l

parser.c: lemon parser.y
	./lemon parser.y

parser.cpp: parser.c lexer.cpp
	mv parser.c parser.cpp

clean:
	rm -f lemon parser.h parser.cpp lexer.cpp pxcompile *.o *.out
