#include <iostream>
#include <cstdio>
#include <cstdlib>
#include "ParserBlock.h"
#include "lexer.h"
#include "parser.h"

extern void *ParseAlloc(void *(*mallocProc)(size_t));
extern void Parse(void *, int, std::string*, Prolixity::ParserBlock*);
extern void ParseTrace(FILE *TraceFILE, char *zTracePrompt);
void ParseFree(void *p, void (*freeProc)(void*));

int main()
{
    // yy_scan_string("z. y. a b c d\ne f g. h i j.\nk l m. n o\n\n\np q");
    // yy_scan_string("var a. on a, invoke b c d, taking (on x, invoke y, taking z)\n"); // , and f, taking g h i.

    #if DEBUG
    ParseTrace(stderr, "->");
    #endif

    Prolixity::ParserBlock *block = new Prolixity::ParserBlock;
    void *parser = ParseAlloc(malloc);
    int tokenType;
    
    while((tokenType = yylex()) != 0) {
        // tokenContent will be deleted by the parser
        std::string *tokenContent = (tokenType == TOKEN_STRING) ? new std::string(Prolixity::LexerGetStringToken()) : new std::string(yytext);
        #if DEBUG
        std::cout << "token: " << *tokenContent << "\n";
        #endif
        Parse(parser, tokenType, tokenContent, block);
    }
        
    Parse(parser, 0, NULL, block);
    
    std::cout << block->dump();
    delete block;
    
    ParseFree(parser, free);
    return 0;
}
