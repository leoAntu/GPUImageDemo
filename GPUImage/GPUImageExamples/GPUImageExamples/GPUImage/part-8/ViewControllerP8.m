//
//  ViewControllerP8.m
//  GPUImageExamples
//
//  Created by 叮咚钱包富银 on 2018/8/1.
//  Copyright © 2018年 leo. All rights reserved.
//

#import "ViewControllerP8.h"
#import <GPUImage/GPUImage.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
@interface ViewControllerP8 ()
@property (nonatomic , strong) GPUImageMovieWriter *movieWriter;
@property (nonatomic , strong) GPUImageDissolveBlendFilter *filter;
@property (nonatomic , strong) GPUImageMovie *movie;

@property (nonatomic , copy) NSString *pathToMovie;
@property (nonatomic , strong) NSURL *movieURL;
@property (nonatomic , strong) UILabel  *mLabel;
@end

@implementation ViewControllerP8

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.mLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 100, 100)];
    self.mLabel.textColor = [UIColor redColor];
    [self.view addSubview:self.mLabel];
    
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

    //添加中间filter,目的是每帧回调；去掉会导致图像无法显示。
    GPUImageFilter *progressFilter = [[GPUImageFilter alloc] init];
    [_movie addTarget:progressFilter];
    //添加麦克风target
    _movie.audioEncodingTarget = _movieWriter;
    [_movie enableSynchronizedEncodingUsingMovieWriter:_movieWriter];
    
    // 水印
    CGSize size = self.view.bounds.size;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    label.text = @"我是水印";
    label.font = [UIFont systemFontOfSize:30];
    label.textColor = [UIColor redColor];
    [label sizeToFit];
    UIImage *image = [UIImage imageNamed:@"watermark"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    UIView *subView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    subView.backgroundColor = [UIColor clearColor];
    imageView.center = CGPointMake(subView.bounds.size.width / 2, subView.bounds.size.height / 2);
    [subView addSubview:imageView];
    [subView addSubview:label];
    
    //创建UIElement
    GPUImageUIElement *uielement = [[GPUImageUIElement alloc] initWithView:subView];
    
    //添加响应链
    [progressFilter addTarget:_filter];
    [uielement addTarget:_filter];
    
    //显示到界面
    [_filter addTarget:(GPUImageView *)self.view];
    [_filter addTarget:_movieWriter];

    //开启movieWriter 必须在前面。否则只能到99%，保存失败
    [_movieWriter startRecording];
    //开启视频播放
    [_movie startProcessing];
    
    __block typeof(self) weakSelf = self;
    //回调需要调用update操作；因为update只会输出一次纹理信息，只适用于一帧。不调用就不会显示
    [progressFilter setFrameProcessingCompletionBlock:^(GPUImageOutput *output, CMTime time) {
        CGRect frame = imageView.frame;
        frame.origin.x += 1;
        frame.origin.y += 1;
        imageView.frame = frame;
        [uielement updateWithTimestamp:time];
    }];
    
    //定时器
    __block  CADisplayLink* dlink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateProgress)];
    [dlink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [dlink setPaused:NO];
    
    //写入完成回掉
    _movieWriter.completionBlock = ^{
        [weakSelf.movie endProcessing];
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


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)closeAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc {
    NSLog(@"%s",__FUNCTION__);
}

@end
