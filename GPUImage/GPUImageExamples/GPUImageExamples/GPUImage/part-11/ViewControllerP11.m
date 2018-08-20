//
//  ViewControllerP11.m
//  GPUImageExamples
//
//  Created by 叮咚钱包富银 on 2018/8/2.
//  Copyright © 2018年 leo. All rights reserved.
//

#import "ViewControllerP11.h"
#import <GPUImage/GPUImage.h>
#import <GPUImageMovieComposition.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
#import "SimpleEditor.h"

@interface ViewControllerP11 ()
@property (nonatomic , strong) UILabel  *mLabel;
@property (nonatomic, strong) GPUImageMovieWriter *movieWriter;
@property (nonatomic , strong) NSMutableArray *clipTimeRanges;
@property (nonatomic , strong) NSMutableArray *clips;
@property (nonatomic , strong) GPUImageMovieComposition *imageMovieComposition;
@property (nonatomic , strong) SimpleEditor *editor;

@end

@implementation ViewControllerP11

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.editor = [[SimpleEditor alloc] init];
    self.clips = [[NSMutableArray alloc] init];
    self.clipTimeRanges = [[NSMutableArray alloc] init];
    
    [self setupEditingAndPlayback];
}

- (void)setupEditingAndPlayback {
    AVURLAsset *asset3 = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"abc" ofType:@"mp4"]]];
    AVURLAsset *asset2 = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"qwe" ofType:@"mp4"]]];
    dispatch_group_t dispatchGroup = dispatch_group_create();
    NSArray *assetKeysToLoadAndTest = @[@"tracks", @"duration", @"composable"];
    
    // 加载视频
    [self loadAsset:asset2 withKeys:assetKeysToLoadAndTest usingDispatchGroup:dispatchGroup];
    [self loadAsset:asset3 withKeys:assetKeysToLoadAndTest usingDispatchGroup:dispatchGroup];
    
    // 等待就绪
    dispatch_group_notify(dispatchGroup, dispatch_get_main_queue(), ^(){
        [self synchronizeWithEditor];
    });
}

- (void)loadAsset:(AVAsset *)asset withKeys:(NSArray *)assetKeysToLoad usingDispatchGroup:(dispatch_group_t)dispatchGroup {
    dispatch_group_enter(dispatchGroup);
    [asset loadValuesAsynchronouslyForKeys:assetKeysToLoad completionHandler:^(){
        // 测试是否成功加载
        BOOL bSuccess = YES;
        for (NSString *key in assetKeysToLoad) {
            NSError *error;
            
            if ([asset statusOfValueForKey:key error:&error] == AVKeyValueStatusFailed) {
                NSLog(@"Key value loading failed for key:%@ with error: %@", key, error);
                bSuccess = NO;
                break;
            }
        }
        if (![asset isComposable]) {
            NSLog(@"Asset is not composable");
            bSuccess = NO;
        }
        if (bSuccess && CMTimeGetSeconds(asset.duration) > 5) {
            [self.clips addObject:asset];
            [self.clipTimeRanges addObject:[NSValue valueWithCMTimeRange:CMTimeRangeMake(CMTimeMakeWithSeconds(0, 1), CMTimeMakeWithSeconds(5, 1))]];
        }
        else {
            NSLog(@"error ");
        }
        dispatch_group_leave(dispatchGroup);
    }];
}

- (void)synchronizePlayerWithEditor {
    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
    unlink([pathToMovie UTF8String]);
    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
    
    self.movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(640, 480)];
    
    
    self.imageMovieComposition = [[GPUImageMovieComposition alloc] initWithComposition:self.editor.composition andVideoComposition:self.editor.videoComposition andAudioMix:self.editor.audioMix];
    //    self.imageMovieComposition.playAtActualSpeed = YES;
    self.imageMovieComposition.runBenchmark = YES;
    
    [self.imageMovieComposition addTarget:self.movieWriter];
    [self.imageMovieComposition addTarget:(GPUImageView *)self.view];
    
    [self.imageMovieComposition enableSynchronizedEncodingUsingMovieWriter:self.movieWriter];
    self.imageMovieComposition.audioEncodingTarget = self.movieWriter;
    
    [_movieWriter startRecording];
    [self.imageMovieComposition startProcessing];

    
    __weak typeof(self) weakSelf = self;
    [_movieWriter setCompletionBlock:^{
        __strong typeof(self) strongSelf = weakSelf;
        
        [strongSelf->_movieWriter finishRecording];
        [strongSelf->_imageMovieComposition endProcessing];
        
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

- (void)synchronizeWithEditor {
    // Clips
    [self synchronizeEditorClipsWithOurClips];
    [self synchronizeEditorClipTimeRangesWithOurClipTimeRanges];
    
    self.editor.transitionDuration = CMTimeMakeWithSeconds(1, 600);
    [self.editor buildCompositionObjectsForPlayback];
    [self synchronizePlayerWithEditor];
    
}

- (void)synchronizeEditorClipsWithOurClips {
    NSMutableArray *validClips = [NSMutableArray array];
    for (AVURLAsset *asset in self.clips) {
        if (![asset isKindOfClass:[NSNull class]]) {
            [validClips addObject:asset];
        }
    }
    
    self.editor.clips = validClips;
}

- (void)synchronizeEditorClipTimeRangesWithOurClipTimeRanges {
    NSMutableArray *validClipTimeRanges = [NSMutableArray array];
    for (NSValue *timeRange in self.clipTimeRanges) {
        if (! [timeRange isKindOfClass:[NSNull class]]) {
            [validClipTimeRanges addObject:timeRange];
        }
    }
    
    self.editor.clipTimeRanges = validClipTimeRanges;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
