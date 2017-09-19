//
//  ViewController.m
//  Gear
//
//  Created by 李响 on 2017/8/31.
//  Copyright © 2017年 lee. All rights reserved.
//

#import "ViewController.h"

#import "LEEAlert.h"

#import "HUD.h"

#import "GearView.h"

#define VIEWSAFEAREAINSETS(view) ({UIEdgeInsets i; if(@available(iOS 11.0, *)) {i = view.safeAreaInsets;} else {i = UIEdgeInsetsZero;} i;})

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *animationBarButton;

@property (nonatomic , strong ) GearView *mainGear; //主齿轮

@property (nonatomic , strong ) UISlider *sliderView; //滑块视图

@property (nonatomic , weak ) GearView *selectedGear; //选中齿轮

@property (nonatomic , assign ) BOOL isAnimation; //是否在动画

@property (nonatomic , assign ) CGFloat animationDuration; //动画时长

/**
 debug模式
 */
@property (nonatomic , assign ) BOOL debug;

/**
 辅助线
 */
@property (nonatomic , assign ) BOOL debugAuxiliaryLines;

/**
 轮齿辅助线
 */
@property (nonatomic , assign ) BOOL debugToothAuxiliaryLines;

/**
 缺口辅助线
 */
@property (nonatomic , assign ) BOOL debugGapAuxiliaryLines;

@end

@implementation ViewController
{
    CGFloat drivenGear_A_Angle;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
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
    
    // 滑块视图
    
    _sliderView = [[UISlider alloc] initWithFrame:CGRectMake(0, 0 , 280, 20)];
    
    _sliderView.center = CGPointMake(self.view.frame.size.width * 0.5f, self.view.frame.size.height - 30);
    
    _sliderView.minimumValue = 0;
    
    _sliderView.maximumValue = 360;
    
    [_sliderView addTarget:self action:@selector(sliderValueChangedAction:) forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:_sliderView];
}

- (void)viewSafeAreaInsetsDidChange{
    
    [super viewSafeAreaInsetsDidChange];
    
    self.sliderView.center = CGPointMake(self.view.frame.size.width * 0.5f, self.view.frame.size.height - 30 - VIEWSAFEAREAINSETS(self.view).bottom);
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
        .LeeCancelAction(@"取消" , nil)
        .LeeAction(@"添加" , ^{
            
            if (!weakSelf) return ;
            
            // 获取相关设置
            
            NSInteger toothCount = toothCountTF.text.length ? [toothCountTF.text integerValue] : 10.0f;
            
            NSInteger angle = angleTF.text.length ? [angleTF.text integerValue] : 0.0f;
            
            CGFloat spacing = spacingTF.text.length ? [spacingTF.text floatValue] : 2.0f;
            
            // 创建从动齿轮
            
            GearView *drivenGear = [GearView gearWithToothCount:toothCount ToothHeight:7 ToothMaxWidth:10 ToothMinWidth:3];
            
            drivenGear.fillColor = [UIColor colorWithRed:arc4random() % 255 / 255.0f green:arc4random() % 255 / 255.0f blue:arc4random() % 255 / 255.0f alpha:(arc4random() % 6 + 5) / 10.0f];
            
            drivenGear.centerRadius = 1.0f * toothCount;
            
            drivenGear.centerWitdh = 0.1f * toothCount;
            
            [weakSelf.selectedGear addDrivenGear:drivenGear Angle:angle Spacing:spacing];
            
            [drivenGear addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:weakSelf action:@selector(gearTapAction:)]];
            
            [weakSelf configGearDebug:drivenGear];
            
            // 移除选中齿轮状态
            
            weakSelf.selectedGear.layer.borderWidth = 0.0f;
            
            weakSelf.selectedGear.layer.borderColor = [UIColor clearColor].CGColor;
            
            weakSelf.selectedGear = nil;
        })
        .LeeShow();
    
    } else {
        
        [HUD showMessage:@"请选中一个齿轮"];
    }
}

#pragma mark - 导航栏设置按钮点击事件

