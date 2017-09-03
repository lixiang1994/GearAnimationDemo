//
//  GearView.h
//  Gear
//
//  Created by 李响 on 2017/8/31.
//  Copyright © 2017年 lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GearView : UIView

@property (nonatomic , assign , readonly ) NSInteger toothCount; //齿轮个数

@property (nonatomic , assign , readonly ) CGFloat toothHeight; //轮齿高度

@property (nonatomic , assign , readonly ) CGFloat toothMaxWidth; //轮齿最大宽度

@property (nonatomic , assign , readonly ) CGFloat toothMinWidth; //轮齿最小宽度

@property (nonatomic , strong ) UIColor *fillColor; //填充颜色

@property (nonatomic , assign ) CGFloat centerRadius; //圆心半径

@property (nonatomic , assign ) CGFloat centerWitdh; //圆心线宽度

/**
 初始化齿轮视图

 @param toothCount 轮齿个数 (轮齿个数不得小于2个)
 @param toothHeight 轮齿高度
 @param toothMaxWidth 轮齿最大宽度
 @param toothMinWidth 轮齿最小宽度 (轮齿最小宽度不得大于最大宽度)
 @return 齿轮视图对象
 */
+ (GearView *)gearWithToothCount:(NSInteger)toothCount
                     ToothHeight:(CGFloat)toothHeight
                   ToothMaxWidth:(CGFloat)toothMaxWidth
                   ToothMinWidth:(CGFloat)toothMinWidth;

/**
 设置从动齿轮位置

 @param drivenGear 从动齿轮
 @param angle 所在角度 0 - 360度
 */
- (void)configDrivenGearPointWithDrivenGear:(GearView *)drivenGear Angle:(CGFloat)angle;

/**
 设置从动齿轮位置
 
 @param drivenGear 从动齿轮
 @param angle 所在角度 0 - 360度
 @param spacing 齿轮间距 (不得小于最小轮齿高度)
 */
- (void)configDrivenGearPointWithDrivenGear:(GearView *)drivenGear Angle:(CGFloat)angle Spacing:(CGFloat)spacing;





#pragma mark - 内部使用

@property (nonatomic , strong , readonly ) NSArray *toothAngleArray; //轮齿角度数组

@property (nonatomic , strong , readonly ) NSArray *gapAngleArray; //缺口角度数组

@end
