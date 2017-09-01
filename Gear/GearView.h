//
//  GearView.h
//  Gear
//
//  Created by 李响 on 2017/8/31.
//  Copyright © 2017年 lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GearView : UIView

@property (nonatomic , assign ) NSInteger toothCount; //齿轮个数

@property (nonatomic , assign ) CGFloat toothHeight; //轮齿高度

@property (nonatomic , assign ) CGFloat toothMaxWidth; //轮齿最大宽度

@property (nonatomic , assign ) CGFloat toothMinWidth; //轮齿最小宽度

@property (nonatomic , strong ) UIColor *fillColor; //填充颜色

@property (nonatomic , assign ) CGFloat centerRadius; //圆心半径

@property (nonatomic , assign ) CGFloat centerWitdh; //圆心线宽度

@end
