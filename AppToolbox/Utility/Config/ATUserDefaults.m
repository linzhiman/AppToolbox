//
//  ATUserDefaults.m
//  AppToolbox
//
//  Created by linzhiman on 2020/5/29.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import "ATUserDefaults.h"
#import "ATGlobalMacro.h"

@interface ATUserDefaults()
@property (nonatomic, strong) NSString *userIdentifier;
@property (nonatomic, strong) NSMutableDictionary *configs;
@end

@implementation ATUserDefaults

AT_IMPLEMENT_SINGLETON(ATUserDefaults);

+ (ATUserDefaultsConfig)configForKey:(NSString *)defaultName
{
    ATUserDefaultsConfig type = ATUserDefaultsConfigDefault;
    if ([ATUserDefaults sharedObject].configs) {
        NSNumber *value = [[ATUserDefaults sharedObject].configs objectForKey:defaultName];
        if (value) {
            type = (ATUserDefaultsConfig)value.integerValue;
        }
    }
    return type;
}

+ (void)addConfig:(ATUserDefaultsConfig)config forKey:(NSString *)defaultName
{
    if (![ATUserDefaults sharedObject].configs) {
        [ATUserDefaults sharedObject].configs = [[NSMutableDictionary alloc] init];
    }
    [[ATUserDefaults sharedObject].configs setObject:@(config) forKey:defaultName];
}

+ (void)setUserIdentifier:(NSString *)userIdentifier
{
    [ATUserDefaults sharedObject].userIdentifier = userIdentifier;
}

+ (NSString *)realKeyForKey:(NSString *)defaultName
{
    NSString *realKey = defaultName;
    
    ATUserDefaultsConfig config = [self configForKey:defaultName];
    if (config & ATUserDefaultsConfigWithAppVersion) {
        NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        realKey = [NSString stringWithFormat:@"%@-%@", realKey, version];
    }
    if (config & ATUserDefaultsConfigWithUserIdentifier) {
        NSString *userIdentifier = [ATUserDefaults sharedObject].userIdentifier;
        NSAssert(userIdentifier != nil, @"Must set [ATUserDefaults setUserIdentifier:]");
        if (userIdentifier) {
            realKey = [NSString stringWithFormat:@"%@-%@", realKey, userIdentifier];
        }
    }
    return realKey;
}

+ (BOOL)boolForKey:(NSString *)defaultName
{
    NSString *realKey = [self realKeyForKey:defaultName];
    return [[NSUserDefaults standardUserDefaults] boolForKey:realKey];
}

+ (void)setBool:(BOOL)value forKey:(NSString *)defaultName
{
    NSString *realKey = [self realKeyForKey:defaultName];
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:realKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSInteger)integerForKey:(NSString *)defaultName
{
    NSString *realKey = [self realKeyForKey:defaultName];
    return [[NSUserDefaults standardUserDefaults] integerForKey:realKey];
}

+ (void)setInteger:(NSInteger)value forKey:(NSString *)defaultName
{
    NSString *realKey = [self realKeyForKey:defaultName];
    [[NSUserDefaults standardUserDefaults] setInteger:value forKey:realKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (nullable NSString *)stringForKey:(NSString *)defaultName
{
    NSString *realKey = [self realKeyForKey:defaultName];
    return [[NSUserDefaults standardUserDefaults] stringForKey:realKey];
}

+ (void)setString:(NSString *)value forKey:(NSString *)defaultName
{
    [self setObject:value forKey:defaultName];
}

+ (nullable NSArray *)arrayForKey:(NSString *)defaultName
{
    NSString *realKey = [self realKeyForKey:defaultName];
    return [[NSUserDefaults standardUserDefaults] arrayForKey:realKey];
}

+ (void)setArray:(NSArray *)value forKey:(NSString *)defaultName
{
    [self setObject:value forKey:defaultName];
}

+ (nullable NSDictionary *)dictionaryForKey:(NSString *)defaultName
{
    NSString *realKey = [self realKeyForKey:defaultName];
    return [[NSUserDefaults standardUserDefaults] dictionaryForKey:realKey];
}

+ (void)setDictionary:(NSDictionary *)value forKey:(NSString *)defaultName
{
    [self setObject:value forKey:defaultName];
}

+ (nullable NSObject *)objectForKey:(NSString *)defaultName
{
    NSString *realKey = [self realKeyForKey:defaultName];
    return [[NSUserDefaults standardUserDefaults] objectForKey:realKey];
}

+ (void)setObject:(NSObject *)value forKey:(NSString *)defaultName
{
    NSString *realKey = [self realKeyForKey:defaultName];
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:realKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)removeObjectForKey:(NSString *)defaultName
{
    NSString *realKey = [self realKeyForKey:defaultName];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:realKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
