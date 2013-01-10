@import "CPView.j"

@implementation _CPMenuItemMenuBarView : CPView
{
    CPMenuItem              _menuItem @accessors(property=menuItem);

    CPFont                  _font;
    CPColor                 _textColor;
    CPColor                 _textShadowColor;

    BOOL                    _isDirty;

    _CPImageAndTextView     _imageAndTextView;
    CPView                  _submenuIndicatorView;
}

+ (CPString)defaultThemeClass
{
    return "menu-item-bar-view";
}

+ (id)themeAttributes
{
    return [CPDictionary dictionaryWithObjects:[[CPNull null], [CPNull null], [CPNull null], [CPNull null], 8.0, 3.0, 4.0]
                                       forKeys:[    @"selection-color",
                                                    @"submenu-indicator-color",
                                                    @"menu-item-selection-color",
                                                    @"menu-item-text-shadow-color",
                                                    @"horizontal-margin",
                                                    @"submenu-indicator-margin",
                                                    @"vertical-margin"]];
}

+ (id)view
{
    return [[self alloc] init];
}

- (id)initWithFrame:(CGRect)aFrame
{
    self = [super initWithFrame:aFrame];

    if (self)
    {
        _imageAndTextView = [[_CPImageAndTextView alloc] initWithFrame:CGRectMake([self valueForThemeAttribute:@"horizontal-margin"], 0.0, 0.0, 0.0)];

        [_imageAndTextView setImagePosition:CPImageLeft];
        [_imageAndTextView setImageOffset:3.0];
        [_imageAndTextView setTextShadowOffset:CGSizeMake(0.0, 1.0)];
        [_imageAndTextView setAutoresizingMask:CPViewMinYMargin | CPViewMaxYMargin];

        [self addSubview:_imageAndTextView];

        _submenuIndicatorView = [[_CPMenuItemMenuBarSubmenuIndicatorView alloc] initWithFrame:CGRectMake(0.0, 0.0, 9.0, 6.0)];

        [_submenuIndicatorView setAutoresizingMask:CPViewMinYMargin | CPViewMaxYMargin];

        [self addSubview:_submenuIndicatorView];

        [self setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
    }

    return self;
}

- (CPColor)textColor
{
    if (![_menuItem isEnabled])
        return [CPColor lightGrayColor];

    return _textColor || [CPColor colorWithCalibratedRed:70.0 / 255.0 green:69.0 / 255.0 blue:69.0 / 255.0 alpha:1.0];
}

- (CPColor)textShadowColor
{
    if (![_menuItem isEnabled])
        return [CPColor colorWithWhite:0.8 alpha:0.8];

    return _textShadowColor || [CPColor colorWithWhite:1.0 alpha:0.8];
}

- (void)update
{
    var x = [self valueForThemeAttribute:@"horizontal-margin"],
        height = 0.0;

    [_imageAndTextView setFont:[_menuItem font] || [_CPMenuBarWindow font]];
    [_imageAndTextView setVerticalAlignment:CPCenterVerticalTextAlignment];
    [_imageAndTextView setImage:[_menuItem image]];
    [_imageAndTextView setText:[_menuItem title]];
    [_imageAndTextView setTextColor:[self textColor]];
    [_imageAndTextView setTextShadowColor:[self textShadowColor]];
    [_imageAndTextView setTextShadowOffset:CGSizeMake(0.0, 1.0)];
    [_imageAndTextView sizeToFit];

    var imageAndTextViewFrame = [_imageAndTextView frame];

    imageAndTextViewFrame.origin.x = x;
    x += CGRectGetWidth(imageAndTextViewFrame);
    height = MAX(height, CGRectGetHeight(imageAndTextViewFrame));

    var hasSubmenuIndicator = [_menuItem hasSubmenu] && [_menuItem action];

    if (hasSubmenuIndicator)
    {
        [_submenuIndicatorView setHidden:NO];
        [_submenuIndicatorView setColor:[self textColor]];
        [_submenuIndicatorView setShadowColor:[self textShadowColor]];

        var submenuViewFrame = [_submenuIndicatorView frame];

        submenuViewFrame.origin.x = x + [self valueForThemeAttribute:@"submenu-indicator-margin"];

        x = CGRectGetMaxX(submenuViewFrame);
        height = MAX(height, CGRectGetHeight(submenuViewFrame));
    }
    else
        [_submenuIndicatorView setHidden:YES];

    height += 2.0 * [self valueForThemeAttribute:@"vertical-margin"];

    imageAndTextViewFrame.origin.y = FLOOR((height - CGRectGetHeight(imageAndTextViewFrame)) / 2.0);
    [_imageAndTextView setFrame:imageAndTextViewFrame];

    if (hasSubmenuIndicator)
    {
        submenuViewFrame.origin.y = FLOOR((height - CGRectGetHeight(submenuViewFrame)) / 2.0) + 1.0;
        [_submenuIndicatorView setFrame:submenuViewFrame];
    }

    [self setAutoresizesSubviews:NO];
    [self setFrameSize:CGSizeMake(x + [self valueForThemeAttribute:@"horizontal-margin"], height)];
    [self setAutoresizesSubviews:YES];
}

- (void)highlight:(BOOL)shouldHighlight
{
    // FIXME: This should probably be even throw.
    if (![_menuItem isEnabled])
        shouldHighlight = NO;

    if (shouldHighlight)
    {
        if (![_menuItem _isMenuBarButton])
            [self setBackgroundColor:[self valueForThemeAttribute:@"selection-color"]];

        [_imageAndTextView setImage:[_menuItem alternateImage] || [_menuItem image]];
        [_imageAndTextView setTextColor:[CPColor whiteColor]];
        [_imageAndTextView setTextShadowColor:[self valueForThemeAttribute:@"menu-item-text-shadow-color"]];

        [_submenuIndicatorView setColor:[CPColor whiteColor]];
        [_submenuIndicatorView setShadowColor:[CPColor colorWithWhite:0.1 alpha:0.7]];
    }
    else
    {
        [self setBackgroundColor:nil];

        [_imageAndTextView setImage:[_menuItem image]];
        [_imageAndTextView setTextColor:[self textColor]];
        [_imageAndTextView setTextShadowColor:[self textShadowColor]];

        [_submenuIndicatorView setColor:[self textColor]];
        [_submenuIndicatorView setShadowColor:[self textShadowColor]];
    }
}

@end

@implementation _CPMenuItemMenuBarSubmenuIndicatorView : CPView
{
    CPColor _color;
    CPColor _shadowColor;
}

- (void)setColor:(CPColor)aColor
{
    if (_color === aColor)
        return;

    _color = aColor;

    [self setNeedsDisplay:YES];
}

- (void)setShadowColor:(CPColor)aColor
{
    if (_shadowColor === aColor)
        return;

    _shadowColor = aColor;

    [self setNeedsDisplay:YES];
}

- (void)drawRect:(CGRect)aRect
{
    var context = [[CPGraphicsContext currentContext] graphicsPort],
        bounds = [self bounds];

    bounds.size.height -= 1.0;
    bounds.size.width -= 2.0;
    bounds.origin.x += 1.0;

    CGContextBeginPath(context);

    CGContextMoveToPoint(context, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
    CGContextAddLineToPoint(context, CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
    CGContextAddLineToPoint(context, CGRectGetMidX(bounds), CGRectGetMaxY(bounds));

    CGContextClosePath(context);

    CGContextSetShadowWithColor(context, CGSizeMake(0.0, 1.0), 1.1, _shadowColor || [CPColor whiteColor]);
    CGContextSetFillColor(context, _color || [CPColor blackColor]);
    CGContextFillPath(context);
}

@end
