//
//  JQResizeView.m
//  demo
//
//  Created by Jingquan Fan on 2023/6/5.
//

#import "JQResizeView.h"


@interface JQResizeView ()

@property (nonatomic, assign, readwrite) CGPoint translation;

@property (nonatomic, assign) CGPoint startPoint;

@end

@implementation JQResizeView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, 44.0f, 44.0f)];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        UIPanGestureRecognizer *gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [self addGestureRecognizer:gestureRecognizer];
    }
    
    return self;
}

- (void)handlePan:(UIPanGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint translationInView = [gestureRecognizer translationInView:self.superview];
        self.startPoint = CGPointMake(roundf(translationInView.x), translationInView.y);
        
        if ([self.delegate respondsToSelector:@selector(jq_OptionalResizeConrolViewDidBeginResizing:)]) {
            [self.delegate jq_OptionalResizeConrolViewDidBeginResizing:self];
        }
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gestureRecognizer translationInView:self.superview];
        self.translation = CGPointMake(roundf(self.startPoint.x + translation.x),
                                       roundf(self.startPoint.y + translation.y));
        
        if ([self.delegate respondsToSelector:@selector(jq_OptionalResizeConrolViewDidResize:)]) {
            [self.delegate jq_OptionalResizeConrolViewDidResize:self];
        }
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded || gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
        if ([self.delegate respondsToSelector:@selector(jq_OptionalResizeConrolViewDidEndResizing:)]) {
            [self.delegate jq_OptionalResizeConrolViewDidEndResizing:self];
        }
    }
}

@end
