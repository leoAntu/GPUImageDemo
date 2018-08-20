//
//  ViewControllerP9.m
//  GPUImageExamples
//
//  Created by 叮咚钱包富银 on 2018/8/1.
//  Copyright © 2018年 leo. All rights reserved.
//

#import "ViewControllerP9.h"
#import <GPUImage/GPUImage.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
#import "THImageMovieWriter.h"
#import "THImageMovie.h"

@interface ViewControllerP9 ()
@property (nonatomic , strong) UILabel  *mLabel;
@property (nonatomic, strong) THImageMovieWriter *movieWriter;
@property (nonatomic, strong) THImageMovie *movie1;
@property (nonatomic, strong) THImageMovie *movie2;
@property (nonatomic, strong) GPUImageDissolveBlendFilter *filter;

@end

@implementation ViewControllerP9

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 100, 100)];
    self.mLabel.textColor = [UIColor redColor];
    [self.view addSubview:self.mLabel];
    
    //创建filter
    _filter = [[GPUImageDissolveBlendFilter alloc] init];
    _filter.mix = 1;
    
    //创建播放movie
    NSURL *sampleURL = [[NSBundle mainBundle] URLForResource:@"abc" withExtension:@"mp4"];
    NSDictionary *inputOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *inputAsset = [[AVURLAsset alloc] initWithURL:sampleURL options:inputOptions];
    _movie1 = [[THImageMovie alloc] initWithAsset:inputAsset];
    _movie1.runBenchmark = YES;
    _movie1.playAtActualSpeed = YES;
    
    NSURL *sampleURL2 = [[NSBundle mainBundle] URLForResource:@"qwe" withExtension:@"mp4"];
    AVURLAsset *inputAsset2 = [[AVURLAsset alloc] initWithURL:sampleURL2 options:inputOptions];
    _movie2 = [[THImageMovie alloc] initWithAsset:inputAsset2];
    _movie2.runBenchmark = YES;
    _movie2.playAtActualSpeed = YES;
    
    NSArray *moveiesArr = @[_movie1,_movie2];
    
    //创建moviewWriter
    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
    unlink([pathToMovie UTF8String]);
    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
    _movieWriter = [[THImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(640, 480) movies:moveiesArr];
    
    //添加响应链
    [_movie2 addTarget:_filter];
    [_movie1 addTarget:_filter];

    //显示到界面
    [_filter addTarget:(GPUImageView *)self.view];
    [_filter addTarget:_movieWriter];
    
    //开启播放和录制
    [_movie1 startProcessing];
    [_movie2 startProcessing];
    [_movieWriter startRecording];
    
    CADisplayLink* dlink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateProgress)];
    [dlink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [dlink setPaused:NO];
    
    __weak typeof(self) weakSelf = self;
    [_movieWriter setCompletionBlock:^{
        [weakSelf.filter removeTarget:weakSelf.movieWriter];
        [weakSelf.movie1 endProcessing];
        [weakSelf.movie2 endProcessing];
        [weakSelf.movieWriter finishRecording];
        
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(pathToMovie))
        {
            [library writeVideoAtPathToSavedPhotosAlbum:movieURL completionBlock:^(NSURL *assetURL, NSError *error)
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
            NSLog(@"error mssg)");
        }
    }];
}

- (void)updateProgress
{
    self.mLabel.text = [NSString stringWithFormat:@"Progress:%d%%", (int)(self.movie1.progress * 100)];
    [self.mLabel sizeToFit];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


@end
