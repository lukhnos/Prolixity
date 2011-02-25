//
// driver.cpp
//
// Copyright (c) 2011 Lukhnos D. Liu (http://lukhnos.org)
//
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
//

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
