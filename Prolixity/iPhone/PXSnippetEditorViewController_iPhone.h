//
//  PXSnippetEditorViewController_iPhone.h
//  Prolixity
//
//  Created by Lukhnos D. Liu on 3/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PXEvaluationResultViewController.h"

@interface PXSnippetEditorViewController_iPhone : UIViewController <UITextViewDelegate>
{    
    NSUInteger lastErrorLineNumber;    
}
@property (retain, nonatomic) NSString *currentSnippetIdentifier;
@property (readonly, nonatomic) UITextView *textView;
@property (retain, nonatomic) PXEvaluationResultViewController *evaluationResultViewController;
@end
