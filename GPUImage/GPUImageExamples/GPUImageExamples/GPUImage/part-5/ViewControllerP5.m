//
//  ViewControllerP5.m
//  GPUImageExamples
//
//  Created by 叮咚钱包富银 on 2018/7/31.
//  Copyright © 2018年 leo. All rights reserved.
//

#import "ViewControllerP5.h"
#import <GPUImage/GPUImage.h>
#import <Masonry.h>
@interface ViewControllerP5 ()
@property (nonatomic , strong) GPUImagePicture *sourcePicture;
@property (nonatomic , strong) GPUImageTiltShiftFilter *sepiaFilter;
@property (nonatomic , strong) GPUImageView *imageView;

@end

@implementation ViewControllerP5

/**
 这次介绍的GPUImageContext、GPUImageFramebufferCache和GPUImagePicture。
 
 GPUImageContext是GPUImage对OpenGL ES上下文的封装，添加了GPUImage相关的上下文，比如说Program的使用缓存，处理队列，CV纹理缓存等。

 GPUImageFramebufferCache是GPUImageFrameBuffer的管理类
 
 GPUImagePicture是PGUImage的图像处理类，继承GPUImageOutput，一般作为响应链的源头。
 
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
    GPUImageView *imageView = [[GPUImageView alloc] init];
    imageView.fillMode = kGPUImageFillModeStretch;
    imageView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.mas_equalTo(64);
    }];
    _imageView = imageView;
    UIImage *inputImage = [UIImage imageNamed:@"face.png"];

    //创建picture
    _sourcePicture = [[GPUImagePicture alloc] initWithImage:inputImage];
    
    //创建filter
    _sepiaFilter = [[GPUImageTiltShiftFilter alloc] init];
    _sepiaFilter.blurRadiusInPixels = 40.0;
    [_sepiaFilter forceProcessingAtSize:imageView.sizeInPixels];
    
    //添加target
    [_sourcePicture addTarget:_sepiaFilter];
    [_sepiaFilter addTarget:imageView];
    
    //开启渲染
    [_sourcePicture processImage];

}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.imageView];
    float rate = point.y / self.view.frame.size.height;
    NSLog(@"Processing -- %f",rate);
    [_sepiaFilter setTopFocusLevel:rate - 0.1];
    [_sepiaFilter setBottomFocusLevel:rate + 0.1];
    [_sourcePicture processImage];
}



@end
