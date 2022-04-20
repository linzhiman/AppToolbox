//
//  UIView+ATFrame.m
//  AppToolbox
//
//  Created by linzhiman on 2022/4/1.
//  Copyright © 2022 AppToolbox. All rights reserved.
//

#import "UIView+ATFrame.h"

@implementation UIView (ATFrame)

- (CGFloat)at_x
{
    return self.frame.origin.x;
}

- (void)setAt_x:(CGFloat)at_x
{
    CGRect rect = self.frame;
    rect.origin.x = at_x;
    self.frame = rect;
}

- (CGFloat)at_y
{
    return self.frame.origin.y;
}

- (void)setAt_y:(CGFloat)at_y
{
    CGRect rect = self.frame;
    rect.origin.y = at_y;
    self.frame = rect;
}

- (CGFloat)at_left
{
    return self.frame.origin.x;
}

- (void)setAt_left:(CGFloat)at_left
{
    CGRect rect = self.frame;
    rect.origin.x = at_left;
    self.frame = rect;
}

- (CGFloat)at_right
{
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setAt_right:(CGFloat)at_right
{
    CGRect frame = self.frame;
    frame.size.width = at_right - frame.origin.x;
    self.frame = frame;
}

- (CGFloat)at_top
{
    return self.frame.origin.y;
}

- (void)setAt_top:(CGFloat)at_top
{
    CGRect rect = self.frame;
    rect.origin.y = at_top;
    self.frame = rect;
}

- (CGFloat)at_bottom
{
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setAt_bottom:(CGFloat)at_bottom
{
    CGRect frame = self.frame;
    frame.size.height = at_bottom - frame.origin.y;
    self.frame = frame;
}

- (CGFloat)at_width
{
    return self.frame.size.width;
}

- (void)setAt_width:(CGFloat)at_width
{
    CGRect rect = self.frame;
    rect.size.width = at_width;
    self.frame = rect;
}

- (CGFloat)at_height
{
    return self.frame.size.height;
}

- (void)setAt_height:(CGFloat)at_height
{
    CGRect rect = self.frame;
    rect.size.height = at_height;
    self.frame = rect;
}

- (CGFloat)at_centerX
{
    return self.center.x;
}

- (void)setAt_centerX:(CGFloat)at_centerX
{
    CGPoint center = self.center;
    center.x = at_centerX;
    self.center = center;
}

- (CGFloat)at_centerY
{
    return self.center.y;
}

- (void)setAt_centerY:(CGFloat)at_centerY
{
    CGPoint center = self.center;
    center.y = at_centerY;
    self.center = center;
}

- (CGSize)at_size
{
    return self.frame.size;
}

- (void)setAt_size:(CGSize)at_size
{
    CGRect frame = self.frame;
    frame.size = at_size;
    self.frame = frame;
}

@end
