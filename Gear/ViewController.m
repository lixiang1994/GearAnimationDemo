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

@property (nonatomic , strong ) UISlider *sliderView; //滑块视图

@end

@implementation ViewController
{
    CGFloat drivenGear_A_Angle;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    // 主动齿轮
    
    _mainGear = [GearView gearWithToothCount:10 ToothHeight:7 ToothMaxWidth:10 ToothMinWidth:3];
    
    _mainGear.center = CGPointMake(self.view.frame.size.width * 0.5f, self.view.frame.size.height * 0.5f);
    
    _mainGear.fillColor = [UIColor darkGrayColor];
    
    _mainGear.centerRadius = 10.0f;
    
    _mainGear.centerWitdh = 2.0f;
    
    [self.view addSubview:_mainGear];
    
    {
        // 添加从动齿轮
        
        GearView *drivenGear = [GearView gearWithToothCount:38 ToothHeight:7 ToothMaxWidth:10 ToothMinWidth:3];
        
        drivenGear.fillColor = [UIColor grayColor];
        
        drivenGear.centerRadius = 50.0f;
        
        drivenGear.centerWitdh = 30.0f;
        
        [self.mainGear addDrivenGear:drivenGear Angle:0 Spacing:2.0f];
        
        GearView *drivenGear2 = [GearView gearWithToothCount:58 ToothHeight:7 ToothMaxWidth:10 ToothMinWidth:3];
        
        drivenGear2.fillColor = [UIColor grayColor];
        
        drivenGear2.centerRadius = 20.0f;
        
        drivenGear2.centerWitdh = 2.0f;
        
        [drivenGear addDrivenGear:drivenGear2 Angle:0 Spacing:2.0f];
    }
    
    {
        // 添加从动齿轮
        
        GearView *drivenGear = [GearView gearWithToothCount:88 ToothHeight:7 ToothMaxWidth:10 ToothMinWidth:3];
        
        drivenGear.fillColor = [UIColor grayColor];
        
        drivenGear.centerRadius = 50.0f;
        
        drivenGear.centerWitdh = 30.0f;
        
        [self.mainGear addDrivenGear:drivenGear Angle:140 Spacing:2.0f];
    }
    
    {
        // 添加从动齿轮
        
        GearView *drivenGear = [GearView gearWithToothCount:18 ToothHeight:7 ToothMaxWidth:10 ToothMinWidth:3];
        
        drivenGear.fillColor = [UIColor grayColor];
        
        drivenGear.centerRadius = 20.0f;
        
        drivenGear.centerWitdh = 2.0f;
        
        [self.mainGear addDrivenGear:drivenGear Angle:260 Spacing:2.0f];
        
        
        GearView *drivenGear2 = [GearView gearWithToothCount:30 ToothHeight:7 ToothMaxWidth:10 ToothMinWidth:3];
        
        drivenGear2.fillColor = [UIColor grayColor];
        
        drivenGear2.centerRadius = 20.0f;
        
        drivenGear2.centerWitdh = 10.0f;
        
        [drivenGear addDrivenGear:drivenGear2 Angle:240 Spacing:2.0f];
    
        
        GearView *drivenGear3 = [GearView gearWithToothCount:18 ToothHeight:7 ToothMaxWidth:10 ToothMinWidth:3];
        
        drivenGear3.fillColor = [UIColor grayColor];
        
        drivenGear3.centerRadius = 20.0f;
        
        drivenGear3.centerWitdh = 2.0f;
        
        [drivenGear2 addDrivenGear:drivenGear3 Angle:300 Spacing:2.0f];
    }
    
    
    // 添加单击手势
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)]];
    
    
    // 滑块视图
    
    _sliderView = [[UISlider alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 30, 280, 20)];
    
    _sliderView.center = CGPointMake(self.view.frame.size.width * 0.5f, self.sliderView.center.y);
    
    _sliderView.minimumValue = 0;
    
    _sliderView.maximumValue = 360;
    
    [_sliderView addTarget:self action:@selector(sliderValueChangedAction:) forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:_sliderView];
    
    
    // 旋转动画
    
    [self.mainGear rotationAnimationWithDuration:2.0f];
}


- (void)tapAction{
    
}

- (void)sliderValueChangedAction:(UISlider *)slider{
    
    [self.mainGear removeRotationAnimation];
    
    [self.mainGear rotationWithAngle:slider.value];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
