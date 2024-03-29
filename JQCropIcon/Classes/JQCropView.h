//
//  JQCropView.h
//  demo
//
//  Created by Jingquan Fan on 2023/6/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JQCropView : UIView

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong, readonly) UIImage *croppedImage;
@property (nonatomic, assign) CGFloat aspectRatio;
@property (nonatomic, assign) CGRect cropRect;

/// to send back if the image have varied
@property (nonatomic, copy) void (^variedBlock)(BOOL varied);

- (void)putOffOverlayView;
- (void)undoAction;

@end

NS_ASSUME_NONNULL_END
