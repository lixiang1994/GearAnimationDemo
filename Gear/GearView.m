//
//  GearView.m
//  Gear
//
//  Created by 李响 on 2017/8/31.
//  Copyright © 2017年 lee. All rights reserved.
//

#import "GearView.h"

@interface GearView ()

@property (nonatomic , assign ) CGPathRef gearPath;

@end

@implementation GearView
{
    BOOL isRotationAnimation;
}

- (void)dealloc{
    
    CGPathRelease(_gearPath);
    
    _toothRadianArray = nil;
    
    _gapRadianArray = nil;
    
    _fillColor = nil;
    
    [_drivenGears removeAllObjects];
    
    _drivenGears = nil;
}

+ (GearView *)gearWithToothCount:(NSInteger)toothCount
                     ToothHeight:(CGFloat)toothHeight
                   ToothMaxWidth:(CGFloat)toothMaxWidth
                   ToothMinWidth:(CGFloat)toothMinWidth{
    
    GearView *view = [[GearView alloc] initWithToothCount:toothCount ToothHeight:toothHeight ToothMaxWidth:toothMaxWidth ToothMinWidth:toothMinWidth];
    
    return view;
}

- (instancetype)initWithToothCount:(NSInteger)toothCount
                       ToothHeight:(CGFloat)toothHeight
                     ToothMaxWidth:(CGFloat)toothMaxWidth
                     ToothMinWidth:(CGFloat)toothMinWidth{
    
    self = [super init];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        _toothCount = toothCount > 2 ? toothCount : 2;
        
        _toothHeight = toothHeight;
        
        _toothMaxWidth = toothMaxWidth;
        
        _toothMinWidth = toothMinWidth > toothMaxWidth ? toothMaxWidth : toothMinWidth;
        
        // 计算视图大小
        
        CGFloat perimeter = _toothCount * (_toothMaxWidth + _toothMinWidth);
        
        CGFloat size = perimeter / M_PI;
        
        size += _toothHeight * 2;
        
        CGRect selfFrame = self.frame;
        
        selfFrame.size = CGSizeMake(size, size);
        
        self.frame = selfFrame;
        
        // 默认设置
        
        _fillColor = [UIColor lightGrayColor];
        
        _centerRadius = 0.0f;
        
        _centerWitdh = 0.0f;
        
        _clockwise = YES;
        
        [self gearPath];
        
        [self setNeedsDisplay];
    }
    return self;
}

#pragma mark - Setter

- (void)setCenterRadius:(CGFloat)centerRadius{
    
    _centerRadius = centerRadius;
    
    [self setNeedsDisplay];
}

- (void)setCenterWitdh:(CGFloat)centerWitdh{
    
    _centerWitdh = centerWitdh;
    
    [self setNeedsDisplay];
}

- (void)setFillColor:(UIColor *)fillColor{
    
    _fillColor = fillColor;
    
    [self setNeedsDisplay];
}

- (void)setDebug:(BOOL)debug{
    
    _debug = debug;
    
    [self setNeedsDisplay];
}

- (void)setDebugAuxiliaryLines:(BOOL)debugAuxiliaryLines{
    
    _debugAuxiliaryLines = debugAuxiliaryLines;
    
    [self setNeedsDisplay];
}

- (void)setDebugToothAuxiliaryLines:(BOOL)debugToothAuxiliaryLines{
    
    _debugToothAuxiliaryLines = debugToothAuxiliaryLines;
    
    [self setNeedsDisplay];
}

- (void)setDebugGapAuxiliaryLines:(BOOL)debugGapAuxiliaryLines{
    
    _debugGapAuxiliaryLines = debugGapAuxiliaryLines;
    
    [self setNeedsDisplay];
}

- (void)setCenter:(CGPoint)center{
    
    [super setCenter:center];
    
    // 主齿轮center发生变化时, 重新设置从动齿轮位置
    
    for (GearView *gearView in self.drivenGears) {
        
        [self configDrivenGearPointWithDrivenGear:gearView Angle:gearView.mainAngle Spacing:gearView.mainSpacing];
    }
}

#pragma mark - 原理拆分演示

