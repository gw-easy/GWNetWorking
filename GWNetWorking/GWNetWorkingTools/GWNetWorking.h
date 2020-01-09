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

typedef enum : NSUInteger {
    //    暂无数据
    WithoutData_GW = 0,
    //    无网络
    WithoutNet_GW,
    //    请求失败
    RequestError_GW
} HTTPResultError_GW;

typedef void(^ResultErrorBlock)(HTTPResultError_GW result);
@interface GWJsonNetWorking : NSObject

+ (instancetype)shareGWNetWorking;
/**
 添加公共请求参数
 */
+ (NSMutableDictionary *)getCommonDict;

/// 异步线程组任务完成通知 -（调用前提-至少有一次带标识的网络请求，否则接收不到）
/// @param ID 线程标识 - 需要和请求标识保持一致
/// @param block block description
+ (void)GWAsyncQueueNotificationID:(NSString *)ID block:(void(^)(void))block;


/// 同步线程组任务完成通知 - 需要和请求标识保持一致 -（调用前提-至少有一次请求，否则接收不到）
/// @param ID 线程标识 - 需要和请求标识保持一致
/// @param block block description
+ (void)GWSyncQueueNotificationID:(NSString *)ID block:(void(^)(void))block;

/**
 不带进度
 
 @param requestUrl 请求url
 @param param 参数
 @param method 方式
 @param success 成功
 @param failure 失败
 */
+ (void)request:(NSString*)requestUrl
      WithParam:(id)param
     withMethod:(HTTPRequestType_GW)method
        success:(void(^)(id result,NSURLResponse *response))success
        failure:(void(^)(NSError *error))failure;

/**
 不带进度-不带loading
 
 @param requestUrl 请求url
 @param param 参数
 @param method 方式
 @param success 成功
 @param failure 失败
 */
+ (void)withoutLoadingRequest:(NSString*)requestUrl
                    WithParam:(id)param
                   withMethod:(HTTPRequestType_GW)method
                      success:(void(^)(id result,NSURLResponse *response))success
                      failure:(void(^)(NSError *error))failure;

/**
 不带进度-可显示到指定view
 
 @param requestUrl 请求url
 @param param 参数
 @param method 方式
 @param success 成功
 @param failure 失败
 @param blockAction 备用回调 如网络发生错误需要点击刷新数据的要求
 */
+ (void)request:(NSString*)requestUrl
      WithParam:(id)param
     withMethod:(HTTPRequestType_GW)method
       showView:(UIView *)showView
        success:(void(^)(id result,NSURLResponse *response))success
        failure:(void(^)(NSError *error))failure
    blockAction:(ResultErrorBlock)blockAction;

/**
 不带进度-不带loading-可显示到指定view
 
 @param requestUrl 请求url
 @param param 参数
 @param method 方式
 @param success 成功
 @param failure 失败
 @param blockAction 备用回调 如网络发生错误需要点击刷新数据的要求
 */
+ (void)withoutLoadingRequest:(NSString*)requestUrl
                    WithParam:(id)param
                   withMethod:(HTTPRequestType_GW)method
                     showView:(UIView *)showView
                      success:(void(^)(id result,NSURLResponse *response))success
                      failure:(void(^)(NSError *error))failure
                  blockAction:(ResultErrorBlock)blockAction;


/// 异步线程组 -- 不带进度
/// @param requestUrl 异步线程组 -- 不带进度
/// @param param 参数
/// @param method 方式
/// @param queueID 线程标识
/// @param success success
/// @param failure failure
+ (void)GWAsyncQueueRequest:(NSString*)requestUrl
                  WithParam:(id)param
                 withMethod:(HTTPRequestType_GW)method
                    queueID:(NSString *)queueID
                    success:(void(^)(id result,NSURLResponse *response))success
                    failure:(void(^)(NSError *error))failure;

/**
 同步线程组 -- 不带进度
 
 @param requestUrl 请求url
 @param param 参数
 @param method 方式
 @param queueID 线程标识
 @param success 成功
 @param failure 失败
 */
