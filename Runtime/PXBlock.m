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
#import "PXBlock+Builder.h"
#import "PXBlock+Bytecode.h"
#import "PXParser.h"
#import "PXLexicon.h"
#import "PXUtilities.h"
#import <objc/runtime.h>

NSString *const PXBlockErrorDomain = @"org.lukhnos.Prolixity.PXBlock";

static const size_t kObjCMaXTypeLength = 256;

static NSString *const PXCurrentBlockInThreadKey = @"PXCurrentBlockInThreadKey";
static NSString *const PXCurrentConsoleBufferInThreadKey = @"PXCurrentConsoleBufferInThreadKey";

@interface PXBlock (Runtime)
+ (void)setCurrentBlock:(PXBlock *)inBlock;
- (void)push:(id)inObject;
- (id)pop;
- (id)loadFromVariable:(NSString *)inName;
- (void)storeValue:(id)inValue toVariable:(NSString *)inName;
- (void)invokeMethod:(id)methodNameCandidates;
@end


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

+ (PXBlock *)blockWithSource:(NSString *)inSource error:(NSError **)outError
{
    const char *u8str = [inSource UTF8String];
    char *error = NULL;
    char *parsed = PXParserParseSource(u8str, &error);
 
    if (error || !parsed) {
        // TODO: Handles error
        
        if (outError) {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:(error ? [NSString stringWithUTF8String:error] : PXLSTR(@"Unknown error.")), NSLocalizedDescriptionKey, nil];
            *outError = [[[NSError alloc] initWithDomain:PXBlockErrorDomain code:PXBlockParserError userInfo:userInfo] autorelease];
        }
        
        free(error);
        free(parsed);
        return nil;
    }

    NSString *data = [[[NSString alloc] initWithBytesNoCopy:parsed length:strlen(parsed) encoding:NSUTF8StringEncoding freeWhenDone:YES] autorelease];
    return [self blockWithBlockAssembly:data];
}

+ (PXBlock *)currentBlock
{
    return [[[NSThread currentThread] threadDictionary] objectForKey:PXCurrentBlockInThreadKey];
}

+ (NSMutableString *)currentConsoleBuffer
{
    NSMutableString *consoleBuffer = [[[NSThread currentThread] threadDictionary] objectForKey:PXCurrentConsoleBufferInThreadKey];
    if (!consoleBuffer) {
        consoleBuffer = [NSMutableString string];
        [[[NSThread currentThread] threadDictionary] setValue:consoleBuffer forKey:PXCurrentConsoleBufferInThreadKey];
    }
    
    return consoleBuffer;
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
    
    @try {
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
                [self invokeMethod:object];
            }
        }
    }
    @catch (NSException *exception) {
        @throw exception;
    }
    @finally {
        [[self class] setCurrentBlock:previousCurrentBlock];    
        parent = nil;
    }

    return tempValue;
}

- (void)exportObject:(id)object toVariable:(id)varName
{
    [variables setObject:object forKey:varName];
}
@synthesize name;
@end


@implementation PXBlock (Runtime)
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
            // see if it's a class object
            Class cls = NSClassFromString(inName);
            if (cls) {
                return cls;
            }

            NSAssert1(0, @"Cannot find the variable: %@", inName);
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
            NSAssert1(0, @"Cannot find the variable: %@", inName);            
        }
    }
}

- (void)invokeMethod:(id)methodNameCandidates
{
    NSObject *object = (tempValue == [NSNull null] ? nil : tempValue);

    SEL selector = NULL;
    
    if ([methodNameCandidates isKindOfClass:[NSString class]]) {
        selector = NSSelectorFromString(methodNameCandidates);
    }
    else {
        for (NSString *c in methodNameCandidates) {
            SEL s = NSSelectorFromString(c);
            if ([object respondsToSelector:s]) {
                selector = s;
                break;
            }
        }
    }    
    NSAssert1(selector != NULL, @"Object must respond to one of the selectors: %@", methodNameCandidates);
    
    NSMethodSignature *methodSignature = [object methodSignatureForSelector:selector];
    NSAssert1(methodSignature != nil, @"Object must respond to selector: %@", NSStringFromSelector(selector));
    
    if (selector == @selector(alloc)) {
        id tmp = tempValue;
        tempValue = [[(Class)object alloc] retain];
        [tmp release];
        return;
    }
    
    if (selector == @selector(class)) {
        id tmp = tempValue;
        tempValue = (id)[NSString class];
        [tmp release];                
        return;
    }
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    [invocation setTarget:object];
    [invocation setSelector:selector];
    
    NSUInteger argumentCount = [methodSignature numberOfArguments];
    for (NSUInteger argi = 2 ; argi < argumentCount ; ++argi) {
        const char *argType = [methodSignature getArgumentTypeAtIndex:argi];
        if (!strcmp(argType, @encode(id))) {
            id arg = [self pop];
            [invocation setArgument:&arg atIndex:argi];
        }
        else if (!strcmp(argType, @encode(NSUInteger))) {
            NSUInteger arg = [[self pop] unsignedIntegerValue];
            [invocation setArgument:&arg atIndex:argi];
        }
        else if (!strcmp(argType, @encode(NSInteger))) {
            NSUInteger arg = [[self pop] integerValue];
            [invocation setArgument:&arg atIndex:argi];
        }
        else if (!strcmp(argType, @encode(CGPoint))) {
            NSValue *arg = [self pop];
            CGPoint p = CGPointMake(0.0, 0.0);
            if (!strcmp([arg objCType], @encode(CGPoint))) {
                [arg getValue:&p];                
            }
            else {
                NSAssert2(NO, @"Invalid argument type, expected: %s, actual: %@", argType, arg);
            }
            [invocation setArgument:&p atIndex:argi];
        }
        else if (!strcmp(argType, @encode(CGRect))) {
            NSValue *arg = [self pop];
            CGRect r = CGRectMake(0.0, 0.0, 0.0, 0.0);
            if (!strcmp([arg objCType], @encode(CGRect))) {
                [arg getValue:&r];                
            }
            else {
                NSAssert2(NO, @"Invalid argument type, expected: %s, actual: %@", argType, arg);
            }
            [invocation setArgument:&r atIndex:argi];
        }
        else {
            NSAssert1(NO, @"Argument type not supported: %s", argType);
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
    else if (!strcmp(returnValueType, @encode(CGPoint))) {
        CGPoint p = CGPointMake(0.0, 0.0);
        [invocation getReturnValue:&p];
        id tmp = tempValue;
        tempValue = [[NSValue valueWithCGPoint:p] retain];
        [tmp release];
    }
    else if (!strcmp(returnValueType, @encode(NSUInteger))) {
        NSUInteger i = 0;
        [invocation getReturnValue:&i];        
        PXRetainAssign(tempValue, [NSNumber numberWithUnsignedInteger:i]);
    }
    else if (!strcmp(returnValueType, @encode(NSInteger))) {
        NSUInteger i = 0;
        [invocation getReturnValue:&i];        
        PXRetainAssign(tempValue, [NSNumber numberWithInteger:i]);
    }
    else if (!strcmp(returnValueType, @encode(id)) || !strcmp(returnValueType, @encode(Class))) {
        id returnValue = nil;
        [invocation getReturnValue:&returnValue];
        
        id tmp = tempValue;
        tempValue = [(returnValue ? returnValue : [NSNull null]) retain];
        [tmp release];
    }
    else {
        NSAssert1(NO, @"Return type not supported: %s", returnValueType);
    }    
}
@end
