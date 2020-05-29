//
//  ATUserDefaults.h
//  AppToolbox
//
//  Created by linzhiman on 2020/5/29.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ATUserDefaultsConfig) {
    ATUserDefaultsConfigDefault = 1,
    ATUserDefaultsConfigWithAppVersion = 1 << 1,
    ATUserDefaultsConfigWithUserIdentifier = 1 << 2
};

@interface ATUserDefaults : NSObject

+ (void)addConfig:(ATUserDefaultsConfig)config forKey:(NSString *)defaultName;
+ (void)setUserIdentifier:(NSString *)userIdentifier;

+ (BOOL)boolForKey:(NSString *)defaultName;
+ (void)setBool:(BOOL)value forKey:(NSString *)defaultName;

+ (NSInteger)integerForKey:(NSString *)defaultName;
+ (void)setInteger:(NSInteger)value forKey:(NSString *)defaultName;

+ (nullable NSString *)stringForKey:(NSString *)defaultName;
+ (void)setString:(NSString *)value forKey:(NSString *)defaultName;

+ (nullable NSArray *)arrayForKey:(NSString *)defaultName;
+ (void)setArray:(NSArray *)value forKey:(NSString *)defaultName;

+ (nullable NSDictionary *)dictionaryForKey:(NSString *)defaultName;
+ (void)setDictionary:(NSDictionary *)value forKey:(NSString *)defaultName;

+ (nullable NSObject *)objectForKey:(NSString *)defaultName;
+ (void)setObject:(NSObject *)value forKey:(NSString *)defaultName;

+ (void)removeObjectForKey:(NSString *)defaultName;

@end

NS_ASSUME_NONNULL_END
