//
//  MJRefreshGearHeader.m
//  Gear
//
//  Created by 李响 on 2017/9/19.
//  Copyright © 2017年 lee. All rights reserved.
//

#import "MJRefreshGearHeader.h"

#import "GearView.h"

#define ADAPTER(n) (([UIScreen mainScreen].bounds.size.width) / 320.0f * n)


@interface MJRefreshGearHeader()

@property (nonatomic , strong ) UIView *view;

@property (nonatomic , strong ) CAShapeLayer *shadowLayer;

@property (nonatomic , strong ) UIView *leftLineView;

@property (nonatomic , strong ) UIView *rightLineView;

@property (nonatomic , strong ) GearView *mainGear; //主齿轮

@property (nonatomic , assign ) BOOL isEnd;

@end

@implementation MJRefreshGearHeader

#pragma mark - 重写方法
#pragma mark 在这里做一些初始化配置（比如添加子控件）
- (void)prepare{
    
    [super prepare];
    
    // 设置控件的高度
    
    self.mj_h = ADAPTER(80.0f);
    
    _view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 0)];
    
    _view.clipsToBounds = YES;
    
    _view.backgroundColor = [UIColor colorWithRed:137/255.0f green:35/255.0f blue:38/255.0f alpha:1.0f];
    
    [self addSubview:_view];
    
    // 主动齿轮
    
    _mainGear = [GearView gearWithToothCount:10 ToothHeight:ADAPTER(4) ToothMaxWidth:ADAPTER(8) ToothMinWidth:ADAPTER(4)];
    
    _mainGear.fillColor = [UIColor colorWithRed:231/255.0f green:103/255.0f blue:94/255.0f alpha:1.0f];
    
    _mainGear.centerRadius = ADAPTER(7.0f);
    
    [self.view addSubview:_mainGear];
    
    // 从动齿轮
    
    GearView *drivenGear_A = [GearView gearWithToothCount:23 ToothHeight:ADAPTER(8) ToothMaxWidth:ADAPTER(8) ToothMinWidth:ADAPTER(4)];
    
    drivenGear_A.fillColor = [UIColor colorWithRed:213/255.0f green:85/255.0f blue:80/255.0f alpha:1.0f];
    
    [self.mainGear addDrivenGear:drivenGear_A Angle:315.0f Spacing:2.0f];
    
    GearView *drivenGear_B = [GearView gearWithToothCount:23 ToothHeight:ADAPTER(8) ToothMaxWidth:ADAPTER(8) ToothMinWidth:ADAPTER(4)];
    
    drivenGear_B.fillColor = [UIColor colorWithRed:213/255.0f green:85/255.0f blue:80/255.0f alpha:1.0f];
    
    [self.mainGear addDrivenGear:drivenGear_B Angle:135.0f Spacing:2.0f];
    
    
    GearView *drivenGear_C = [GearView gearWithToothCount:40 ToothHeight:ADAPTER(8) ToothMaxWidth:ADAPTER(8) ToothMinWidth:ADAPTER(4)];
    
    drivenGear_C.fillColor = [UIColor colorWithRed:193/255.0f green:63/255.0f blue:62/255.0f alpha:1.0f];
    
    [drivenGear_A addDrivenGear:drivenGear_C Angle:47.0f Spacing:4.0f];
    
    GearView *drivenGear_D = [GearView gearWithToothCount:40 ToothHeight:ADAPTER(8) ToothMaxWidth:ADAPTER(8) ToothMinWidth:ADAPTER(4)];
    
    drivenGear_D.fillColor = [UIColor colorWithRed:193/255.0f green:63/255.0f blue:62/255.0f alpha:1.0f];
    
    [drivenGear_B addDrivenGear:drivenGear_D Angle:225.0f Spacing:4.0f];
    
    
    // 左右线条视图
    
    _leftLineView = [[UIView alloc] initWithFrame:CGRectMake(15.0f, 0, 10.0f, 0)];
    
    _leftLineView.backgroundColor = [UIColor colorWithRed:231/255.0f green:103/255.0f blue:94/255.0f alpha:1.0f];
    
    [self.view addSubview:_leftLineView];
    
    _rightLineView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width - 25.0f, 0, 10.0f, 0)];
    
    _rightLineView.backgroundColor = [UIColor colorWithRed:231/255.0f green:103/255.0f blue:94/255.0f alpha:1.0f];
    
    [self.view addSubview:_rightLineView];

    // 阴影
    
    _shadowLayer = [CAShapeLayer layer];
    
    _shadowLayer.shadowColor = [UIColor blackColor].CGColor;
    
    _shadowLayer.shadowOffset = CGSizeMake(0, 5);
    
    _shadowLayer.shadowRadius = 5.0f;
    
    _shadowLayer.shadowOpacity = 0.8f;
    
    [self.view.layer addSublayer:_shadowLayer];
}

