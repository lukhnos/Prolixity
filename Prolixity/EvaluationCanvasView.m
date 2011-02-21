//
//  EvaluationCanvasView.m
//  Prolixity
//
//  Created by Lukhnos D. Liu on 2/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EvaluationCanvasView.h"
#import "PXBlock.h"

@implementation EvaluationCanvasView
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
