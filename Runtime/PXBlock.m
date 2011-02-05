//
// PXBlock.m
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

#import "PXBlock.h"
#import "PXParser.h"
#import <objc/runtime.h>

@interface PXLexer : NSObject
{
    const char *str;
    const char *pos;
    
    NSString *nextToken;
}
- (id)initWithCString:(const char *)inString;
- (NSString *)peek;
- (NSString *)next;
@end

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


@interface PXBlock ()
- (void)parse:(PXLexer *)inLexer;

+ (PXBlock *)currentBlock;
+ (void)setCurrentBlock:(PXBlock *)inBlock;
- (void)push:(id)inObject;
- (id)pop;
- (id)loadFromVariable:(NSString *)inName;
- (void)storeValue:(id)inValue toVariable:(NSString *)inName;
- (void)invokeMethod:(SEL)inSelector;
@end



@implementation NSObject (PXSupport)
- (void)dump
{
    NSLog(@"%@", self);
}
@end

@implementation NSNumber (PXSupport)
- (NSNumber *)plus:(NSNumber *)inNumber
{
    const char *aType = [self objCType];
    const char *bType = [inNumber objCType];
    
    if (!strcmp(aType, "d") || !strcmp(bType, "d")) {
        return [NSNumber numberWithDouble:[self doubleValue] + [inNumber doubleValue]];
    }
    else if (!strcmp(aType, "f") || !strcmp(bType, "f")) {
        return [NSNumber numberWithFloat:[self floatValue] + [inNumber floatValue]];
    }
    else {
        // TODO: Expand type support
        return [NSNumber numberWithInteger:[self integerValue] + [inNumber integerValue]];
    }
}

- (NSNumber *)gt:(NSNumber *)inNumber
{
    return ([self compare:inNumber] == NSOrderedDescending) ? (id)kCFBooleanTrue : (id)kCFBooleanFalse;
}

- (NSNumber *)lt:(NSNumber *)inNumber
{
    return ([self compare:inNumber] == NSOrderedAscending) ? (id)kCFBooleanTrue : (id)kCFBooleanFalse;
}


- (id)ifTrue:(PXBlock *)inBlock
{
    if ([self boolValue]) {
        PXBlock *currentBlock = [PXBlock currentBlock];
        [inBlock runWithParent:currentBlock];
        return (id)kCFBooleanTrue;
    }
    return (id)kCFBooleanFalse;
}

- (id)ifFalse:(PXBlock *)inBlock
{
    if ([self boolValue]) {
        return (id)kCFBooleanTrue;
    }

    PXBlock *currentBlock = [PXBlock currentBlock];
    [inBlock runWithParent:currentBlock];
    return (id)kCFBooleanFalse;
}
@end


static NSString *const PXCurrentBlockInThreadKey = @"PXCurrentBlockInThreadKey";
static NSString *const PXInstructionLoadImmediate = @"loadi";
static NSString *const PXInstructionLoad = @"load";
static NSString *const PXInstructionStore = @"save";
static NSString *const PXInstructionInvoke = @"invoke";
static NSString *const PXInstructionPop = @"pop";
static NSString *const PXInstructionPush = @"push";

static const size_t kObjCMaXTypeLength = 256;

@implementation PXBlock
- (void)dealloc
{
    parent = nil;
    [tempValue release], tempValue = nil;
    [stack release], stack = nil;
    [variables release], variables = nil;
    [instructions release], instructions = nil;
    [super dealloc];
}

+ (PXBlock *)blockWithSource:(NSString *)inSource
{
    const char *u8str = [inSource UTF8String];
    char *error = NULL;
    char *parsed = PXParserParseSource(u8str, &error);
 
    if (error || !parsed) {
        // TODO: Handles error
        free(error);
        free(parsed);
        return nil;
    }

    NSString *data = [[[NSString alloc] initWithBytesNoCopy:parsed length:strlen(parsed) encoding:NSUTF8StringEncoding freeWhenDone:YES] autorelease];
    NSLog(@"parsed block assembly: %@", data);
    return [self blockWithBlockAssembly:data];
}

+ (PXBlock *)blockWithBlockAssembly:(NSString *)inAsm
{
    PXLexer *lexer = [[PXLexer alloc] initWithCString:[inAsm UTF8String]];    
    PXBlock *block = [[PXBlock alloc] init];
    
    [block parse:lexer];
    
    [lexer release];
    return [block autorelease];
}

