//
//  JQCropRectView.m
//  demo
//
//  Created by Jingquan Fan on 2023/6/5.
//

#import "JQCropRectView.h"
#import "JQResizeView.h"

@interface JQCropRectView () <JQResizeConrolViewDelegate>

@property (nonatomic, strong) JQResizeView *topLeftCornerView;
@property (nonatomic, strong) JQResizeView *topRightCornerView;
@property (nonatomic, strong) JQResizeView *bottomLeftCornerView;
@property (nonatomic, strong) JQResizeView *bottomRightCornerView;
@property (nonatomic, strong) JQResizeView *topEdgeView;
@property (nonatomic, strong) JQResizeView *leftEdgeView;
@property (nonatomic, strong) JQResizeView *bottomEdgeView;
@property (nonatomic, strong) JQResizeView *rightEdgeView;

@property (nonatomic, assign) CGRect initialRect;
@property (nonatomic, getter = isLiveResizing) BOOL liveResizing;

@property (nonatomic, assign) CGRect firstRecordRect;
@property (nonatomic, assign) BOOL isRecord;

@end

@implementation JQCropRectView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.contentMode = UIViewContentModeRedraw;
        
        self.layer.borderWidth = 1;
        self.layer.borderColor = [[UIColor whiteColor] CGColor];
        
        self.showsGridMajor = YES;
        
        self.isRecord = NO;
        
        self.topLeftCornerView = [[JQResizeView alloc] init];
        self.topLeftCornerView.delegate = self;
        [self addSubview:self.topLeftCornerView];
        
        self.topRightCornerView = [[JQResizeView alloc] init];
        self.topRightCornerView.delegate = self;
        [self addSubview:self.topRightCornerView];
        
        self.bottomLeftCornerView = [[JQResizeView alloc] init];
        self.bottomLeftCornerView.delegate = self;
        [self addSubview:self.bottomLeftCornerView];
        
        self.bottomRightCornerView = [[JQResizeView alloc] init];
        self.bottomRightCornerView.delegate = self;
        [self addSubview:self.bottomRightCornerView];
        
        self.topEdgeView = [[JQResizeView alloc] init];
        self.topEdgeView.delegate = self;
        [self addSubview:self.topEdgeView];
        
        self.leftEdgeView = [[JQResizeView alloc] init];
        self.leftEdgeView.delegate = self;
        [self addSubview:self.leftEdgeView];
        
        self.bottomEdgeView = [[JQResizeView alloc] init];
        self.bottomEdgeView.delegate = self;
        [self addSubview:self.bottomEdgeView];
        
        self.rightEdgeView = [[JQResizeView alloc] init];
        self.rightEdgeView.delegate = self;
        [self addSubview:self.rightEdgeView];
    }
    return self;
}

