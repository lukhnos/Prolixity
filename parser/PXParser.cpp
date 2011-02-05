#include "PXParser.h"
#include "lexer.h"
#include "parser.h"
#include "ParserBlock.h"
#include <iostream>
#include <cstdio>
#include <cstdlib>

extern void *ParseAlloc(void *(*mallocProc)(size_t));
extern void Parse(void *, int, std::string*, Prolixity::ParserBlock*);
extern void ParseTrace(FILE *TraceFILE, char *zTracePrompt);
void ParseFree(void *p, void (*freeProc)(void*));

char *PXParserParseSource(const char *source, char **outError)
{
    if (!source) {
        if (outError) {
            // TODO: Handles error
        }
        return 0;
    }
    
    // TODO: Thread-safety
    
    yy_scan_string(source);

#if 0
    ParseTrace(stderr, (char*)"->");
#endif

    Prolixity::ParserBlock* blk = new Prolixity::ParserBlock;

    void *parser = ParseAlloc(malloc);
    int tokenType;
    
    while((tokenType = yylex()) != 0) {
        // tokenContent will be deleted by the parser
        std::string *tokenContent = (tokenType == TOKEN_STRING) ? new std::string(Prolixity::LexerGetStringToken()) : new std::string(yytext);
        Parse(parser, tokenType, tokenContent, blk);
    }
    
    Parse(parser, 0, NULL, blk);

    char *result = 0;
    if (0) {
        if (outError) {
            // TODO: Handles error
        }
        result = 0;
    }
    else {
        result = strdup(blk->dump().c_str());
    }
    
    delete blk;    
    ParseFree(parser, free);
    return result;    
}
