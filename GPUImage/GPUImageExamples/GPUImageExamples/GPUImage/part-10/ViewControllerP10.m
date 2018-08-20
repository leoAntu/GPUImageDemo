//
//  ViewControllerP10.m
//  GPUImageExamples
//
//  Created by 叮咚钱包富银 on 2018/8/2.
//  Copyright © 2018年 leo. All rights reserved.
//

#import "ViewControllerP10.h"
#import <GPUImage/GPUImage.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
@interface ViewControllerP10 ()
@property (weak, nonatomic) IBOutlet UIImageView *mImageView;
@property (nonatomic , strong) UILabel  *mLabel;
@property (nonatomic , strong) GPUImageRawDataOutput *mOutput;
@property (nonatomic , strong) GPUImageVideoCamera *videoCamera;
@property (nonatomic , strong) CADisplayLink* dlink;

@end

@implementation ViewControllerP10

/**
 纹理输入输出GPUImageTextureInpput 和 GPUImageTextureOutput
 二进制数据输入输出GPUImageRawDataInput 和 GPUImageRawDataOutput
 
 GPUImageTextureOutput和GPUImageTextureInput用于GPUImage和OpenGL ES之间的协调，
 GPUImageRawDataOutput和GPUImageRawDataInput用于GPUImage和UIKit之间的协调,
 GPUImageFilterPipeline用于把多个滤镜简单串联。

 */
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.mLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 200, 100)];
    self.mLabel.textColor = [UIColor redColor];
    [self.view addSubview:self.mLabel];
    
    //创建摄像头
    _videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition:AVCaptureDevicePositionFront];
    //防止黑屏
    [_videoCamera addAudioInputsAndOutputs];
    _videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    _videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    
    //创建output
    _mOutput = [[GPUImageRawDataOutput alloc] initWithImageSize:CGSizeMake(640, 480) resultsInBGRAFormat:YES];
    
    //添加target
    [_videoCamera addTarget:_mOutput];
    
    //获取每一帧的回调
    __weak typeof(self) weakSelf = self;
    __weak typeof(self.mOutput) weakMoutput = self.mOutput;
    [_mOutput setNewFrameAvailableBlock:^{
        
        @autoreleasepool {
            //锁住当前buffer
            [weakMoutput lockFramebufferForReading];
            GLubyte *ouputBytes = [weakMoutput rawBytesForImage];
            NSInteger bytesPerRow = [weakMoutput bytesPerRowInOutput];
//            //获取当前帧的pixelBuffer
//            //CVPixelBufferRef里包含很多图片相关属性，比较重要的有 width，height，PixelFormatType等。
//            CVPixelBufferRef pixelBuffer = NULL;
//            CVReturn ret = CVPixelBufferCreateWithBytes(kCFAllocatorDefault, 640, 480, kCVPixelFormatType_32BGRA, ouputBytes, bytesPerRow, nil, nil, nil, &pixelBuffer);
//            if (ret != kCVReturnSuccess) {
//                NSLog(@"status %d", ret);
//            }
//            //解锁当前buffer
            [weakMoutput unlockFramebufferAfterReading];
//            if (pixelBuffer == NULL) {
//                return;
//            }
            
            //获取CGImageRef
            CGColorSpaceRef rgbSpaceRef = CGColorSpaceCreateDeviceRGB();
            CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, ouputBytes, bytesPerRow * 480, NULL);
            CGImageRef cgImage = CGImageCreate(640, 480, 8, 32, bytesPerRow, rgbSpaceRef, kCGImageAlphaPremultipliedFirst|kCGBitmapByteOrder32Little, provider, NULL, true, kCGRenderingIntentDefault);
            
            //cgimageRef 转化成uiimage
            UIImage *image = [UIImage imageWithCGImage:cgImage];
            [weakSelf updateWithImage:image];
            
            //释放内存
            CGImageRelease(cgImage);
//            CFRelease(pixelBuffer);
        }
    }];
    
    //开启摄像头
    [_videoCamera startCameraCapture];
    _dlink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateProgress)];
    [_dlink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [_dlink setPaused:NO];
}

- (void)updateWithImage:(UIImage *)image {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.mImageView.image = image;
    });
}

- (void)updateProgress
{
    self.mLabel.text = [[NSDate dateWithTimeIntervalSinceNow:0] description];
    [self.mLabel sizeToFit];
}

- (IBAction)closeAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc {
    NSLog(@"%s",__FUNCTION__);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_dlink invalidate];
}

@end
