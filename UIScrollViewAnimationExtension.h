//
//  UIScrollViewAnimationExtension.h
//  CollectionAnimation
//
//  Created by 贾亚宁 on 2022/1/22.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CAnimationOption) {
     linear,
     quadIn,
     quadOut,
     quadInOut,
     cubicIn,
     cubicOut,
     cubicInOut,
     quartIn,
     quartOut,
     quartInOut,
     quintIn,
     quintOut,
     quintInOut,
     sineIn,
     sineOut,
     sineInOut,
     expoIn,
     expoOut,
     expoInOut,
     circleIn,
     circleOut,
     circleInOut
};

@interface UIScrollView (YNExtension)

- (void)setContentOffset:(CGPoint)contentOffset duration:(NSTimeInterval)duration option:(CAnimationOption)option complete:(dispatch_block_t)complete;

@end
