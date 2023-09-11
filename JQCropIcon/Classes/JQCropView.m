//
//  JQCropView.m
//  demo
//
//  Created by Jingquan Fan on 2023/6/5.
//

#import "JQCropView.h"
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import "JQCropRectView.h"

static const CGFloat MarginVertical = 40.0f;
static const CGFloat MarginHorizontal = 20.0f;

@interface JQCropView ()
<
UIScrollViewDelegate,
UIGestureRecognizerDelegate,
JQCropRectViewDelegate
>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *zoomingView;
@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) JQCropRectView *cropRectView;
@property (nonatomic, strong) UIView *topOverlayView;
@property (nonatomic, strong) UIView *leftOverlayView;
@property (nonatomic, strong) UIView *rightOverlayView;
@property (nonatomic, strong) UIView *bottomOverlayView;

@property (nonatomic, assign) CGRect editingRect;
@property (nonatomic, assign) CGPoint scrollFinalOffset;

@property (nonatomic, strong) UIColor* overlayLightColor;
@property (nonatomic, strong) UIColor* overlayDimColor;

@property (nonatomic, getter = isResizing) BOOL resizing;

// 用来标志是否移动过
@property (nonatomic, assign) BOOL isZoom;

@end

@implementation JQCropView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundColor = [UIColor clearColor];
        
        self.overlayLightColor = [UIColor clearColor];
        self.overlayDimColor = [UIColor colorWithWhite:0.0f alpha:0.9f];
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        self.scrollView.delegate = self;
        self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        self.scrollView.backgroundColor = [UIColor clearColor];
        self.scrollView.maximumZoomScale = 20.0f;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.bounces = NO;
        self.scrollView.bouncesZoom = NO;
        self.scrollView.clipsToBounds = NO;
        [self addSubview:self.scrollView];
        
        self.cropRectView = [[JQCropRectView alloc] init];
        self.cropRectView.delegate = self;
        [self addSubview:self.cropRectView];
        
        self.topOverlayView = [[UIView alloc] init];
        self.topOverlayView.backgroundColor = self.overlayLightColor;
        [self addSubview:self.topOverlayView];
        
        self.leftOverlayView = [[UIView alloc] init];
        self.leftOverlayView.backgroundColor = self.overlayLightColor;
        [self addSubview:self.leftOverlayView];
        
        self.rightOverlayView = [[UIView alloc] init];
        self.rightOverlayView.backgroundColor = self.overlayLightColor;
        [self addSubview:self.rightOverlayView];
        
        self.bottomOverlayView = [[UIView alloc] init];
        self.bottomOverlayView.backgroundColor = self.overlayLightColor;
        [self addSubview:self.bottomOverlayView];
    }
    
    return self;
}

#pragma mark -

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [self.cropRectView hitTest:[self convertPoint:point toView:self.cropRectView] withEvent:event];
    if (hitView) {
        return hitView;
    }
    CGPoint locationInImageView = [self convertPoint:point toView:self.zoomingView];
    CGPoint zoomedPoint = CGPointMake(locationInImageView.x * self.scrollView.zoomScale, locationInImageView.y * self.scrollView.zoomScale);
    if (CGRectContainsPoint(self.zoomingView.frame, zoomedPoint)) {
        return self.scrollView;
    }
    
    return [super hitTest:point withEvent:event];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (!self.image) {
        return;
    }
    
    self.editingRect = CGRectInset(self.bounds, MarginHorizontal, MarginVertical);
    
    if (!self.imageView) {
        [self setupImageView];
    }
    
    if (!self.isResizing) {
        [self layoutCropRectViewWithCropRect:self.scrollView.frame];
    }
}

- (void)layoutCropRectViewWithCropRect:(CGRect)cropRect {
    CGFloat width = cropRect.size.width;
    CGFloat height = cropRect.size.height;
    CGRect rect = CGRectMake(CGRectGetMinX(cropRect),
                             CGRectGetMinY(cropRect) + (height - width)/2,
                             width,
                             width);
    [UIView animateWithDuration:0.5f
                     animations:^{
                         self.cropRectView.frame = rect;
                     } completion:^(BOOL finished) {
                         self.cropRectView.frame = rect;
                     }];
    [self layoutOverlayViewsWithCropRect:cropRect];
}

