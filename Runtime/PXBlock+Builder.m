//
// PXBlock+Builder.m
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

#import "PXBlock+Builder.h"
#import "PXBlock+Bytecode.h"
#import "PXLexicon.h"

NS_INLINE NSString *PXIdentifierFromLexemedIdentifier(NSString *identifier)
{
    NSArray *lexemes = [PXLexicon lexemesProlixityIdentifier:identifier];
    NSArray *candidates = [[PXLexicon classLexicon] candidatesForLexemes:lexemes];
    
    NSString *result = nil;
    
    if ([candidates count] == 0) {
        result = identifier;
    }
    else {
        result = [candidates objectAtIndex:0];
    }
    
    if (!NSClassFromString(result)) {
        return [result lowercaseString];
    }
    
    return result;
}

@implementation PXBlock (Builder)
+ (PXBlock *)blockWithBlockAssembly:(NSString *)inAsm
{
    PXLexer *lexer = [[PXLexer alloc] initWithCString:[inAsm UTF8String]];    
    PXBlock *block = [[PXBlock alloc] init];
    
    [block parse:lexer];
    
    [lexer release];
    return [block autorelease];
}

- (void)parse:(PXLexer *)inLexer
{
    NSString *t = [inLexer peek];
    if (![t isEqualToString:@"block"]) {
        return;
    }

    [inLexer next];
    t = [inLexer next];
    if (!t) {
        return;
    }
    
    id tmp = name;
    name = [t copy];
    [tmp release];
    
    while ((t = [inLexer peek])) {
        if ([t isEqualToString:@"block"]) {
            PXBlock *newBlock = [[PXBlock alloc] init];
            [newBlock parse:inLexer];
            
            [variables setObject:newBlock forKey:newBlock.name];
            [newBlock release];
            continue;
        }

        [inLexer next];
        
        if ([t isEqualToString:@"end"]) {
            return;
        }
        
        if ([t isEqualToString:@"var"]) {
            [self declareVariable:[inLexer next]];
        }
        else if ([t isEqualToString:@"load"]) {
            [self addLoad:[inLexer next]];            
        }
        else if ([t isEqualToString:@"store"]) {
            [self addStore:[inLexer next]];
            
        }
        else if ([t isEqualToString:@"loadin"]) {
            NSString *numberText = [inLexer next];            
            NSNumber *number = nil;
            if ([numberText rangeOfString:@"."].location != NSNotFound) {
                number = [NSNumber numberWithDouble:[numberText doubleValue]];
            }
            else {
                number = [NSNumber numberWithInteger:[numberText integerValue]];
            }
            
            [self addLoadImmeidate:number];
        }
        else if ([t isEqualToString:@"loado_point"]) {
            CGFloat x = [[inLexer next] doubleValue];
            CGFloat y = [[inLexer next] doubleValue];
            
            [self addLoadImmeidate:[NSValue valueWithCGPoint:CGPointMake(x, y)]];

        }        
        else if ([t isEqualToString:@"loado_size"]) {
            CGFloat w = [[inLexer next] doubleValue];
            CGFloat h = [[inLexer next] doubleValue];
            
            [self addLoadImmeidate:[NSValue valueWithCGSize:CGSizeMake(w, h)]];            
        }        
        else if ([t isEqualToString:@"loado_range"]) {
            NSUInteger location = [[inLexer next] integerValue];
            NSUInteger length = [[inLexer next] integerValue];
            
            [self addLoadImmeidate:[NSValue valueWithRange:NSMakeRange(location, length)]];
            
        }        
        else if ([t isEqualToString:@"loado_rect"]) {
            CGFloat x1 = [[inLexer next] doubleValue];
            CGFloat y1 = [[inLexer next] doubleValue];
            CGFloat x2 = [[inLexer next] doubleValue];
            CGFloat y2 = [[inLexer next] doubleValue];
            
            [self addLoadImmeidate:[NSValue valueWithCGRect:CGRectMake(x1, y1, (fabs(x2 - x1) + 1), (fabs(y2 - y1) + 1))]];
            
        }
        else if ([t isEqualToString:@"loadis"]) {
            [self addLoadImmeidate:[inLexer next]];
            
        }
        else if ([t isEqualToString:@"push"]) {
            [self addPush];            
        }
        else if ([t isEqualToString:@"pop"]) {
            [self addPop];
        }
        else if ([t isEqualToString:@"invoke"]) {
            [self addInvoke:[inLexer next]];
        }
    }
}

- (void)declareVariable:(NSString *)inName
{    
    [variables setObject:[NSNull null] forKey:PXIdentifierFromLexemedIdentifier(inName)];
}

- (void)addLoadImmeidate:(id)inObject
{
    [instructions addObject:PXInstructionLoadImmediate];
    [instructions addObject:inObject];
}

- (void)addLoad:(NSString *)inName
{
    [instructions addObject:PXInstructionLoad];
    [instructions addObject:PXIdentifierFromLexemedIdentifier(inName)];
}

- (void)addStore:(NSString *)inName
{
    [instructions addObject:PXInstructionStore];
    [instructions addObject:PXIdentifierFromLexemedIdentifier(inName)];
}

- (void)addPush
{
    [instructions addObject:PXInstructionPush];
    [instructions addObject:[NSNull null]];    
}

- (void)addPop
{
    [instructions addObject:PXInstructionPop];
    [instructions addObject:[NSNull null]];
}

- (void)addInvoke:(NSString *)methodName
{
    NSArray *lexemes = [PXLexicon lexemesForProlixityMethodName:methodName];
    NSArray *candidates = [[PXLexicon methodLexicon] candidatesForLexemes:lexemes];
    
    [instructions addObject:PXInstructionInvoke];
    
    NSUInteger candidateCount = [candidates count];
    if (candidateCount == 0) {
        [instructions addObject:methodName];
    }
    else if (candidateCount == 1) {
        [instructions addObject:[candidates objectAtIndex:0]];
    }
    else {
        [instructions addObject:candidates];
    }
}
@end
