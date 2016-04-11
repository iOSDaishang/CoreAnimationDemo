//
//  DemoViewController.m
//  CoreAnimationDemo
//
//  Created by Dai on 16/1/21.
//  Copyright © 2016年 daishang. All rights reserved.
//

#import "DemoViewController.h"

#define WIDTH 50

@interface DemoViewController ()
/**
 *  雪花飘落动画根图层
 */
@property (nonatomic ,strong) CALayer *layer;
/**
 *  弹簧动画效果的iamgeView
 */
@property (nonatomic ,strong) UIImageView *imageView;

@end

@implementation DemoViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //为何加载动画放在这里而不是viewDidLoad中，和viewController的生命周期有关，详情请看http://www.jianshu.com/p/85c98a9e93eb
    [self createDemoAnimation];
    [self createBackButton];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
}
//返回按钮
-(void)createBackButton
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame     = CGRectMake(5, 20, 100, 30);
    btn.backgroundColor = [UIColor grayColor];
    [btn setTitle:@"返回" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(clickBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}
//点击按钮事件
-(void)clickBtn
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)createDemoAnimation
{
//    if (self.demoNum == 0)
//    {
//        [self createDemo0];
//    }
//    else if (self.demoNum == 1)
//    {
//        [self createDemo1];
//    }
    
    switch (self.demoNum)
    {
        case 0:
            [self createDemo0];
            break;
        case 1:
            [self createDemo1];
            break;
        case 2:
            [self createDemo2];
            break;
        default:
            break;
    }
}
//点击变大变小
-(void)createDemo0
{
    CGSize size = [UIScreen mainScreen].bounds.size;
    
    //获得根图层
    CALayer *layer1 = [[CALayer alloc] init];

    layer1.backgroundColor = [UIColor colorWithRed:0 green:146/255.0 blue:1.0 alpha:1.0].CGColor;
    //设置中心点
    layer1.position = CGPointMake(size.width/2, size.height/2);
    //设置大小
    layer1.bounds = CGRectMake(0, 0, WIDTH, WIDTH);
    //设置圆角
    layer1.cornerRadius  = WIDTH/2;
    //设置阴影
    layer1.shadowColor   = [UIColor grayColor].CGColor;
    layer1.shadowOffset  = CGSizeMake(2, 2);
    layer1.shadowOpacity = 0.9;//透明度
    
    [self.view.layer addSublayer:layer1];
}

-(void)createDemo1
{
    //设置背景
    UIImage *backImage  = [UIImage imageNamed:@"snow.jpg"];
    UIImageView *imageV = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    imageV.image        = backImage;
    [self.view addSubview:imageV];
    //    self.view.backgroundColor = [UIColor colorWithPatternImage:backImage];
    
    //自定义一个图层
    self.layer          = [[CALayer alloc] init];
    self.layer.frame    = CGRectMake(0, 0, 20, 20);
    self.layer.position = CGPointMake(50, 150);
    self.layer.contents = (id)[UIImage imageNamed:@"snowflake"].CGImage;
    [self.view.layer addSublayer:self.layer];
    
    //创建动画
    [self groupAnimation];
}

-(void)createDemo2
{
    self.imageView        = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tennis_ball"]];
    self.imageView.center = CGPointMake(160, 100);
    [self.view addSubview:self.imageView];
}

#pragma mark -
#pragma mark ----点击放大、弹簧动画
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    //获取点击坐标
    UITouch *touch   = [touches anyObject];
    CGPoint location = [touch locationInView:self.view];
    
    if (self.demoNum == 0)
    {
        CALayer *layer1 = self.view.layer.sublayers[0];
        CGFloat width   = layer1.bounds.size.width;
        if (self.demoNum == 0)
        {
            width = (width == WIDTH)?(WIDTH*4):WIDTH;
        }
        layer1.bounds       = CGRectMake(0, 0, width, width);
        layer1.position     = [touch locationInView:self.view];
        layer1.cornerRadius = width/2;
    }
    else if (self.demoNum == 2)
    {
        /**
         创建弹性动画
         
         damping:阻尼，范围0-1，阻尼越接近于0，弹性效果越明显
         velocitu:弹性复位的速度
         */
        [UIView animateWithDuration:5.0 delay:0 usingSpringWithDamping:0.1 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.imageView.center = location;
        } completion:nil];
    }
    
}

#pragma mark -
#pragma mark ----雪景动画
//基础旋转动画
-(CABasicAnimation *)rotationAnimation
{
    CABasicAnimation *basicAnimation   = [CABasicAnimation animationWithKeyPath:@"transform"];
    CGFloat toValue                    = M_PI_2*3;
    basicAnimation.toValue             = [NSNumber numberWithFloat:toValue];
    //    basicAnimation.duration = 6.0;
    basicAnimation.autoreverses        = true;
    basicAnimation.repeatCount         = HUGE_VALF;
    basicAnimation.removedOnCompletion = NO;
    
    [basicAnimation setValue:[NSNumber numberWithFloat:toValue] forKey:@"KCBasicAnimationProperty_ToValue"];
    return basicAnimation;
}

//关键帧移动动画
-(CAKeyframeAnimation *)translationAnimation
{
    CAKeyframeAnimation *keyframeAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    
    CGPoint endPoint         = CGPointMake(55, 400);
    CGMutablePathRef  path   = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, self.layer.position.x, self.layer.position.y);
    CGPathAddCurveToPoint(path, NULL, 160, 280, -30, 300, endPoint.x, endPoint.y);
    
    keyframeAnimation.path   = path;
    CGPathRelease(path);
    
    [keyframeAnimation setValue:[NSValue valueWithCGPoint:endPoint] forKey:@"KCBasicAnimationProperty_EndPosition"];
    
    return keyframeAnimation;
}
//创建动画组
-(void)groupAnimation
{
    //1.创建动画组
    CAAnimationGroup *animationGroup       = [CAAnimationGroup animation];
    
    //2.设置组中的动画和其他属性
    CABasicAnimation *basicAnimation       = [self rotationAnimation];
    CAKeyframeAnimation *keyframeAnimation = [self translationAnimation];
    animationGroup.animations              = @[basicAnimation,keyframeAnimation];
    
    //设置动画时间，如果动画组中已经设置过动画属性则不再生效
//    animationGroup.duration                = 10.0;
    animationGroup.duration                = 10;
    animationGroup.beginTime               = CACurrentMediaTime()+2;//延迟2秒执行
    animationGroup.delegate                = self;
    //3.给图层添加动画
    [self.layer addAnimation:animationGroup forKey:nil];
}

#pragma mark ----动画组代理方法
//动画完成
-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    CAAnimationGroup *animationGroup       = (CAAnimationGroup *)anim;
    CABasicAnimation *basicAnimation       = (CABasicAnimation *)animationGroup.animations[0];
    CAKeyframeAnimation *keyframeAnimation = (CAKeyframeAnimation *)animationGroup.animations[1];
    CGFloat toValue                        = [[basicAnimation valueForKey:@"KCBasicAnimationProperty_ToValue"] floatValue];
    CGPoint endPoint                       = [[keyframeAnimation valueForKey:@"KCBasicAnimationProperty_EndPosition"] CGPointValue];
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    //设置动画最终状态
    self.layer.position  = endPoint;
    self.layer.transform = CATransform3DMakeRotation(toValue, 0, 0, 1);
    
    [CATransaction commit];
}

@end
