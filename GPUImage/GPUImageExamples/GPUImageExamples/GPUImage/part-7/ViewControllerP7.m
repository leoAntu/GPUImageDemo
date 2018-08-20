//
//  ViewControllerP7.m
//  GPUImageExamples
//
//  Created by 叮咚钱包富银 on 2018/8/1.
//  Copyright © 2018年 leo. All rights reserved.
//

#import "ViewControllerP7.h"
#import <GPUImage/GPUImage.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
@interface ViewControllerP7 ()
@property (nonatomic, strong) GPUImageVideoCamera     *videoCamera;
@property (nonatomic , strong) GPUImageMovieWriter *movieWriter;
@property (nonatomic , strong) GPUImageDissolveBlendFilter *filter;
@property (nonatomic , strong) GPUImageMovie *movie;

@property (nonatomic , copy) NSString *pathToMovie;
@property (nonatomic , strong) NSURL *movieURL;
@property (nonatomic , strong) UILabel  *mLabel;

@end

@implementation ViewControllerP7

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.mLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 100, 100)];
    self.mLabel.textColor = [UIColor redColor];
    [self.view addSubview:self.mLabel];
    
    //创建camera
    _videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition:AVCaptureDevicePositionBack];
    _videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    //处理录制视频闪一下，出现丢帧
    [self.videoCamera addAudioInputsAndOutputs];
    
    //movieWriter
    //录制初始化，先存沙盒
    _pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/shuiyin.m4v"];
    unlink([_pathToMovie UTF8String]); // 如果已经存在文件，AVAssetWriter会有异常，删除旧文件
    _movieURL = [NSURL fileURLWithPath:_pathToMovie];
    _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:_movieURL size:CGSizeMake(480, 640)];
    _movieWriter.encodingLiveVideo = YES;  //encodingLiveVideo影响的其实是expectsMediaDataInRealTime属性，YES时用于输入流是实时的，比如说摄像头。
    _movieWriter.shouldPassthroughAudio = YES;
  
    //创建movie
    NSURL *sampleURL = [[NSBundle mainBundle] URLForResource:@"abc" withExtension:@"mp4"];
    _movie = [[GPUImageMovie alloc] initWithURL:sampleURL];
    _movie.runBenchmark = YES;
    _movie.playAtActualSpeed = YES;
    
    //创建滤镜
    //    GPUImageDissolveBlendFilter类继承GPUImageTwoInputFilter，添加属性mix作为片元着色器的mix参数。GPUImageDissolveBlendFilter在响应链上需要接受两个输入，当两个输入都就绪时，会通过mix()操作把输入混合，并且输出到响应链上。
    self.filter = [[GPUImageDissolveBlendFilter alloc] init];
    self.filter.mix = 0.5;
    
    //添加响应链
    //选择哪个音频播放。NO 选择摄像头中麦克风, YES 选择movie中音频
//    音频的来源不同会导致CMTime的不同，响应链视频信息的CMTime默认采用第一个输入的CMTime，故而修改音频来源的时候需要修改响应链的输入顺序，否则几秒钟的视频文件会产生两个多小时的文件（CMTime不同步导致）。
    
    Boolean audioFromFile = NO;
    if (audioFromFile) {
        //添加响应链
        [_movie addTarget:_filter];
        [_videoCamera addTarget:_filter];
        //添加麦克风target
        _movie.audioEncodingTarget = _movieWriter;
        [_movie enableSynchronizedEncodingUsingMovieWriter:_movieWriter];
    } else {
        //添加响应链
        [_videoCamera addTarget:_filter];
        [_movie addTarget:_filter];
        //添加麦克风target
        _videoCamera.audioEncodingTarget = _movieWriter;
    }
    
    //显示到界面
    [_filter addTarget:(GPUImageView *)self.view];
    [_filter addTarget:_movieWriter];
    
    //开启摄像头
    [_videoCamera startCameraCapture];
    //开启movieWriter
    [_movieWriter startRecording];
    //开启视频播放
    [_movie startProcessing];
    
    //监听横竖屏
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];

    __block  CADisplayLink* dlink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateProgress)];
    [dlink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [dlink setPaused:NO];
    
    //写入完成回掉
    __weak typeof(self) weakSelf = self;
    _movieWriter.completionBlock = ^{
        [weakSelf.movie cancelProcessing];
        [weakSelf.filter removeTarget:weakSelf.movieWriter];
        [weakSelf.movieWriter finishRecording];
        [dlink invalidate];

        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(weakSelf.pathToMovie)) {
            [library writeVideoAtPathToSavedPhotosAlbum:weakSelf.movieURL completionBlock:^(NSURL *assetURL, NSError *error)
             {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     if (error) {
                         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"视频保存失败" message:nil
                                                                        delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                         [alert show];
                     } else {
                         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"视频保存成功" message:nil
                                                                        delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                         [alert show];
                     }
                 });
             }];
        }
        else {
            NSLog(@"error mssg");
        }
    };
}

- (void)updateProgress {
    self.mLabel.text = [NSString stringWithFormat:@"Progress:%d%%", (int)(_movie.progress * 100)];
    [self.mLabel sizeToFit];
}

- (void)deviceOrientationDidChange:(NSNotification *)notification {
    UIInterfaceOrientation orientation = (UIInterfaceOrientation)[UIDevice currentDevice].orientation;
    self.videoCamera.outputImageOrientation = orientation;
}

- (IBAction)closeAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc {
    NSLog(@"%s",__FUNCTION__);
}

@end