- (void)debug:(CGRect)rect{
    
    /**
     
     思路简析:
     
     对于齿轮来说, 我把它分为3部分: 1.外圆 , 2.内圆 , 3.轮齿边线
     这三部分在运行demo中分别对应 橙色 , 红色 , 蓝色.
     轮齿的形状我们可以看做一个梯形或者一个矩形, 不过梯形居多. 正确的轮齿应该是顶部宽度小于底部宽度, 属性中 `toothMinWidth` 和 `toothMaxWidth` 就是设置顶部和底部的宽度.
     `toothHeight` 则为轮齿的高, `toothCount`为轮齿的数量.
     
     这里齿轮的大小取决于 轮齿的高度和轮齿的最大最小宽度以及轮齿的个数.
     每个轮齿之间的间距等于轮齿最小宽度, 这样相同轮齿的齿轮才能正常咬合.
     
     1. 根据轮齿最大最小宽度 高度 数量, 计算出内圆外圆所需半径 并计算出每一个轮齿的弧度以及每一个轮齿的最大最小弧度.
     2. 内圆每个弧线的弧度等于轮齿的最小弧度 间距为轮齿的最大弧度 循环绘制 (demo中红色部分就完成了)
     3. 外圆每个弧线的弧度不等于轮齿的最小弧度, 由于半径比内圆半径大, 所以弧度相同的话会导致绘制出来的弧线长度大于内圆弧线长度. 所以这里需要做一下转换计算, 根据内圆弧线长度计算出外圆同样长度所需的弧度, 这样再根据新的弧度绘制即可. (外圆和内圆绘制的起始点不同 这里要注意 , 例如内圆起始点为0度, 那么外圆的起始点应该是: (内圆最小弧度 + (内圆最大弧度 - 外圆最小弧度) ÷ 2) 度)
     4. 外圆的绘制方式与内圆相同, 起始点和弧度计算好即可. (demo中橙色部分就完成了)
     5. 轮齿边的绘制等同于内圆第一条弧线的结束点 -> 外圆第一条弧线的起始点 .... 以此类推, 这里为了演示 我将这些点放到了数组中 然后添加线条绘制出来了. (demo中蓝色部分就完成了)
     
     这个方法是为了更方便去理解 所以分开绘制每一个部分, 优化后只要一个循环就可以搞定.
     
     */
    
    
    CGFloat width = rect.size.width;
    
    CGFloat height = rect.size.height;
    
    CGFloat exteriorRadius = width * 0.5f; //外圆半径
    
    CGFloat interiorRadius = (width - self.toothHeight * 2) * 0.5f; //内圆半径
    
    CGFloat minAndMaxRatio = (self.toothMinWidth / (self.toothMinWidth + self.toothMaxWidth)); //最小宽度与最大宽度的比例
    
    CGFloat averageRadian = (M_PI * 2) / self.toothCount; //平均每个的弧度 (平均弧度 = 最小弧度 + 最大弧度)
    
    CGFloat minRadian = averageRadian * minAndMaxRatio; //最小弧度
    
    CGFloat maxRadian = averageRadian - minRadian; //最大弧度
    
    
    NSMutableArray *exteriorPointArray = [NSMutableArray array]; //外圆坐标点数组
    
    NSMutableArray *interiorPointArray = [NSMutableArray array]; //内圆坐标点数组
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextBeginPath(context);
    
    CGContextSetLineWidth(context, 1.0f);
    
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    
    // 内圆路径绘制
    
    {
        // 根据轮齿个数循环
        
        for (NSInteger i = 0 ; i < self.toothCount; i++) {
            
            CGFloat startRadian = maxRadian * i + minRadian * i; // 起始弧度
            
            CGFloat endRadian = maxRadian * i + minRadian * (i + 1); // 结束弧度
            
            CGContextAddArc(context, width * 0.5f, height * 0.5f, interiorRadius, startRadian, endRadian , 0);
            
            CGContextStrokePath(context);
            
            // 获取起始和结束的坐标
            
            CGPoint startPoint = [self getPointWithRadius:interiorRadius Radian:startRadian];
            
            CGPoint endPoint = [self getPointWithRadius:interiorRadius Radian:endRadian];
            
            // 添加到内圆坐标数组
            
            [interiorPointArray addObject:[NSValue valueWithCGPoint:CGPointMake(startPoint.x + self.toothHeight, startPoint.y + self.toothHeight)]];
            
            [interiorPointArray addObject:[NSValue valueWithCGPoint:CGPointMake(endPoint.x + self.toothHeight, endPoint.y + self.toothHeight)]];
        }
        
    }
    
    CGContextSetStrokeColorWithColor(context, [UIColor orangeColor].CGColor);
    
    // 外圆路径绘制
    
    {
        // 根据内圆半径和弧度计算外圆弧度
        // 计算内圆最小弧长度 (脑残公式: 2πr÷360*a)
        
        CGFloat minLength = M_PI * 2 * interiorRadius / 360 * minRadian;
        
        // 根据内圆最小弧长度计算出长度相同的外圆最小弧度和最大弧度
        
        CGFloat tempminRadian = (minLength * 180) / (M_PI * exteriorRadius);
        
        CGFloat tempmaxRadian = averageRadian - tempminRadian;
        
        // 根据轮齿个数循环
        
        for (NSInteger i = 0 ; i < self.toothCount; i++) {
            
            CGFloat placeholderRadian = minRadian + ((maxRadian - tempminRadian) * 0.5f); //占位弧度 (内圆起始弧度为0 , 外圆起始弧度为占位弧度)
            
            CGFloat startRadian = tempmaxRadian * i + tempminRadian * i + placeholderRadian; // 起始弧度
            
            CGFloat endRadian = tempmaxRadian * i + tempminRadian * (i + 1) + placeholderRadian; // 结束弧度
            
            CGContextAddArc(context, width * 0.5f, height * 0.5f, exteriorRadius, startRadian, endRadian , 0);
            
            CGContextStrokePath(context);
            
            // 获取起始和结束的坐标
            
            CGPoint startPoint = [self getPointWithRadius:exteriorRadius Radian:startRadian];
            
            CGPoint endPoint = [self getPointWithRadius:exteriorRadius Radian:endRadian];
            
            [exteriorPointArray addObject:[NSValue valueWithCGPoint:CGPointMake(startPoint.x, startPoint.y)]];
            
            [exteriorPointArray addObject:[NSValue valueWithCGPoint:CGPointMake(endPoint.x, endPoint.y)]];
        }
        
    }
    
    // 轮齿边线
    
    CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
    
    for (NSInteger i = 0; i < exteriorPointArray.count; i++) {
        
        CGPoint exteriorPoint = [exteriorPointArray[i] CGPointValue];
        
        CGPoint interiorPoint = [interiorPointArray[i < interiorPointArray.count - 1 ? i + 1 : 0] CGPointValue];
        
        CGContextMoveToPoint(context, exteriorPoint.x, exteriorPoint.y);
        
        CGContextAddLineToPoint(context, interiorPoint.x, interiorPoint.y);
        
        CGContextStrokePath(context);
    }
    
    
    // 垂直水平辅助线
    {
        if (self.debugAuxiliaryLines) {
            
            CGContextSetLineWidth(context, 1.0f / [[UIScreen mainScreen] scale]);
            
            CGContextSetStrokeColorWithColor(context, [UIColor lightGrayColor].CGColor);
            
            CGFloat list[] = {2.0f, 2.0f};
            
            CGContextSetLineDash(context, 0, list, 2);
            
            CGContextMoveToPoint(context, width * 0.5f, 0.0);
            
            CGContextAddLineToPoint(context, width * 0.5f , height);
            
            CGContextStrokePath(context);
            
            CGContextMoveToPoint(context, 0.0f, height * 0.5f);
            
            CGContextAddLineToPoint(context, width, height * 0.5f);
            
            CGContextStrokePath(context);
        }
    }
    
    
    // 轮齿缺口辅助线
    {
        CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
        
        CGContextSetLineWidth(context, 1.0f / [[UIScreen mainScreen] scale]);
        
        CGFloat list[] = {2.0f, 2.0f};
        
        CGContextSetLineDash(context, 0, list, 2);
        
        if (self.debugToothAuxiliaryLines) {
            
            for (NSNumber *radian in self.toothRadianArray) {
                
                CGPoint point = [self getPointWithRadius:exteriorRadius Radian:[radian floatValue]];
                
                CGContextMoveToPoint(context, width * 0.5f, height * 0.5f);
                
                CGContextAddLineToPoint(context, point.x , point.y);
                
                CGContextStrokePath(context);
            }
            
            CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
        }
        
        if (self.debugGapAuxiliaryLines) {
            
            for (NSNumber *radian in self.gapRadianArray) {
                
                CGPoint point = [self getPointWithRadius:interiorRadius Radian:[radian floatValue]];
                
                CGContextMoveToPoint(context, width * 0.5f, height * 0.5f);
                
                CGContextAddLineToPoint(context, point.x + self.toothHeight , point.y + self.toothHeight);
                
                CGContextStrokePath(context);
            }
        }
    }
    
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
    if (self.debug) {
        
        [self debug:rect];
    
    } else {
        
        CGFloat width = rect.size.width;
        
        CGFloat height = rect.size.height;
        
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextBeginPath(context);
        
        CGContextSetLineWidth(context, 1.0f);
        
        CGContextSetFillColorWithColor(context, self.fillColor.CGColor);
        
        // 齿轮
        
        CGContextAddPath(context, self.gearPath);
        
        CGContextClosePath(context);
        
        CGContextFillPath(context);
        
        CGContextStrokePath(context);
        
        // 圆心
        
        if (self.centerRadius > 0.0f) {
            
            CGContextSetBlendMode(context, kCGBlendModeClear);
            
            CGContextSetLineWidth(context, self.centerWitdh);
            
            CGContextAddArc(context, width * 0.5f, height * 0.5f, self.centerRadius, 0.0f, M_PI * 2, 0);
            
            if (self.centerWitdh > 0.0f) CGContextStrokePath(context); else CGContextFillPath(context);
            
            CGContextSetBlendMode(context, kCGBlendModeNormal);
        }
    }
    
}

