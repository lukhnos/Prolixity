//
//  EvaluationResultViewController.h
//  Prolixity
//
//  Created by Lukhnos D. Liu on 2/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EvaluationCanvasView.h"

@interface EvaluationResultViewController : UIViewController {
    
}
- (IBAction)dismissAction;
@property (retain, nonatomic) EvaluationCanvasView *evaluationCanvasView;
@end
