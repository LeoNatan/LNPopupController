//
//  TOInsetGroupedTableView.m
//
//  Copyright 2020 Timothy Oliver. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
//  IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "TOInsetGroupedTableView.h"

// Un-comment when testing this on iOS 13 and up
// #define DEBUG_TOINSETGROUPEDTABLEVIEW 1

/**
 The KVO key we'll be using to detect when the table view
 manipulates the shape of any of the subviews
*/
static NSString * const kTOInsetGroupedTableViewFrameKey = @"frame";

/**
 The KVO key we'll be using to detect when the table view
 has been set to selected or not (which is the best time to calculate rounded corners)
*/
static NSString * const kTOInsetGroupedTableViewSelectedKey = @"selected";

/** The corner radius of the top and bottom cells.
 This is hard-coded with the same value as in iOS 13.
 */
static CGFloat const kTOInsetGroupedTableViewCornerRadius = 10.0f;

@interface TOInsetGroupedTableView ()

/**
 A set to store a reference to each view that we attached
 a KVO observer to.
 */
@property (nonatomic, strong) NSMutableSet *observedViews;

@property (nonatomic, assign) int realSeparatorStyle;

@end

@implementation TOInsetGroupedTableView

#pragma mark - View Life-cycle -

- (instancetype)init
{
    // Set a non-zero default frame value
    CGRect frame = (CGRect){0,0,320,480};
    
#ifndef DEBUG_TOINSETGROUPEDTABLEVIEW
    // On iOS 13, cancel out to simply using the official grouped inset style
    if (@available(iOS 13.0, *)) {
        return [super initWithFrame:frame style:UITableViewStyleInsetGrouped];
    }
#endif
    
    // On iOS 12 and below, force the grouped style, and perform common setup
    if (self = [super initWithFrame:frame style:UITableViewStyleGrouped]) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
#ifndef DEBUG_TOINSETGROUPEDTABLEVIEW
    // On iOS 13 and above, cancel out as we can simply use the official
    // grouped inset style.
    if (@available(iOS 13.0, *)) {
        return [super initWithFrame:frame style:UITableViewStyleInsetGrouped];
    }
#endif
    
    // On iOS 12 and below, make sure we explicitly force the grouped style
    if (self = [super initWithFrame:frame style:UITableViewStyleGrouped]) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
#ifndef DEBUG_TOINSETGROUPEDTABLEVIEW
    // On iOS 13 and up, override with the standard system implementation
    if (@available(iOS 13.0, *)) {
        return [super initWithFrame:frame style:UITableViewStyleInsetGrouped];
    }
#endif

    // On iOS 12 and below, make sure we explicitly force the grouped style
    if (self = [super initWithFrame:frame style:UITableViewStyleGrouped]) {
        [self commonInit];
    }

    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    if (self = [super initWithCoder:coder]) {
        // If the user left the style as "Plain" in IB, since we can't
        // override it here, throw an exception.
        // (Thankfully on iOS 12, IB will gracefully default it back to "Grouped")
        if (self.style < UITableViewStyleGrouped) {
            NSString *reason = @"TOInsetGroupedTableView: Make sure the table view style "
                                    "is set to \"Inset Grouped\" in Interface Builder";
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:reason
                                         userInfo:nil];
        }
    
        // On iOS 12 or lower, perform the common set-up
#ifndef DEBUG_TOINSETGROUPEDTABLEVIEW
        if (@available(iOS 13.0, *)) { return self; }
#endif
        
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit
{
    // Create the set to hold our observed views
    self.observedViews = [NSMutableSet set];
    
    // Explicitly disable any magic insetting, as we'll
    // be manually calculating the insetting ourselves
    self.insetsLayoutMarginsFromSafeArea = NO;
}

- (void)dealloc
{
    [self removeAllObservers];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	for(UIView* subview in self.subviews)
	{
		if (![subview isKindOfClass:[UITableViewHeaderFooterView class]] &&
			![subview isKindOfClass:[UITableViewCell class]])
		{
			continue;
		}
		
		[self performInsetLayoutForView:subview];
	}
}

#pragma mark - Table View Behaviour Overrides -

- (void)didAddSubview:(UIView *)subview
{
    [super didAddSubview:subview];
    
#ifndef DEBUG_TOINSETGROUPEDTABLEVIEW
    if (@available(iOS 13.0, *)) { return; }
#endif

    // If it's not a section header/footer view, or a table cell, ignore it
    if (![subview isKindOfClass:[UITableViewHeaderFooterView class]] &&
        ![subview isKindOfClass:[UITableViewCell class]])
     {
        return;
    }

    // Register this view for observation
    [self addObserverIfNeeded:subview];
}

- (void)setSeparatorStyle:(UITableViewCellSeparatorStyle)separatorStyle
{
    if (separatorStyle == UITableViewCellSeparatorStyleNone) {
        // make sure there will be _UITableViewCellSeparatorView in cell's subViews
        self.separatorColor = UIColor.clearColor;
        self.realSeparatorStyle = UITableViewCellSeparatorStyleNone;
        return;
    }
    self.realSeparatorStyle = -1;
    [super setSeparatorStyle:separatorStyle];
}

- (UITableViewCellSeparatorStyle)separatorStyle
{
    if (self.realSeparatorStyle > -1) {
        return self.realSeparatorStyle;
    }
    return [super separatorStyle];
}

#pragma mark - Observer Life-cycle -

- (void)addObserverIfNeeded:(UIView *)view
{
#ifndef DEBUG_TOINSETGROUPEDTABLEVIEW
    if (@available(iOS 13.0, *)) { return; }
#endif
    
    // If the view had already been registered, exit out,
    // otherwise a system exception will be thrown
    if ([self.observedViews containsObject:view]) {
        return;
    }
    
    // Register the view to observe its frame shape
    [view addObserver:self
           forKeyPath:kTOInsetGroupedTableViewFrameKey
              options:0
              context:nil];
    
    // If it's a cell, register for when it's set as selected
    // so we can round the corners then
    if ([view isKindOfClass:[UITableViewCell class]]) {
        [view addObserver:self
               forKeyPath:kTOInsetGroupedTableViewSelectedKey
                  options:0
                  context:nil];
    }
    
    // Add it to the set
    [self.observedViews addObject:view];
}

- (void)removeAllObservers
{
#ifndef DEBUG_TOINSETGROUPEDTABLEVIEW
    if (@available(iOS 13.0, *)) { return; }
#endif
    
    // Loop through each object in the set, and de-register them
    for (UIView *view in self.observedViews) {
        // Remove the frame observer
        [view removeObserver:self
                  forKeyPath:kTOInsetGroupedTableViewFrameKey
                     context:nil];
        
        // If table cell, remove the selected observer
        if ([view isKindOfClass:[UITableViewCell class]]) {
            [view removeObserver:self
                      forKeyPath:kTOInsetGroupedTableViewSelectedKey
                         context:nil];
        }
    }
    
    // Clean out all of the views from the set
    [self.observedViews removeAllObjects];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context
{
    // Double check this notification is about an object we care about
    if ([object isKindOfClass:[UIView class]] == NO) { return; }
    UIView *view = (UIView *)object;

    // If the key was a frame observation, perform the inset
    if ([keyPath isEqualToString:kTOInsetGroupedTableViewFrameKey]) {
        [self performInsetLayoutForView:view];
    }
    else if ([keyPath isEqualToString:kTOInsetGroupedTableViewSelectedKey]) {
        // If the key was the selection key, apply rounding
        [self applyRoundedCornersToTableViewCell:(UITableViewCell *)view];
    }
}

#pragma mark - Behaviour Overrides -

- (void)performInsetLayoutForView:(UIView *)view
{
    CGRect frame = view.frame;
    UIEdgeInsets margins = self.layoutMargins;
    UIEdgeInsets safeAreaInsets = self.safeAreaInsets;
    
    // Calculate the left margin.
    // If the margin on its own isn't larger than
    // the safe area inset, combine the two.
    CGFloat leftInset = margins.left;
    if (leftInset - safeAreaInsets.left < 0.0f - FLT_EPSILON) {
        leftInset += safeAreaInsets.left;
    }
    
    // Calculate the right margin with the same logic.
    CGFloat rightInset = margins.right;
    if (rightInset - safeAreaInsets.right < 0.0f - FLT_EPSILON) {
        rightInset += safeAreaInsets.right;
    }
    
    // Calculate offset and width off the insets
    frame.origin.x = leftInset;
    frame.size.width = CGRectGetWidth(self.frame) - (leftInset + rightInset);
    
    // Apply the new frame value to the underlying CALayer
    // to avoid triggering the KVO observer into an infinite loop
    view.layer.frame = frame;
}

- (void)applyRoundedCornersToTableViewCell:(UITableViewCell *)cell
{
    // Set the cell to always mask its child content
    cell.layer.masksToBounds = YES;
    
    // Set flags for checking both top and bottom
    BOOL topRounded = NO;
    BOOL bottomRounded = NO;

    // The maximum height a separator might be
    CGFloat separatorHeight = 1.0f;
    
    // Since the cell might still be not laid out yet
    // (And the separators aren't in the right places)
    // force a re-layout beforehand.
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    // Loop through each subview
    for (UIView *subview in cell.subviews) {
        CGRect frame = subview.frame;
        
        // Separators will always be less than 1 point high
        if (frame.size.height > separatorHeight) { continue; }
        
        // If the X origin isn't 0, it's a separator we want to keep.
        // Since it may have been a border separator we hid before, un-hide it.
        if (frame.origin.x > FLT_EPSILON) {
            subview.hidden = NO;
            continue;
        }
        
        // Check if it's a top or bottom separator
        if (frame.origin.y < FLT_EPSILON) {
            topRounded = YES;
        }
        else {
            bottomRounded = YES;
        }
        
        // Hide this view to get a clean looking border
        subview.hidden = YES;
    }
    
    BOOL needsRounding = (topRounded || bottomRounded);
    
    // Set the corner radius as needed
    cell.layer.cornerRadius = needsRounding ? kTOInsetGroupedTableViewCornerRadius : 0.0f;
    
    // Set which corners need to be rounded depending on top or bottom
    NSUInteger cornerRoundingFlags = 0;
    if (topRounded) {
        cornerRoundingFlags |= (kCALayerMinXMinYCorner|kCALayerMaxXMinYCorner);
    }
    if (bottomRounded) {
        cornerRoundingFlags |= (kCALayerMinXMaxYCorner|kCALayerMaxXMaxYCorner);
    }
    cell.layer.maskedCorners = cornerRoundingFlags;
}

@end
