//
//  ATFileManager.h
//  AppToolbox
//
//  Created by linzhiman on 2020/5/21.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ATFileManager : NSObject

/// file or directory
+ (BOOL)isPathExist:(NSString *)path;
+ (BOOL)isFileExists:(NSString *)filePath;
+ (BOOL)isDirectoryExist:(NSString *)directoryPath;

+ (NSString *)fileNameFromUrl:(NSString *)url;
/// 获取url最后斜杆里面.之后的字符串。如果没有.字符，就返回整个名字
+ (NSString *)fileExtensionFromUrl:(NSString *)url;

+ (BOOL)moveFile:(NSString *)oldFilePath to:(NSString *)newFilePath;
+ (BOOL)copyFile:(NSString *)oldFilePath to:(NSString *)newFilePath;
+ (BOOL)removeFile:(NSString *)filePath;
+ (BOOL)removePath:(NSString *)path;
+ (void)copyFilesInDirectory:(NSString *)srcPath toPath:(NSString *)destPath;
+ (void)writeData:(NSData *)data toFile:(NSString *)filePath completeBlock:(void (^)(NSError *error))block;

+ (BOOL)createDirectoryPath:(NSString *)directoryPath;

/// 程序的整个根目录
+ (NSString *)appDirectory;
/// 根目录下的Documents，会被itunes备份
+ (NSString *)documentsDirectory;
/// Library下的Caches目录，不会被itunes备份，而且系统磁盘不足时候会删除这个文件夹的内容
+ (NSString *)libraryCachesDirectory;
/// 系统的临时目录，每次重新启动app都会被删除
+ (NSString *)systemTmpDirectory;

@end

NS_ASSUME_NONNULL_END
