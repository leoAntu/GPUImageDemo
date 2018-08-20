//
//  ViewController.m
//  lesson-1-GLKit
//
//  Created by 叮咚钱包富银 on 2018/6/28.
//  Copyright © 2018年 leo. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<GLKViewDelegate>
@property (nonatomic, strong) EAGLContext *content; //上下文
@property (nonatomic, strong) GLKBaseEffect *mEffect; //着色器
@property (nonatomic, assign) NSInteger type; //0正常绘制，1. 思考题1
@property (nonatomic , assign) int mCount;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.type = 0;
    //正常操作三步曲
//    [self setConfig];
//
//    [self setVertexArray];
//
//    [self setTexture];
    
    
    //思考题1： 可以使用四个顶点，绘制2个三角形 的6个顶点中有2个是重复的，使用索引可以减少重复。
//    [self test1];
    
//    思考题2：如果把这个图变成左右两只对称的熊猫，该如何改？把屏幕切分成4个三角形，左边两个三角形同上，右边两个三角形的纹理坐标的x值调整即可。
    [self test2];
}

//创建上下文
- (void)setConfig {
    self.content = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    GLKView *view = (GLKView *)self.view;
    view.delegate = self;
    view.context = self.content;
    //设置颜色缓冲区格式
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    [EAGLContext setCurrentContext:self.content];
}

//设置顶点坐标
- (void)setVertexArray {
    //顶点数据，前三个是顶点坐标（x、y、z轴），后面两个是纹理坐标（x，y）
    //顶点坐标，OpenGLES的世界坐标系是[-1, 1]，故而点(0, 0)是在屏幕的正中间。
//      [-1,1] 左上                [1,1]右上
//                  [0,0] 中间
//      [-1,-1] 左下                [1,-1]右下
    
//    纹理坐标系的取值范围是[0, 1]，原点是在左下角。故而点(0, 0)在左下角，点(1, 1)在右上角。
//       [0,1] 左上        [1, 1]右上
//
//       [0,0] 左下        [1, 0]右下
    
//    索引数组是顶点数组的索引，把squareVertexData数组看成4个顶点，每个顶点会有5个GLfloat数据，索引从0开始。
    
    //顶点坐标没有使用z轴，所以全部为0
    
//    OpenGL只支持 顶点、线段、三角形 的渲染，所以vertexData是6组数据，
    //使用六个顶点渲染一个图片位置，有两个顶点是重合（类似一个四边形，从对角线分开成两个三角形）
    GLfloat vertexData[] = {
        //左边三角形坐标
        -0.5, 0.5, 0.0f,    0.0f, 1.0f, //左上
        0.5, 0.5, 0.0f,    1.0f, 1.0f, //右上
        0.5, -0.5, 0.0f,    1.0f, 0.0f, //右下
        //右边三角坐标
        0.5, -0.5, 0.0f,    1.0f, 0.0f, //右下
        -0.5, 0.5, 0.0f,    0.0f, 1.0f, //左上
        -0.5, -0.5, 0.0f,   0.0f, 0.0f, //左下
    };
    
    //顶点数据缓存
    GLuint buffer;
//    glGenBuffers申请一个标识符
    glGenBuffers(1, &buffer);
//    glBindBuffer把标识符绑定到GL_ARRAY_BUFFER上
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    //    glBufferData把顶点数据从cpu内存复制到gpu内存
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertexData), vertexData, GL_STATIC_DRAW);

    //glEnableVertexAttribArray 是开启对应的顶点属性
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    
//  传递顶点着色器的位置信息。  glVertexAttribPointer设置合适的格式从buffer里面读取数据
    //    void glVertexAttribPointer(GLuint index, GLint size, GLenum type, GLboolean normalized, GLsizei stride,const GLvoid * pointer)
//    参数意义如下：
//    index：顶点数据在着色器程序中的属性，这里即GLKVertexAttribPosition。
//    size：每个顶点属性的组件数量，这里3表示每个顶点由三个元素组成，如0.0f, 0.5f, 0.0f。
//    type：每个顶点属性的组件类型，这里即GL_FLOAT。
//    normalized：指定当被访问时，固定点数据值是否应该被归一化或直接转换成固定点值，这里即GL_FALSE。
    //    stride：指定相邻两个顶点数据之间的偏移量，即间隔大小。OpenGL根据该间隔从由多个顶点数据组成的数据块中跳跃地读取相应的顶点数据，这里相邻两个顶点数据之间的间隔设置为 sizeof(float) * 5 。  5个float长度代表一个顶点数据的长度
    //ptr: 面定义数组时是x y z，s t这种形式，前三个是顶点坐标，后两个是纹理坐标，所以纹理坐标得跳过x y z三个数设置为+3,顶点坐标设置为0
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat *)NULL + 0);

    glEnableVertexAttribArray(GLKVertexAttribTexCoord0); //开启纹理坐标属性
    //给数组赋值
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat *)NULL + 3);
}

