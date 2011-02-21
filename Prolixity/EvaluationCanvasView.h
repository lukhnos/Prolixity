//
//  EvaluationCanvasView.h
//  Prolixity
//
//  Created by Lukhnos D. Liu on 2/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface EvaluationCanvasView : UIView
{
    CGPoint somePoint;
}

- (CGPoint)somePoint;
- (void)setSomePoint:(CGPoint)p;

@property (retain, nonatomic) NSString *source;
@property (retain, nonatomic) IBOutlet UITextView *textView;
@end