#pragma mark - 旋转

- (void)rotationWithAngle:(CGFloat)angle{
    
    CGFloat radian = M_PI / 180 * angle;
    
    [self rotationWithRadian: self.clockwise ? radian : -radian];
}

- (void)rotationWithRadian:(CGFloat)radian{
    
    self.transform = CGAffineTransformRotate(self.transform, radian);
    
    // 从动齿轮数 = 主动齿轮数 * 速度 / 从动齿轮数
    
    for (GearView *gear in self.drivenGears) {
        
        [gear rotationWithRadian:-(((radian * self.toothCount) / gear.toothCount))];
    }
    
}

- (void)rotationAnimationWithDuration:(CGFloat)duration{
    
    if (duration < 1.0f) duration = 1.0f;
    
    isRotationAnimation = YES;
    
    [self rotationAnimationWithDuration:duration / 100.0f Angle:3.6f];
}

- (void)rotationAnimationWithDuration:(CGFloat)duration Angle:(CGFloat)angle{
    
    if (angle > 180.0f) angle = 180.0f;
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationCurveLinear | UIViewAnimationOptionAllowUserInteraction animations:^{
        
        [self rotationWithAngle:angle];
        
    } completion:^(BOOL finished) {
       
        if (!finished) return ;
        
        if (isRotationAnimation) [self rotationAnimationWithDuration:duration Angle:angle];
    }];
    
}

