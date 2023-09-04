//
//  JQCropRectView.h
//  demo
//
//  Created by Jingquan Fan on 2023/6/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class JQCropRectView;

@protocol JQCropRectViewDelegate <NSObject>

- (void)jq_OptionalCropRectViewDidBeginEditing:(JQCropRectView *)cropRectView;

- (void)jq_OptionalCropRectViewEditingChanged:(JQCropRectView *)cropRectView;

- (void)jq_OptionalCropRectViewDidEndEditing:(JQCropRectView *)cropRectView;

@end

@interface JQCropRectView : UIView

@property (nonatomic, weak) id<JQCropRectViewDelegate> delegate;

@property (nonatomic, assign) BOOL showsGridMajor;

@end

NS_ASSUME_NONNULL_END
