//
//  ViewControllerP12.m
//  GPUImageExamples
//
//  Created by 叮咚钱包富银 on 2018/8/2.
//  Copyright © 2018年 leo. All rights reserved.
//

#import "ViewControllerP12.h"
#import <GPUImage/GPUImage.h>
@interface ViewControllerP12 ()
@property (nonatomic , strong) GPUImageVideoCamera *videoCamera;
@property (nonatomic , strong) GPUImageSobelEdgeDetectionFilter *filter; //Sobel边界检测滤镜进行解析
@end

@implementation ViewControllerP12

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition:AVCaptureDevicePositionBack];
    //防止黑屏
    [_videoCamera addAudioInputsAndOutputs];
    _videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    
    _filter = [[GPUImageSobelEdgeDetectionFilter alloc] init];
    _filter.edgeStrength = 2;
    
    [_videoCamera addTarget:_filter];
    [_filter addTarget:(GPUImageView *)self.view];
    
    [_videoCamera startCameraCapture];
}

@end
