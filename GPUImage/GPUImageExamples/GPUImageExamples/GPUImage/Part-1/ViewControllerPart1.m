
//
//  ViewControllerPart1.m
//  GPUImageExamples
//
//  Created by 叮咚钱包富银 on 2018/7/31.
//  Copyright © 2018年 leo. All rights reserved.
//

#import "ViewControllerPart1.h"
#import <GPUImage/GPUImage.h>
#import <Masonry.h>
@interface ViewControllerPart1 ()
@property (nonatomic , strong) UIImageView* mImageView;

@end

@implementation ViewControllerPart1

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.mImageView];
//    self.mImageView.contentMode = UIViewContentModeScaleToFill;
    [self.mImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(64);
        make.bottom.left.right.equalTo(self.view);
    }];
    
    [self onCustom];
}

- (void)onCustom {
    GPUImageFilter *filter = [[GPUImageFilter alloc] init];
    UIImage *image = [UIImage imageNamed:@"face"];
    if (image) {
        self.mImageView.image = [filter imageByFilteringImage:image];
    }
}


@end
