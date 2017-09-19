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

@property (nonatomic , strong ) NSMutableArray *drivenGears; //从动齿轮数组

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
 旋转 (仅主动齿轮调用)

 @param angle 旋转角度 0 - 360度
 */
- (void)rotationWithAngle:(CGFloat)angle;

/**
 旋转动画
 
 @param duration 每旋转90度的动画时长
 */
- (void)rotationAnimationWithDuration:(CGFloat)duration;

/**
 移除旋转动画
 */
- (void)removeRotationAnimation;


/**
 移除旋转动画

 @param instant 是否立即移除
 */
- (void)removeRotationAnimationWithInstant:(BOOL)instant;

/**
 添加从动齿轮

 @param drivenGear 从动齿轮
 @param angle 所在角度 0 - 360度
 */
- (void)addDrivenGear:(GearView *)drivenGear Angle:(CGFloat)angle;

/**
 添加从动齿轮
 
 @param drivenGear 从动齿轮
 @param angle 所在角度 0 - 360度
 @param spacing 齿轮间距 (不得小于最小轮齿高度)
 */
- (void)addDrivenGear:(GearView *)drivenGear Angle:(CGFloat)angle Spacing:(CGFloat)spacing;

/**
 移除从动齿轮

 @param drivenGear 从动齿轮
 */
- (void)removeDrivenGear:(GearView *)drivenGear;


#pragma mark - DEBUG模式

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

#pragma mark - 内部使用

@property (nonatomic , strong , readonly ) NSArray *toothRadianArray; //轮齿弧度数组

@property (nonatomic , strong , readonly ) NSArray *gapRadianArray; //缺口弧度数组

@property (nonatomic , assign ) CGFloat initialRadian; //初始弧度

@end
