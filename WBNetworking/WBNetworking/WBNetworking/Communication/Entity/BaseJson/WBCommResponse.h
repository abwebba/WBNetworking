//
//  WBCommResponse.h
//  WBNetworking
//
//  Created by zwb on 16/5/12.
//  Copyright © 2016年 zwb. All rights reserved.
//

#import "WBBaseJSONModel.h"
#import "WBCacheModel.h"

@interface WBCommResponse : WBBaseJSONModel

/**
 *  状态码
 */
@property (assign, nonatomic) NSInteger status;

/**
 *  信息
 */
@property (strong, nonatomic) NSString *message;

/**
 *  实体
 */
@property (strong, nonatomic) id<NSObject> data;

/**
 *  请求编号
 */
@property (nonatomic, assign) NSInteger requestId;

/**
 *  缓存创建的时间
 */
@property (nonatomic, strong) NSDate *cacheTime;

- (id)initWithCacheModel:(WBCacheModel *)cache;
@end
