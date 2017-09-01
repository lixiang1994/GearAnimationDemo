//
//  ViewController.m
//  Gear
//
//  Created by 李响 on 2017/8/31.
//  Copyright © 2017年 lee. All rights reserved.
//

#import "ViewController.h"

#import "GearView.h"

@interface ViewController ()

@property (nonatomic , strong ) NSTimer *timer;

@property (nonatomic , strong ) GearView *mainGear;//主齿轮

@property (nonatomic , strong ) GearView *drivenGear_A;//从动齿轮A

@property (nonatomic , strong ) GearView *drivenGear_B;//从动齿轮B

@property (nonatomic , strong ) GearView *drivenGear_C;//从动齿轮C

@property (nonatomic , strong ) GearView *drivenGear_D;//从动齿轮D

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    // 主动齿轮
    
    _mainGear = [[GearView alloc] init];
    
    _mainGear.center = CGPointMake(self.view.frame.size.width * 0.5f, self.view.frame.size.height * 0.5f);
    
    _mainGear.fillColor = [UIColor darkGrayColor];
    
    _mainGear.centerRadius = 20.0f;
    
    _mainGear.centerWitdh = 5.0f;
    
    [self.view addSubview:_mainGear];
    
    // 从动齿轮A
    
    _drivenGear_A = [[GearView alloc] init];
    
    _drivenGear_A.toothCount = 28;
    
    _drivenGear_A.fillColor = [UIColor lightGrayColor];
    
    _drivenGear_A.centerRadius = 50.0f;
    
    _drivenGear_A.centerWitdh = 30.0f;
    
    [self.view addSubview:_drivenGear_A];
    
    // 根据主齿轮位置 设置从动齿轮位置 轮齿之间保留缝隙
    
    CGFloat x = self.view.frame.size.width - (_mainGear.center.x + _mainGear.frame.size.width * 0.5f + _drivenGear_A.frame.size.width * 0.5f - _mainGear.toothHeight * 0.9f);
    
    _drivenGear_A.center = CGPointMake(x, _mainGear.center.y);
    
    // 调整初始角度 对齐主齿轮
    
    _drivenGear_A.transform = CGAffineTransformRotate(_drivenGear_A.transform, M_PI_4 * 0.05f);
    
    
    
    
    
    
    
    
    
    
    
    // 计数器
    
    _timer = [NSTimer timerWithTimeInterval:1.0f target:self selector:@selector(timerAction:)userInfo:nil repeats:YES];
    
    [[NSRunLoop currentRunLoop]addTimer:_timer forMode:NSRunLoopCommonModes];

    [_timer setFireDate:[NSDate date]];
    
    // 延迟暂停
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self.timer setFireDate:[NSDate distantFuture]];
    });
}

#pragma mark - 计时器事件

- (void)timerAction:(NSTimer *)timer{
    
    [UIView beginAnimations:@"" context:NULL];
    
    [UIView setAnimationDuration:1.0f];
    
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    
    CGFloat speed = M_PI_4;
    
    self.mainGear.transform = CGAffineTransformRotate(self.mainGear.transform, - speed);
    
    // 从动齿轮数 = 主动齿轮数 * 速度 / 从动齿轮数
    
    self.drivenGear_A.transform = CGAffineTransformRotate(self.drivenGear_A.transform, ((speed * self.mainGear.toothCount) / self.drivenGear_A.toothCount));
    
    [UIView commitAnimations];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