- (void)removeRotationAnimation{
    
    [self removeRotationAnimationWithInstant:YES];
}

- (void)removeRotationAnimationWithInstant:(BOOL)instant{
    
    isRotationAnimation = NO;
    
    // 移除动画
    
    if (instant) [self.layer removeAllAnimations];
    
    for (GearView *gear in self.drivenGears) {
        
        [gear removeRotationAnimationWithInstant:instant];
    }
}

#pragma mark - 添加从动齿轮

- (void)addDrivenGear:(GearView *)drivenGear Angle:(CGFloat)angle{
    
    [self addDrivenGear:drivenGear Angle:angle Spacing:1.0f];
}

- (void)addDrivenGear:(GearView *)drivenGear Angle:(CGFloat)angle Spacing:(CGFloat)spacing{
    
    if (!drivenGear) return;
    
    if (!self.superview) return;
    
    [self.superview addSubview:drivenGear];
    
    [self.superview insertSubview:drivenGear belowSubview:self];
    
    drivenGear.mainAngle = angle;
    
    drivenGear.mainSpacing = spacing;
    
    if (![self.drivenGears containsObject:drivenGear]) [self.drivenGears addObject:drivenGear];
    
    // 设置从动齿轮位置
    
    [self configDrivenGearPointWithDrivenGear:drivenGear Angle:angle Spacing:spacing];
    
    // 设置从动齿轮初始弧度
    
    [self configDrivenGearInitialRadianWithDrivenGear:drivenGear Angle:angle Spacing:spacing];
}

#pragma mark - 移除从动齿轮

