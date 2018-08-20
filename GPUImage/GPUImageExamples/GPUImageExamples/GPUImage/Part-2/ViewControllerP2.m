//
//  ViewControllerP2.m
//  GPUImageExamples
//
//  Created by 叮咚钱包富银 on 2018/7/31.
//  Copyright © 2018年 leo. All rights reserved.
//

#import "ViewControllerP2.h"
#import <GPUImage/GPUImage.h>
#import <Masonry.h>
@interface ViewControllerP2 ()
@property (nonatomic, strong)  GPUImageView *gpuView;
@property (nonatomic, strong) GPUImageVideoCamera *gpuVideoCamera;
@end

@implementation ViewControllerP2

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.gpuView = [[GPUImageView alloc] init];
    self.gpuView.fillMode = kGPUImageFillModeStretch;
    [self.view addSubview:self.gpuView];

    self.gpuVideoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition:AVCaptureDevicePositionBack];
    self.gpuVideoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;

    [self.gpuVideoCamera addTarget:self.gpuView];
    [self.gpuVideoCamera startCameraCapture];
    
    //监听横竖屏
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)deviceOrientationDidChange:(NSNotification *)notification {
    UIInterfaceOrientation orientation = (UIInterfaceOrientation)[UIDevice currentDevice].orientation;
    self.gpuVideoCamera.outputImageOrientation = orientation;
}

- (void)viewWillLayoutSubviews {
    UIInterfaceOrientation orientation = (UIInterfaceOrientation)[UIDevice currentDevice].orientation;

    if (orientation != UIInterfaceOrientationPortrait) {
        [self.gpuView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(40);
            make.left.right.bottom.equalTo(self.view);
        }];
    } else {
        [self.gpuView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(64);
            make.left.right.bottom.equalTo(self.view);
        }];
    }
}

@end