- (id)init
{
    self = [super init];
    if (self) {
        stack = [[NSMutableArray alloc] init];
        variables = [[NSMutableDictionary alloc] init];
        instructions = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)runWithParent:(PXBlock *)inParent
{
    NSAssert(parent == nil, @"Parent must not be set before running.");
    parent = inParent;
    
    PXBlock *previousCurrentBlock = [[self class] currentBlock];
    [[self class] setCurrentBlock:self];
    
    NSEnumerator *ienum = [instructions objectEnumerator];    
    NSString *instruction = nil;
    while ((instruction = [ienum nextObject])) {
        id object = [ienum nextObject];
        NSAssert(object != nil, @"object cannot be nil");
        
        if (instruction == PXInstructionLoadImmediate) {
            id tmp = tempValue;
            tempValue = [object retain];
            [tmp release];
        }
        else if (instruction == PXInstructionLoad) {
            id tmp = tempValue;
            tempValue = [[self loadFromVariable:object] retain];
            [tmp release];
        }
        else if (instruction == PXInstructionStore) {
            [self storeValue:tempValue toVariable:object];
        }
        else if (instruction == PXInstructionPop) {
            id tmp = tempValue;
            tempValue = [[self pop] retain];
            [tmp release];
        }
        else if (instruction == PXInstructionPush) {
            [self push:tempValue];
        }
        else if (instruction == PXInstructionInvoke) {
            [self invokeMethod:NSSelectorFromString(object)];
        }
    }
        
    [[self class] setCurrentBlock:previousCurrentBlock];    
    parent = nil;

    return tempValue;
}

- (void)declareVariable:(NSString *)inName
{
    [variables setObject:[NSNull null] forKey:inName];
}

- (void)addLoadImmeidate:(id)inObject
{
    [instructions addObject:PXInstructionLoadImmediate];
    [instructions addObject:inObject];
}

- (void)addLoad:(NSString *)inName
{
    [instructions addObject:PXInstructionLoad];
    [instructions addObject:inName];    
}

- (void)addStore:(NSString *)inName
{
    [instructions addObject:PXInstructionStore];
    [instructions addObject:inName];
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

- (void)addInvoke:(SEL)inSelector
{
    [instructions addObject:PXInstructionInvoke];
    [instructions addObject:NSStringFromSelector(inSelector)];
}

#pragma Private methods

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
            [self addLoadImmeidate:[NSNumber numberWithInteger:[[inLexer next] integerValue]]];
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
            [self addInvoke:NSSelectorFromString([inLexer next])];
        }
    }
}

+ (PXBlock *)currentBlock
{
    return [[[NSThread currentThread] threadDictionary] objectForKey:PXCurrentBlockInThreadKey];
}

+ (void)setCurrentBlock:(PXBlock *)inBlock
{
    [[[NSThread currentThread] threadDictionary] setValue:inBlock forKey:PXCurrentBlockInThreadKey];
}

- (void)push:(id)inObject
{
    [stack addObject:inObject];
}

- (id)pop
{
    NSAssert([stack count] > 0, @"Stack cannot be empty when being popped.");
    id result = [[[stack lastObject] retain] autorelease];
    [stack removeLastObject];
    return result;
}

- (id)loadFromVariable:(NSString *)inName
{
    id object = [variables objectForKey:inName];
    if (object) {
        return object;
    }
    else {
        if (parent) {
            return [parent loadFromVariable:inName];
        }
        else {
            NSAssert(0, @"Cannot find the variable");
        }
    }

    return nil;
}

- (void)storeValue:(id)inValue toVariable:(NSString *)inName
{
    if ([variables objectForKey:inName]) {
        [variables setObject:inValue forKey:inName];
    }
    else {
        if (parent) {
            [parent storeValue:inValue toVariable:inName];
        }
        else {
            NSAssert(0, @"Cannot find the variable");            
        }
    }
}

- (id)whileTrue:(PXBlock *)inBlock
{
    PXBlock *currentBlock = [PXBlock currentBlock];
    
    id evalResult = nil;
    id result;
    
    while ((result = [self runWithParent:currentBlock]) == (id)kCFBooleanTrue) {
        evalResult = [inBlock runWithParent:currentBlock];
    }
    
    return evalResult;
}

