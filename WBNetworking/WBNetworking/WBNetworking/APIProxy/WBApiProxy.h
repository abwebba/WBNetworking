//
//  WBApiProxy.h
//  WBNetworking
//
//  Created by zwb on 16/6/2.
//  Copyright © 2016年 zwb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WBURLResponse.h"

typedef void(^CompletedCallBack)(WBURLResponse *response);

@interface WBApiProxy : NSObject

/**
 *  网络请求单例
 *
 *  @return 单例
 */
+ (instancetype)sharedApiProxy;

/**
 *  GET请求
 *
 *  @param params     参数
 *  @param host       主机
 *  @param methodName 方法名
 *  @param success    成功回调
 *  @param fail       失败回调
 *
 *  @return 请求编号
 */
- (NSInteger)callGETWithParams:(NSDictionary *)params
                          host:(NSString *)host
                    methodName:(NSString *)methodName
                       success:(CompletedCallBack)success
                          fail:(CompletedCallBack)fail;

/**
 *  POST请求
 *
 *  @param params     参数
 *  @param host       主机
 *  @param methodName 方法名
 *  @param success    成功回调
 *  @param fail       失败回调
 *
 *  @return 请求编号
 */
- (NSInteger)callPOSTWithParams:(NSDictionary *)params
                           host:(NSString *)host
                     methodName:(NSString *)methodName
                        success:(CompletedCallBack)success
                           fail:(CompletedCallBack)fail;

/**
 *  POST上传文件
 *
 *  @param params     参数
 *  @param host       主机
 *  @param methodName 方法名
 *  @param files      文件数据集
 *  @param success    成功回调
 *  @param fail       失败回调
 *
 *  @return 请求编号
 */
- (NSInteger)callMultipartPOSTWithParams:(NSDictionary *)params
                                    host:(NSString *)host
                              methodName:(NSString *)methodName
                                   files:(NSArray<NSData *> *)files
                                 success:(CompletedCallBack)success
                                    fail:(CompletedCallBack)fail;

/**
 *  下载文件
 *
 *  @param remoteURL     地址
 *  @param progressBlock 进度回调
 *  @param completion    结果回调
 *
 *  @return 请求编号
 */
- (NSInteger)downloadFileFrom:(NSString *)remoteURL
                     progress:(void (^)(NSProgress *progress))progressBlock
                   completion:(void (^)(NSURL *filePath, NSError *error))completion;

/**
 *  取消请求
 *
 *  @param requestID 请求编号
 */
- (void)cancelRequestWithRequestID:(NSNumber *)requestID;

/**
 *  批量取消请求
 *
 *  @param requestIDList 请求编号集合
 */
- (void)cancelRequestWithRequestIDList:(NSArray *)requestIDList;

@end
