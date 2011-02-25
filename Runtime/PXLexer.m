//
// PXLexer.m
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

#import "PXLexer.h"

@implementation PXLexer
- (void)dealloc
{
    [nextToken release], nextToken = nil;
    [super dealloc];
}

- (id)initWithCString:(const char *)inString
{
    self = [super init];
    if (self) {
        str = inString;
        pos = str;
    }
    return self;
}

- (NSString *)peek
{
    if (nextToken) {
        return nextToken;
    }
    
    if (!*pos) {
        return nil;
    }
    
    #define ISWHITESPACE(x) (x == ' ' || x == '\t' || x == '\n' || x == '\r')
    
    char c;
    while ((c = *pos)) {
        if (!ISWHITESPACE(c)) {
            break;
        }
        ++pos;
    }
    
    if (!*pos) {
        return nil;
    }

    BOOL stringMode = NO;
    
    if (*pos == '\"') {
        ++pos;
        stringMode = YES;
    }

    const char *start = pos;
    while ((c = *pos)) {
        if ((stringMode && c == '\"') || (!stringMode && ISWHITESPACE(c))) {
            break;
        }
        ++pos;
    }
    
    
    nextToken = [[NSString alloc] initWithBytes:start length:(NSUInteger)(pos - start) encoding:NSUTF8StringEncoding];

    if (*pos == '\"') {
        ++pos;
        
        // TODO: Handle string escape
    }

    return nextToken;
}

- (NSString *)next
{
    if (!nextToken) {
        [self peek];
    }
        
    NSString *result = [nextToken autorelease];
    nextToken = nil;
    return result;
}
@end
