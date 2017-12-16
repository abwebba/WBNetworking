//
//  WBCacheModel.h
//  WBNetworking
//
//  Created by zwb on 16/6/23.
//  Copyright © 2016年 zwb. All rights reserved.
//

#import "WBBaseJSONModel.h"

@interface WBCacheModel : WBBaseJSONModel

/**
 *  缓存创建的时间
 */
@property (nonatomic, strong) NSDate *cacheTime;

/**
 *  缓存数据
 */
@property (nonatomic, strong) id<NSObject> data;

- (id)initWithData:(id<NSObject>)data;
@end
