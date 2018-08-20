//
//  ViewControllerP6.m
//  GPUImageExamples
//
//  Created by 叮咚钱包富银 on 2018/7/31.
//  Copyright © 2018年 leo. All rights reserved.
//

#import "ViewControllerP6.h"
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <GPUImage/GPUImage.h>

@interface ViewControllerP6 ()
@property (nonatomic, strong) GPUImageVideoCamera     *videoCamera;
@property (nonatomic , strong) GPUImageMovieWriter *movieWriter;
@property (nonatomic , strong) GPUImageSepiaFilter *sepiaFilter; //怀旧风格
@property (weak, nonatomic) IBOutlet UILabel *timeLab;

@property (nonatomic , copy) NSString *pathToMovie;
@property (nonatomic , strong) NSURL *movieURL;
@property (nonatomic , strong) NSTimer  *mTimer;
@property (nonatomic , assign) NSInteger timeCount;

@end

@implementation ViewControllerP6

- (void)dealloc {
    NSLog(@"%s",__FUNCTION__);
}

- (IBAction)closeAction:(id)sender {
    [self invalidTimer];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self invalidTimer];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition:AVCaptureDevicePositionFront];
    self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    //前置摄像头镜像是否一致
    self.videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    //处理录制视频闪一下，出现丢帧
    [self.videoCamera addAudioInputsAndOutputs];
    
    //录制初始化，先存沙盒
    _pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
    unlink([_pathToMovie UTF8String]); // 如果已经存在文件，AVAssetWriter会有异常，删除旧文件
    _movieURL = [NSURL fileURLWithPath:_pathToMovie];
    
    self.movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:_movieURL size:CGSizeMake(480, 640)];
    //设置直播编码
    _movieWriter.encodingLiveVideo = YES;
    //设置音频编码target，麦克风录制
    self.videoCamera.audioEncodingTarget = _movieWriter;
    
    //添加怀旧滤镜
    self.sepiaFilter = [[GPUImageSepiaFilter alloc] init];
    
    //添加target
    [self.videoCamera addTarget:self.sepiaFilter];
    [self.sepiaFilter addTarget:(GPUImageView *)self.view];    //view继承GPUImageView
//
    //开启相机
    [self.videoCamera startCameraCapture];
    
    //监听横竖屏
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)deviceOrientationDidChange:(NSNotification *)notification {
    UIInterfaceOrientation orientation = (UIInterfaceOrientation)[UIDevice currentDevice].orientation;
    self.videoCamera.outputImageOrientation = orientation;
}

- (IBAction)recAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.isSelected) {
        [self.sepiaFilter addTarget:self.movieWriter];
        [self.movieWriter startRecording];
        [self createTimer];
    } else {
        [self.sepiaFilter removeTarget:self.movieWriter];
        [self.movieWriter finishRecording];
        [self invalidTimer];
        //将沙盒中的视频文件写入相册
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(self.pathToMovie))
        {
            [library writeVideoAtPathToSavedPhotosAlbum:self.movieURL completionBlock:^(NSURL *assetURL, NSError *error)
             {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     if (error) {
                         NSLog(@"保存失败");
                     } else {
                         NSLog(@"保存成功");
                         
                     }
                 });
             }];
        }
        else {
            NSLog(@"error mssg)");
        }
    }
}

- (IBAction)sliderAction:(UISlider *)sender {
    self.sepiaFilter.intensity = 1.0 - sender.value;
}

- (void)createTimer {
    self.timeLab.hidden = false;
    self.mTimer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(timeRun) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.mTimer forMode:NSRunLoopCommonModes];
}

- (void)timeRun {
    _timeCount++;
    [self updateTimeLabText];
}

- (void)invalidTimer {
    self.timeLab.hidden = YES;
    if ([self.mTimer isValid]) {
        [self.mTimer invalidate];
        self.mTimer = nil;
        _timeCount = 0;
        [self updateTimeLabText];
    }
}

- (void)updateTimeLabText{
    self.timeLab.text = [NSString stringWithFormat:@"录制时间：%ldS",_timeCount];
}
@end
