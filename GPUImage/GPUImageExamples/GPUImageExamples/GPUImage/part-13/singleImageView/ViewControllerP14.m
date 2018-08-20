//
//  ViewControllerP14.m
//  GPUImageExamples
//
//  Created by 叮咚钱包富银 on 2018/8/3.
//  Copyright © 2018年 leo. All rights reserved.
//

#import "ViewControllerP14.h"
#import <GPUImage/GPUImage.h>
#import "LYMultiTextureFilter.h"

@interface ViewControllerP14 ()
@property (nonatomic, strong) LYMultiTextureFilter *lyMultiTextureFilter;
@end

@implementation ViewControllerP14
#define MaxRow (2)
#define MaxColumn (3)


/**
 这个方案的特点：
 优点：统一渲染，避免的渲染次数大于屏幕帧率；
 缺点：multiTexFilter实现复杂，画面拼接需要用shader来实现；
 
 GPU对比：多路的GPU消耗比单路的消耗更小！！！

 */
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSArray *fileNamesArray = @[@"abc", @"qwe", @"abc", @"qwe", @"abc", @"qwe"];
    self.lyMultiTextureFilter = [[LYMultiTextureFilter alloc] initWithMaxFilter:fileNamesArray.count];

    for (int indexRow = 0; indexRow < MaxRow; ++indexRow) {
        for (int indexColumn = 0; indexColumn < MaxColumn; ++indexColumn) {
            CGRect frame = CGRectMake(indexColumn * 1.0 / MaxColumn,
                                      indexRow * 1.0 / MaxRow,
                                      1.0 / MaxColumn,
                                      1.0 / MaxRow);
            
    
            //创建movie
            NSURL *videoUrl = [[NSBundle mainBundle] URLForResource:fileNamesArray[indexRow * MaxColumn + indexColumn] withExtension:@"mp4"];
            GPUImageMovie *movie = [[GPUImageMovie alloc] initWithURL:videoUrl];
            movie.playAtActualSpeed = YES;
            movie.shouldRepeat = YES;
            
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
            
            NSInteger index = [self.lyMultiTextureFilter nextAvailableTextureIndex];
            [transformFilter addTarget:self.lyMultiTextureFilter atTextureLocation:index];
            [self.lyMultiTextureFilter setDrawRect:frame atIndex:index];
            

            //开启视频播放
            [movie startProcessing];
            
        }
        
    }
  
    //创建imageview
    GPUImageView *imageView = [[GPUImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    imageView.backgroundColor = [UIColor clearColor];
    imageView.fillMode = kGPUImageFillModeStretch;
    [self.lyMultiTextureFilter addTarget:imageView];
    [self.view addSubview:imageView];
    
}



@end
