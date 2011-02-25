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
@synthesize source;
@synthesize textView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
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

- (void)drawRect:(CGRect)rect
{
    if (![source length]) {
        return;
    }

    // Drawing code
    
    PXBlock *b = [PXBlock blockWithSource:source];
    if (b) {
        [b exportObject:[NSArray class] toVariable:@"NSArray"];
        [b exportObject:[NSMutableArray class] toVariable:@"NSMutableArray"];
        [b exportObject:[NSDictionary class] toVariable:@"NSDictionary"];
        [b exportObject:[NSMutableDictionary class] toVariable:@"NSMutableDictionary"];
        [b exportObject:[NSValue class] toVariable:@"NSValue"];
        [b exportObject:self toVariable:@"canvas"];
        [b runWithParent:nil];
    }
    self.textView.text = [PXBlock currentConsoleBuffer];
}

- (void)dealloc
{
    [source dealloc];
    [textView dealloc];
    [super dealloc];
}

@end