//设置着色器
- (void)setTexture {
    //纹理贴图
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"1" ofType:@"png"];
    NSDictionary* options = [NSDictionary dictionaryWithObjectsAndKeys:@(1), GLKTextureLoaderOriginBottomLeft, nil];//GLKTextureLoaderOriginBottomLeft 纹理坐标系是相反的
    //GLKTextureLoader 读取图片，或者图片info
    GLKTextureInfo* textureInfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:nil];
    //创建着色器
    self.mEffect = [[GLKBaseEffect alloc] init];
    self.mEffect.texture2d0.enabled = GL_TRUE;
    //把纹理赋值给着色器
    self.mEffect.texture2d0.name = textureInfo.name;
}

#pragma mark -- delegate
/**
 渲染场景
 */
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClearColor(0.3f, 0.6f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    //启动着色器
    [self.mEffect prepareToDraw];
    
    if (self.type == 0) {
        //6代表绘制6个顶点
        glDrawArrays(GL_TRIANGLES, 0, 6);
        
    } else if (self.type == 1) {
        //6代表绘制6个顶点
        glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_BYTE, 0);
    } else if (self.type == 2) {
        //12代表绘制12个顶点
        glDrawElements(GL_TRIANGLES, 12, GL_UNSIGNED_BYTE, 0);
    }
}

#pragma mark -- 思考题1
- (void)test1 {
    self.type = 1;
    //创建上下文
    [self setConfig];
    
    //设置坐标
    GLfloat vertexData[] = {
        -0.5, 0.5, 0.0f,    0.0f, 1.0f, //左上
        0.5, 0.5, 0.0f,    1.0f, 1.0f, //右上
        0.5, -0.5, 0.0f,    1.0f, 0.0f, //右下
        -0.5, -0.5, 0.0f,   0.0f, 0.0f, //左下
    };
    
    
    //顶点索引
//    0,1,2 代表在vertexData的取值，没三个代表代表绘制一个三角形
    GLbyte indices[] =
    {
        0, 1, 2,
        2, 3, 0
    };
    
    //顶点数据缓存
    GLuint buffer;
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertexData), vertexData, GL_STATIC_DRAW);
    
    GLuint texturebuffer;
    glGenBuffers(1, &texturebuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, texturebuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition); //顶点数据缓存
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat *)NULL + 0);
    
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0); //纹理
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat *)NULL + 3);
    
    //设置纹理贴图
    [self setTexture];
}

#pragma mark -- 思考题2

- (void)test2 {
    self.type = 2;

    [self setConfig];
    //       [0,1] 左上        [1, 1]右上
    //
    //       [0,0] 左下        [1, 0]右下
    
    //设置坐标
    //两张图片对称，主要是对称的一方把纹理坐标反过来
    GLfloat vertexData[] = {
        //左边图片顶点坐标
        -1, 0.5, 0.0f, 0.0f, 1.0f, //左上
        -1, -0.5, 0.0f, 0.0f, 0.0f, //左下
        0.0, -0.5, 0.0f, 1.0f, 0.0f, //中下
        0.0, 0.5, 0.0f, 1.0f, 1.0f, //中上
        
        //绘制右边图片顶点坐标
        1, -0.5, 0.0f, 0.0f, 0.0f, //右下
        1, 0.5, -0.0f, 0.0f, 1.0f, //右上
        0.0, 0.5, 0.0f, 1.0f, 1.0f, //中上
        0.0, -0.5, 0.0f, 1.0f, 0.0f, //中下
        
    };
    
    //顶点索引
    //    0,1,2 代表在vertexData的取值，没三个代表代表绘制一个三角形
    GLbyte indices[] =
    {
        0, 1, 2,
        2, 3, 0,
        
        4, 5, 6,
        6, 7, 4
    };
    
    
    //顶点数据缓存
    GLuint buffer;
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertexData), vertexData, GL_STATIC_DRAW);
    
    GLuint texturebuffer;
    glGenBuffers(1, &texturebuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, texturebuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition); //顶点数据缓存
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat *)NULL + 0);
    
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0); //纹理
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat *)NULL + 3);
    
    //设置纹理贴图
    //纹理贴图
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"for_test" ofType:@"jpg"];
    NSDictionary* options = [NSDictionary dictionaryWithObjectsAndKeys:@(1), GLKTextureLoaderOriginBottomLeft, nil];//GLKTextureLoaderOriginBottomLeft 纹理坐标系是相反的
    //GLKTextureLoader 读取图片，或者图片info
    GLKTextureInfo* textureInfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:nil];
    //创建着色器
    self.mEffect = [[GLKBaseEffect alloc] init];
    self.mEffect.texture2d0.enabled = GL_TRUE;
    //把纹理赋值给着色器
    self.mEffect.texture2d0.name = textureInfo.name;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
