//
// NSNumber+PXSupport.m
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

#import "NSNumber+PXSupport.h"
#import "PXBlock.h"

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

- (NSNumber *)minus:(NSNumber *)inNumber
{
    const char *aType = [self objCType];
    const char *bType = [inNumber objCType];
    
    if (!strcmp(aType, "d") || !strcmp(bType, "d")) {
        return [NSNumber numberWithDouble:[self doubleValue] - [inNumber doubleValue]];
    }
    else if (!strcmp(aType, "f") || !strcmp(bType, "f")) {
        return [NSNumber numberWithFloat:[self floatValue] - [inNumber floatValue]];
    }
    else {
        // TODO: Expand type support
        return [NSNumber numberWithInteger:[self integerValue] - [inNumber integerValue]];
    }
}


- (NSNumber *)mul:(NSNumber *)inNumber
{
    const char *aType = [self objCType];
    const char *bType = [inNumber objCType];
    
    if (!strcmp(aType, "d") || !strcmp(bType, "d")) {
        return [NSNumber numberWithDouble:[self doubleValue] * [inNumber doubleValue]];
    }
    else if (!strcmp(aType, "f") || !strcmp(bType, "f")) {
        return [NSNumber numberWithFloat:[self floatValue] * [inNumber floatValue]];
    }
    else {
        // TODO: Expand type support
        return [NSNumber numberWithInteger:[self integerValue] * [inNumber integerValue]];
    }
}

- (NSNumber *)div:(NSNumber *)inNumber
{
    const char *aType = [self objCType];
    const char *bType = [inNumber objCType];
    
    if (!strcmp(aType, "d") || !strcmp(bType, "d")) {
        return [NSNumber numberWithDouble:[self doubleValue] / [inNumber doubleValue]];
    }
    else if (!strcmp(aType, "f") || !strcmp(bType, "f")) {
        return [NSNumber numberWithFloat:[self floatValue] / [inNumber floatValue]];
    }
    else {
        // TODO: Expand type support
        return [NSNumber numberWithInteger:[self integerValue] / [inNumber integerValue]];
    }
}
- (NSNumber *)gt:(NSNumber *)inNumber
{
    return ([self compare:inNumber] == NSOrderedDescending) ? (id)kCFBooleanTrue : (id)kCFBooleanFalse;
}

- (NSNumber *)ge:(NSNumber *)inNumber
{
    return ([self compare:inNumber] != NSOrderedAscending) ? (id)kCFBooleanTrue : (id)kCFBooleanFalse;
}

- (NSNumber *)lt:(NSNumber *)inNumber
{
    return ([self compare:inNumber] == NSOrderedAscending) ? (id)kCFBooleanTrue : (id)kCFBooleanFalse;
}

- (NSNumber *)le:(NSNumber *)inNumber
{
    return ([self compare:inNumber] != NSOrderedDescending) ? (id)kCFBooleanTrue : (id)kCFBooleanFalse;
}

- (NSNumber *)negate
{
    return [NSNumber numberWithBool:![self boolValue]];
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
