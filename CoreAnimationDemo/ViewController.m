//
//  ViewController.m
//  CoreAnimationDemo
//
//  Created by Dai on 16/1/21.
//  Copyright © 2016年 daishang. All rights reserved.
//

#import "ViewController.h"
#import "DemoViewController.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic ,strong) UITableView *myTable;

@property (nonatomic ,strong) CAShapeLayer *layer;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    

    [self createTableView];
    
    /**
     *  没有动画切换的时候可以直接把雪花飘落动画在viewDidLoad中加载，而有视图或者动画切换的时候需要写在viewWillAppear或者viewDidAppear中。因此我在viewcontroller和DemoViewController中都保留了雪花飘落动画为了更清楚的看到这个问题。
     */
//    [self createDemo1];//雪花飘落动画
    
}

-(void)createTableView
{
    _myTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height -64) style:UITableViewStylePlain];
    
    _myTable.delegate        = self;
    _myTable.dataSource      = self;
    _myTable.tableFooterView = [[UIView alloc] init];
    
    [self.view addSubview:_myTable];
}

#pragma mark ----tableView代理
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
//    cell.backgroundColor  = [UIColor grayColor];
    cell.textLabel.text   = [NSString stringWithFormat:@"demo%ld",indexPath.row];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DemoViewController *demoVC = [[DemoViewController alloc] init];
    demoVC.demoNum             = indexPath.row;
    [self presentViewController:demoVC animated:YES completion:nil];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
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
    self.layer          = [[CAShapeLayer alloc] init];
    self.layer.frame    = CGRectMake(0, 0, 20, 20);
    self.layer.position = CGPointMake(50, 150);
    self.layer.contents = (id)[UIImage imageNamed:@"snowflake"].CGImage;
    [self.view.layer addSublayer:self.layer];
    
    //创建动画
    [self groupAnimation];
}

#pragma mark -
#pragma mark ----雪景动画
//基础旋转动画
-(CABasicAnimation *)rotationAnimation
{
    CABasicAnimation *basicAnimation   = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
//    CGFloat fromeValue               = M_PI_2;
    CGFloat toValue                    = M_PI_2*3;
    //设置动画属性初始值、结束值
//    basicAnimation.fromValue         = [NSNumber numberWithFloat:fromeValue];
    basicAnimation.toValue             = [NSNumber numberWithFloat:toValue];
    //    basicAnimation.duration = 6.0;
    basicAnimation.autoreverses        = true;//旋转后再旋转到原来的位置
    basicAnimation.repeatCount         = HUGE_VALF;//设置无线循环，HUGE_VALF可看做无穷大，起到循环动画的效果
    basicAnimation.removedOnCompletion = NO;
    
    //存储当前位置在动画结束后使用
    [basicAnimation setValue:[NSNumber numberWithFloat:toValue] forKey:@"KCBasicAnimationProperty_ToValue"];
    return basicAnimation;
}

//关键帧移动动画
-(CAKeyframeAnimation *)translationAnimation
{
    CAKeyframeAnimation *keyframeAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    
    //绘制贝塞尔曲线
    /**
     *  二次贝塞尔曲线
     *
     *  @param c#>   图形上下文 description#>
     *  @param cpx#> 控制点x坐标 description#>
     *  @param cpy#> 控制点y坐标 description#>
     *  @param x#>   结束点x坐标 description#>
     *  @param y#>   技术点y坐标 description#>
     *
     */
//    CGContextAddQuadCurveToPoint(<#CGContextRef  _Nullable c#>, <#CGFloat cpx#>, <#CGFloat cpy#>, <#CGFloat x#>, <#CGFloat y#>)
    
    /**
     *  三次贝塞尔曲线
     *
     *  @param c#>    图形上下文 description#>
     *  @param cp1x#> 第一个控制点x坐标 description#>
     *  @param cp1y#> 第一个控制点y坐标 description#>
     *  @param cp2x#> 第二个控制点x坐标 description#>
     *  @param cp2y#> 第二个控制点y坐标 description#>
     *  @param x#>    结束点x坐标 description#>
     *  @param y#>    结束点y坐标 description#>
     *
     */
//    CGContextAddCurveToPoint(<#CGContextRef  _Nullable c#>, <#CGFloat cp1x#>, <#CGFloat cp1y#>, <#CGFloat cp2x#>, <#CGFloat cp2y#>, <#CGFloat x#>, <#CGFloat y#>)
    
    CGPoint endPoint         = CGPointMake(55, 400);
    CGMutablePathRef  path   = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, self.layer.position.x, self.layer.position.y);//移动到起始点
    /**
     *  CGPathAddLineToPoint 添加直线路径
     *  CGPathAddCurveToPoint 添加曲线路径
     */
    CGPathAddCurveToPoint(path, NULL, 160, 280, -30, 300, endPoint.x, endPoint.y);//添加一条曲线路径到path
    
    keyframeAnimation.path   = path;//设置path属性
    CGPathRelease(path);//释放路径对象
    
    //添加动画到图层，添加动画后就会执行动画
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
    animationGroup.duration                = 10.0;
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
