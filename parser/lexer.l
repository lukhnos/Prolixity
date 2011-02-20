%{
//
// lexer.l
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
    
#include "parser.h"
#include "lexer.h"

namespace Prolixity {
    namespace {
        static std::string LexerStringToken;
    };

    const std::string LexerGetStringToken();
};
%}

%option yylineno

 /* defines a string-capturing mode */
%x STRMODE
%x IDMODE

 /* definitions */
DIGIT           [0-9]
IDENTIFEME      [A-Za-z_][0-9A-Za-z_]*
DOUBLEQUOTE	    \"
 /* this stops some editors from syntax highlighing from the last double quote " */
SPACE           (" "|\r|\t)
ELLIPSIS        \.\.\.
DOUBLEDASH      --
COMMA           ,
PERIOD          \.

%%

 /* double dash is treated as comment */
{DOUBLEDASH}.*\n
<IDMODE>{DOUBLEDASH}.*\n    { BEGIN(0); }

 /* double quote enters string mode */
{DOUBLEQUOTE} {
        Prolixity::LexerStringToken = "";
        BEGIN(STRMODE);
    }

<IDMODE>{DOUBLEQUOTE} {
        Prolixity::LexerStringToken = "";
        BEGIN(STRMODE);
    }

 /* string cannot end unclosed at end of line */
<STRMODE>\n {
        BEGIN(0);
        return TOKEN_ERROR;
    }

 /* string connot end unclosed at EOF */
<STRMODE><<EOF>> {
        BEGIN(0);
        return TOKEN_ERROR;
    }

 /* double quote in string mode ends the capturing */
<STRMODE>{DOUBLEQUOTE} {
        BEGIN(0);
        return TOKEN_STRING;
    }

 /* capture everything, including escape sequence e.g. "\n", as is */
<STRMODE>. {
        Prolixity::LexerStringToken += yytext;
    }

 /* keywords */
 /* note that the keyword "taking" does not starts IDMODE because in the grammar it follows an expression */
(?i:var)                { BEGIN(IDMODE); return TOKEN_VAR; }
(?i:set)                { return TOKEN_SET; }
(?i:save)
(?i:to)                 { BEGIN(IDMODE); return TOKEN_TO; }
(?i:on)                 { BEGIN(IDMODE); return TOKEN_ON; }
(?i:invoke)             { BEGIN(IDMODE); return TOKEN_INVOKE; }
(?i:taking)             { return TOKEN_TAKING; }
(?i:begin)              { return TOKEN_BEGIN; }
(?i:end)                { return TOKEN_END; }
(?i:and)                { BEGIN(IDMODE); return TOKEN_AND; }

(?i:point)              { return TOKEN_POINT; }
(?i:rectangle)          { return TOKEN_RECT; }
(?i:rect)               { return TOKEN_RECT; }
(?i:size)               { return TOKEN_SIZE; }
(?i:range)              { return TOKEN_RANGE; }

 /*
(?i:color)
(?i:alpha)
(?i:true)
(?i:false)
(?i:self)
 */

 /* symbols; $ is an override symbol that starts IDMODE */
 /* this makes this snippet possible: var set union. on a, invoke b, taking $ set union */
"("                     { return TOKEN_LEFT_PAREN; }
")"                     { return TOKEN_RIGHT_PAREN; }
<IDMODE>")"             { BEGIN(0); return TOKEN_RIGHT_PAREN; }
"$"                     { BEGIN(IDMODE); }
<IDMODE>"$"
{COMMA}                 { return TOKEN_COMMA; }
<IDMODE>{COMMA}         { BEGIN(0); return TOKEN_COMMA; }
{PERIOD}                { return TOKEN_PERIOD; }
<IDMODE>{PERIOD}        { BEGIN(0); return TOKEN_PERIOD; }
{DIGIT}+(\.{DIGIT}+)?   { return TOKEN_NUMBER; }
<IDMODE>{DIGIT}+(\.{DIGIT}+)?   { BEGIN(0); return TOKEN_NUMBER; }
{IDENTIFEME}            { BEGIN(IDMODE); return TOKEN_IDENTIFEME; }
<IDMODE>{IDENTIFEME}    { return TOKEN_IDENTIFEME; }
{ELLIPSIS}              { return TOKEN_ELLIPSIS; }
<IDMODE>{ELLIPSIS}      { BEGIN(0); return TOKEN_ELLIPSIS; }

 /* skip space and CR */
{SPACE}
<IDMODE>{SPACE}

 /*LF is treated as a meaningful token in the grammar */
\n                      { return TOKEN_LF; }
<IDMODE>\n              { BEGIN(0); return TOKEN_LF; }

 /* everything else returns an error */
.			            { return TOKEN_ERROR; }
<IDMODE>.               { return TOKEN_ERROR; }

%%

int yywrap()
{
    return 1;
}

namespace Prolixity {
    const std::string LexerGetStringToken()
    {
        return LexerStringToken;
    }
}