- (void)layoutOverlayViewsWithCropRect:(CGRect)cropRect {
    self.topOverlayView.frame = CGRectMake(0.0f,
                                           0.0f,
                                           CGRectGetWidth(self.bounds),
                                           CGRectGetMinY(cropRect));
    self.leftOverlayView.frame = CGRectMake(0.0f,
                                            CGRectGetMinY(cropRect),
                                            CGRectGetMinX(cropRect),
                                            CGRectGetHeight(cropRect));
    self.rightOverlayView.frame = CGRectMake(CGRectGetMaxX(cropRect),
                                             CGRectGetMinY(cropRect),
                                             CGRectGetWidth(self.bounds) - CGRectGetMaxX(cropRect),
                                             CGRectGetHeight(cropRect));
    self.bottomOverlayView.frame = CGRectMake(0.0f,
                                              CGRectGetMaxY(cropRect),
                                              CGRectGetWidth(self.bounds),
                                              CGRectGetHeight(self.bounds) - CGRectGetMaxY(cropRect));
}

- (void)setupImageView {
    CGRect insetRect = CGRectInset(self.bounds, MarginHorizontal, MarginVertical);
    CGFloat scrollWH = self.bounds.size.width - MarginHorizontal * 2;
    CGRect scrollRect = CGRectMake(MarginHorizontal, (self.bounds.size.height - scrollWH)/2, scrollWH, scrollWH);
    
    CGFloat width = self.image.size.width;
    CGFloat height = self.image.size.height;
    
    CGFloat finalScale;
    if (width > height) {
        finalScale = scrollWH/height;
    }else {
        finalScale = scrollWH/width;
    }
    
    CGFloat insetRatio = insetRect.size.width/insetRect.size.height;
    CGFloat imageRatio = width/height;

    CGFloat originalScale;
    if (imageRatio > insetRatio) {
        originalScale = insetRect.size.width/width;
    } else {
        originalScale = insetRect.size.height/height;
    }
    
    self.scrollView.frame = scrollRect;
    self.scrollView.contentSize = CGSizeMake(width * finalScale, height * finalScale);
    self.scrollView.contentOffset = CGPointMake(((width * originalScale) - CGRectGetWidth(scrollRect))/2,  ((height * originalScale) - CGRectGetHeight(scrollRect))/2);

    self.zoomingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width * originalScale, height * originalScale)];
    self.zoomingView.backgroundColor = [UIColor clearColor];
    [self.scrollView addSubview:self.zoomingView];
    
    CGRect imageOriginalRect = [self.zoomingView convertRect:self.zoomingView.bounds toView:self];
    self.cropRectView.frame = imageOriginalRect;
    
    self.imageView = [[UIImageView alloc] initWithFrame:self.zoomingView.bounds];
    self.imageView.backgroundColor = [UIColor clearColor];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.image = self.image;
    [self.zoomingView addSubview:self.imageView];
    
    self.scrollFinalOffset = CGPointMake(((width * finalScale) - CGRectGetWidth(scrollRect))/2,  ((height * finalScale) - CGRectGetHeight(scrollRect))/2);
    [UIView animateWithDuration:0.5 animations:^{
        self.scrollView.contentOffset = self.scrollFinalOffset;
        self.zoomingView.frame = CGRectMake(0, 0, width * finalScale, height * finalScale);
        self.imageView.frame = self.zoomingView.bounds;
    } completion:^(BOOL finished) {
        self.scrollView.contentOffset = self.scrollFinalOffset;
        self.zoomingView.frame = CGRectMake(0, 0, width * finalScale, height * finalScale);
        self.imageView.frame = self.zoomingView.bounds;
    }];
}

#pragma mark -

- (void)setImage:(UIImage *)image {
    _image = image;
    
    [self.imageView removeFromSuperview];
    self.imageView = nil;
    
    [self.zoomingView removeFromSuperview];
    self.zoomingView = nil;
    
    [self setNeedsLayout];
}

- (void)setAspectRatio:(CGFloat)aspectRatio {
    CGRect cropRect = self.scrollView.frame;
    CGFloat width = CGRectGetWidth(cropRect);
    CGFloat height = CGRectGetHeight(cropRect);
    if (width < height) {
        width = height * aspectRatio;
    } else {
        height = width * aspectRatio;
    }
    cropRect.size = CGSizeMake(width, height);
    [self zoomToCropRect:cropRect];
}

- (CGFloat)aspectRatio {
    CGRect cropRect = self.scrollView.frame;
    CGFloat width = CGRectGetWidth(cropRect);
    CGFloat height = CGRectGetHeight(cropRect);
    return width / height;
}

