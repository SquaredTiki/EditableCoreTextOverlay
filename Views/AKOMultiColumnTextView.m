//
//  AKOMultiColumnTextView.m
//  CoreTextWrapper
//
//  Created by Adrian on 4/24/10.
//  Copyright 2010 akosma software. All rights reserved.
//

#import "AKOMultiColumnTextView.h"
#import "UIFont+CoreTextExtensions.h"

@interface AKOMultiColumnTextView ()

- (void)updateAttributedStringWhileReloadingString:(BOOL)reloadString;
- (void)updateFramesWithNewAtts:(BOOL)newAtts andShouldReloadStirng:(BOOL)reloadString;
- (void)setup;
- (void)createColumns;

@end


@implementation AKOMultiColumnTextView

@synthesize attributes, theTextView;
@dynamic font;
@dynamic columnCount;
@dynamic text;
@dynamic color;
@synthesize startIndex = _startIndex;
@synthesize finalIndex = _finalIndex;
@synthesize moreTextAvailable = _moreTextAvailable;
@synthesize attributedString = _attributedString;
@synthesize isCharBreakMode;

#pragma mark -
#pragma mark Init and dealloc

- (void)setup
{
    self.backgroundColor = [UIColor whiteColor];
    _columnCount = 3;
    _text = [@"" copy];
    _font = [[UIFont fontWithName:@"Helvetica" size:14.0] retain];
    _color = [[UIColor blackColor] retain];
    _startIndex = 0;
    _finalIndex = 0;
    _moreTextAvailable = NO;
    _columnPaths = NULL;
    _frames = NULL;
}

- (id)initWithFrame:(CGRect)frame 
{
    if (self = [super initWithFrame:frame])
    {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self setup];
    }
    return self;
}

- (void)dealloc 
{
    if (_columnPaths != NULL)
    {
        CFRelease(_columnPaths);
    }
    
    if (_frames != NULL)
    {
        CFRelease(_frames);
    }
    
    self.attributedString = nil;

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

- (UIColor *)color
{
    return _color;
}

- (void)setColor:(UIColor *)newColor
{
    [_color release];
    _color = [newColor retain];
	[self updateFramesWithNewAtts:YES andShouldReloadStirng:YES];
    [self setNeedsDisplay];
}

- (UIFont *)font
{
    return _font;
}

- (void)setFont:(UIFont *)newFont
{
    if (newFont != _font)
    {
        [_font release];
        _font = [newFont retain];
		[self updateFramesWithNewAtts:YES andShouldReloadStirng:YES];
        [self setNeedsDisplay];
    }
}

- (void)setNewAttributedString:(NSAttributedString *)newText
{
	self.attributedString = [newText mutableCopy];
		
	[self updateFramesWithNewAtts:YES andShouldReloadStirng:NO];
	[self setNeedsDisplay];
}

- (NSString *)text
{
    return _text;
}

- (void)setText:(NSString *)newText
{
    if (![_text isEqualToString:newText])
    {
        [_text release];
        _text = [newText copy];
        
        self.attributedString = nil;
		[self updateFramesWithNewAtts:YES andShouldReloadStirng:YES];
        [self setNeedsDisplay];
    }
}

- (void)insertText:(NSString *)insertText atLocation:(NSInteger)location {
	{
		NSMutableString *newText = [NSMutableString stringWithString:_text];
		[newText insertString:insertText atIndex:location];
		
        [_text release];
        _text = [NSString stringWithString:newText];
        
        self.attributedString = nil;
		[self updateFramesWithNewAtts:YES andShouldReloadStirng:YES];
        [self setNeedsDisplay];
    }
}

- (NSInteger)columnCount
{
    return _columnCount;
}

- (void)setColumnCount:(NSInteger)newColumnCount
{
    if (_columnCount != newColumnCount)
    {
        _columnCount = newColumnCount;
		[self updateFramesWithNewAtts:YES andShouldReloadStirng:YES];
        [self setNeedsDisplay];
    }
}

#pragma mark -
#pragma mark Drawing methods

- (void)drawRect:(CGRect)rect 
{
    // Initialize the text matrix to a known value.
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // This is required, otherwise the text is drawn upside down in iPhone OS 3.2 (!?)
    CGContextSaveGState(context);
    CGAffineTransform flip = CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, self.frame.size.height); 
    CGContextConcatCTM(context, flip);
    CFIndex pathCount = CFArrayGetCount(_columnPaths);
    
    for (int column = 0; column < pathCount; column++)
    {
        CTFrameRef frame = (CTFrameRef)CFArrayGetValueAtIndex(_frames, column);
        CTFrameDraw(frame, context);
    }
    
    CGContextRestoreGState(context);
}

#pragma mark -
#pragma mark Private methods

- (void)createColumns
{		
	CGSize contentSize = theTextView.contentSize;
	int height = contentSize.height;
	
	CGRect newBounds = self.bounds;
	
	if (height <= 1024) {
		newBounds.size.height = 960; // !!!: Customize depending on Text View Height
	} else {
		newBounds.size.height = height + 10; // !!!: Customize depending on Text View font size
	}
		
	newBounds.size.width = 769;
	
	self.bounds = newBounds;
	self.frame = newBounds;
		
    CGRect columnRect = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height);
        
    // Inset all columns by a few pixels of margin.
	columnRect = CGRectInset(columnRect, 10.0, 10.0);
    
    // Create an array of layout paths, one for each column.
    if (_columnPaths != NULL)
    {
        CFRelease(_columnPaths);
    }
    _columnPaths = CFArrayCreateMutable(kCFAllocatorDefault, _columnCount, &kCFTypeArrayCallBacks);
	
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathAddRect(path, NULL, columnRect);
	CFArrayInsertValueAtIndex(_columnPaths, 0, path);
	CFRelease(path);
}

