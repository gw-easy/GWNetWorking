//
//  GWNetWorking.h
//  gw_test
//
//  Created by gw on 2018/3/23.
//  Copyright © 2018年 gw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
typedef enum : NSUInteger {
    POST_GW = 0,
    GET_GW,
    PUT_GW,
    DELETE_GW
} HTTPRequestType_GW;

@interface GWNetWorking : NSObject
//任务数组
@property (readonly,strong, nonatomic) NSMutableArray *taskArray;

+ (instancetype)shareGWNetWorking;
/**
 添加公共请求参数
 */
+ (NSMutableDictionary *)getCommonDict;

/**
 //异步线程组任务完成通知
 @param block block
 */
+ (void)GWAsyncQueueNotification:(void(^)(void))block;

/**
 //同步线程组任务完成通知
 @param block block
 */
+ (void)GWSyncQueueNotification:(void(^)(void))block;

/**
 不带进度

 @param taskID 请求url
 @param param 参数
 @param method 方式
 @param success 成功
 @param failure 失败
 */
+ (void)request:(NSString*)taskID
      WithParam:(id)param
     withMethod:(HTTPRequestType_GW)method
        success:(void(^)(id result,NSURLResponse *response))success
        failure:(void(^)(NSError *error))failure;

/**
 异步线程组 -- 不带进度
 
 @param taskID 请求url
 @param param 参数
 @param method 方式
 @param success 成功
 @param failure 失败
 */
+ (void)GWAsyncQueueRequest:(NSString*)taskID
                  WithParam:(id)param
                 withMethod:(HTTPRequestType_GW)method
                    success:(void(^)(id result,NSURLResponse *response))success
                    failure:(void(^)(NSError *error))failure;

/**
 同步线程组 -- 不带进度
 
 @param taskID 请求url
 @param param 参数
 @param method 方式
 @param success 成功
 @param failure 失败
 */
+ (void)GWSyncQueueRequest:(NSString*)taskID
                 WithParam:(id)param
                withMethod:(HTTPRequestType_GW)method
                   success:(void(^)(id result,NSURLResponse *response))success
                   failure:(void(^)(NSError *error))failure;

/**
 带进度条

 @param taskID 请求url
 @param param 参数
 @param method 方式
 @param uploadFileProgress 进度
 @param success 成功
 @param failure 失败
 */
+ (void)request:(NSString*)taskID
      WithParam:(id)param
     withMethod:(HTTPRequestType_GW)method
uploadFileProgress:(void(^)(NSProgress *uploadProgress))uploadFileProgress
        success:(void(^)(id result,NSURLResponse *response))success
        failure:(void(^)(NSError *error))failure;

/**
 异步线程组 -- 带进度条
 
 @param taskID 请求url
 @param param 参数
 @param method 方式
 @param uploadFileProgress 进度
 @param success 成功
 @param failure 失败
 */
+ (void)GWAsyncQueueRequest:(NSString*)taskID
                  WithParam:(id)param
                 withMethod:(HTTPRequestType_GW)method
         uploadFileProgress:(void(^)(NSProgress *uploadProgress))uploadFileProgress
                    success:(void(^)(id result,NSURLResponse *response))success
                    failure:(void(^)(NSError *error))failure;

/**
 同步线程组 -- 带进度条
 
 @param taskID 请求url
 @param param 参数
 @param method 方式
 @param uploadFileProgress 进度
 @param success 成功
 @param failure 失败
 */
+ (void)GWSyncQueueRequest:(NSString*)taskID
                 WithParam:(id)param
                withMethod:(HTTPRequestType_GW)method
        uploadFileProgress:(void(^)(NSProgress *uploadProgress))uploadFileProgress
                   success:(void(^)(id result,NSURLResponse *response))success
                   failure:(void(^)(NSError *error))failure;

/**
 上传
 
 @param taskID 请求url
 @param param 参数
 @param method 方式
 @param block 上传block
 @param uploadFileProgress 进度
 @param success 成功
 @param failure 失败
 */
+ (void)request:(NSString*)taskID
      WithParam:(NSDictionary*)param
     withMethod:(HTTPRequestType_GW)method
constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
uploadFileProgress:(void(^)(NSProgress *uploadProgress))uploadFileProgress
        success:(void (^)(id result,NSURLResponse *response))success
        failure:(void (^)(NSError* error))failure;

/**
 异步线程组 -- 上传
 
 @param taskID 请求url
 @param param 参数
 @param method 方式
 @param block 上传block
 @param uploadFileProgress 进度
 @param success 成功
 @param failure 失败
 */
+ (void)GWAsyncQueueRequest:(NSString*)taskID
                  WithParam:(id)param
                 withMethod:(HTTPRequestType_GW)method
  constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
         uploadFileProgress:(void(^)(NSProgress *uploadProgress))uploadFileProgress
                    success:(void(^)(id result,NSURLResponse *response))success
                    failure:(void(^)(NSError *error))failure;

/**
 同步线程组 -- 上传
 
 @param taskID 请求url
 @param param 参数
 @param method 方式
 @param block 上传block
 @param uploadFileProgress 进度
 @param success 成功
 @param failure 失败
 */
