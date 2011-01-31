//
//  AKOMultiColumnTextView.h
//  CoreTextWrapper
//
//  Created by Adrian on 4/24/10.
//  Copyright 2010 akosma software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@interface AKOMultiColumnTextView : UIView 
{
@private
    NSInteger _columnCount;
    UIFont *_font;
    NSString *_text;
    NSMutableAttributedString *_attributedString;
    UIColor *_color;
    CFMutableArrayRef _columnPaths;
    CFMutableArrayRef _frames;
    CFIndex _startIndex;
    CFIndex _finalIndex;
    BOOL _moreTextAvailable;
	
	// Additions
	NSMutableArray *attributes;
	UITextView *theTextView;
	BOOL isCharBreakMode;
}

@property (nonatomic, retain) NSMutableAttributedString *attributedString;
@property (nonatomic) NSInteger columnCount;
@property (nonatomic, retain) UIFont *font;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, retain) UIColor *color;
@property (nonatomic) CFIndex startIndex;
@property (nonatomic, readonly) CFIndex finalIndex;
@property (nonatomic, readonly) BOOL moreTextAvailable;
@property (nonatomic, retain) UITextView *theTextView;

@property (nonatomic, retain) NSMutableArray *attributes;
@property (nonatomic) BOOL isCharBreakMode;

- (void)setNewAttributedString:(NSAttributedString *)newText;

- (void)updateFramesWithNewAtts:(BOOL)newAtts andShouldReloadStirng:(BOOL)reloadString;
- (void)insertText:(NSString *)insertText atLocation:(NSInteger)location;

@end