- (IBAction)settingBarButtonAction:(id)sender {
    
    __weak typeof(self) weakSelf = self;
    
    __block UITextField *animationDurationTF;
    
    [LEEAlert alert].config
    .LeeTitle(@"设置")
    .LeeAddTextField(^(UITextField *textField) {
        
        textField.placeholder = @"旋转90度动画时长 (默认2秒)";
        
        textField.keyboardType = UIKeyboardTypeNumberPad;
        
        animationDurationTF = textField;
    })
    .LeeAddAction(^(LEEAction *action) {
        
        action.title = @"Debug";
        
        action.titleColor = [UIColor redColor];
        
        action.clickBlock = ^{
            
            if (!weakSelf) return ;
            
            UISwitch *debugSwitch = [[UISwitch alloc] init];
            
            debugSwitch.on = weakSelf.debug;
            
            UISwitch *debugAuxiliaryLinesSwitch = [[UISwitch alloc] init];
            
            debugAuxiliaryLinesSwitch.on = weakSelf.debugAuxiliaryLines;
            
            UISwitch *debugToothAuxiliaryLinesSwitch = [[UISwitch alloc] init];
            
            debugToothAuxiliaryLinesSwitch.on = weakSelf.debugToothAuxiliaryLines;
            
            UISwitch *debugGapAuxiliaryLinesSwitch = [[UISwitch alloc] init];
            
            debugGapAuxiliaryLinesSwitch.on = weakSelf.debugGapAuxiliaryLines;
            
            [LEEAlert alert].config
            .LeeContent(@"Debug")
            .LeeCustomView(debugSwitch)
            .LeeContent(@"--------------------------")
            .LeeContent(@"水平垂直辅助线")
            .LeeCustomView(debugAuxiliaryLinesSwitch)
            .LeeContent(@"轮齿辅助线")
            .LeeCustomView(debugToothAuxiliaryLinesSwitch)
            .LeeContent(@"齿槽辅助线")
            .LeeCustomView(debugGapAuxiliaryLinesSwitch)
            .LeeCancelAction(@"取消" , nil)
            .LeeAction(@"确认", ^{
                
                if (!weakSelf) return ;
                
                if (debugAuxiliaryLinesSwitch.on ||
                    debugToothAuxiliaryLinesSwitch.on ||
                    debugGapAuxiliaryLinesSwitch.on) {
                    
                    debugSwitch.on = YES;
                }
                
                weakSelf.debug = debugSwitch.on;
                
                weakSelf.debugAuxiliaryLines = debugAuxiliaryLinesSwitch.on;
                
                weakSelf.debugToothAuxiliaryLines = debugToothAuxiliaryLinesSwitch.on;
                
                weakSelf.debugGapAuxiliaryLines = debugGapAuxiliaryLinesSwitch.on;
                
                [weakSelf configGearDebug:weakSelf.mainGear];
            })
            .LeeShow();
        };
    })
    .LeeAction(@"确认" , ^{
        
        if (!weakSelf) return ;
        
        CGFloat animationDuration = animationDurationTF.text.length ? [animationDurationTF.text floatValue] : 2.0f;
        
        weakSelf.animationDuration = animationDuration;
        
        if (weakSelf.isAnimation) {
            
            // 移除旋转动画
            
            [weakSelf.mainGear removeRotationAnimation];
            
            // 重新添加旋转动画
            
            [weakSelf.mainGear rotationAnimationWithDuration:weakSelf.animationDuration];
        }
        
    })
    .LeeCancelAction(@"取消" , nil)
    .LeeShow();
}

#pragma mark - 设置齿轮 debug

- (void)configGearDebug:(GearView *)gearView{
    
    gearView.debug = self.debug;
    
    gearView.debugAuxiliaryLines = self.debugAuxiliaryLines;
    
    gearView.debugToothAuxiliaryLines = self.debugToothAuxiliaryLines;
    
    gearView.debugGapAuxiliaryLines = self.debugGapAuxiliaryLines;
    
    for (GearView *item in gearView.drivenGears) {
        
        [self configGearDebug:item];
    }
    
}

#pragma mark - 齿轮点击事件

- (void)gearTapAction:(UITapGestureRecognizer *)tap{
    
    GearView *selectedGear = (GearView *)tap.view;
    
    if (self.selectedGear == selectedGear) {
        
        self.selectedGear.layer.borderWidth = 0.0f;
        
        self.selectedGear.layer.borderColor = [UIColor clearColor].CGColor;
        
        self.selectedGear = nil;
    
    } else {
        
        if (self.selectedGear) {
            
            self.selectedGear.layer.borderWidth = 0.0f;
            
            self.selectedGear.layer.borderColor = [UIColor clearColor].CGColor;
            
            self.selectedGear = nil;
        }
        
        self.selectedGear = selectedGear;
        
        self.selectedGear.layer.borderWidth = 1/[[UIScreen mainScreen] scale];
        
        self.selectedGear.layer.borderColor = [UIColor redColor].CGColor;
    }
    
}

#pragma mark - 滑动值改变事件

- (void)sliderValueChangedAction:(UISlider *)slider{
    
    if (self.isAnimation) [self animationBarButtonAction:self.animationBarButton];
    
    [self.sliderView showMessage:[NSString stringWithFormat:@"当前 %.f度" , slider.value]];
    
    [self.mainGear rotationWithAngle:slider.value];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