+ (void)GWSyncQueueRequest:(NSString*)requestUrl
                 WithParam:(id)param
                withMethod:(HTTPRequestType_GW)method
                   queueID:(NSString *)queueID
                   success:(void(^)(id result,NSURLResponse *response))success
                   failure:(void(^)(NSError *error))failure;

/**
 带进度条
 
 @param requestUrl 请求url
 @param param 参数
 @param method 方式
 @param uploadFileProgress 进度
 @param success 成功
 @param failure 失败
 */
+ (void)request:(NSString*)requestUrl
      WithParam:(id)param
     withMethod:(HTTPRequestType_GW)method
uploadFileProgress:(void(^)(NSProgress *uploadProgress))uploadFileProgress
        success:(void(^)(id result,NSURLResponse *response))success
        failure:(void(^)(NSError *error))failure;

/**
 带进度条-不带loading
 
 @param requestUrl 请求url
 @param param 参数
 @param method 方式
 @param uploadFileProgress 进度
 @param success 成功
 @param failure 失败
 */
+ (void)withoutLoadingRequest:(NSString*)requestUrl
                    WithParam:(id)param
                   withMethod:(HTTPRequestType_GW)method
           uploadFileProgress:(void(^)(NSProgress *uploadProgress))uploadFileProgress
                      success:(void(^)(id result,NSURLResponse *response))success
                      failure:(void(^)(NSError *error))failure;

/**
 带进度条-可显示到指定view
 
 @param requestUrl 请求requesturl
 @param param 参数
 @param method 方式
 @param uploadFileProgress 进度
 @param success 成功
 @param failure 失败
 @param blockAction 备用回调 如网络发生错误需要点击刷新数据的要求
 */
+ (void)request:(NSString*)requestUrl
      WithParam:(id)param
     withMethod:(HTTPRequestType_GW)method
       showView:(UIView *)showView
uploadFileProgress:(void(^)(NSProgress *uploadProgress))uploadFileProgress
        success:(void(^)(id result,NSURLResponse *response))success
        failure:(void(^)(NSError *error))failure
    blockAction:(ResultErrorBlock)blockAction;

/**
 带进度条-不带loading-可显示到指定view
 
 @param requestUrl 请求requesturl
 @param param 参数
 @param method 方式
 @param uploadFileProgress 进度
 @param success 成功
 @param failure 失败
 @param blockAction 备用回调 如网络发生错误需要点击刷新数据的要求
 */
+ (void)withoutLoadingRequest:(NSString*)requestUrl
                    WithParam:(id)param
                   withMethod:(HTTPRequestType_GW)method
                     showView:(UIView *)showView
           uploadFileProgress:(void(^)(NSProgress *uploadProgress))uploadFileProgress
                      success:(void(^)(id result,NSURLResponse *response))success
                      failure:(void(^)(NSError *error))failure
                  blockAction:(ResultErrorBlock)blockAction;


///  异步线程组 -- 带进度条
/// @param requestUrl 请求url
/// @param param 参数
/// @param method 方式
/// @param queueID 线程标识
/// @param uploadFileProgress 进度
/// @param success success description
/// @param failure failure description
+ (void)GWAsyncQueueRequest:(NSString*)requestUrl
         WithParam:(id)param
        withMethod:(HTTPRequestType_GW)method
           queueID:(NSString *)queueID
uploadFileProgress:(void(^)(NSProgress *uploadProgress))uploadFileProgress
           success:(void(^)(id result,NSURLResponse *response))success
           failure:(void(^)(NSError *error))failure;

/**
 同步线程组 -- 带进度条
 
 @param requestUrl 请求url
 @param param 参数
 @param method 方式
 @param queueID 线程标识
 @param uploadFileProgress 进度
 @param success 成功
 @param failure 失败
 */
+ (void)GWSyncQueueRequest:(NSString*)requestUrl
                 WithParam:(id)param
                withMethod:(HTTPRequestType_GW)method
                   queueID:(NSString *)queueID
        uploadFileProgress:(void(^)(NSProgress *uploadProgress))uploadFileProgress
                   success:(void(^)(id result,NSURLResponse *response))success
                   failure:(void(^)(NSError *error))failure;

