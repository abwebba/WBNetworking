//
//  WBCache.h
//  WBNetworking
//
//  Created by zwb on 2017/12/16.
//  Copyright © 2017年 zwb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WBCacheModel.h"

@interface WBCache : NSObject

/**
 *  缓存类单例
 *
 *  @return 缓存类单例
 */
+ (instancetype)sharedCache;

/**
 *  更换账号后，要重置缓存
 */
- (void)resetDiskCache;

#pragma mark - 共用缓存方法
/**
 获取缓存中的数据大小
 
 @return 大小
 */
- (NSInteger)totalCost;

/**
 清空所有缓存
 */
- (void)removeAllObject;

/**
 *  缓存数据
 *
 *  @param object 数据
 *  @param key    key
 */
- (void)setObject:(id<NSObject>)object forKey:(NSString *)key;

/**
 *  获取缓存的数据
 *
 *  @param key key
 *
 *  @return 数据
 */
- (WBCacheModel *)objectForKey:(NSString *)key;

/**
 *  删除缓存数据
 *
 *  @param key key
 */
- (void)removeObjectForKey:(NSString *)key;

@end
