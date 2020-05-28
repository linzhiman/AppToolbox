//
//  ATFileManager.m
//  AppToolbox
//
//  Created by linzhiman on 2020/5/21.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import "ATFileManager.h"

@implementation ATFileManager

+ (BOOL)isPathExist:(NSString *)path
{
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

+ (BOOL)isFileExists:(NSString *)filePath
{
    BOOL isDirectory = NO;
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory] && !isDirectory;
}

+ (BOOL)isDirectoryExist:(NSString *)directoryPath
{
    BOOL isDirectory = NO;
    return [[NSFileManager defaultManager] fileExistsAtPath:directoryPath isDirectory:&isDirectory] && isDirectory;
}

+ (BOOL)moveFile:(NSString *)oldFileName to:(NSString *)newFileName
{
    NSError *error = nil;
    if (![[NSFileManager defaultManager] moveItemAtPath:oldFileName toPath:newFileName error:&error]) {
        return NO;
    }
    return  YES;
}

+ (BOOL)copyFile:(NSString *)oldFileName to:(NSString *)newFileName
{
    NSError *error = nil;
    if (![[NSFileManager defaultManager] copyItemAtPath:oldFileName toPath:newFileName error:&error]) {
        return NO;
    }
    return  YES;
}

+ (BOOL)removeFile:(NSString *)filepath
{
    if (filepath == nil) {
        return NO;
    }
    
    if (![ATFileManager isFileExists:filepath]) {
        return YES;
    }
    
    NSError *error = nil;
    if (![[NSFileManager defaultManager] removeItemAtPath:filepath error:&error]) {
        return NO;
    }
    return YES;
}

+ (BOOL)removePath:(NSString *)path
{
    if (path == nil) {
        return NO;
    }
    
    if (![ATFileManager isPathExist:path]) {
        return YES;
    }
    
    NSError *error = nil;
    if (![[NSFileManager defaultManager] removeItemAtPath:path error:&error]) {
        return NO;
    }
    return YES;
}

+ (void)copyFilesInDirectory:(NSString *)srcPath toPath:(NSString *)destPath
{
    if (YES == [self isDirectoryExist:srcPath]
        && YES == [self isDirectoryExist:destPath]) {
        NSString *aFileName = nil;
        NSFileManager *aFileManager = [NSFileManager defaultManager];
        NSDirectoryEnumerator *enumrator =  [aFileManager enumeratorAtPath:srcPath];
        
        while (nil != (aFileName = [enumrator nextObject])) {
            NSString *aSrcFilePath = [srcPath stringByAppendingPathComponent:aFileName];
            NSString *aDestFilePath = [destPath stringByAppendingPathComponent:aFileName];
            [self copyFile:aSrcFilePath to:aDestFilePath];
        }
    }
}

+ (void)writeData:(NSData *)data toFile:(NSString *)filePath completeBlock:(void (^)(NSError *error))block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSError *error;
        NSString *fileFolder = [filePath stringByDeletingLastPathComponent];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:fileFolder]) {
            BOOL succ = [fileManager createDirectoryAtPath:fileFolder
                               withIntermediateDirectories:YES
                                                attributes:nil
                                                     error:&error];
            if (!succ) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    block(error);
                });
                return;
            }
        }
        if ([data writeToFile:filePath atomically:YES]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(nil);
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                block([NSError errorWithDomain:@"[ATFileManager writeData]" code:-1 userInfo:nil]);
            });
        }
    });
}

+ (BOOL)createDirectoryPath:(NSString *)directoryPath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
}

+ (NSString *)appDirectory
{
    static NSString *appDirectory = nil;
    do {
        if (appDirectory) {
            break;
        }
        
        NSArray *directories = NSSearchPathForDirectoriesInDomains(NSApplicationDirectory, NSUserDomainMask, YES);
        if ([directories count] < 1) {
            break;
        }
        
        appDirectory = [directories objectAtIndex:0];
        
        NSUInteger length = [appDirectory length];
        if (length < 1) {
            appDirectory = nil;
            break;
        }
        
        if ('/' == [appDirectory characterAtIndex:length - 1]) {
            break;
        }
        
        appDirectory = [appDirectory stringByAppendingString:@"/"];
    } while (false);
    
    return appDirectory;
}

+ (NSString *)documentsDirectory
{
    static NSString *documentDirectory = nil;
    do {
        if (documentDirectory) {
            break;
        }
        
        NSArray *directories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        if ([directories count] < 1) {
            break;
        }
        
        documentDirectory = [directories objectAtIndex:0];
        
        NSUInteger length = [documentDirectory length];
        if (length < 1) {
            documentDirectory = nil;
            break;
        }
        
        if ('/' == [documentDirectory characterAtIndex:length - 1]) {
            break;
        }
        
        documentDirectory = [documentDirectory stringByAppendingString:@"/"];
    } while (false);
    
    return documentDirectory;
}

+ (NSString *)libraryCachesDirectory
{
    static NSString *libraryCachesDirectory = nil;
    do {
        if (libraryCachesDirectory) {
            break;
        }
        
        NSArray *directories = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        if ([directories count] < 1) {
            break;
        }
        
        libraryCachesDirectory = [directories objectAtIndex:0];
        
        NSUInteger length = [libraryCachesDirectory length];
        if (length < 1) {
            libraryCachesDirectory = nil;
            break;
        }
        
        if ('/' == [libraryCachesDirectory characterAtIndex:length - 1]) {
            break;
        }
        
        libraryCachesDirectory = [libraryCachesDirectory stringByAppendingString:@"/"];
    } while (false);
    
    return libraryCachesDirectory;
}

+ (NSString *)systemTmpDirectory
{
    static NSString *systemTmpDirectory = nil;
    do {
        if (systemTmpDirectory) {
            break;
        }
        
        systemTmpDirectory = NSTemporaryDirectory();
        
        NSUInteger length = [systemTmpDirectory length];
        if (length < 1) {
            systemTmpDirectory = nil;
            break;
        }
        
        if ('/' == [systemTmpDirectory characterAtIndex:length - 1]) {
            break;
        }
        
        systemTmpDirectory = [systemTmpDirectory stringByAppendingString:@"/"];
    } while (false);
    
    return systemTmpDirectory;
}

+ (NSString *)fileNameFromUrl:(NSString *)url
{
    NSInteger indexOfLastSlash = -1;
    for (NSUInteger i = [url length]; i > 0; i --) {
        if ('/' == [url characterAtIndex:i - 1]) {
            indexOfLastSlash = i - 1;
            break;
        }
    }
    
    if (-1 == indexOfLastSlash) {
        return url;
    }
    return [url substringFromIndex:indexOfLastSlash + 1];
}

+ (NSString *)fileExtensionFromUrl:(NSString *)url
{
    NSString *fileName = [ATFileManager fileNameFromUrl:url];
    NSInteger indexOfLastPoint = -1;
    for (NSUInteger i = 0; i < fileName.length; i++) {
        if ('.' == [fileName characterAtIndex:i]) {
            indexOfLastPoint = i - 1;
            break;
        }
    }
    
    if (-1 == indexOfLastPoint) {
        return fileName;
    }
    return [fileName substringFromIndex:indexOfLastPoint + 1];
}

@end
