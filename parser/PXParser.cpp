//
// PXParser.cpp
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

#include "PXParser.h"
#include "lexer.h"
#include "parser.h"
#include "ParserBlock.h"
#include <iostream>
#include <cstdio>
#include <cstdlib>

#ifndef PX_PARSER_TRACE
#define PX_PARSER_TRACE 1
#endif

extern void *ParseAlloc(void *(*mallocProc)(size_t));
extern void Parse(void *, int, std::string*, Prolixity::ParserBlock*);
extern void ParseTrace(FILE *TraceFILE, char *zTracePrompt);
void ParseFree(void *p, void (*freeProc)(void*));

char *PXParserParseSource(const char *source, char **outError)
{
    if (!source) {
        if (outError) {
            *outError = strdup("No source code is given.");
        }
        return 0;
    }
    
    // TODO: If we continue using Lex, we want to make pthread library calls to ensure thread-safety
    
    yy_scan_string(source);

#if PX_PARSER_TRACE
    ParseTrace(stderr, (char*)"->");
#endif

    Prolixity::ParserBlock* blk = new Prolixity::ParserBlock;

    void *parser = ParseAlloc(malloc);
    int tokenType;
    
    while((tokenType = yylex()) != 0) {
        // tokenContent will be deleted by the parser
        std::string *tokenContent = (tokenType == TOKEN_STRING) ? new std::string(Prolixity::LexerGetStringToken()) : new std::string(yytext);
        Parse(parser, tokenType, tokenContent, blk);

#if PX_PARSER_TRACE
        std::cerr << "line no: " << yylineno << ", token: " << (yytext ? yytext : "") << ", length: " << yyleng << std::endl;
#endif        
    }
    
    Parse(parser, 0, NULL, blk);

    char *result = 0;

    std::string lastError = blk->getLastError();
    if (lastError.length()) {
        if (outError) {
            *outError = strdup(lastError.c_str());
        }
    }
    else {
        result = strdup(blk->dump().c_str());
    }
    
    delete blk;    
    ParseFree(parser, free);
    return result;    
}
