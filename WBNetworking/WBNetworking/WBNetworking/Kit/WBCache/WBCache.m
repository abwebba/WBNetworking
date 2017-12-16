//
//  WBCache.m
//  WBNetworking
//
//  Created by zwb on 2017/12/16.
//  Copyright © 2017年 zwb. All rights reserved.
//

#import "WBCache.h"
#import "YYCache.h"

@interface WBCache()
@property (nonatomic, strong) YYDiskCache *yyDiskCache;
@end


@implementation WBCache

+ (instancetype)sharedCache {
    static id _sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (YYDiskCache *)yyDiskCache {
    if (!_yyDiskCache) {
        NSString *basePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        _yyDiskCache = [[YYDiskCache alloc] initWithPath:[basePath stringByAppendingPathComponent:[NSString stringWithFormat:@"DiskCache"]]];
    }
    return _yyDiskCache;
}

- (void)resetDiskCache {
    self.yyDiskCache = nil;
}

#pragma mark - 共用缓存方法
- (void)setObject:(id<NSObject>)object forKey:(NSString *)key {
    [self.yyDiskCache setObject:[[WBCacheModel alloc] initWithData:object].toDictionary forKey:key];
}

- (WBCacheModel *)objectForKey:(NSString *)key {
    return [[WBCacheModel alloc] initWithDictionary:(NSDictionary *)[self.yyDiskCache objectForKey:key] error:nil];
}

- (void)removeObjectForKey:(NSString *)key {
    [self.yyDiskCache removeObjectForKey:key];
}

- (NSInteger)totalCost {
    return [self.yyDiskCache totalCost];
}

- (void)removeAllObject {
    [self.yyDiskCache removeAllObjects];
}
@end
