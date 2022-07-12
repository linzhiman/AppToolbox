//
//  DemoBaseViewController.h
//  Demo
//
//  Created by linzhiman on 2022/5/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DemoBaseViewController : UIViewController

- (void)addAction:(NSString *)title action:(dispatch_block_t)action;
- (void)log:(NSString *)format, ...NS_FORMAT_FUNCTION(1,2);
- (void)clearLog;

@end

NS_ASSUME_NONNULL_END
