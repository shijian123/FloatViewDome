//
//  FloatView.m
//  FloatViewDome
//
//  Created by zcy on 2017/11/14.
//  Copyright © 2017年 CY. All rights reserved.
//

#import "FloatView.h"
#import <objc/runtime.h>

#define NavBarBottom 64
#define TabBarHeight 49
#define CYScreenWidth [UIScreen mainScreen].bounds.size.width
#define CYScreenHeight [UIScreen mainScreen].bounds.size.height
#define IPHONE_X [UIScreen mainScreen].bounds.size.height == 812

static char kActionHandlerTapBlockKey;
static char kActionHandlerTapGestureKey;

@implementation FloatView
{
    BOOL isHalfScreen;
}

#pragma mark - init method

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
        self.stayEdgeDistance = 5;
        self.stayAnimateTime = 0.3;
        [self initStayLocation];
    }
    return self;
}

/**
 设置浮动图片的初始位置
 */
- (void)initStayLocation{
    CGRect frame = self.frame;
    CGFloat stayWidth = frame.size.width;
    CGFloat initX = CYScreenWidth - self.stayEdgeDistance - stayWidth/2.0;
    CGFloat initY;
    if (IPHONE_X) {
        initY = (CYScreenHeight - NavBarBottom - TabBarHeight - 34) * (2.0/3.0) + NavBarBottom;
    }else{
        initY = (CYScreenHeight - NavBarBottom - TabBarHeight) * (2.0/3.0) + NavBarBottom;
    }
    frame.origin.x = initX;
    frame.origin.y = initY;
    self.frame = frame;
    isHalfScreen = NO;
    
}

#pragma mark - touches method

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    // 先让悬浮图片的alpha为1
    self.alpha = 1;
    //获取手指当前的点
    UITouch *touch = [touches anyObject];
    CGPoint curPoint = [touch locationInView:self];
    CGPoint prePoint = [touch previousLocationInView:self];

    //x方向移动的距离
    CGFloat deltaX = curPoint.x - prePoint.x;
    CGFloat deltaY = curPoint.y - prePoint.y;
    CGRect frame = self.frame;
    frame.origin.x += deltaX;
    frame.origin.y += deltaY;
    self.frame = frame;
    
    self.alpha =1;
    touch = [touches anyObject];
    
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self moveStay];
    // 这里可以设置过几秒，alpha减小
    //    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //        [pThis animateHidden];
    });
}

#pragma mark - move method

/**
 根据stayModel来移动悬浮图片
 */
- (void)moveStay{
    BOOL isLeft = [self judgeLocationIsLeft];
    switch (_stayMode) {
        case STAYMODE_LEFTANDRIGHT:
            [self moveToBorder:isLeft];
            break;
        case STAYMODE_LEFT:
            [self moveToBorder:YES];
            break;
        case STAYMODE_RIGHT:
            [self moveToBorder:NO];
            break;
        default:
            break;
    }
}

/**
 移动到屏幕边缘
 */
- (void)moveToBorder:(BOOL)isLeft{
    CGRect frame = self.frame;
    CGFloat destinationX;
    if (isLeft) {
        destinationX = self.stayEdgeDistance;
    }else{
        CGFloat stayWidth = frame.size.width;
        destinationX = CYScreenWidth - self.stayEdgeDistance - stayWidth;
    }
    frame.origin.x = destinationX;
    frame.origin.y = [self moveSafeLocationY];
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:_stayAnimateTime animations:^{
        __strong typeof(self) pThis = weakSelf;
        pThis.frame = frame;
    }];
    isHalfScreen = NO;
}

/**
 当滚动的时候悬浮图片居中在屏幕边缘
 */
- (void)moveToHalfInScreenWhenScrolling{
    BOOL isLeft = [self judgeLocationIsLeft];
    [self moveStayToMiddleInScreenBorder:isLeft];
    isHalfScreen = YES;
}

/**
 悬浮图片居中在屏幕边缘
 */
- (void)moveStayToMiddleInScreenBorder:(BOOL)isLeft{
    CGRect frame = self.frame;
    CGFloat stayWidth = frame.size.width;
    CGFloat destinationX;
    if (isLeft == YES) {
        destinationX = - stayWidth/2;
    }else{
        destinationX = CYScreenWidth - stayWidth + stayWidth/2;
    }
    
    frame.origin.x = destinationX;
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.2 animations:^{
        __strong typeof(self) pThis = weakSelf;
        pThis.frame = frame;
    }];
    
}

/**
 设置悬浮图片不高于屏幕顶端，不低于屏幕底端
 */
- (CGFloat)moveSafeLocationY{
    CGRect frame = self.frame;
    CGFloat stayHeight = frame.size.height;
    //当前view的值
    CGFloat curY = self.frame.origin.y;
    CGFloat destinationY = frame.origin.y;
    //悬浮图片的最顶端Y值
    CGFloat stayMostTopY = NavBarBottom + _stayEdgeDistance;
    if (curY <= stayMostTopY) {
        destinationY = stayMostTopY;
    }
    //悬浮图片的底端Y值
    CGFloat stayMostBottomY = CYScreenHeight - TabBarHeight - _stayEdgeDistance - stayHeight;
    if (IPHONE_X) {
        stayMostBottomY -=34;
    }
    if (curY >= stayMostBottomY) {
        destinationY = stayMostBottomY;
    }
    return  destinationY;
}

#pragma mark - judgeLocationLeft method

/**
 判断当前view是否在父界面的左边
 */
- (BOOL)judgeLocationIsLeft{
    //手机屏幕中间位置x值
    CGFloat middleX = [UIScreen mainScreen].bounds.size.width / 2.0;
    CGFloat curX = self.frame.origin.x + self.bounds.size.width/2;
    if (curX <= middleX) {
        return YES;
    }else{
        return NO;
    }
}

#pragma mark - tapBlock method

- (void)setTapActionWithBlock:(void (^)(void))block{
    // 为gesture添加关联是为了gesture只创建一次，objc_getAssociatedObject如果返回nil就创建一次
    UITapGestureRecognizer *tap = objc_getAssociatedObject(self, &kActionHandlerTapGestureKey);
    if (!tap) {
        tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleActionForTapGesture:)];
        [self addGestureRecognizer:tap];
        objc_setAssociatedObject(self, &kActionHandlerTapGestureKey, tap, OBJC_ASSOCIATION_RETAIN);
    }
    objc_setAssociatedObject(self, &kActionHandlerTapBlockKey, block, OBJC_ASSOCIATION_COPY);
}

- (void)handleActionForTapGesture:(UITapGestureRecognizer *)tap{
    if (tap.state == UIGestureRecognizerStateRecognized) {
        void(^action)(void) = objc_getAssociatedObject(self, &kActionHandlerTapBlockKey);
        if (action) {
            self.alpha = 1;
            if (isHalfScreen == NO) {
                action();
            }else{
                [self moveStay];
            }
        }
    }
    
}

#pragma mark - setter method

- (void)setImageWithName:(NSString *)imageName{
    self.image = [UIImage imageNamed:imageName];
}

- (void)setCurrentAlpha:(CGFloat)stayAlpha{
    if (stayAlpha <= 0) {
        stayAlpha = 1;
    }
    self.alpha = stayAlpha;
}

@end