#pragma mark -

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    NSArray *subviews = self.subviews;
    for (UIView *subview in subviews) {
        if ([subview isKindOfClass:[JQResizeView class]]) {
            if (CGRectContainsPoint(subview.frame, point)) {
                return subview;
            }
        }
    }
    
    return nil;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    
    for (NSInteger i = 0; i < 3; i++) {
        if (self.showsGridMajor) {
            if (i > 0) {
                [[UIColor whiteColor] set];
                
                UIRectFill(CGRectMake(roundf(width / 3 * i), 0.0f, 0.5f, roundf(height)));
                UIRectFill(CGRectMake(0.0f, roundf(height / 3 * i), roundf(width), 0.5f));
            }
        }
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.topLeftCornerView.frame = (CGRect){CGRectGetWidth(self.topLeftCornerView.bounds) / -2, CGRectGetHeight(self.topLeftCornerView.bounds) / -2, self.topLeftCornerView.bounds.size};
    self.topRightCornerView.frame = (CGRect){CGRectGetWidth(self.bounds) - CGRectGetWidth(self.topRightCornerView.bounds) / 2, CGRectGetHeight(self.topRightCornerView.bounds) / -2, self.topLeftCornerView.bounds.size};
    self.bottomLeftCornerView.frame = (CGRect){CGRectGetWidth(self.bottomLeftCornerView.bounds) / -2, CGRectGetHeight(self.bounds) - CGRectGetHeight(self.bottomLeftCornerView.bounds) / 2, self.bottomLeftCornerView.bounds.size};
    self.bottomRightCornerView.frame = (CGRect){CGRectGetWidth(self.bounds) - CGRectGetWidth(self.bottomRightCornerView.bounds) / 2, CGRectGetHeight(self.bounds) - CGRectGetHeight(self.bottomRightCornerView.bounds) / 2, self.bottomRightCornerView.bounds.size};
    self.topEdgeView.frame = (CGRect){CGRectGetMaxX(self.topLeftCornerView.frame), CGRectGetHeight(self.topEdgeView.frame) / -2, CGRectGetMinX(self.topRightCornerView.frame) - CGRectGetMaxX(self.topLeftCornerView.frame), CGRectGetHeight(self.topEdgeView.bounds)};
    self.leftEdgeView.frame = (CGRect){CGRectGetWidth(self.leftEdgeView.frame) / -2, CGRectGetMaxY(self.topLeftCornerView.frame), CGRectGetWidth(self.leftEdgeView.bounds), CGRectGetMinY(self.bottomLeftCornerView.frame) - CGRectGetMaxY(self.topLeftCornerView.frame)};
    self.bottomEdgeView.frame = (CGRect){CGRectGetMaxX(self.bottomLeftCornerView.frame), CGRectGetMinY(self.bottomLeftCornerView.frame), CGRectGetMinX(self.bottomRightCornerView.frame) - CGRectGetMaxX(self.bottomLeftCornerView.frame), CGRectGetHeight(self.bottomEdgeView.bounds)};
    self.rightEdgeView.frame = (CGRect){CGRectGetWidth(self.bounds) - CGRectGetWidth(self.rightEdgeView.bounds) / 2, CGRectGetMaxY(self.topRightCornerView.frame), CGRectGetWidth(self.rightEdgeView.bounds), CGRectGetMinY(self.bottomRightCornerView.frame) - CGRectGetMaxY(self.topRightCornerView.frame)};
}

#pragma mark -

- (void)setShowsGridMajor:(BOOL)showsGridMajor
{
    _showsGridMajor = showsGridMajor;
    [self setNeedsDisplay];
}

#pragma mark -

- (void)jq_OptionalResizeConrolViewDidBeginResizing:(JQResizeView *)resizeConrolView
{
    self.liveResizing = YES;
    self.initialRect = self.frame;
    
    if ([self.delegate respondsToSelector:@selector(jq_OptionalCropRectViewDidBeginEditing:)]) {
        [self.delegate jq_OptionalCropRectViewDidBeginEditing:self];
    }
    
    
    if (!self.isRecord && CGRectGetWidth(self.initialRect) > 0) {
        self.isRecord = YES;
        self.firstRecordRect = self.initialRect;
    }
}

- (void)jq_OptionalResizeConrolViewDidResize:(JQResizeView *)resizeConrolView
{
    self.frame = [self cropRectMakeWithResizeControlView:resizeConrolView];
    
    if ([self.delegate respondsToSelector:@selector(jq_OptionalCropRectViewEditingChanged:)]) {
        [self.delegate jq_OptionalCropRectViewEditingChanged:self];
    }
}

- (void)jq_OptionalResizeConrolViewDidEndResizing:(JQResizeView *)resizeConrolView
{
    self.liveResizing = NO;
    
    if ([self.delegate respondsToSelector:@selector(jq_OptionalCropRectViewDidEndEditing:)]) {
        [self.delegate jq_OptionalCropRectViewDidEndEditing:self];
    }
}

