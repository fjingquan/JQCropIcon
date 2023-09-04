//
//  JQImageEditVC.m
//  demo
//
//  Created by Jingquan Fan on 2023/6/5.
//

#import "JQImageEditVC.h"
#import "JQCropView.h"

@interface JQImageEditVC ()

@property (nonatomic, weak) id <JQPhotoEditVCDelegate>delegate;

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong) JQCropView *cropView;

@property (nonatomic, strong) UIButton *backButton;

@property (nonatomic, strong) UIButton *doneButton;

@property (nonatomic, strong) UIButton *undoButton;

@end

@implementation JQImageEditVC

- (instancetype)initWithImage:(UIImage *)aImage delegate:(id<JQPhotoEditVCDelegate>)aDelegate {
    self = [super init];
    if (self) {
        _image = aImage;
        _delegate = aDelegate;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    // 编辑处 view
    self.cropView = [[JQCropView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:self.cropView];
    
    self.cropView.image = self.image;
    
    [self.view addSubview:self.backButton];
    [self.view addSubview:self.doneButton];
    [self.view addSubview:self.undoButton];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
    CGFloat bottomSafeAreaInset = window.safeAreaInsets.bottom;
    CGFloat buttonH = 50.;
    CGFloat buttonW = 60.;
    CGFloat buttonM = 20.;
    CGFloat buttonY = self.view.bounds.size.height - bottomSafeAreaInset - buttonH;
    CGFloat boundsW = self.view.bounds.size.width;
    
    self.backButton.frame = CGRectMake(buttonM, buttonY, buttonW, buttonH);
    self.doneButton.frame = CGRectMake(boundsW - buttonM - buttonW, buttonY, buttonW, buttonH);
    self.undoButton.frame = CGRectMake((boundsW - buttonW)/2., buttonY, buttonW, buttonH);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.cropView putOffOverlayView];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [UIApplication sharedApplication].statusBarHidden = NO;
    [super viewWillDisappear:animated];
}

#pragma mark - Click Events
- (void)onBackAction {
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)onDoneAction {
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(jq_OptionalPhotoEditVC:didFinishCroppingImage:)]) {
        [self.delegate jq_OptionalPhotoEditVC:self didFinishCroppingImage:self.cropView.croppedImage];
    }
}

- (void)onUndo {
    [self.cropView undoAction];
}

#pragma mark - lazy
- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(onBackAction) forControlEvents:UIControlEventTouchUpInside];
        _backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeading;
    }
    return _backButton;
}

- (UIButton *)doneButton {
    if (!_doneButton) {
        _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_doneButton setTitle:@"Done" forState:UIControlStateNormal];
        [_doneButton addTarget:self action:@selector(onDoneAction) forControlEvents:UIControlEventTouchUpInside];
        _doneButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentTrailing;
    }
    return _doneButton;
}

- (UIButton *)undoButton {
    if (!_undoButton) {
        _undoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_undoButton setTitle:@"Undo" forState:UIControlStateNormal];
        [_undoButton addTarget:self action:@selector(onUndo) forControlEvents:UIControlEventTouchUpInside];
    }
    return _undoButton;
}

@end
