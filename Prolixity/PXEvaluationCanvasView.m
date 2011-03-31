//
// EvaluationCanvasView.m
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

#import "PXEvaluationCanvasView.h"
#import "PXBlock.h"

@implementation PXEvaluationCanvasView
@synthesize block;
@synthesize textView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)dealloc
{
    [block release];
    [textView release];
    [super dealloc];
}

- (void)awakeFromNib
{
    self.textView.backgroundColor = [UIColor clearColor];
}

- (CGPoint)somePoint
{
    return somePoint;
}

- (void)setSomePoint:(CGPoint)p
{
    somePoint = p;
    
    [[UIColor redColor] setFill];
    [[UIBezierPath bezierPathWithOvalInRect:CGRectMake(p.x - 5.0, p.x - 5.0, 10.0, 10.0)] fill];
}

- (void)drawDot:(CGPoint)p
{
    [[UIColor redColor] setFill];
    [[UIBezierPath bezierPathWithOvalInRect:CGRectMake(p.x - 5.0, p.y - 5.0, 10.0, 10.0)] fill];    
}

- (void)drawRect:(CGRect)rect
{
    if (!self.block) {
        return;
    }

    // Drawing code
    @try {
        [self.block exportObject:self toVariable:@"canvas"];
        [self.block runWithParent:nil];
    }
    @catch (NSException *e) {
        [[[[UIAlertView alloc] initWithTitle:@"Exception" message:[e description] delegate:nil cancelButtonTitle:@"Continue" otherButtonTitles:nil] autorelease] show];
    }

    self.textView.text = [PXBlock currentConsoleBuffer];
}

@end
