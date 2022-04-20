//
//  UIView+ATFrame.h
//  AppToolbox
//
//  Created by linzhiman on 2022/4/1.
//  Copyright © 2022 AppToolbox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (ATFrame)

@property (nonatomic, assign) CGFloat at_x;
@property (nonatomic, assign) CGFloat at_y;

@property (nonatomic, assign) CGFloat at_left;
@property (nonatomic, assign) CGFloat at_right;
@property (nonatomic, assign) CGFloat at_top;
@property (nonatomic, assign) CGFloat at_bottom;

@property (nonatomic, assign) CGFloat at_centerX;
@property (nonatomic, assign) CGFloat at_centerY;

@property (nonatomic, assign) CGFloat at_width;
@property (nonatomic, assign) CGFloat at_height;

@property (nonatomic, assign) CGSize at_size;

@end

NS_ASSUME_NONNULL_END