#pragma mark 在这里设置子控件的位置和尺寸

- (void)placeSubviews{
    
    [super placeSubviews];
    
    CGRect viewFrame = self.view.frame;
    
    viewFrame.size.width = self.frame.size.width;
    
    self.view.frame = viewFrame;
    
    
    if (!self.shadowLayer.path) self.shadowLayer.path = [UIBezierPath bezierPathWithRect:CGRectMake(0, -5, self.view.frame.size.width, 5.0f)].CGPath;
    
    
    CGRect leftLineViewFrame = self.leftLineView.frame;
    
    leftLineViewFrame.origin.x = 15.0f;
    
    leftLineViewFrame.size.height = self.view.frame.size.height;
    
    self.leftLineView.frame = leftLineViewFrame;
    
    
    CGRect rightLineViewFrame = self.rightLineView.frame;
    
    rightLineViewFrame.origin.x = self.view.frame.size.width - 25.0f;
    
    rightLineViewFrame.size.height = self.view.frame.size.height;
    
    self.rightLineView.frame = rightLineViewFrame;
    
    
    self.mainGear.center = CGPointMake(self.view.frame.size.width * 0.5f, self.view.frame.size.height * 0.5f);
}

#pragma mark 监听scrollView的contentOffset改变

- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change{
    
    [super scrollViewContentOffsetDidChange:change];
    
    if (self.isEnd) return;
    
    CGPoint point = [change[@"new"] CGPointValue];
    
    CGRect frame = self.view.frame;
    
    frame.size.height = fabs(point.y);
    
    frame.size.height = frame.size.height < 0.0f ? 0.0f : frame.size.height;
    
    frame.origin.y = self.frame.size.height - frame.size.height;
    
    self.view.frame = frame;
}

#pragma mark 监听scrollView的contentSize改变

- (void)scrollViewContentSizeDidChange:(NSDictionary *)change{
    
    [super scrollViewContentSizeDidChange:change];
}

#pragma mark 监听scrollView的拖拽状态改变

- (void)scrollViewPanStateDidChange:(NSDictionary *)change{
    
    [super scrollViewPanStateDidChange:change];
}

- (void)executeRefreshingCallback{
    
    [super executeRefreshingCallback];
    
    [self.mainGear rotationAnimationWithDuration:1.0f];
}

- (void)endRefreshing{
    
    self.isEnd = YES;
    
    dispatch_async(dispatch_get_main_queue(), ^{
       
        [self.mainGear removeRotationAnimationWithInstant:YES];
        
        [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionLayoutSubviews | UIViewAnimationOptionOverrideInheritedOptions animations:^{
            
//            self.mainGear.layer.transform = CATransform3DMakeScale(0.0, 0.0, 0.0);
            
        } completion:^(BOOL finished) {
            
            [super endRefreshing];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.isEnd = NO;
            });
            
        }];
        
    });
    
}

#pragma mark 监听控件的刷新状态

- (void)setState:(MJRefreshState)state{
    
    MJRefreshCheckState;
    
    switch (state) {
        case MJRefreshStateIdle:
            
            break;
        case MJRefreshStatePulling:
            
            break;
        case MJRefreshStateRefreshing:
           
            break;
        default:
            break;
    }
}

#pragma mark 监听拖拽比例（控件被拖出来的比例）

- (void)setPullingPercent:(CGFloat)pullingPercent{
    
    [super setPullingPercent:pullingPercent];
    
    [self.mainGear rotationWithAngle:360 * pullingPercent];
}

@end
