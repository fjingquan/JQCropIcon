//
//  JQResizeView.h
//  demo
//
//  Created by Jingquan Fan on 2023/6/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class JQResizeView;

@protocol JQResizeConrolViewDelegate <NSObject>

@optional

- (void)jq_OptionalResizeConrolViewDidBeginResizing:(JQResizeView *)resizeConrolView;

- (void)jq_OptionalResizeConrolViewDidResize:(JQResizeView *)resizeConrolView;

- (void)jq_OptionalResizeConrolViewDidEndResizing:(JQResizeView *)resizeConrolView;

@end

@interface JQResizeView : UIView

@property (nonatomic, weak) id<JQResizeConrolViewDelegate> delegate;

@property (nonatomic, assign, readonly) CGPoint translation;

@end

NS_ASSUME_NONNULL_END
