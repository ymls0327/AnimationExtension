//
//  UIScrollViewAnimationExtension.m
//  CollectionAnimation
//
//  Created by 贾亚宁 on 2022/1/22.
//

#import "UIScrollViewAnimationExtension.h"
#import <objc/message.h>

@interface ScrollViewAnimator : NSObject
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, copy) dispatch_block_t complete;
@property (nonatomic, assign) CAnimationOption option;
@property (nonatomic, assign) NSTimeInterval startTime;
@property (nonatomic, assign) CGPoint startOffset;
@property (nonatomic, assign) CGPoint endOffset;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) NSTimeInterval runTime;
@property (nonatomic, strong) CADisplayLink *timer;
@end

@implementation ScrollViewAnimator

- (instancetype)initWithScrollView:(UIScrollView *)scrollView option:(CAnimationOption)option {
    self = [super init];
    if (self) {
        _scrollView = scrollView;
        _option = option;
    }
    return self;
}

- (void)setContentOffset:(CGPoint)contentOffset duration:(NSTimeInterval)duration {
    if (!_scrollView) {
        return;
    }
    // 如果执行时间，直接设置，不进行动画
    if (duration <= 0) {
        [_scrollView setContentOffset:contentOffset animated:NO];
        return;
    }
    _startTime = [[NSDate new] timeIntervalSince1970];
    _startOffset = _scrollView.contentOffset;
    _endOffset = contentOffset;
    _duration = duration;
    _runTime = 0;
    // 初始化定时器
    if (!_timer) {
        _timer = [CADisplayLink displayLinkWithTarget:self selector:@selector(animtedScroll)];
        [_timer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
}

- (void)animtedScroll {
    // 这里是怕在动画过程中，scrollView被销毁，销毁后停止执行
    if (!_timer || !_scrollView) {
        return;
    }
    _runTime += _timer.duration;
    if (_runTime >= _duration) {
        [_scrollView setContentOffset:_endOffset animated:NO];
        [_timer invalidate];
        _timer = nil;
        !_complete?:_complete();
        return;
    }
    CGPoint offset = _scrollView.contentOffset;
    offset.x = [self compute:(CGFloat)_runTime begin:_startOffset.x change:_endOffset.x-_startOffset.x duration:(CGFloat)_duration];
    offset.y = [self compute:(CGFloat)_runTime begin:_startOffset.y change:_endOffset.y-_startOffset.y duration:(CGFloat)_duration];
    [_scrollView setContentOffset:offset animated:NO];
}

- (CGFloat)compute:(CGFloat)t begin:(CGFloat)b change:(CGFloat)c duration:(CGFloat)d {
    switch (_option) {
        case linear:
            return c * t / d + b;
        case quadIn:
            t /= d;
            return c * t * t + b;
        case quadOut:
            t /= d;
            return -c * t * (t - 2) + b;
        case quadInOut:
            t /= d / 2;
            if (t < 1) {
                return c / 2 * t * t + b;
            }
            t -= 1;
            return -c / 2 * (t * (t - 2) - 1) + b;
        case cubicIn:
            t /= d;
            return c * t * t * t + b;
        case cubicOut:
            t = t / d - 1;
            return c * (t * t * t + 1) + b;
        case cubicInOut:
            t /= d / 2;
            if (t < 1) {
                return c / 2 * t * t * t + b;
            }
            t -= 2;
            return c / 2 * (t * t * t + 2) + b;
        case quartIn:
            t /= d;
            return c * t * t * t * t + b;
        case quartOut:
            t = t / d - 1;
            return -c * (t * t * t * t - 1) + b;
        case quartInOut:
            t /= d / 2;
            if (t < 1) {
                return c / 2 * t * t * t * t + b;
            }
            t -= 2;
            return -c / 2 * (t * t * t * t - 2) + b;
        case quintIn:
            t /= d;
            return c * t * t * t * t * t + b;
        case quintOut:
            t = t / d - 1;
            return c * ( t * t * t * t * t + 1) + b;
        case quintInOut:
            t /= d / 2;
            if (t < 1) {
                return c / 2 * t * t * t * t * t + b;
            }
            t -= 2;
            return c / 2 * (t * t * t * t * t + 2) + b;
        case sineIn:
            return -c * cos(t / d * (M_PI / 2)) + c + b;
        case sineOut:
            return c * sin(t / d * (M_PI / 2)) + b;
        case sineInOut:
            return -c / 2 * (cos(M_PI * t / d) - 1) + b;
        case expoIn:
            return (t == 0) ? b : c * pow(2, 10 * (t / d - 1)) + b;
        case expoOut:
            return (t == d) ? b + c : c * (-pow(2, -10 * t / d) + 1) + b;
        case expoInOut:
            if (t == 0) {
                return b;
            }
            if (t == d) {
                return b + c;
            }
            t /= d / 2;
            if (t < 1) {
                return c / 2 * pow(2, 10 * (t - 1)) + b;
            }
            t -= 1;
            return c / 2 * (-pow(2, -10 * t) + 2) + b;
        case circleIn:
            t /= d;
            return -c * (sqrt(1 - t * t) - 1) + b;
        case circleOut:
            t = t / d - 1;
            return c * sqrt(1 - t * t) + b;
        case circleInOut:
            t /= d / 2;
            if (t < 1) {
                return -c / 2 * (sqrt(1 - t * t) - 1) + b;
            }
            t -= 2;
            return c / 2 * (sqrt(1 - t * t) + 1) + b;
        default:
            break;
    }
    return 0;
}

@end

@interface UIScrollView (YNExtension)
@property (nonatomic, strong) ScrollViewAnimator *animator;
@end

NSString *const AssociatedKey = @"AssociatedAnimatorKey";

@implementation UIScrollView (YNExtension)

- (void)setAnimator:(ScrollViewAnimator *)animator {
    objc_setAssociatedObject(self, &AssociatedKey, animator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (ScrollViewAnimator *)animator {
    return (ScrollViewAnimator *)objc_getAssociatedObject(self, &AssociatedKey);
}

- (void)setContentOffset:(CGPoint)contentOffset duration:(NSTimeInterval)duration option:(CAnimationOption)option complete:(dispatch_block_t)complete {
    if (self.animator == nil) {
        self.animator = [[ScrollViewAnimator alloc] initWithScrollView:self option:option];
    }
    __weak typeof(self)weakSelf = self;
    [self.animator setComplete:^{
        __strong typeof(weakSelf)strongSelf = weakSelf;
        dispatch_async(dispatch_get_main_queue(), ^{
            strongSelf.animator = nil;
        });
        !complete?:complete();
    }];
    [self.animator setContentOffset:contentOffset duration:duration];
}

@end