/**
 上传
 
 @param requestUrl 请求url
 @param param 参数
 @param method 方式
 @param block 上传block
 @param uploadFileProgress 进度
 @param success 成功
 @param failure 失败
 */
+ (void)request:(NSString*)requestUrl
      WithParam:(NSDictionary*)param
     withMethod:(HTTPRequestType_GW)method
constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
uploadFileProgress:(void(^)(NSProgress *uploadProgress))uploadFileProgress
        success:(void (^)(id result,NSURLResponse *response))success
        failure:(void (^)(NSError* error))failure;

/**
 异步线程组 -- 上传
 
 @param requestUrl 请求url
 @param param 参数
 @param method 方式
 @param queueID 线程标识
 @param block 上传block
 @param uploadFileProgress 进度
 @param success 成功
 @param failure 失败
 */
+ (void)GWAsyncQueueRequest:(NSString*)requestUrl
                  WithParam:(id)param
                 withMethod:(HTTPRequestType_GW)method
                    queueID:(NSString *)queueID
  constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
         uploadFileProgress:(void(^)(NSProgress *uploadProgress))uploadFileProgress
                    success:(void(^)(id result,NSURLResponse *response))success
                    failure:(void(^)(NSError *error))failure;

/**
 同步线程组 -- 上传
 
 @param requestUrl 请求url
 @param param 参数
 @param method 方式
 @param queueID 线程标识
 @param block 上传block
 @param uploadFileProgress 进度
 @param success 成功
 @param failure 失败
 */
+ (void)GWSyncQueueRequest:(NSString*)requestUrl
                 WithParam:(id)param
                withMethod:(HTTPRequestType_GW)method
                   queueID:(NSString *)queueID
 constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
        uploadFileProgress:(void(^)(NSProgress *uploadProgress))uploadFileProgress
                   success:(void(^)(id result,NSURLResponse *response))success
                   failure:(void(^)(NSError *error))failure;

/**
 图片上传
 
 @param requestUrl 请求url
 @param param 参数
 @param Exparam 图片参数
 @param method 方式
 @param uploadFileProgress 进度
 @param success 成功
 @param failure 失败
 */
+ (void)request:(NSString*)requestUrl
      WithParam:(NSDictionary*)param
    withExParam:(NSDictionary*)Exparam
     withMethod:(HTTPRequestType_GW)method
uploadFileProgress:(void(^)(NSProgress *uploadProgress))uploadFileProgress
        success:(void (^)(id result,NSURLResponse *response))success
        failure:(void (^)(NSError* error))failure;



/**
 上传音频文件
 
 @param requestUrl 请求url
 @param param 参数
 @param Exparam 音频参数
 @param method 方式
 @param uploadFileProgress 进度
 @param success 成功
 @param failure 失败
 */
+ (void)requestSoundFileRequest:(NSString*)requestUrl
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
 @param queueID 线程标识
 @param downloadFileProgress 下载进度
 @param setupFilePath 保存路径
 @param downloadCompletionHandler 完成
 */
+ (void)GWAsyncQueueDownloadFileWithURLString:(NSString *)URLString
                                    WithParam:(NSDictionary *)param
                                   withMethod:(HTTPRequestType_GW)method
                                      queueID:(NSString *)queueID
                         downloadFileProgress:(void(^)(NSProgress *downloadProgress))downloadFileProgress
                                setupFilePath:(NSURL * (^)(NSURL *targetPath, NSURLResponse *response))setupFilePath
                    downloadCompletionHandler:(void (^)(NSURL *filePath, NSError *error))downloadCompletionHandler;

/**
 同步线程组 -- 下载文件
 
 @param URLString 请求url
 @param param 参数
 @param method 方式
 @param queueID 线程标识
 @param downloadFileProgress 下载进度
 @param setupFilePath 保存路径
 @param downloadCompletionHandler 完成
 */
+ (void)GWSyncQueueDownloadFileWithURLString:(NSString *)URLString
                                   WithParam:(NSDictionary *)param
                                  withMethod:(HTTPRequestType_GW)method
                                     queueID:(NSString *)queueID
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
@interface GWFormNetWorking : GWJsonNetWorking

@end

