# OPenGLES系列学习

## GPUImage系列
#### part-1 初步了解
这是第一篇，介绍GPUImageFilter 和 GPUImageFramebuffer。
假设我们自定义一个OpenGL ES程序来处理图片，那么会有以下几个步骤：
1、初始化OpenGL ES环境，编译、链接顶点着色器和片元着色器；
2、缓存顶点、纹理坐标数据，传送图像数据到GPU；
3、绘制图元到特定的帧缓存；
4、在帧缓存取出绘制的图像。
GPUImageFilter负责的是第一、二、三步。
GPUImageFramebuffer负责是第四步。

#### part-2 使用GPUImageVideoCamera
GPUImageVideoCamera是GPUImageOutput的子类，提供来自摄像头的图像数据作为源数据，一般是响应链的源头。
GPUImage使用AVFoundation框架来获取视频。

#### part-3 实时美颜滤镜（GPUImageBeautifyFilter）

#### part-4 实时美颜滤镜（GPUImageFilter过滤组合）

#### part-5 模糊图片处理

#### part-6 滤镜视频录制（怀旧滤镜类型）

#### part-7 用视频做摄像头视频水印

#### part-8 给视频文字水印和动态图像水印

#### part-9 视频合并混音

#### part-10 图像的输入输出和滤镜通道

#### part-11 用GPUImage和指令配合合并视频

#### part-12 Sobel边界检测滤镜

#### part-13 多路视频绘制 方案1：多个gpuimageview绘制

#### part-14 多路视频绘制 方案2：单个gpuimageview绘制

#### part-15 多路视频绘制 方案3：屏幕帧率驱动的单GPUImageView方案


## GLKit系列
####  [lession-1-GLKit](https://github.com/leoAntu/OpenGLES/tree/master/OpenGL%20ES/lesson-1-GLKit)
* 初步了解OC中GLKit（ GLKit框架的设计目标是为了简化基于OpenGL或者OpenGL ES的应用开发）框架
* 了解OpenGL中顶点坐标系和纹理坐标系
* 简单的通过GLKit框架绘制一张图片GLKView上显示