- (CGRect)cropRectMakeWithResizeControlView:(JQResizeView *)resizeControlView
{
    CGRect rect = self.frame;
    
    if (resizeControlView == self.topEdgeView) {
        CGFloat width = CGRectGetHeight(self.initialRect) - resizeControlView.translation.y;
        
        rect = CGRectMake(CGRectGetMinX(self.initialRect) + resizeControlView.translation.y/2,
                          CGRectGetMinY(self.initialRect) + resizeControlView.translation.y,
                          width,
                          width);
    } else if (resizeControlView == self.leftEdgeView) {
        CGFloat width = CGRectGetWidth(self.initialRect) - resizeControlView.translation.x;
        
        rect = CGRectMake(CGRectGetMinX(self.initialRect) + resizeControlView.translation.x,
                          CGRectGetMinY(self.initialRect) + resizeControlView.translation.x/2,
                          width,
                          width);
    } else if (resizeControlView == self.bottomEdgeView) {
        CGFloat width = CGRectGetHeight(self.initialRect) + resizeControlView.translation.y;
        
        rect = CGRectMake(CGRectGetMinX(self.initialRect) - resizeControlView.translation.y/2,
                          CGRectGetMinY(self.initialRect),
                          width,
                          width);
    } else if (resizeControlView == self.rightEdgeView) {
        CGFloat width = CGRectGetWidth(self.initialRect) + resizeControlView.translation.x;
        
        rect = CGRectMake(CGRectGetMinX(self.initialRect),
                          CGRectGetMinY(self.initialRect) - resizeControlView.translation.x/2,
                          width,
                          width);
    } else if (resizeControlView == self.topLeftCornerView) {
        rect = CGRectMake(CGRectGetMinX(self.initialRect) + resizeControlView.translation.x,
                          CGRectGetMinY(self.initialRect) + resizeControlView.translation.x,
                          CGRectGetWidth(self.initialRect) - resizeControlView.translation.x,
                          CGRectGetHeight(self.initialRect) - resizeControlView.translation.x);
    } else if (resizeControlView == self.topRightCornerView) {
        rect = CGRectMake(CGRectGetMinX(self.initialRect),
                          CGRectGetMinY(self.initialRect) + resizeControlView.translation.y,
                          CGRectGetWidth(self.initialRect) - resizeControlView.translation.y,
                          CGRectGetHeight(self.initialRect) - resizeControlView.translation.y);
    } else if (resizeControlView == self.bottomLeftCornerView) {
        rect = CGRectMake(CGRectGetMinX(self.initialRect) + resizeControlView.translation.x,
                          CGRectGetMinY(self.initialRect),
                          CGRectGetWidth(self.initialRect) - resizeControlView.translation.x,
                          CGRectGetHeight(self.initialRect) - resizeControlView.translation.x);
    } else if (resizeControlView == self.bottomRightCornerView) {
        rect = CGRectMake(CGRectGetMinX(self.initialRect),
                          CGRectGetMinY(self.initialRect),
                          CGRectGetWidth(self.initialRect) + resizeControlView.translation.x,
                          CGRectGetHeight(self.initialRect) + resizeControlView.translation.x);
    }
    
    CGFloat minWidth = CGRectGetWidth(self.leftEdgeView.bounds) + CGRectGetWidth(self.rightEdgeView.bounds);
    if (CGRectGetWidth(rect) < minWidth) {
        rect.origin.x = CGRectGetMaxX(self.frame) - minWidth;
        rect.size.width = minWidth;
    }
    
    CGFloat minHeight = CGRectGetHeight(self.topEdgeView.bounds) + CGRectGetHeight(self.bottomEdgeView.bounds);
    if (CGRectGetHeight(rect) < minHeight) {
        rect.origin.y = CGRectGetMaxY(self.frame) - minHeight;
        rect.size.height = minHeight;
    }
    
    // 边界之外不让滑动
    rect = CGRectMake(MAX(CGRectGetMinX(rect), CGRectGetMinX(self.firstRecordRect)),
                      MAX(CGRectGetMinY(rect), CGRectGetMinY(self.firstRecordRect)),
                      MIN(CGRectGetWidth(rect), CGRectGetWidth(self.firstRecordRect)),
                      MIN(CGRectGetHeight(rect), CGRectGetHeight(self.firstRecordRect)));
    
    return rect;
}

@end