- (void)setCropRect:(CGRect)cropRect {
    [self zoomToCropRect:cropRect];
}

- (CGRect)cropRect {
    return self.scrollView.frame;
}

- (UIImage *)croppedImage {
    CGFloat scrollWH = self.bounds.size.width - MarginHorizontal * 2;
    CGRect scrollRect = CGRectMake(MarginHorizontal, (self.bounds.size.height - scrollWH)/2, scrollWH, scrollWH);
    
    CGFloat width = self.image.size.width;
    CGFloat height = self.image.size.height;
    
    CGFloat scale;
    if (width > height) {
        scale = scrollWH/height;
    }else {
        scale = scrollWH/width;
    }
    
    CGRect rect = CGRectMake(((width * scale) - CGRectGetWidth(scrollRect))/2, ((height * scale) - CGRectGetHeight(scrollRect))/2, width * scale, height * scale);
    
    CGRect cropRect = [self convertRect:self.cropRectView.frame toView:self.zoomingView];
    CGSize size = self.image.size;
    
    if (!self.isZoom) {
        cropRect = CGRectMake(cropRect.origin.x, cropRect.origin.y, cropRect.size.width, cropRect.size.width);
    }
    
    CGFloat ratio = 1.0f;
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad || UIInterfaceOrientationIsPortrait(orientation)) {
        ratio = CGRectGetWidth(AVMakeRectWithAspectRatioInsideRect(self.image.size, rect)) / size.width;
    } else {
        ratio = CGRectGetHeight(AVMakeRectWithAspectRatioInsideRect(self.image.size, rect)) / size.height;
    }
    
    CGRect zoomedCropRect = CGRectMake(cropRect.origin.x / ratio,
                                       cropRect.origin.y / ratio,
                                       cropRect.size.width / ratio,
                                       cropRect.size.height / ratio);
    
    UIImage *anchorImage = [self anchorImageWithImage:self.image transform:self.imageView.transform];
    
    CGImageRef croppedImage = CGImageCreateWithImageInRect(anchorImage.CGImage, zoomedCropRect);
    UIImage *image = [UIImage imageWithCGImage:croppedImage scale:1.0f orientation:anchorImage.imageOrientation];
    
    CGImageRelease(croppedImage);
    
    return image;
}

// adjust the image's center
- (UIImage *)anchorImageWithImage:(UIImage *)image transform:(CGAffineTransform)transform {
    CGSize size = image.size;
    
    UIGraphicsBeginImageContextWithOptions(size, NO, image.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, size.width / 2, size.height / 2);
    CGContextConcatCTM(context, transform);
    CGContextTranslateCTM(context, size.width / -2, size.height / -2);
    [image drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height)];
    
    UIImage *anchorImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return anchorImage;
}

- (CGRect)cappedCropRectInImageRectWithCropRectView:(JQCropRectView *)cropRectView {
    CGRect cropRect = cropRectView.frame;
    
    CGRect rect = [self convertRect:cropRect toView:self.scrollView];
    if (CGRectGetMinX(rect) < CGRectGetMinX(self.zoomingView.frame)) {
        cropRect.origin.x = CGRectGetMinX([self.scrollView convertRect:self.zoomingView.frame toView:self]);
        cropRect.size.width = CGRectGetMaxX(rect);
    }
    if (CGRectGetMinY(rect) < CGRectGetMinY(self.zoomingView.frame)) {
        cropRect.origin.y = CGRectGetMinY([self.scrollView convertRect:self.zoomingView.frame toView:self]);
        cropRect.size.height = CGRectGetMaxY(rect);
    }
    if (CGRectGetMaxX(rect) > CGRectGetMaxX(self.zoomingView.frame)) {
        cropRect.size.width = CGRectGetMaxX([self.scrollView convertRect:self.zoomingView.frame toView:self]) - CGRectGetMinX(cropRect);
    }
    if (CGRectGetMaxY(rect) > CGRectGetMaxY(self.zoomingView.frame)) {
        cropRect.size.height = CGRectGetMaxY([self.scrollView convertRect:self.zoomingView.frame toView:self]) - CGRectGetMinY(cropRect);
    }
    
    return cropRect;
}

