//
//  ViewControllerP13.m
//  GPUImageExamples
//
//  Created by 叮咚钱包富银 on 2018/8/3.
//  Copyright © 2018年 leo. All rights reserved.
//

#import "ViewControllerP13.h"
#import <GPUImage/GPUImage.h>

@interface ViewControllerP13 ()

@end

@implementation ViewControllerP13


/**
 优点：实现简单，画面拼接由UIKit层的API实现；
 缺点：渲染到屏幕的次数增多，渲染频率远大于屏幕显示帧率；
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSArray *fileNamesArray = @[@"abc", @"qwe", @"abc", @"qwe", @"abc", @"qwe"];
    for (NSInteger i = 0; i < fileNamesArray.count; i++) {
        
        CGFloat width = [UIScreen mainScreen].bounds.size.width / 2;
        CGFloat height = [UIScreen mainScreen].bounds.size.height / 3;
        NSInteger row = i / 2;
        NSInteger colum = i % 2;
        CGRect rect = CGRectMake(colum * width, height * row, width, height);
        
        //创建movie
        NSURL *videoUrl = [[NSBundle mainBundle] URLForResource:fileNamesArray[i] withExtension:@"mp4"];
        GPUImageMovie *movie = [[GPUImageMovie alloc] initWithURL:videoUrl];
        movie.playAtActualSpeed = YES;
        movie.shouldRepeat = YES;
        //创建imageview
        GPUImageView *imageView = [[GPUImageView alloc] initWithFrame:rect];
        [self.view addSubview:imageView];

        //创建filter
        // 1080 1920，这里已知视频的尺寸。如果不清楚视频的尺寸，可以先读取视频帧CVPixelBuffer，再用CVPixelBufferGetHeight/Width
        //裁剪filter
        GPUImageCropFilter *cropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake((1920 - 1080) / 2 / 1920, 0, 1080.0 / 1920, 1)];
        //创建转场filter
        GPUImageTransformFilter *transformFilter = [[GPUImageTransformFilter alloc] init];
        transformFilter.affineTransform = CGAffineTransformMakeRotation(M_PI_2);
        //添加target
        [movie addTarget:cropFilter];
        
        [cropFilter addTarget:transformFilter];
        
        [transformFilter addTarget:imageView];
        
        //开启视频播放
        [movie startProcessing];
    }
}


@end
