//
// NSValue+PXSupport.m
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

#import "NSValue+PXSupport.h"

@implementation NSValue (PXSupport)
+ (NSValue *)valueWithCGPointNumberX:(NSNumber *)x numberY:(NSNumber *)y
{
    return [NSValue valueWithCGPoint:CGPointMake([x doubleValue], [y doubleValue])];
}

+ (NSValue *)valueWithCGSizeNumberWidth:(NSNumber *)width numberHeight:(NSNumber *)height
{
    return [NSValue valueWithCGSize:CGSizeMake([width doubleValue], [height doubleValue])];
}

+ (NSValue *)valueWithNSRangeNumberLocation:(NSNumber *)location numberLength:(NSNumber *)length
{
    return [NSValue valueWithRange:NSMakeRange([location integerValue], [length integerValue])];
}

+ (NSValue *)valueWithCGRectValueCGPoint:(NSValue *)pointValue valueCGSize:(NSValue *)sizeValue
{
    CGRect rect;
    rect.origin = [pointValue CGPointValue];
    rect.size = [sizeValue CGSizeValue];
    return [NSValue valueWithCGRect:rect];
}

+ (NSValue *)valueWithCGRectNumberX1:(NSNumber *)x1 numberY1:(NSNumber *)y1 numberX2:(NSNumber *)x2 numberY2:(NSNumber *)y2
{
    double dx1 = [x1 doubleValue];
    double dy1 = [y1 doubleValue];
    double dx2 = [x2 doubleValue];
    double dy2 = [y2 doubleValue];
    return [NSValue valueWithCGRect:CGRectMake(dx1, dy1, (fabs(dx2 - dx1) + 1), (fabs(dy2 - dy1) + 1))];
}
@end