- (void)automaticZoomIfEdgeTouched:(CGRect)cropRect {
    if (CGRectGetMinX(cropRect) < CGRectGetMinX(self.editingRect) - 5.0f ||
        CGRectGetMaxX(cropRect) > CGRectGetMaxX(self.editingRect) + 5.0f ||
        CGRectGetMinY(cropRect) < CGRectGetMinY(self.editingRect) - 5.0f ||
        CGRectGetMaxY(cropRect) > CGRectGetMaxY(self.editingRect) + 5.0f) {
        [UIView animateWithDuration:1.0
                              delay:0.0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             [self zoomToCropRect:self.cropRectView.frame];
                         } completion:^(BOOL finished) {
                             
                         }];
    }
}

#pragma mark -

- (void)jq_OptionalCropRectViewDidBeginEditing:(JQCropRectView *)cropRectView {
    self.resizing = YES;
    self.isZoom = YES;
    [self lightUpOverlayView];
}

- (void)jq_OptionalCropRectViewEditingChanged:(JQCropRectView *)cropRectView {
    CGRect cropRect = [self cappedCropRectInImageRectWithCropRectView:cropRectView];
    
    [self layoutCropRectViewWithCropRect:cropRect];
    
    [self automaticZoomIfEdgeTouched:cropRect];
}

- (void)jq_OptionalCropRectViewDidEndEditing:(JQCropRectView *)cropRectView {
    self.resizing = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!self.resizing) {
            [self zoomToCropRect:self.cropRectView.frame];
        }
    });
}

- (void)zoomToCropRect:(CGRect)toRect {
    if (CGRectEqualToRect(self.scrollView.frame, toRect)) {
        return;
    }
    
    CGFloat width = CGRectGetWidth(toRect);
    CGFloat height = CGRectGetHeight(toRect);
    
    CGFloat scale = MIN(CGRectGetWidth(self.editingRect) / width, CGRectGetHeight(self.editingRect) / height);
    
    CGFloat scaledWidth = width * scale;
    CGFloat scaledHeight = height * scale;
    CGRect cropRect = CGRectMake((CGRectGetWidth(self.bounds) - scaledWidth) / 2,
                                 (CGRectGetHeight(self.bounds) - scaledHeight) / 2,
                                 scaledWidth,
                                 scaledHeight);
    
    CGRect zoomRect = [self convertRect:toRect toView:self.zoomingView];
    zoomRect.size.width = CGRectGetWidth(cropRect) / (self.scrollView.zoomScale * scale);
    zoomRect.size.height = CGRectGetHeight(cropRect) / (self.scrollView.zoomScale * scale);
    
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.scrollView.bounds = cropRect;
                         [self.scrollView zoomToRect:zoomRect animated:NO];
                         
                         [self layoutCropRectViewWithCropRect:cropRect];
                     } completion:^(BOOL finished) {
                         [self putOffOverlayView];
                     }];
}

- (void)lightUpOverlayView {
    [UIView animateWithDuration:0.25 animations:^{
        self.topOverlayView.backgroundColor = self.overlayLightColor;
        self.leftOverlayView.backgroundColor = self.overlayLightColor;
        self.rightOverlayView.backgroundColor = self.overlayLightColor;
        self.bottomOverlayView.backgroundColor = self.overlayLightColor;
    }];
}

- (void)putOffOverlayView {
    [self putOffOverlayView:0];
}

- (void)undoAction {
    self.scrollView.zoomScale = 1;
    self.scrollView.contentOffset = self.scrollFinalOffset;
}

- (void)putOffOverlayView:(NSTimeInterval)time {
    [UIView animateWithDuration:0.25 delay:time options:0 animations:^{
        self.topOverlayView.backgroundColor = self.overlayDimColor;
        self.leftOverlayView.backgroundColor = self.overlayDimColor;
        self.rightOverlayView.backgroundColor = self.overlayDimColor;
        self.bottomOverlayView.backgroundColor = self.overlayDimColor;
        } completion:^(BOOL finished) {
            
        }];
}

#pragma mark - Gesture&Scroll

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.zoomingView;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self lightUpOverlayView];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    CGPoint contentOffset = scrollView.contentOffset;
    *targetContentOffset = contentOffset;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self putOffOverlayView:1];
        
    BOOL originalShape = (scrollView.zoomScale == 1)&&(CGPointEqualToPoint(scrollView.contentOffset, self.scrollFinalOffset));
    !self.variedBlock ?: self.variedBlock(!originalShape);
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    [self lightUpOverlayView];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    [self putOffOverlayView:1];
    
    BOOL originalShape = (scrollView.zoomScale == 1)&&(CGPointEqualToPoint(scrollView.contentOffset, self.scrollFinalOffset));
    !self.variedBlock ?: self.variedBlock(!originalShape);
}

@end
