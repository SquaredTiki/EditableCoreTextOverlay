//
//  CoreTextStarterViewController.h
//  CoreTextStarter
//
//  Created by Joshua Garnham on 14/11/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AKOMultiPageTextView.h"

@class AKOMultiPageTextView, HighlightingController;

@interface CoreTextStarterViewController : UIViewController <UIScrollViewDelegate, UITextViewDelegate> {
	IBOutlet AKOMultiPageTextView *pageView;
	IBOutlet UITextView *myView;
	HighlightingController *highlightingController;
}

- (IBAction)colorSomeText;

@end