- (void)updateAttributedStringWhileReloadingString:(BOOL)reloadString
{
    if (self.text != nil)
    {
		if (reloadString)
			self.attributedString = [[[NSMutableAttributedString alloc] initWithString:self.text] autorelease];
		
        NSRange range = NSMakeRange(0, [self.attributedString.string length]);
        
        if (self.font != nil)
        {
		//	CTFontRef customFont = [UIFont bundledFontNamed:@"HelveticaNeueCustom" size:self.font.pointSize];
			CTFontRef customFont = [UIFont bundledFontNamed:@"CourierCustom" size:self.font.pointSize];
            [self.attributedString addAttribute:(NSString *)kCTFontAttributeName
                                        //  value:(id)self.font.CTFont
										  value:(id)customFont
                                          range:range];
        }
       
        if (self.color != nil && reloadString)
        {
            [self.attributedString addAttribute:(NSString *)kCTForegroundColorAttributeName 
                                          value:(id)self.color.CGColor
                                          range:range];
        }
				
		NSInteger lengthOfText = self.attributedString.string.length;

		for (NSDictionary *attribute in attributes) {			
			NSRange range = NSRangeFromString([attribute valueForKey:@"range"]);
			
			if (range.location + range.length > lengthOfText)
				range.length = lengthOfText - range.location;
			
			if (range.location > lengthOfText) 
				continue;
			
			[self.attributedString addAttribute:[attribute valueForKey:@"attributeName"] 
                                          value:[attribute valueForKey:@"value"]
                                          range:range];
		}
		        
        CFIndex theNumberOfSettings = 7;
        CTLineBreakMode lineBreakMode = kCTLineBreakByWordWrapping;
		if (isCharBreakMode) {
			NSLog(@"Char Wrap");
			lineBreakMode = kCTLineBreakByCharWrapping;
		}
        CTTextAlignment textAlignment = kCTLeftTextAlignment;
        CGFloat indent = 0.0;
        CGFloat spacing = 0.0;
        CGFloat topSpacing = 0.0;
//        CGFloat lineSpacing = 2.3;
		CGFloat lineSpacing = 0.6;
		
		CFIndex i = 0; 
		CTTextTabRef tabArray[10]; 
		CTTextAlignment align = 0; 
		CGFloat location = 80; 
		for (;i < 10; i++ ) { 
			tabArray[i] = CTTextTabCreate( align, location, NULL ); 
			location = location + 80;
		}		
		CFArrayRef tabStops = CFArrayCreate( kCFAllocatorDefault, (const void**) tabArray, 10, &kCFTypeArrayCallBacks );		
		for (;i < 10; i++ ) { CFRelease( tabArray[i] ); } 
		
        CTParagraphStyleSetting theSettings[7] =
        {
            { kCTParagraphStyleSpecifierAlignment, sizeof(CTTextAlignment), &textAlignment },
            { kCTParagraphStyleSpecifierLineBreakMode, sizeof(CTLineBreakMode), &lineBreakMode },
            { kCTParagraphStyleSpecifierFirstLineHeadIndent, sizeof(CGFloat), &indent },
            { kCTParagraphStyleSpecifierParagraphSpacing, sizeof(CGFloat), &spacing },
            { kCTParagraphStyleSpecifierParagraphSpacingBefore, sizeof(CGFloat), &topSpacing },
            { kCTParagraphStyleSpecifierLineSpacing, sizeof(CGFloat), &lineSpacing },
			{ kCTParagraphStyleSpecifierTabStops, sizeof(CFArrayRef), &tabStops },
        };
        
        CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(theSettings, theNumberOfSettings);
        [self.attributedString addAttribute:(NSString *)kCTParagraphStyleAttributeName 
                                      value:(id)paragraphStyle
                                      range:range];
		
/*		[self.attributedString addAttribute:(NSString *)kCTKernAttributeName 
									  value:[NSNumber numberWithFloat:0.15] 
									  range:range];	 */
        
        CFRelease(paragraphStyle);
    }
}

- (void)updateFramesWithNewAtts:(BOOL)newAtts andShouldReloadStirng:(BOOL)reloadString;
{
	if (self.text != nil)
    {
		if (newAtts)
			[self updateAttributedStringWhileReloadingString:reloadString];
		
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self.attributedString);
        [self createColumns];
		        
        CFIndex currentIndex = self.startIndex;
        
        if (_frames != NULL)
        {
            CFRelease(_frames);
        }
		
        _frames = CFArrayCreateMutable(kCFAllocatorDefault, 1, &kCFTypeArrayCallBacks);
				        
		CGPathRef path = (CGPathRef)CFArrayGetValueAtIndex(_columnPaths, 0);
		
		CTFrameRef theFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(currentIndex, 0), path, NULL);
		CFArrayInsertValueAtIndex(_frames, 0, theFrame);
		
		CFRange frameRange = CTFrameGetVisibleStringRange(theFrame);
		currentIndex += frameRange.length;
        
        _finalIndex = currentIndex;
        _moreTextAvailable = [self.text length] > self.finalIndex;

        CFRelease(framesetter);
    }
}

@end
