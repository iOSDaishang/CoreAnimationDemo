# CoreAnimationDemo
#pragma mark ----雪景动画
#pragma mark ----基础旋转动画
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

#pragma mark ----关键帧移动动画
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
#pragma mark ----创建动画组
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
