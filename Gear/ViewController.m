//
//  ViewController.m
//  Gear
//
//  Created by 李响 on 2017/8/31.
//  Copyright © 2017年 lee. All rights reserved.
//

#import "ViewController.h"

#import "LEEAlert.h"

#import "GearView.h"

#define VIEWSAFEAREAINSETS(view) ({UIEdgeInsets i; if(@available(iOS 11.0, *)) {i = view.safeAreaInsets;} else {i = UIEdgeInsetsZero;} i;})

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *animationBarButton;

@property (nonatomic , strong ) GearView *mainGear; //主齿轮

@property (nonatomic , strong ) NSMutableArray *drivenGearArray; //从动齿轮数组

@property (nonatomic , strong ) UISlider *sliderView; //滑块视图



@property (nonatomic , weak ) GearView *selectedGear; //选中齿轮


@property (nonatomic , assign ) BOOL isAnimation;

@property (nonatomic , assign ) CGFloat animationDuration;

@end

@implementation ViewController
{
    CGFloat drivenGear_A_Angle;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // 添加设置完成通知
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishSetNotify:) name:@"finishSet" object:self];
    
    // 默认动画时长
    
    _animationDuration = 2.0f;
    
    // 初始化子视图
    
    [self initSubView];
}

- (void)initSubView{
    
    // 主动齿轮
    
    _mainGear = [GearView gearWithToothCount:10 ToothHeight:7 ToothMaxWidth:10 ToothMinWidth:3];
    
    _mainGear.center = CGPointMake(self.view.frame.size.width * 0.5f, self.view.frame.size.height * 0.5f);
    
    _mainGear.fillColor = [UIColor darkGrayColor];
    
    _mainGear.centerRadius = 10.0f;
    
    _mainGear.centerWitdh = 2.0f;
    
    [self.view addSubview:_mainGear];
    
    [_mainGear addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gearTapAction:)]];
    /*
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
    */
    // 滑块视图
    
    _sliderView = [[UISlider alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 30 - VIEWSAFEAREAINSETS(self.view).top - VIEWSAFEAREAINSETS(self.view).bottom , 280, 20)];
    
    _sliderView.center = CGPointMake(self.view.frame.size.width * 0.5f, self.sliderView.center.y);
    
    _sliderView.minimumValue = 0;
    
    _sliderView.maximumValue = 360;
    
    [_sliderView addTarget:self action:@selector(sliderValueChangedAction:) forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:_sliderView];
}

#pragma mark - 导航栏动画按钮点击事件

- (IBAction)animationBarButtonAction:(UIBarButtonItem *)sender {
    
    if (self.isAnimation) {
        
        sender.title = @"开始动画";
        
        // 移除旋转动画
        
        [self.mainGear removeRotationAnimationWithInstant:YES];
        
        self.isAnimation = NO;
        
    } else {
        
        sender.title = @"停止动画";
        
        // 添加旋转动画
        
        [self.mainGear rotationAnimationWithDuration:self.animationDuration];
        
        self.isAnimation = YES;
    }
    
}

#pragma mark - 导航栏添加按钮点击事件

- (IBAction)addBarButtonAction:(id)sender {
    
    if (self.selectedGear) {
        
        // 移除旋转动画
        
        if (self.isAnimation) [self.mainGear removeRotationAnimation];
        
        // 获取齿轮相关设置
        
        __weak typeof(self) weakSelf = self;
        
        __block UITextField *toothCountTF;
        __block UITextField *angleTF;
        __block UITextField *spacingTF;
        
        [LEEAlert alert].config
        .LeeTitle(@"添加齿轮")
        .LeeAddTextField(^(UITextField *textField) {
        
            textField.placeholder = @"轮齿个数 (默认10个 最少3个)";
            
            textField.keyboardType = UIKeyboardTypeNumberPad;
            
            toothCountTF = textField;
        })
        .LeeAddTextField(^(UITextField *textField) {
            
            textField.placeholder = @"所在角度 (0 - 360)";
            
            textField.keyboardType = UIKeyboardTypeNumberPad;
            
            angleTF = textField;
        })
        .LeeAddTextField(^(UITextField *textField) {
            
            textField.placeholder = @"齿轮间距 (默认2 建议适中)";
            
            textField.keyboardType = UIKeyboardTypeNumberPad;
            
            spacingTF = textField;
        })
        .LeeAction(@"添加" , ^{
            
            if (!weakSelf) return ;
            
            // 获取相关设置
            
            NSInteger toothCount = toothCountTF.text.length ? [toothCountTF.text integerValue] : 10.0f;
            
            NSInteger angle = angleTF.text.length ? [angleTF.text integerValue] : 0.0f;
            
            CGFloat spacing = spacingTF.text.length ? [spacingTF.text floatValue] : 2.0f;
            
            // 创建从动齿轮
            
            GearView *drivenGear = [GearView gearWithToothCount:toothCount ToothHeight:7 ToothMaxWidth:10 ToothMinWidth:3];
            
            drivenGear.fillColor = [UIColor colorWithRed:arc4random() % 255 / 255.0f green:arc4random() % 255 / 255.0f blue:arc4random() % 255 / 255.0f alpha:(arc4random() % 6 + 5) / 10.0f];
            
            drivenGear.centerRadius = 1.0f * 18.0f;
            
            drivenGear.centerWitdh = 0.1f * 18.0f;
            
            [weakSelf.selectedGear addDrivenGear:drivenGear Angle:angle Spacing:spacing];
            
            [drivenGear addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:weakSelf action:@selector(gearTapAction:)]];
            
            // 移除选中齿轮状态
            
            weakSelf.selectedGear.backgroundColor = [UIColor clearColor];
            
            weakSelf.selectedGear = nil;
        })
        .LeeCancelAction(@"取消" , nil)
        .LeeShow();
    
    } else {
        
        [LEEAlert alert].config
        .LeeContent(@"请选中一个齿轮")
        .LeeClickBackgroundClose(YES)
        .LeeShow();
    }
}

#pragma mark - 导航栏设置按钮点击事件

- (IBAction)settingBarButtonAction:(id)sender {
    
    
}

#pragma mark - 齿轮点击事件

- (void)gearTapAction:(UITapGestureRecognizer *)tap{
    
    GearView *selectedGear = (GearView *)tap.view;
    
    if (self.selectedGear == selectedGear) {
        
        self.selectedGear.backgroundColor = [UIColor clearColor];
        
        self.selectedGear = nil;
    
    } else {
        
        if (self.selectedGear) {
            
            self.selectedGear.backgroundColor = [UIColor clearColor];
            
            self.selectedGear = nil;
        }
        
        self.selectedGear = selectedGear;
        
        self.selectedGear.backgroundColor = [UIColor redColor];
    }
    
}

#pragma mark - 滑动值改变事件

- (void)sliderValueChangedAction:(UISlider *)slider{
    
    [self.mainGear removeRotationAnimation];
    
    [self.mainGear rotationWithAngle:slider.value];
}

- (void)finishSetNotify:(NSNotification *)notify{
    
    NSDictionary *info = notify.userInfo;
    
    self.animationDuration = [info[@"animationDuration"] floatValue];
    
    if (self.isAnimation) {
        
        // 移除旋转动画
        
        [self.mainGear removeRotationAnimation];
        
        // 重新添加旋转动画
        
        [self.mainGear rotationAnimationWithDuration:self.animationDuration];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
