//
//  ViewController.m
//  demo
//
//  Created by Jingquan Fan on 2023/5/27.
//

#import "ViewController.h"
#import "JQImageEditVC.h"

@interface ViewController ()<JQPhotoEditVCDelegate>

@property (nonatomic, strong) UIImagePickerController *picker;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.backgroundColor = [UIColor redColor];
    btn.frame = CGRectMake(100, 100, 100, 100);
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void)btnClick {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    self.picker = picker;
    picker.delegate = self;
    
    if (@available(iOS 11.0, *)) {
        for (UIView *view in picker.view.subviews) {
            if ([view isKindOfClass:[UIScrollView class]]) {
                UIScrollView *scrollView = (UIScrollView *)view;
                scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            }
        }
    }else {
        picker.automaticallyAdjustsScrollViewInsets = NO;
    }
    picker.navigationBar.translucent = NO;

    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    [self presentViewController:picker animated:YES completion:^{
        #if defined(__IPHONE_13_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_13_0
            if (@available(iOS 13.0, *)) {
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDarkContent];
            }else{
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
            }
        #else
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        #endif
    }];
}

#pragma mark delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    UIImage *selectedImage = nil;
    if (info[UIImagePickerControllerEditedImage]) {
        selectedImage = info[UIImagePickerControllerEditedImage];
    }else if(info[UIImagePickerControllerOriginalImage]){
        selectedImage = info[UIImagePickerControllerOriginalImage];
    }
    
    
    JQImageEditVC *vc = [[JQImageEditVC alloc] initWithImage:selectedImage delegate:self];
    picker.view.backgroundColor = [UIColor whiteColor];
    [picker pushViewController:vc animated:YES];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)jq_OptionalPhotoEditVC:(JQImageEditVC *)controller didFinishCroppingImage:(UIImage *)croppedImage {
    UIImageView *imgV = [[UIImageView alloc] initWithImage:croppedImage];
    imgV.frame = CGRectMake(20, 200, 300, 300);
    [self.view addSubview:imgV];
    [self.picker dismissViewControllerAnimated:YES completion:nil];
}

@end
