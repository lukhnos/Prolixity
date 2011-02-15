//
// PXLexicon.m
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

#import "PXLexicon.h"
#import <objc/runtime.h>

// assumes all elements are strings
static NSArray *PXStringCollectionProduct(id a, id b);
static NSArray *PXSplitObjectiveCName(NSString *name);

@interface PXLexiconNode : NSObject
{
    NSMutableSet *candidates;
    NSMutableDictionary *dictionary;
}
@property (readonly, nonatomic) NSMutableSet *candidates;
@property (readonly, nonatomic) NSMutableDictionary *dictionary;
@end


@implementation PXLexicon
- (id)init
{
    self = [super init];
    if (self) {
        root = [[PXLexiconNode alloc] init];
    }
    return self;
}
- (void)dealloc
{
    [root release];
    [super dealloc];
}

+ (PXLexicon *)currentLexicon
{
    static PXLexicon *instance = nil;
    
    @synchronized(self) {
        if (!instance) {
            instance = [[PXLexicon alloc] init];
        }
    }

    return instance;    
}

- (void)build:(NSArray *)lexemes
{
    @synchronized(self) {
        PXLexiconNode *current = root;
        
        for (NSString *lex in lexemes) {
            NSString *indexer = [lex lowercaseString];
            PXLexiconNode *next = [current.dictionary objectForKey:indexer];
            
            if (!next) {
                next = [[PXLexiconNode alloc] init];
                [current.dictionary setObject:next forKey:indexer];
                [next release];
            }
            
            [next.candidates addObject:lex];
            current = next;
        }
    }
}

- (NSArray *)candidatesForLexemes:(NSArray *)lexemes
{
    NSArray *results = [NSArray array];

    @synchronized(self) {        
        NSUInteger i;
        NSUInteger c = [lexemes count];
        PXLexiconNode *current = root;
        
        for (i = 0 ; i < c ; ++i) {
            NSString *lex = [[lexemes objectAtIndex:i] lowercaseString];
            PXLexiconNode *next = [current.dictionary objectForKey:lex];

            if (!next) {
                break;
            }
            else {
                id candidates = next.candidates;
                if (![candidates count]) {
                    candidates = [NSArray arrayWithObject:lex];
                }
                
                results = PXStringCollectionProduct(results, candidates);
                current = next;
            }
        }
        
        if (i < c) {
            NSString *remainder = [[lexemes subarrayWithRange:NSMakeRange(i, c - i)] componentsJoinedByString:@""];
            results = PXStringCollectionProduct(results, [NSArray arrayWithObject:remainder]);
        }
        
    }
    return results;
}
@end


@implementation PXLexicon (RuntimeSupport)
+ (PXLexicon *)classLexicon
{
    static PXLexicon *instance = nil;
    @synchronized(self) {
        if (!instance) {
            instance = [[PXLexicon alloc] init];
        }
    }
    return instance;
}

+ (PXLexicon *)methodLexicon
{
    static PXLexicon *instance = nil;
    @synchronized(self) {
        if (!instance) {
            instance = [[PXLexicon alloc] init];
        }
    }
    return instance;    
}

+ (void)addClass:(Class)cls
{
    NSString *className = NSStringFromClass(cls);
    [[self classLexicon] build:PXSplitObjectiveCName(className)];
    
    unsigned int numMethods = 0;
    Method *methods = class_copyMethodList(cls, &numMethods);
    for (unsigned int j = 0 ; j < numMethods ; j++) {
        Method method = methods[j];
        SEL selector = method_getName(method);
        
        NSString *methodName = NSStringFromSelector(selector);
        
        NSArray *splitM = [methodName componentsSeparatedByString:@":"];
        if ([splitM count] == 1) {
            [[self methodLexicon] build:PXSplitObjectiveCName(methodName)];
        }
        else {
            NSMutableArray *lexemes = [NSMutableArray array];

            for (NSString *m in splitM) {                
                if (![m length]) {
                    continue;
                }
            
                NSString *colonM = [m stringByAppendingString:@":"];
                [lexemes addObjectsFromArray:PXSplitObjectiveCName(colonM)];
            }
            [[self methodLexicon] build:lexemes];
        }
    }
    free(methods);
}
@end


@implementation PXLexiconNode
@synthesize candidates;
@synthesize dictionary;

- (id)init
{
    self = [super init];
    if (self) {
        candidates = [[NSMutableSet alloc] init];
        dictionary = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [candidates release];
    [dictionary release];
    [super dealloc];
}
@end


static NSArray *PXStringCollectionProduct(id a, id b)
{
    id c = [a count] ? a : [NSArray arrayWithObject:@""];
    id d = [b count] ? b : [NSArray arrayWithObject:@""];
    NSMutableArray *results = [NSMutableArray array];
    
    
    for (NSString *x in c) {
        for (NSString *y in d) {
            [results addObject:[x stringByAppendingString:y]];
        }
    }    
    
    return results;
}

static NSArray *PXSplitObjectiveCName(NSString *name)
{
    // this is an inefficient, surrogate-unsafe way of splitting a string
    BOOL lowerCaseState = YES;
    
    NSMutableArray *result = [NSMutableArray array];
    NSMutableString *currentTerm = [NSMutableString string];
    
    for (NSUInteger i = 0, len = [name length]; i < len; ++i) {
        UniChar c = [name characterAtIndex:i];
        if (islower(c) || !isalpha(c)) {
            if (lowerCaseState) {
                [currentTerm appendFormat:@"%C", c];
            }
            else {
                lowerCaseState = YES;
                if ([currentTerm length] > 1) {
                    [result addObject:[currentTerm substringToIndex:[currentTerm length] - 1]];
                    currentTerm = [NSMutableString stringWithFormat:@"%@%C", [currentTerm substringFromIndex:[currentTerm length] - 1], c];
                }
                else {
                    [currentTerm appendFormat:@"%C", c];
                }
            }
        }
        else {
            if (lowerCaseState) {
                if ([currentTerm length]) {
                    [result addObject:currentTerm];
                }
                currentTerm = [NSMutableString stringWithFormat:@"%C", c];
                lowerCaseState = NO;
            }
            else {
                [currentTerm appendFormat:@"%C", c];
            }
        }
    }
    if ([currentTerm length] > 0){
        [result addObject:currentTerm];
    }
    
    return result;
}
