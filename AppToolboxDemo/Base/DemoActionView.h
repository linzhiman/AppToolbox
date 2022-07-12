//
//  DemoActionView.h
//  Demo
//
//  Created by linzhiman on 2022/5/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DemoActionView : UIView

- (void)addActionTitle:(NSString *)title action:(dispatch_block_t)action;

@end

NS_ASSUME_NONNULL_END