- (void)removeDrivenGear:(GearView *)drivenGear{
    
    if ([self.drivenGears containsObject:drivenGear]) {
        
        for (GearView *gear in drivenGear.drivenGears) {
            
            [drivenGear removeDrivenGear:gear];
        }
        
        [drivenGear removeFromSuperview];
        
        [self.drivenGears removeObject:drivenGear];
    }
}

#pragma mark - 设置从动齿轮位置

- (void)configDrivenGearPointWithDrivenGear:(GearView *)drivenGear Angle:(CGFloat)angle Spacing:(CGFloat)spacing{
    
    if (!drivenGear) return;
    
    if (angle < 0 || angle > 359) angle = 0;
    
    CGFloat radian = M_PI / 180 * angle;
    
    CGFloat mainRadius = self.bounds.size.width * 0.5f; //主动齿轮半径
    
    CGFloat drivenRadius = drivenGear.bounds.size.width * 0.5f; //从动齿轮半径
    
    CGFloat minToothHeight = MIN(self.toothHeight, drivenGear.toothHeight); //最小的轮齿高度
    
    if (minToothHeight < spacing) spacing = 1.0f;
    
    minToothHeight = minToothHeight - spacing; //去除间隙
    
    // 获取从动齿轮当前弧度坐标
    
    CGPoint point = [self getPointWithRadius:mainRadius + drivenRadius - minToothHeight Radian:radian];
    
    // 根据主动齿轮中心点坐标计算出从动齿轮中心点坐标 (包括轮齿间距)
    
    CGPoint drivenPoint = CGPointMake(point.x + self.center.x - drivenRadius - mainRadius + minToothHeight, point.y + self.center.y - drivenRadius - mainRadius + minToothHeight);
    
    drivenGear.center = drivenPoint;
}

#pragma mark - 设置从动齿轮初始弧度

- (void)configDrivenGearInitialRadianWithDrivenGear:(GearView *)drivenGear Angle:(CGFloat)angle Spacing:(CGFloat)spacing{
    
    if (!drivenGear) return;
    
    if (angle < 0 || angle > 359) angle = 0;
    
    CGFloat radian = M_PI / 180 * angle;
    
    CGFloat mainRadius = self.bounds.size.width * 0.5f; //主动齿轮半径
    
    CGFloat drivenRadius = drivenGear.bounds.size.width * 0.5f; //从动齿轮半径
    
    CGFloat minToothHeight = MIN(self.toothHeight, drivenGear.toothHeight); //最小的轮齿高度
    
    if (minToothHeight < spacing) spacing = 1.0f;
    
    minToothHeight = minToothHeight - spacing; //去除间隙
    
    // 计算从动齿轮初始弧度 以保证轮齿咬合
    
    if (self.toothRadianArray.count == 0 || self.gapRadianArray.count == 0) return ;
    
    // 获取与主动齿轮最接近的轮齿或缺口弧度
    
    NSNumber *mainNearestRadianNumber = [self getNearestNumberWithArrayA:self.toothRadianArray ArrayB:self.gapRadianArray Number:@(radian)];
    
    CGFloat mainNearestRadian = [mainNearestRadianNumber floatValue];
    
    BOOL isTooth = [self.toothRadianArray containsObject:mainNearestRadianNumber]; // 是否为轮齿 用于判断主动齿轮最近接的位置是轮齿还是缺口
    
    // 计算主动齿轮最接近的坐标点 (包括两个齿轮的间距)
    
    CGFloat halfSpacing = spacing * 0.5f;
    
    CGPoint mainNearestPoint = [self getPointWithRadius:isTooth ? mainRadius + halfSpacing : mainRadius + halfSpacing - self.toothHeight Radian:mainNearestRadian];
    
    mainNearestPoint = CGPointMake(mainNearestPoint.x + self.center.x - mainRadius - halfSpacing, mainNearestPoint.y + self.center.y - mainRadius - halfSpacing);
    
    if (!isTooth) mainNearestPoint.x += self.toothHeight;
    
    if (!isTooth) mainNearestPoint.y += self.toothHeight;
    
    // 根据主动齿轮最近的坐标 计算相对于从动齿轮最接近的坐标点的弧度以及偏差
    
    CGFloat drivenNearestRadian = [self getRadianWithCenter:drivenGear.center Point:mainNearestPoint] + M_PI;
    
    CGFloat drivenNearestOffsetRadian = drivenNearestRadian - [[self getNearestNumberWithArray:isTooth ? drivenGear.gapRadianArray : drivenGear.toothRadianArray Number:@(drivenNearestRadian)] floatValue]; //从动齿轮偏移弧度 = 主动齿轮最接近点的坐标较从动齿轮的弧度 - 从动齿轮的轮齿或缺口最接近的弧度
    
    // 计算从动齿轮初始弧度 (根据主动齿轮弧度计算)
    
    CGFloat drivenInitialRadian = acosf(self.transform.a) * self.toothCount / drivenGear.toothCount;
    
    drivenGear.transform = CGAffineTransformMakeRotation(self.transform.b < 0 ? drivenInitialRadian : -drivenInitialRadian);
    
    drivenGear.transform = CGAffineTransformRotate(drivenGear.transform, drivenNearestOffsetRadian);
    
    
    /** 计算从动齿轮最接近的坐标 (调试使用)  */
    
    CGPoint drivenNearestPoint = [self getPointWithRadius:isTooth ? drivenRadius - drivenGear.toothHeight : drivenRadius Radian:drivenNearestRadian];
    
    drivenNearestPoint = CGPointMake(drivenNearestPoint.x + drivenGear.center.x - drivenRadius, drivenNearestPoint.y + drivenGear.center.y  - drivenRadius);
    
    if (isTooth) drivenNearestPoint.x += drivenGear.toothHeight;
    
    if (isTooth) drivenNearestPoint.y += drivenGear.toothHeight;
    /*
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
        
        view.center = mainNearestPoint;
        
        view.backgroundColor = [UIColor blueColor];
        
        [self.superview addSubview:view];
    }
    
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
        
        view.center = drivenNearestPoint;
        
        view.backgroundColor = [UIColor redColor];
        
        [self.superview addSubview:view];
    }
     */
}

