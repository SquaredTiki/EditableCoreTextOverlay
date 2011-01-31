//
//  AKOMultiPageTextView.m
//  CoreTextWrapper
//
//  Created by Adrian on 4/28/10.
//  Copyright 2010 akosma software. All rights reserved.
//

#import "AKOMultiPageTextView.h"
#import "AKOMultiColumnTextView.h"

@interface AKOMultiPageTextView ()

- (void)setup;

@end

@implementation AKOMultiPageTextView

@synthesize columnTextView, theTextView;
@synthesize scrollView = _scrollView;
@dynamic text;
@dynamic font;
@dynamic columnCount;
@dynamic color;
@synthesize isCharBreakMode, isHighlighting;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame 
{
    if (self = [super initWithFrame:frame])
    {
        [self setup];
    }
    return self;
}

- (void)setup
{    
    CGRect scrollViewFrame = CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height);
    self.scrollView = [[[UIScrollView alloc] initWithFrame:scrollViewFrame] autorelease];
    self.scrollView.scrollEnabled = YES;
    self.scrollView.bounces = YES;
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.scrollView.delegate = self;
    
    [self addSubview:self.scrollView];
	
	if (attributes == nil) {
		attributes = [[NSMutableArray alloc] init];
	}
	
	if (delayedAdjustments == nil) {
		delayedAdjustments = [[NSMutableArray alloc] init];
	}
}

- (void)dealloc 
{
    self.scrollView = nil;

    [_text release];
    _text = nil;
    [_font release];
    _font = nil;
    [_color release];
    _color = nil;

    [super dealloc];
}

#pragma mark -
#pragma mark Properties

- (NSString *)text
{
    return _text;
}

- (void)setText:(NSString *)newText
{
    if (![self.text isEqualToString:newText])
    {
        [_text release];
        _text = [newText copy];
		columnTextView.text = self.text;
    //    [self setNeedsDisplay];
    }
}

- (void)setAttributedString:(NSAttributedString *)newText
{
	[columnTextView setNewAttributedString:newText];
}

- (void)insertText:(NSString *)insertText atLocation:(NSInteger)location {
	{
		[columnTextView insertText:insertText atLocation:location];
    }
}

- (UIFont *)font
{
    return _font;
}

- (void)setFont:(UIFont *)newFont
{
    if (newFont != self.font)
    {
        [_font release];
        _font = [newFont retain];
        [self setNeedsDisplay];
    }
}

- (NSInteger)columnCount
{
    return _columnCount;
}

- (void)setColumnCount:(NSInteger)newColumnCount
{
    if (newColumnCount != self.columnCount)
    {
        _columnCount = newColumnCount;
        [self setNeedsDisplay];
    }
}

- (UIColor *)color
{
    return _color;
}

- (void)setColor:(UIColor *)newColor
{
    if (newColor != self.color)
    {
        [_color release];
        _color = [newColor retain];
        [self setNeedsDisplay];
    }
}

#pragma mark -
#pragma mark Attributes Control

- (void)adjustAttributesInRange:(NSRange)aRange by:(NSInteger)adjustment {
	if (isHighlighting) {
		NSDictionary *adjustmentDict = [NSDictionary dictionaryWithObjectsAndKeys:NSStringFromRange(aRange), @"range", [NSNumber numberWithInteger:adjustment], @"adjustment", nil];
		[delayedAdjustments addObject:adjustmentDict];
	}	
	
	NSMutableArray *newAtts = [[NSMutableArray alloc] initWithArray:attributes copyItems:YES];
	for (NSDictionary *attribute in attributes) {
		NSRange attributeRange = NSRangeFromString([attribute valueForKey:@"range"]);
		if (aRange.location + aRange.length >= attributeRange.location && attributeRange.location + attributeRange.length -1 >= aRange.location) {
			if (aRange.location > attributeRange.location && aRange.location < attributeRange.location + attributeRange.length) {	
				NSLog(@"Range : %@", NSStringFromRange(aRange));
				NSLog(@"GOTTA SPLIT This attribute : %@", attribute);
				id valueOfAtt = [attribute valueForKey:@"value"];
				NSString *attName = [attribute valueForKey:@"attributeName"];
								
				NSRange beforeAttRange = NSMakeRange(attributeRange.location, aRange.location - attributeRange.location + adjustment + 1);
				NSRange afterAttRange = NSMakeRange(aRange.location + adjustment, attributeRange.location + attributeRange.length - aRange.location);
												
				NSMutableDictionary *beforeAtt = [NSDictionary dictionaryWithObjectsAndKeys:valueOfAtt, @"value", attName, @"attributeName", NSStringFromRange(beforeAttRange), @"range", nil];
				NSMutableDictionary *afterAtt = [NSDictionary dictionaryWithObjectsAndKeys:valueOfAtt, @"value", attName, @"attributeName", NSStringFromRange(afterAttRange), @"range", nil];
							
				[newAtts replaceObjectAtIndex:[attributes indexOfObject:attribute] withObject:beforeAtt];
				
				[newAtts addObject:afterAtt];
			} else {				
				NSRange newAttRange = NSMakeRange(attributeRange.location + adjustment, attributeRange.length);
				NSMutableDictionary *alternateAttribute = [[newAtts objectAtIndex:[attributes indexOfObject:attribute]] mutableCopy];
				[alternateAttribute setValue:NSStringFromRange(newAttRange) forKey:@"range"];
				[newAtts replaceObjectAtIndex:[attributes indexOfObject:attribute] withObject:alternateAttribute];
				[alternateAttribute release];
			}
		}
	}
	attributes = newAtts;
	columnTextView.attributes = attributes;
}

