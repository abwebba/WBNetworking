//
//  WBApiProxy.m
//  WBNetworking
//
//  Created by zwb on 16/6/2.
//  Copyright © 2016年 zwb. All rights reserved.
//

#import "WBApiProxy.h"
#import <AFNetworking/AFNetworking.h>
#import "WBRequestGenerator.h"

@interface WBApiProxy ()

/**
 *  请求任务列表
 */
@property (strong, nonatomic) NSMutableDictionary *dispatchTable;

/**
 *  Session管理器
 */
@property (strong, nonatomic) AFHTTPSessionManager *sessionManager;

@end

@implementation WBApiProxy

+ (instancetype)sharedApiProxy {
    static id _sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[self alloc] init];
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    });
    return _sharedInstance;
}

#pragma mark - public methods
- (NSInteger)callGETWithParams:(NSDictionary *)params
                          host:(NSString *)host
                    methodName:(NSString *)methodName
                       success:(CompletedCallBack)success
                          fail:(CompletedCallBack)fail {
    
    NSURLRequest *request = [[WBRequestGenerator sharedRequestGenerator] generateGETRequestWithRequestParams:params host:host methodName:methodName];
    NSNumber *requestId = [self callApiWithRequest:request success:success fail:fail];
    return [requestId integerValue];
}

- (NSInteger)callPOSTWithParams:(NSDictionary *)params
                           host:(NSString *)host
                     methodName:(NSString *)methodName
                        success:(CompletedCallBack)success
                           fail:(CompletedCallBack)fail {
    
    NSURLRequest *request = [[WBRequestGenerator sharedRequestGenerator] generatePOSTRequestWithRequestParams:params host:host methodName:methodName];
    NSNumber *requestId = [self callApiWithRequest:request success:success fail:fail];
    return [requestId integerValue];
}

- (NSInteger)callMultipartPOSTWithParams:(NSDictionary *)params
                                    host:(NSString *)host
                              methodName:(NSString *)methodName
                                   files:(NSArray<NSData *> *)files
                                 success:(CompletedCallBack)success
                                    fail:(CompletedCallBack)fail {
    
    NSURLRequest *request = [[WBRequestGenerator sharedRequestGenerator]generatePOSTRequestWithRequestParams:params files:files host:host methodName:methodName];
    NSNumber *requestId = [self callApiWithUploadRequest:request success:success fail:fail];
    return [requestId integerValue];
}

- (NSInteger)downloadFileFrom:(NSString *)remoteURL
                     progress:(void (^)(NSProgress *progress))progressBlock
                   completion:(void (^)(NSURL *filePath, NSError *error))completion {
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:remoteURL]];
    NSNumber *requestId = [self callApiWithDownloadRequest:request progress:progressBlock completion:completion];
    return [requestId integerValue];
}

- (void)cancelRequestWithRequestID:(NSNumber *)requestID {
    NSURLSessionTask *requestOperation = self.dispatchTable[requestID];
    [requestOperation cancel];
    [self.dispatchTable removeObjectForKey:requestID];
}

- (void)cancelRequestWithRequestIDList:(NSArray *)requestIDList {
    for (NSNumber *requestId in requestIDList) {
        [self cancelRequestWithRequestID:requestId];
    }
}

#pragma mark - getters and setters
- (NSMutableDictionary *)dispatchTable {
    if (_dispatchTable == nil) {
        _dispatchTable = [[NSMutableDictionary alloc] init];
    }
    return _dispatchTable;
}

- (AFHTTPSessionManager *)sessionManager {
    if (_sessionManager == nil) {
        _sessionManager = [AFHTTPSessionManager manager];
        _sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        _sessionManager.securityPolicy.allowInvalidCertificates = YES;
        _sessionManager.securityPolicy.validatesDomainName = NO;
    }
   
    return _sessionManager;
}

#pragma mark - private methods
- (NSNumber *)callApiWithRequest:(NSURLRequest *)request
                         success:(CompletedCallBack)success
                            fail:(CompletedCallBack)fail {
    
    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        NSNumber *requestID = @([dataTask taskIdentifier]);
        [self.dispatchTable removeObjectForKey:requestID];
      
        if ([responseObject isKindOfClass:[NSData class]]) {
            NSData *responseData = responseObject;
            NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            
            [self logDebugInfoWithResponse:(NSHTTPURLResponse *)response resposeString:responseString request:request error:error];
            if (error) {
                WBURLResponse *wbResponse = [[WBURLResponse alloc] initWithResponseString:responseString requestId:requestID request:request responseData:responseData error:error];
                fail?fail(wbResponse):nil;
                
            } else {
                WBURLResponse *wbResponse = [[WBURLResponse alloc] initWithResponseString:responseString requestId:requestID request:request responseData:responseData status:WBURLResponseStatusSuccess];
                success?success(wbResponse):nil;
            }
            
        } else {
            NSData *responseData = responseObject;
            NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            [self logDebugInfoWithResponse:(NSHTTPURLResponse *)response resposeString:responseString request:request error:error];
            WBURLResponse *response = [[WBURLResponse alloc] initErrorWithRequest:request requestId:requestID];
            fail?fail(response):nil;
        }
        
    }];
    
    NSNumber *requestId = @([dataTask taskIdentifier]);
    
    self.dispatchTable[requestId] = dataTask;
    [dataTask resume];
    
    return requestId;
}

