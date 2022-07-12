//
//  DemoLogView.h
//  Demo
//
//  Created by linzhiman on 2022/5/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DemoLogView : UIView

- (void)appendLog:(NSString *)log;
- (void)clearLog;

@end

NS_ASSUME_NONNULL_END
