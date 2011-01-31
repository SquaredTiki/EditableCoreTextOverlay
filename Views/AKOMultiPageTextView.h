//
//  AKOMultiPageTextView.h
//  CoreTextWrapper
//
//  Created by Adrian on 4/28/10.
//  Copyright 2010 akosma software. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AKOMultiColumnTextView;

@interface AKOMultiPageTextView : UIView <UIScrollViewDelegate>
{
@private
    NSString *_text;
    UIFont *_font;
    UIColor *_color;
    UIScrollView *_scrollView;
    NSInteger _columnCount;
	AKOMultiColumnTextView *columnTextView;
	
	// Additions
	NSMutableArray *attributes;
	UITextView *theTextView;
	BOOL isCharBreakMode;
	BOOL isHighlighting;
	NSMutableArray *delayedAdjustments;
}

@property (nonatomic, copy) NSString *text;
@property (nonatomic, retain) UIFont *font;
@property (nonatomic, retain) UIColor *color;
@property (nonatomic) NSInteger columnCount;
@property (nonatomic, retain) AKOMultiColumnTextView *columnTextView;
@property (nonatomic, retain) UITextView *theTextView;
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic) BOOL isCharBreakMode;
@property (nonatomic) BOOL isHighlighting;

- (void)setAttributedString:(NSAttributedString *)newText;

- (void)removeAttribute:(NSString *)attributeName range:(NSRange)aRange;
- (void)addAttribute:(NSString *)attributeName value:(id)value range:(NSRange)range delayed:(BOOL)delayed;
- (id)valueForAttribute:(NSString *)attributeName atIndex:(NSUInteger)index;
- (NSDictionary *)attributesAtIndex:(NSUInteger)index;
- (void)insertText:(NSString *)insertText atLocation:(NSInteger)location;

- (void)adjustAttributesInRange:(NSRange)aRange by:(NSInteger)adjustment;

@end
