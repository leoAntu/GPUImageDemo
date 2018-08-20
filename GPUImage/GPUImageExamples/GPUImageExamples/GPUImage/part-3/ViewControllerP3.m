//
//  ViewControllerP3.m
//  GPUImageExamples
//
//  Created by 叮咚钱包富银 on 2018/7/31.
//  Copyright © 2018年 leo. All rights reserved.
//

#import "ViewControllerP3.h"
#import <GPUImage/GPUImage.h>
#import "GPUImageBeautifyFilter.h"
#import <AssetsLibrary/ALAssetsLibrary.h>

@interface ViewControllerP3 ()
@property (nonatomic, strong) GPUImageVideoCamera     *videoCamera;
@property (nonatomic , strong) GPUImageMovieWriter *movieWriter;
@property (nonatomic , strong) GPUImageBeautifyFilter *beautifyFilter;

@property (nonatomic , copy) NSString *pathToMovie;
@property (nonatomic , strong) NSURL *movieURL;

@end

@implementation ViewControllerP3

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

    //添加滤镜美颜
    self.beautifyFilter = [[GPUImageBeautifyFilter alloc] init];
    [self.videoCamera addTarget:self.beautifyFilter];
    [self.beautifyFilter addTarget:(GPUImageView *)self.view];    //view继承GPUImageView
//    [self.beautifyFilter addTarget:self.movieWriter];

    //开启相机
    [self.videoCamera startCameraCapture];
    //开启录制
//    [self.movieWriter startRecording];

    //监听横竖屏
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];

//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.beautifyFilter removeTarget:self.movieWriter];
//        [self.movieWriter finishRecording];
//        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(self.pathToMovie))
//        {
//            [library writeVideoAtPathToSavedPhotosAlbum:self.movieURL completionBlock:^(NSURL *assetURL, NSError *error)
//             {
//                 dispatch_async(dispatch_get_main_queue(), ^{
//
//                     if (error) {
//                         NSLog(@"保存失败");
//                     } else {
//                         NSLog(@"保存成功");
//
//                     }
//                 });
//             }];
//        }
//        else {
//            NSLog(@"error mssg)");
//        }
//    });
}


- (void)deviceOrientationDidChange:(NSNotification *)notification {
    UIInterfaceOrientation orientation = (UIInterfaceOrientation)[UIDevice currentDevice].orientation;
    self.videoCamera.outputImageOrientation = orientation;
}

- (IBAction)closeBtnAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

//录制时间
- (IBAction)recAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    
    if (sender.isSelected) {
        [self.beautifyFilter addTarget:self.movieWriter];
        [self.movieWriter startRecording];

        
    } else {
        [self.beautifyFilter removeTarget:self.movieWriter];
        [self.movieWriter finishRecording];
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

@end
