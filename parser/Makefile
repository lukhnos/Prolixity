all: lexer.cpp parser.cpp driver.cpp
	g++ -g -o pxcompile lexer.cpp parser.cpp driver.cpp -lstdc++

lexer.cpp: lexer.l parser.cpp
	flex -o lexer.cpp lexer.l

parser.cpp: parser.y
	./lemon parser.y
	mv parser.c parser.cpp

clean:
	rm -f parser.h parser.cpp lexer.cpp pxcompile *.o *.out
