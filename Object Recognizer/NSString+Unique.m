//
//  NSString+Unique.m
//  Object Recognizer
//
//  Created by Luke Vella on 4/2/12.
//  Copyright (c) 2012 N/A. All rights reserved.
//
//  SOURCE: http://stackoverflow.com/questions/5343003/create-a-unique-string-used-for-saving-data

#import "NSString+Unique.h"

@implementation NSString (Unique)

+ (NSString *)getUniqueFilenameInFolder:(NSString *)folder {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *existingFiles = [fileManager contentsOfDirectoryAtPath:folder error:nil];
    NSString *uniqueFilename;
    
    do {
        CFUUIDRef newUniqueId = CFUUIDCreate(kCFAllocatorDefault);
        CFStringRef newUniqueIdString = CFUUIDCreateString(kCFAllocatorDefault, newUniqueId);
        
        uniqueFilename = [NSString stringWithString:(__bridge NSString *)newUniqueIdString];
        
        CFRelease(newUniqueId);
        CFRelease(newUniqueIdString);
    } while ([existingFiles containsObject:uniqueFilename]);
    
    return uniqueFilename;
}

@end