- (void)invokeMethod:(SEL)inSelector
{
    NSObject *object = (tempValue == [NSNull null] ? nil : tempValue);
    NSMethodSignature *methodSignature = [object methodSignatureForSelector:inSelector];
    NSAssert(methodSignature != nil, @"Object must respond to selector");
    
    if (inSelector == @selector(alloc)) {
        id tmp = tempValue;
        tempValue = [[object alloc] retain];
        [tmp release];
        return;
    }
    
    if (inSelector == @selector(class)) {
        id tmp = tempValue;
        tempValue = (id)[NSString class];
        [tmp release];                
        return;
    }
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    [invocation setTarget:object];
    [invocation setSelector:inSelector];
    
    NSUInteger argumentCount = [methodSignature numberOfArguments];
    for (NSUInteger argi = 2 ; argi < argumentCount ; ++argi) {
        const char *argType = [methodSignature getArgumentTypeAtIndex:argi];
        if (!strcmp(argType, @encode(id))) {
            id arg = [self pop];
            [invocation setArgument:&arg atIndex:argi];
        }
        else {
            NSAssert(NO, @"Return type not supported");
        }
    }
         
    [invocation retainArguments];
    [invocation invoke];
    
    const char *returnValueType = [methodSignature methodReturnType];
    
    if (!strcmp(returnValueType, @encode(void))) {
        id tmp = tempValue;
        tempValue = [NSNull null];
        [tmp release];
    }
    else if (!strcmp(returnValueType, @encode(id)) || !strcmp(returnValueType, @encode(Class))) {
        id returnValue = nil;
        [invocation getReturnValue:&returnValue];
        
        id tmp = tempValue;
        tempValue = [(returnValue ? returnValue : [NSNull null]) retain];
        [tmp release];
    }
    else {
        NSAssert(NO, @"Return type not supported");
    }    
}

@synthesize name;
@end


@interface PXLexemeBuilder ()
+ (NSArray *)splitObjectiveCName:(NSString *)inName;
- (void)addSynonyms:(NSArray *)inOriginalTerms;
@end


@implementation PXLexemeBuilder
- (id)init {
    self = [super init];
    if (self) {
        synonymMap = [[NSMutableDictionary alloc] init];
        directTermMap = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [synonymMap release], synonymMap = nil;
    [directTermMap release], directTermMap = nil;
    [super dealloc];
}

- (void)addSynonym:(NSString *)inSynonym forTerm:(NSString *)inTerm
{
    NSString *lowerCasedKey = [inTerm lowercaseString];
    NSMutableSet *synonyms = [synonymMap objectForKey:lowerCasedKey];
    if (!synonyms) {
        synonyms = [NSMutableSet set];
        [synonymMap setObject:synonyms forKey:lowerCasedKey];
    }

    [synonyms addObject:inSynonym];
}

- (void)addObjectiveCMethod:(SEL)inSelector
{
    // ignores the case where e.g. @selector(::::) or @selector(a:b:::) is also possible
    
    NSString *methodName = [NSString stringWithUTF8String:sel_getName(inSelector)];
    NSArray *components = [methodName componentsSeparatedByString:@":"];
    if ([components count] >= 1) {
        components = [components subarrayWithRange:NSMakeRange(0, [components count] - 1)];
    }
    
    for (NSString *c in components) {
        [self addSynonyms:[[self class] splitObjectiveCName:c]];
    }    
}

- (void)addObjectiveCClass:(Class)inClass
{
    [self addSynonyms:[[self class] splitObjectiveCName:NSStringFromClass(inClass)]];
    
    unsigned int numMethods = 0;
    Method *methods = class_copyMethodList(inClass, &numMethods);
    for (unsigned int j = 0 ; j < numMethods ; j++) {
        Method method = methods[j];
        SEL selector = method_getName(method);
        [self addSynonyms:[[self class] splitObjectiveCName:NSStringFromSelector(selector)]];        
    }
    free(methods);    
}

- (NSSet *)synonymsForTerm:(NSString *)inTerm
{
    NSSet *result = [synonymMap objectForKey:[inTerm lowercaseString]];
    return result ? result : [NSSet setWithObject:inTerm];
}

- (NSArray *)candidateLexemesFromParts:(NSArray *)inParts
{
    // this definitely needs some help from n-gram model and Viterbi algorithm...
    NSMutableArray *result = [NSMutableArray arrayWithObject:@""];

    for (NSString *p in inParts) {
        NSSet *synonyms = [self synonymsForTerm:p];
        NSMutableArray *newResult = [NSMutableArray array];
        for (NSString *r in result) {
            for (NSString *s in synonyms) {
                [newResult addObject:[r stringByAppendingString:s]];
            }
        }
        result = newResult;
    }    
    
    return result;
}

- (void)addSynonyms:(NSArray *)inOriginalTerms
{
    for (NSString *t in inOriginalTerms) {
        [self addSynonym:t forTerm:t];
    }
    
    if ([inOriginalTerms count] > 1) {
        NSString *combined = [inOriginalTerms componentsJoinedByString:@""];
        [self addSynonym:combined forTerm:combined];
    }
}

+ (NSArray *)splitObjectiveCName:(NSString *)inName
{
    // this is an inefficient, surrogate-unsafe way of splitting a string
    BOOL lowerCaseState = YES;
    
    NSMutableArray *result = [NSMutableArray array];
    NSMutableString *currentTerm = [NSMutableString string];
    
    for (NSUInteger i = 0, len = [inName length]; i < len; ++i) {
        UniChar c = [inName characterAtIndex:i];
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
@end