#pragma mark - 获取数组中最接近的值

- (NSNumber *)getNearestNumberWithArray:(NSArray <NSNumber *>*)array Number:(NSNumber *)number{
    
    NSMutableArray *tempArray = [NSMutableArray array];
    
    for (NSNumber *item in array) {
        
        // 计算相差的绝对值
        
        [tempArray addObject:@(fabs([item floatValue] - [number floatValue]))];
    }
    
    NSNumber *min = [tempArray valueForKeyPath:@"@min.self"];
    
    return array[[tempArray indexOfObject:min]];
}

- (NSNumber *)getNearestNumberWithArrayA:(NSArray <NSNumber *>*)arrayA ArrayB:(NSArray <NSNumber *>*)arrayB Number:(NSNumber *)number{
    
    NSMutableArray *tempArrayA = [NSMutableArray array];
    
    for (NSNumber *item in arrayA) {
        
        // 计算相差的绝对值
        
        [tempArrayA addObject:@(fabs([item floatValue] - [number floatValue]))];
    }
    
    NSNumber *minA = [tempArrayA valueForKeyPath:@"@min.self"];
    
    
    NSMutableArray *tempArrayB = [NSMutableArray array];
    
    for (NSNumber *item in arrayB) {
        
        // 计算相差的绝对值
        
        [tempArrayB addObject:@(fabs([item floatValue] - [number floatValue]))];
    }
    
    NSNumber *minB = [tempArrayB valueForKeyPath:@"@min.self"];
    
    
    if ([minA compare:minB] == NSOrderedAscending) {
        
        return arrayA[[tempArrayA indexOfObject:minA]];
        
    } else {
     
        return arrayB[[tempArrayB indexOfObject:minB]];
    }
    
}

#pragma mark - 根据半径和弧度获取坐标

- (CGPoint)getPointWithRadius:(CGFloat)radius Radian:(CGFloat)radian{
    
    NSInteger index = (radian) / M_PI_2; //区分在第几象限内
    
    CGFloat needRadian = radian - index * M_PI_2; //用于计算正弦/余弦的弧度
    
    CGFloat x = 0, y = 0;
    
    // 因为贝塞尔绘制的0度起始位置与正常0度位置偏移了90度, 所以为了方便计算这里同步0度起始位置
    
    switch (index) {
            
        case 0:
            //NSLog(@"第二象限");
            x = radius + cosf(needRadian)*radius;
            y = radius + sinf(needRadian)*radius;
            break;
        case 1:
            //NSLog(@"第三象限");
            x = radius - sinf(needRadian)*radius;
            y = radius + cosf(needRadian)*radius;
            break;
        case 2:
            //NSLog(@"第四象限");
            x = radius - cosf(needRadian)*radius;
            y = radius - sinf(needRadian)*radius;
            break;
        case 3:
            //NSLog(@"第一象限");
            x = radius + sinf(needRadian)*radius;
            y = radius - cosf(needRadian)*radius;
            break;
            
        default:
            break;
    }
    
    return CGPointMake(x, y);
}

