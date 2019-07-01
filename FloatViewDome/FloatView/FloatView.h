//
//  FloatView.h
//  FloatViewDome
//
//  Created by zcy on 2017/11/14.
//  Copyright © 2017年 CY. All rights reserved.
//

#import <UIKit/UIKit.h>
// 停留方式
typedef NS_ENUM(NSUInteger,StayMode) {
    // 停靠左右两侧
    STAYMODE_LEFTANDRIGHT = 0,
    // 停靠左侧
    STAYMODE_LEFT,
    // 停靠右侧
    STAYMODE_RIGHT
};

@interface FloatView : UIImageView

/** 悬浮图片停留的方式(默认为STAYMODE_LEFTANDRIGHT)*/
@property (nonatomic) StayMode stayMode;
/** 悬浮图片左右边距(默认5)*/
@property (nonatomic) CGFloat stayEdgeDistance;
/** 悬浮图片停靠的动画事件(默认0.3秒)*/
@property (nonatomic) CGFloat stayAnimateTime;

/**
 设置简单的轻点 block事件
 */
- (void)setTapActionWithBlock:(void(^)(void))block;
/**
 根据 imageName 改变FloatView的image
 */
- (void)setImageWithName:(NSString *)imageName;
/**
 当滚动的时候悬浮图片居中在屏幕边缘
 */
- (void)moveToHalfInScreenWhenScrolling;
/**
 设置当前浮动图片的透明度
 */
- (void)setCurrentAlpha:(CGFloat)stayAlpha;

@end
