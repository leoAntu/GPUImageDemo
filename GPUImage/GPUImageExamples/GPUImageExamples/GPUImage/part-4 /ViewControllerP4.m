//
//  ViewControllerP4.m
//  GPUImageExamples
//
//  Created by 叮咚钱包富银 on 2018/7/31.
//  Copyright © 2018年 leo. All rights reserved.
//

#import "ViewControllerP4.h"
#import <GPUImage/GPUImage.h>
#import <AssetsLibrary/ALAssetsLibrary.h>

@interface ViewControllerP4 ()
@property (nonatomic, strong) GPUImageVideoCamera     *videoCamera;
@property (nonatomic, strong) GPUImageBilateralFilter     *bilateralFilter;
@property (nonatomic, strong) GPUImageBrightnessFilter     *brightnessFilter;


@end

@implementation ViewControllerP4

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initBottomView];
    self.videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition:AVCaptureDevicePositionFront];
    self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    //前置摄像头镜像是否一致
    self.videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    //处理录制视频闪一下，出现丢帧
    [self.videoCamera addAudioInputsAndOutputs];

    //创建磨皮，美白组合
    GPUImageFilterGroup *group = [[GPUImageFilterGroup alloc] init];
    
    //磨皮滤镜
    GPUImageBilateralFilter *bilateralFilter = [[GPUImageBilateralFilter alloc] init];
    [group addFilter:bilateralFilter];
    _bilateralFilter = bilateralFilter;
    [_bilateralFilter setDistanceNormalizationFactor:20];

    //创建美白滤镜
    GPUImageBrightnessFilter *brightnessFilter = [[GPUImageBrightnessFilter alloc] init];
    [group addFilter:brightnessFilter];
    _brightnessFilter = brightnessFilter;
    
    //设置滤镜组合链
    //磨皮和美白相关联，输入图像
    [bilateralFilter addTarget:brightnessFilter];
    //下面两个方法必须要实现，否则没输出
    [group setInitialFilters:@[bilateralFilter]];
    //设置最后终端输出的滤镜.
    group.terminalFilter = brightnessFilter;
    
//    //或者两者滤镜调换顺序同样
//    [brightnessFilter addTarget:bilateralFilter];
//    [group setInitialFilters:@[brightnessFilter]];
//    group.terminalFilter = bilateralFilter;
    
    //  设置GPUImage处理链 从数据源->滤镜->界面展示
    [self.videoCamera addTarget:group];
    [group addTarget:(GPUImageView *)self.view];    //view继承GPUImageView
    
    //开启相机
    [self.videoCamera startCameraCapture];

    //监听横竖屏
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
 
}

- (void)initBottomView
{
    UIView *bottomControlView = [[UIView alloc] initWithFrame:CGRectMake(0, 450, 320, 118)];
    [self.view addSubview:bottomControlView];
    
    
    //磨皮
    UILabel *bilateralL = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 40, 25)];
    bilateralL.text = @"磨皮";
    bilateralL.font = [UIFont systemFontOfSize:12];
    [bottomControlView addSubview:bilateralL];
    
    UISlider *bilateralSld  = [[UISlider alloc] initWithFrame:CGRectMake(50, 10, 250, 30)
                               ];
    bilateralSld.maximumValue = 20;
    [bilateralSld addTarget:self action:@selector(bilateralFilter:) forControlEvents:UIControlEventValueChanged];
    [bottomControlView addSubview:bilateralSld];
    
    
    //美白
    UILabel *brightnessL = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, 40, 25)];
    brightnessL.text = @"美白";
    brightnessL.font = [UIFont systemFontOfSize:12];
    [bottomControlView addSubview:brightnessL];
    
    UISlider *brightnessSld  = [[UISlider alloc] initWithFrame:CGRectMake(50, 40, 250, 30)
                                ];
    brightnessSld.minimumValue = -1;
    brightnessSld.maximumValue = 1;
    //    brightnessSld.value = 0;
    [brightnessSld addTarget:self action:@selector(brightnessFilter:) forControlEvents:UIControlEventValueChanged];
    [bottomControlView addSubview:brightnessSld];
}
#pragma mark - 调整亮度
- (void)brightnessFilter:(UISlider *)slider
{
    _brightnessFilter.brightness = slider.value;
}

#pragma mark - 调整磨皮
- (void)bilateralFilter:(UISlider *)slider
{
    //值越小，磨皮效果越好
    CGFloat maxValue = 20;
    [_bilateralFilter setDistanceNormalizationFactor:(maxValue - slider.value)];
}


- (void)deviceOrientationDidChange:(NSNotification *)notification {
    UIInterfaceOrientation orientation = (UIInterfaceOrientation)[UIDevice currentDevice].orientation;
    self.videoCamera.outputImageOrientation = orientation;
}


@end