- (void)removeAttribute:(NSString *)attributeName range:(NSRange)aRange {
	[columnTextView.attributedString removeAttribute:attributeName range:aRange];
	
//	NSLog(@"---------------------------------------");	
//	NSLog(@"Remove Attribute %@ in Range %@", attributeName, NSStringFromRange(aRange));
//	NSLog(@"Attribute Count before Removal : %i", attributes.count);
	
	NSMutableArray *objectsToRemove = [[NSMutableArray alloc] init];
	for (NSDictionary *attribute in attributes) {
		if ([[attribute valueForKey:@"attributeName"] isEqualToString:attributeName]) {
			NSRange attributeRange = NSRangeFromString([attribute valueForKey:@"range"]);
			if (attributeRange.location >= aRange.location && attributeRange.location + attributeRange.length <= aRange.location + aRange.length) {
				[objectsToRemove addObject:attribute];
			}
		}
	}
	for (NSDictionary *object in objectsToRemove) {
		[attributes removeObject:object];
	}
	[objectsToRemove release];
	
//	NSLog(@"Attribute Count after Removal : %i", attributes.count);
	
}

- (void)addAttribute:(NSString *)attributeName value:(id)value range:(NSRange)range delayed:(BOOL)delayed {
//	NSLog(@"---------------------------------------");	
//	NSLog(@"Attribute Count before Add : %i", attributes.count);
	
	if (delayed == YES && delayedAdjustments.count != 0) {
//		NSLog(@"Delayed");
		for (NSDictionary *adjustmentDict in delayedAdjustments) {
			NSRange adjustmentRange = NSRangeFromString([adjustmentDict valueForKey:@"range"]);
			NSInteger adjustment = [[adjustmentDict valueForKey:@"adjustment"] integerValue];
			if (range.location + range.length >= adjustmentRange.location && adjustmentRange.location + adjustmentRange.length >= range.location && adjustmentRange.length != 0) {
				NSLog(@"Attribute within Adjustment Range which is %@", NSStringFromRange(adjustmentRange));
					NSRange newAttRange = NSMakeRange(range.location + adjustment, range.length);
					
					NSArray *objects = [NSArray arrayWithObjects:value, attributeName, NSStringFromRange(newAttRange), nil];
					NSArray *keys = [NSArray arrayWithObjects:@"value", @"attributeName", @"range", nil];
					
					NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
					[attributes addObject:dictionary];
			} else {
			//	NSLog(@"Attribute outside of Adjustment Range");
				
				NSArray *objects = [NSArray arrayWithObjects:value, attributeName, NSStringFromRange(range), nil];
				NSArray *keys = [NSArray arrayWithObjects:@"value", @"attributeName", @"range", nil];
				
				NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
				[attributes addObject:dictionary];
			}
		}
		[delayedAdjustments removeAllObjects];
	} else {		
	//	NSLog(@"Not Delayed");
		NSArray *objects = [NSArray arrayWithObjects:value, attributeName, NSStringFromRange(range), nil];
		NSArray *keys = [NSArray arrayWithObjects:@"value", @"attributeName", @"range", nil];
	
		NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
		[attributes addObject:dictionary];
	}
	
	//NSLog(@"Attribute Count after Add : %i", attributes.count);
	
	[self setNeedsDisplay];
}

- (id)valueForAttribute:(NSString *)attributeName atIndex:(NSUInteger)index {
	return [columnTextView.attributedString attribute:attributeName atIndex:index effectiveRange:NULL];
}

- (NSDictionary *)attributesAtIndex:(NSUInteger)index {
	return [columnTextView.attributedString attributesAtIndex:index effectiveRange:NULL];
}

#pragma mark -
#pragma mark Drawing code

- (void)drawRect:(CGRect)rect 
{
    NSInteger currentPosition = 0;
    NSInteger iteration = 0;
    BOOL moreTextAvailable = YES;
    do 
    {
        CGRect currentFrame = CGRectOffset(self.scrollView.frame, self.scrollView.frame.size.width * iteration, 0.0);
        AKOMultiColumnTextView *view = [[[AKOMultiColumnTextView alloc] initWithFrame:currentFrame] autorelease];
		
		view.isCharBreakMode = isCharBreakMode;
        view.startIndex = currentPosition;
        view.text = self.text;
        view.font = self.font;
        view.columnCount = self.columnCount;
        view.color = self.color;
				
		view.attributes = attributes;
		view.theTextView = theTextView;

        [self.scrollView addSubview:view];
		
		columnTextView = view;

		[view updateFramesWithNewAtts:YES andShouldReloadStirng:YES];
		[view setNeedsLayout];
		 
        currentPosition = view.finalIndex;
        iteration += 1;
        
        self.scrollView.contentSize = theTextView.contentSize;
        moreTextAvailable = view.moreTextAvailable;
    } 
    while (moreTextAvailable);
}

@end
