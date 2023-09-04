//
//  JQImageEditVC.h
//  demo
//
//  Created by Jingquan Fan on 2023/6/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class JQImageEditVC;

@protocol JQPhotoEditVCDelegate <NSObject>

@optional

- (void)jq_OptionalPhotoEditVC:(JQImageEditVC *)controller didFinishCroppingImage:(UIImage *)croppedImage;

@end

@interface JQImageEditVC : UIViewController

- (instancetype)initWithImage:(UIImage *)aImage delegate:(id<JQPhotoEditVCDelegate>)aDelegate;

@end

NS_ASSUME_NONNULL_END
