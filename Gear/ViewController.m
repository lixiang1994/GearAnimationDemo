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
{
    CGFloat drivenGear_A_Angle;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    // 主动齿轮
    
    _mainGear = [GearView gearWithToothCount:10 ToothHeight:10 ToothMaxWidth:20 ToothMinWidth:10];
    
    _mainGear.center = CGPointMake(self.view.frame.size.width * 0.5f, self.view.frame.size.height * 0.5f);
    
    _mainGear.fillColor = [UIColor darkGrayColor];
    
    _mainGear.centerRadius = 20.0f;
    
    _mainGear.centerWitdh = 5.0f;
    
    [self.view addSubview:_mainGear];
    
    // 从动齿轮A
    
    _drivenGear_A = [GearView gearWithToothCount:38 ToothHeight:10 ToothMaxWidth:20 ToothMinWidth:10];
    
    _drivenGear_A.fillColor = [UIColor lightGrayColor];
    
    _drivenGear_A.centerRadius = 50.0f;
    
    _drivenGear_A.centerWitdh = 30.0f;
    
    [self.view addSubview:_drivenGear_A];
    
    // 设置从动齿轮位置
    
    [self.mainGear configDrivenGearPointWithDrivenGear:_drivenGear_A Angle:0 Spacing:5.0f];
    
    // 添加单击手势
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)]];
    
    
    // 计数器
    
    _timer = [NSTimer timerWithTimeInterval:1.0f target:self selector:@selector(timerAction:)userInfo:nil repeats:YES];
    
    [[NSRunLoop currentRunLoop]addTimer:_timer forMode:NSRunLoopCommonModes];

    [_timer setFireDate:[NSDate date]];
    
//    [self.timer setFireDate:[NSDate distantFuture]];
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

- (void)tapAction{
    
    [self.timer setFireDate:[NSDate distantFuture]];
    
    self.mainGear.transform = CGAffineTransformIdentity;
    
    [self.mainGear configDrivenGearPointWithDrivenGear:_drivenGear_A Angle:arc4random() % 360];
    
    [self.timer setFireDate:[NSDate date]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