#pragma mark - 根据圆心与另一个坐标位置获取相对于圆心的弧度

- (CGFloat)getRadianWithCenter:(CGPoint)center Point:(CGPoint)point{
    
    /**
     
     根据圆心和一个点的坐标 求弧度
     
     数学公式: arctan(y2 - y1) / (x2 - x1)
     
     C函数:
     angel = Math.atan2(y,x)
     x 指定两个点横坐标的差
     y 指定两个点纵坐标的差
     */
    
    return atan2f(center.y - point.y, center.x - point.x);
}

#pragma mark - LazyLoading

- (CGPathRef)gearPath{
    
    if (!_gearPath) {
        
        CGMutablePathRef path = CGPathCreateMutable();
        
        CGFloat width = self.frame.size.width;
        
        CGFloat height = self.frame.size.height;
        
        CGFloat exteriorRadius = width * 0.5f; //外圆半径
        
        CGFloat interiorRadius = (width - self.toothHeight * 2) * 0.5f; //内圆半径
        
        CGFloat minAndMaxRatio = (self.toothMinWidth / (self.toothMinWidth + self.toothMaxWidth)); //最小宽度与最大宽度的比例
        
        CGFloat averageRadian = (M_PI * 2) / self.toothCount; //平均每个的弧度 (平均弧度 = 最小弧度 + 最大弧度)
        
        CGFloat minRadian = averageRadian * minAndMaxRatio; //最小弧度
        
        CGFloat maxRadian = averageRadian - minRadian; //最大弧度
        
        NSMutableArray *toothRadianArray = [NSMutableArray array];
        
        NSMutableArray *gapRadianArray = [NSMutableArray array];
        
        for (NSInteger i = 0 ; i < self.toothCount; i++) {
            
            {
                // 内圆
                
                CGFloat startRadian = maxRadian * i + minRadian * i; // 起始弧度
                
                CGFloat endRadian = maxRadian * i + minRadian * (i + 1); // 结束弧度
                
                CGPathAddArc(path, NULL, width * 0.5f, height * 0.5f, interiorRadius, startRadian, endRadian, 0);
                
                [gapRadianArray addObject:@(startRadian + (endRadian - startRadian) * 0.5f)];
            }
            
            {
                // 外圆
                
                // 根据内圆半径和弧度计算外圆弧度
                // 计算内圆最小弧长度 (脑残公式: 2πr÷360*a)
                
                CGFloat minLength = M_PI * 2 * interiorRadius / 360 * minRadian;
                
                // 根据内圆最小弧长度计算出长度相同的外圆最小弧度和最大弧度
                
                CGFloat tempminRadian = (minLength * 180) / (M_PI * exteriorRadius);
                
                CGFloat tempmaxRadian = averageRadian - tempminRadian;
                
                CGFloat placeholderRadian = minRadian + ((maxRadian - tempminRadian) * 0.5f); //占位弧度 (内圆起始弧度为0 , 外圆起始弧度为占位弧度)
                
                CGFloat startRadian = tempmaxRadian * i + tempminRadian * i + placeholderRadian; // 起始弧度
                
                CGFloat endRadian = tempmaxRadian * i + tempminRadian * (i + 1) + placeholderRadian; // 结束弧度
                
                CGPathAddArc(path, NULL, width * 0.5f, height * 0.5f, exteriorRadius, startRadian, endRadian , 0);
                
                [toothRadianArray addObject:@(startRadian + (endRadian - startRadian) * 0.5f)];
            }
            
        }
        
        _toothRadianArray = [toothRadianArray copy];
        
        _gapRadianArray = [gapRadianArray copy];
        
        _gearPath = CGPathCreateCopy(path);
        
        CGPathRelease(path);
    }
    
    return _gearPath;
}

- (NSMutableArray *)drivenGears{
    
    if (!_drivenGears) _drivenGears = [NSMutableArray array];
    
    return _drivenGears;
}

@end
