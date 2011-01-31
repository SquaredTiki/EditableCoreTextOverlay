//
//  CoreTextStarterViewController.m
//  CoreTextStarter
//
//  Created by Joshua Garnham on 14/11/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CoreTextStarterViewController.h"
#import <CoreText/CoreText.h>
#import <QuartzCore/QuartzCore.h>

@implementation CoreTextStarterViewController

- (IBAction)colorSomeText {
	[pageView addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[[UIColor redColor] CGColor] range:NSMakeRange(0, 5) delayed:NO];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {	
	if (![text isEqualToString:@""] && range.length == 0 && ![text isEqualToString:@" "] && ![text isEqualToString:@"	"] && ![text isEqualToString:@"\n"]) {
		// Normal New Leter
		
		NSString *firstHalf = [textView.text substringToIndex:range.location];
		NSString *secondHalf = [textView.text substringFromIndex:range.location];
		
		NSRange adjustmentRange = NSMakeRange(range.location, [[textView.text substringFromIndex:range.location] length]);
		NSInteger adjustment = [text length];
		[pageView adjustAttributesInRange:adjustmentRange by:adjustment];
		
		pageView.text = [NSString stringWithFormat:@"%@%@%@", firstHalf, text, secondHalf];
	//	[pageView insertText:text atLocation:range.location];
	} else if (![text isEqualToString:@""] && range.length != 0) {
		// Replace Selected Text
		NSRange adjustmentRange = NSMakeRange(range.location + range.length, [[textView.text substringFromIndex:range.location] length]);
		NSInteger adjustment = (-range.length) + [text length];
		[pageView adjustAttributesInRange:adjustmentRange by:adjustment];
		
		NSString *replacement = [textView.text stringByReplacingCharactersInRange:range withString:text];
		pageView.text = replacement;
	} else if (range.length != 0) {
		// Delete/Backspace
		NSString *firstHalf = [textView.text substringToIndex:range.location];
		NSString *secondHalf = [textView.text substringFromIndex:range.location + range.length];
				
		NSRange adjustmentRange = NSMakeRange(range.location + range.length, [[textView.text substringFromIndex:range.location] length] - 1);
		NSInteger adjustment = -(range.length);
				
		[pageView adjustAttributesInRange:adjustmentRange by:adjustment];
		
		pageView.text = [NSString stringWithFormat:@"%@%@", firstHalf, secondHalf];	
		
	} else if ([text isEqualToString:@" "] && range.length == 0) {
		// Space
		if (range.location < textView.text.length) {
			NSString *previousLetter = [textView.text substringWithRange:NSMakeRange(range.location - 1, 1)];
			NSString *nextLetter = [textView.text substringWithRange:NSMakeRange(range.location, 1)];
			if ([previousLetter isEqualToString:@" "] && [nextLetter isEqualToString:@" "])
				return NO; // DO NOT ALLOW MORE THAN ONE SPACE - Offsets Core Text from UITextView text which makes everything out of line.
		} else if (range.location != 0) {
			NSString *previousLetter = [textView.text substringWithRange:NSMakeRange(range.location - 1, 1)];
			if ([previousLetter isEqualToString:@" "])
				return NO; // DO NOT ALLOW MORE THAN ONE SPACE - Offsets Core Text from UITextView text which makes everything out of line.
		} else if (range.location == 0) {
			NSString *nextLetter = [textView.text substringWithRange:NSMakeRange(range.location, 1)];
			if ([nextLetter isEqualToString:@" "])
				return NO; // DO NOT ALLOW MORE THAN ONE SPACE - Offsets Core Text from UITextView text which makes everything out of line.
		}
		
		NSString *firstHalf = [textView.text substringToIndex:range.location];
		NSString *secondHalf = [textView.text substringFromIndex:range.location];
	
		NSRange adjustmentRange = NSMakeRange(range.location, [[textView.text substringFromIndex:range.location] length]);
		NSInteger adjustment = 1;
		[pageView adjustAttributesInRange:adjustmentRange by:adjustment];
		
		// Now insert the Space
		pageView.text = [NSString stringWithFormat:@"%@%@%@", firstHalf, text, secondHalf];		
	} else if ([text isEqualToString:@"	"]) {
		// Tab
		NSString *textUpToLoc = [textView.text substringToIndex:range.location];
		NSInteger lineNumber = [[textUpToLoc componentsSeparatedByString:@"\n"] count] -1;
		
		NSArray *allLines = [textView.text componentsSeparatedByString:@"\n"];
		NSMutableString *wholeLine = [NSMutableString stringWithString:[allLines objectAtIndex:lineNumber]];
		
		NSInteger totalNumber = [wholeLine replaceOccurrencesOfString:@"	" withString:@"T" options:NSLiteralSearch range:NSMakeRange(0, [wholeLine length])] + 1;
		
		if (totalNumber == 4)
			return NO;
		
		NSRange adjustmentRange = NSMakeRange(range.location, [[textView.text substringFromIndex:range.location] length]);
		NSInteger adjustment = 1;
		[pageView adjustAttributesInRange:adjustmentRange by:adjustment];
		
		NSString *firstHalf = [textView.text substringToIndex:range.location];
		NSString *secondHalf = [textView.text substringFromIndex:range.location];
		pageView.text = [NSString stringWithFormat:@"%@%@%@", firstHalf, text, secondHalf];
	} else if ([text isEqualToString:@"\n"] && range.length == 0) {
		NSString *firstHalf = [textView.text substringToIndex:range.location];
		NSString *secondHalf = [textView.text substringFromIndex:range.location];
				
		NSRange adjustmentRange = NSMakeRange(range.location, [[textView.text substringFromIndex:range.location] length]);
		NSInteger adjustment = 1;
		[pageView adjustAttributesInRange:adjustmentRange by:adjustment];
		
		pageView.text = [NSString stringWithFormat:@"%@%@%@", firstHalf, text, secondHalf];
	}
	return YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[pageView.scrollView setContentOffset:scrollView.contentOffset animated:NO];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[[myView.subviews objectAtIndex:1] setHidden:YES];
	myView.contentInset = UIEdgeInsetsMake(2, 0, 44, 0); // '44' Bottom, because of toolbar. -1 for helvetica or 2 for courier.
	myView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 44, 0); // '44' Bottom, because of toolbar.
	pageView.text = myView.text;
    pageView.font = myView.font;
    pageView.columnCount = 1;
	pageView.theTextView = myView;
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
	NSLog(@"!!! : WARNING : !!! | --------- MEMORY IS LOW --------- | !!! : WARNING : !!!");
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

@end