- (NSNumber *)callApiWithUploadRequest:(NSURLRequest *)request
                               success:(CompletedCallBack)success
                                  fail:(CompletedCallBack)fail {
    
    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [self.sessionManager uploadTaskWithStreamedRequest:request progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        NSNumber *requestID = @([dataTask taskIdentifier]);
        [self.dispatchTable removeObjectForKey:requestID];
        if ([responseObject isKindOfClass:[NSData class]]) {
            NSData *responseData = responseObject;
            NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];

            if (error) {
                WBURLResponse *wbResponse = [[WBURLResponse alloc] initWithResponseString:responseString requestId:requestID request:request responseData:responseData error:error];
                fail ? fail(wbResponse) : nil;
                
            } else {
                WBURLResponse *wbResponse = [[WBURLResponse alloc] initWithResponseString:responseString requestId:requestID request:request responseData:responseData status:WBURLResponseStatusSuccess];
                success ? success(wbResponse) : nil;
            }
            
        } else {
            WBURLResponse *response = [[WBURLResponse alloc] initErrorWithRequest:request requestId:requestID];
            fail?fail(response):nil;
        }
        
    }];
    
    NSNumber *requestId = @([dataTask taskIdentifier]);
    
    self.dispatchTable[requestId] = dataTask;
    [dataTask resume];
    
    return requestId;
}

- (NSNumber *)callApiWithDownloadRequest:(NSURLRequest *)request
                                progress:(void (^)(NSProgress *progress))progressBlock
                              completion:(void (^)(NSURL *filePath, NSError *error))completion {
    
    __block NSURLSessionDownloadTask *dataTask = nil;
    dataTask = [self.sessionManager downloadTaskWithRequest:request progress:progressBlock destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        // 文件保存的路径
        NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        NSString *path = [cachesPath stringByAppendingPathComponent:response.suggestedFilename];
        return [NSURL fileURLWithPath:path];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        NSNumber *requestID = @([dataTask taskIdentifier]);
        [self.dispatchTable removeObjectForKey:requestID];
        if (completion) {
            completion(filePath, error);
        }
    }];
    
    NSNumber *requestId = @([dataTask taskIdentifier]);
    
    self.dispatchTable[requestId] = dataTask;
    [dataTask resume];
    
    return requestId;
}

#pragma mark - Log
- (void)logDebugInfoWithResponse:(NSHTTPURLResponse *)response resposeString:(NSString *)responseString request:(NSURLRequest *)request error:(NSError *)error {
#ifdef DEBUG
    BOOL shouldLogError = error ? YES : NO;
    
    NSMutableString *logString = [NSMutableString stringWithString:@"\n\n==============================================================\n=                        API Response                        =\n==============================================================\n\n"];
    
    [logString appendFormat:@"Status:\t%ld\t(%@)\n\n", (long)response.statusCode, [NSHTTPURLResponse localizedStringForStatusCode:response.statusCode]];
    [logString appendFormat:@"Content:\n\t%@\n", responseString];
    if (shouldLogError) {
        [logString appendFormat:@"Error Domain:\t\t\t\t\t\t\t%@\n", error.domain];
        [logString appendFormat:@"Error Domain Code:\t\t\t\t\t\t%ld\n", (long)error.code];
        [logString appendFormat:@"Error Localized Description:\t\t\t%@\n", error.localizedDescription];
        [logString appendFormat:@"Error Localized Failure Reason:\t\t\t%@\n", error.localizedFailureReason];
        [logString appendFormat:@"Error Localized Recovery Suggestion:\t%@\n\n", error.localizedRecoverySuggestion];
    }
    
    [logString appendString:@"\n---------------  Related Request Content  --------------\n"];
    
    [logString appendFormat:@"\nHTTP URL:\n\t%@", request.URL];
    //[logString appendFormat:@"\n\nHTTP Header:\n%@", request.allHTTPHeaderFields ? request.allHTTPHeaderFields : @"\t\t\t\t\tN/A"];
    //[logString appendFormat:@"\n\nHTTP Body:\n\t%@", [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding]];
    
    [logString appendFormat:@"\n\nGET Text:\n\t%@?%@", request.URL, [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding]];
    
    [logString appendFormat:@"\n\n==============================================================\n=                        Response End                        =\n==============================================================\n\n"];
    
   // if ([response.URL.absoluteString rangeOfString:@"doraemon"].length || [response.URL.absoluteString rangeOfString:@"kds"].length) {
        NSLog(@"%@", logString);
  //  }
   // [[ALLogView sharedLogView] setLog:logString];
    
#endif
}
@end