+ (void)GWSyncQueueRequest:(NSString*)taskID
                 WithParam:(id)param
                withMethod:(HTTPRequestType_GW)method
 constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
        uploadFileProgress:(void(^)(NSProgress *uploadProgress))uploadFileProgress
                   success:(void(^)(id result,NSURLResponse *response))success
                   failure:(void(^)(NSError *error))failure;

/**
 图片上传

 @param taskID 请求url
 @param param 参数
 @param Exparam 图片参数
 @param method 方式
 @param uploadFileProgress 进度
 @param success 成功
 @param failure 失败
 */
+ (void)request:(NSString*)taskID
      WithParam:(NSDictionary*)param
    withExParam:(NSDictionary*)Exparam
     withMethod:(HTTPRequestType_GW)method
uploadFileProgress:(void(^)(NSProgress *uploadProgress))uploadFileProgress
        success:(void (^)(id result,NSURLResponse *response))success
        failure:(void (^)(NSError* error))failure;



/**
 上传音频文件

 @param taskID 请求url
 @param param 参数
 @param Exparam 音频参数
 @param method 方式
 @param uploadFileProgress 进度
 @param success 成功
 @param failure 失败
 */
+ (void)requestSoundFileRequest:(NSString*)taskID
                      WithParam:(NSDictionary *)param
                    withExParam:(NSDictionary*)Exparam
                     withMethod:(HTTPRequestType_GW)method
             uploadFileProgress:(void(^)(NSProgress *uploadProgress))uploadFileProgress
                        success:(void(^)(id result,NSURLResponse *response))success
                        failure:(void(^)(NSError *error))failure;



/**
 上传视频文件

 @param URLString 请求url
 @param param 参数
 @param videoPath 视频路径
 @param method 请求方式
 @param uploadFileProgress 进度
 @param success 成功
 @param failure 失败
 */
+ (void)requestUploadVideoWithURLString:(NSString *)URLString
                              WithParam:(NSDictionary *)param
                          withVideoPath:(NSString *)videoPath
                             withMethod:(HTTPRequestType_GW)method
                     uploadFileProgress:(void(^)(NSProgress *uploadProgress))uploadFileProgress
                                success:(void(^)(id result,NSURLResponse *response))success
                                failure:(void(^)(NSError *error))failure;
/**
 下载文件

 @param URLString 请求url
 @param param 参数
 @param method 方式
 @param downloadFileProgress 下载进度
 @param setupFilePath 保存路径
 @param downloadCompletionHandler 完成
 */
+ (void)requestDownloadFileWithURLString:(NSString *)URLString
                               WithParam:(NSDictionary *)param
                              withMethod:(HTTPRequestType_GW)method
                    downloadFileProgress:(void(^)(NSProgress *downloadProgress))downloadFileProgress
                           setupFilePath:(NSURL*(^)(NSURLResponse *response))setupFilePath
               downloadCompletionHandler:(void (^)(NSURL *filePath, NSError *error))downloadCompletionHandler;

/**
 异步线程组 -- 下载文件
 
 @param URLString 请求url
 @param param 参数
 @param method 方式
 @param downloadFileProgress 下载进度
 @param setupFilePath 保存路径
 @param downloadCompletionHandler 完成
 */
+ (void)GWAsyncQueueDownloadFileWithURLString:(NSString *)URLString
                                    WithParam:(NSDictionary *)param
                                   withMethod:(HTTPRequestType_GW)method
                         downloadFileProgress:(void(^)(NSProgress *downloadProgress))downloadFileProgress
                                setupFilePath:(NSURL * (^)(NSURL *targetPath, NSURLResponse *response))setupFilePath
                    downloadCompletionHandler:(void (^)(NSURL *filePath, NSError *error))downloadCompletionHandler;

/**
 同步线程组 -- 下载文件
 
 @param URLString 请求url
 @param param 参数
 @param method 方式
 @param downloadFileProgress 下载进度
 @param setupFilePath 保存路径
 @param downloadCompletionHandler 完成
 */
+ (void)GWSyncQueueDownloadFileWithURLString:(NSString *)URLString
                                   WithParam:(NSDictionary *)param
                                  withMethod:(HTTPRequestType_GW)method
                        downloadFileProgress:(void(^)(NSProgress *downloadProgress))downloadFileProgress
                               setupFilePath:(NSURL * (^)(NSURL *targetPath, NSURLResponse *response))setupFilePath
                   downloadCompletionHandler:(void (^)(NSURL *filePath, NSError *error))downloadCompletionHandler;

//取消所有任务
- (void)cancelAllTask;
//取消当前任务
- (void)cancelCurrentTask;
//取消除当前任务外，所有的任务
- (void)cancelNoCurrentAllTask;

///////////////////////////////////////////////////////////



@end

#pragma mark - 表单请求
@interface GWFormNetWorking : GWNetWorking

@end

#pragma mark - json请求
@interface GWJsonNetWorking : GWNetWorking

@end
