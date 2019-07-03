//
//  GWNetWorking.m
//  gw_test
//
//  Created by gw on 2018/3/23.
//  Copyright © 2018年 gw. All rights reserved.
//

#import "GWNetWorking.h"
#import <objc/runtime.h>
#import "VoiceConverter.h"
@class GWFormNetWorking;
@class GWJsonNetWorking;

//设置超时时间
#define Time_Out_GWSet 10.0f

//是否显示手机状态栏loading标记
#define setNetworkActivityIndicatorVisible(x) [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:x];

#define GWNetWorking_Share [self shareGWNetWorking]
#define GWNetQueueGroup_Share [GWNetQueueGroup shareGWNetQueueGroup]

@interface GWNetQueueGroup : NSObject{
@public
    dispatch_queue_t GW_Async_Queue;
    dispatch_group_t GW_Async_Group;
    dispatch_queue_t GW_Sync_Queue;
    dispatch_group_t GW_Sync_Group;
    dispatch_semaphore_t sema_t;
}

@end

@implementation GWNetQueueGroup

static GWNetQueueGroup *baseGroup = nil;
+ (instancetype)shareGWNetQueueGroup{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        baseGroup = [[super allocWithZone:NULL] init];
    });
    return baseGroup;
}

+(instancetype)allocWithZone:(struct _NSZone *)zone{
    return [GWNetQueueGroup shareGWNetQueueGroup];
}

- (id)copy{
    return [GWNetQueueGroup shareGWNetQueueGroup];
}

- (id)mutableCopy{
    return [GWNetQueueGroup shareGWNetQueueGroup];
}

- (instancetype)init{
    if (self = [super init]) {
        //        自建并行线程
        GW_Async_Queue = dispatch_queue_create("GW_Async_Queue", DISPATCH_QUEUE_CONCURRENT);
        GW_Async_Group = dispatch_group_create();
        //        自建串行线程
        GW_Sync_Queue = dispatch_queue_create("GW_Sync_Queue", NULL);
        GW_Sync_Group = dispatch_group_create();
        sema_t = dispatch_semaphore_create(0);
    }
    return self;
}



@end


const void *GW_ins = @"GW_Instance";
@interface GWNetWorking()
@property (strong, nonatomic) AFHTTPSessionManager *sessionManager;

@property (strong, nonatomic) GWNetQueueGroup *queueGroup;

@property (readwrite,strong, nonatomic) NSMutableArray *taskArray;

@property (weak, nonatomic) NSURLSessionTask *currentTask;
@end

@implementation GWNetWorking

static GWNetWorking *baseNet = nil;

+(instancetype)shareGWNetWorking{
    id instance = objc_getAssociatedObject(self, GW_ins);
    if (!instance){
        instance = [[super allocWithZone:NULL] init];
        objc_setAssociatedObject(self, GW_ins, instance, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return instance;
}
+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    return [self shareGWNetWorking];
}
-(instancetype)copyWithZone:(struct _NSZone *)zone
{
    Class selfClass = [self class];
    return [selfClass shareGWNetWorking] ;
}


- (instancetype)init{
    if (self = [super init]) {
        // 创建全局并行
        
        _taskArray = [[NSMutableArray alloc] init];
        
        _sessionManager = [AFHTTPSessionManager manager];
        
        [self setSessionManagerConfigerIsJson:YES];
        
    }
    return self;
}

//设置afn网络请求方式
- (void)setSessionManagerConfigerIsJson:(BOOL)isJson{
    //        根据后台接受数据形式，如果是表单形式接收，使用AFHTTPRequestSerializer 如果是json数据接收，使用AFJSONRequestSerializer
    if (isJson) {
        //        json形式
        self.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
        self.sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
        //        [self.sessionManager.requestSerializer setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        ////        [self.sessionManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        
    }else{
        //        表单形式
        self.sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
        self.sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        //        [self.sessionManager.requestSerializer setValue:UserInfoManagerModel.gradeId forHTTPHeaderField:@"gradeId"];
        //        [self.sessionManager.requestSerializer setValue:UserInfoManagerModel.token forHTTPHeaderField:@"token"];
    }
    
   
    //        响应服务器的文件格式
    self.sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json",@"text/html", @"text/plain",@"text/javascript",@"charset/UTF-8",nil];
    //是否需要cookies缓存
    //        self.sessionManager.requestSerializer.HTTPShouldHandleCookies = YES;
    /*! 设置相应的缓存策略 */
    //        self.sessionManager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    //        设置请求超时时间
    self.sessionManager.requestSerializer.timeoutInterval = Time_Out_GWSet;
    
#pragma mark - 服务器安全链接ssl（https）
    //        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    
    //        AFSSLPinningModeNone: 代表客户端无条件地信任服务器端返回的证书。
    //        AFSSLPinningModePublicKey: 代表客户端会将服务器端返回的证书与本地保存的证书中，PublicKey的部分进行校验；如果正确，才继续进行。
    //        AFSSLPinningModeCertificate: 代表客户端会将服务器端返回的证书和本地保存的证书中的所有内容，包括PublicKey和证书部分，全部进行校验；如果正确，才继续进行。
    
    
    //        [securityPolicy setAllowInvalidCertificates:NO];//  allowInvalidCertificates 定义了客户端是否信任非法证书。
    
    //        validatesDomainName 是指是否校验在证书中的domain这一个字段。每个证书都会包含一个DomainName, 它可以是一个IP地址，一个域名或者一端带有通配符的域名。如*.google.com, www.google.com 都可以成为这个证书的DomainName。设置validatesDomainName=YES将严格地保证其安全性。
    //        [securityPolicy setValidatesDomainName:YES];
    
    //          请求头格式设置，Content-Type代表发送端（客户端|服务器）发送的实体数据的数据类型，Accept代表发送端（客户端）希望接受的数据类型
    
}

+ (NSMutableDictionary *)getCommonDict{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    return dict;
}

+ (void)GWAsyncQueueNotification:(void(^)(void))block{
    dispatch_group_notify(GWNetQueueGroup_Share->GW_Async_Group, GWNetQueueGroup_Share->GW_Async_Queue, block);
}

+ (void)GWSyncQueueNotification:(void(^)(void))block{
    dispatch_group_notify(GWNetQueueGroup_Share->GW_Sync_Group, GWNetQueueGroup_Share->GW_Sync_Queue, block);
}

//不带进度
+ (void)request:(NSString*)requestUrl
      WithParam:(id)param
     withMethod:(HTTPRequestType_GW)method
        success:(void(^)(id result,NSURLResponse *response))success
        failure:(void(^)(NSError *error))failure{
    
    [self request:requestUrl WithParam:param withMethod:method showView:nil success:success failure:failure blockAction:nil];
}

// 不带进度-不带loading
+ (void)withoutLoadingRequest:(NSString *)requestUrl WithParam:(id)param withMethod:(HTTPRequestType_GW)method success:(void (^)(id, NSURLResponse *))success failure:(void (^)(NSError *))failure{
    [self withoutLoadingRequest:requestUrl WithParam:param withMethod:method uploadFileProgress:nil success:success failure:failure];
}

//不带进度-可显示到指定view
+ (void)request:(NSString *)requestUrl WithParam:(id)param withMethod:(HTTPRequestType_GW)method showView:(UIView *)showView success:(void (^)(id, NSURLResponse *))success failure:(void (^)(NSError *))failure blockAction:(ResultErrorBlock)blockAction{
    [self request:requestUrl WithParam:param withMethod:method showView:showView uploadFileProgress:nil success:success failure:failure blockAction:blockAction];
}

//不带进度-不带loading-可显示到指定view
+ (void)withoutLoadingRequest:(NSString *)requestUrl WithParam:(id)param withMethod:(HTTPRequestType_GW)method showView:(UIView *)showView success:(void (^)(id, NSURLResponse *))success failure:(void (^)(NSError *))failure blockAction:(ResultErrorBlock)blockAction{
    [self withoutLoadingRequest:requestUrl WithParam:param withMethod:method showView:showView uploadFileProgress:nil success:success failure:failure blockAction:blockAction];
}


+ (void)GWAsyncQueueRequest:(NSString*)requestUrl
                  WithParam:(id)param
                 withMethod:(HTTPRequestType_GW)method
                    success:(void(^)(id result,NSURLResponse *response))success
                    failure:(void(^)(NSError *error))failure{
    [self GWAsyncQueueRequest:requestUrl WithParam:param withMethod:method uploadFileProgress:nil success:success failure:failure];
}

+ (void)GWSyncQueueRequest:(NSString*)requestUrl
                 WithParam:(id)param
                withMethod:(HTTPRequestType_GW)method
                   success:(void(^)(id result,NSURLResponse *response))success
                   failure:(void(^)(NSError *error))failure{
    [self GWSyncQueueRequest:requestUrl WithParam:param withMethod:method uploadFileProgress:nil success:success failure:failure];
}

// 带进度条
+ (void)request:(NSString*)requestUrl
      WithParam:(id)param
     withMethod:(HTTPRequestType_GW)method
uploadFileProgress:(void(^)(NSProgress *uploadProgress))uploadFileProgress
        success:(void(^)(id result,NSURLResponse *response))success
        failure:(void(^)(NSError *error))failure{
    
    [self request:requestUrl WithParam:param withMethod:method showView:nil uploadFileProgress:uploadFileProgress success:success failure:failure blockAction:nil];
    
}

//带进度条-不带loading
+ (void)withoutLoadingRequest:(NSString *)requestUrl WithParam:(id)param withMethod:(HTTPRequestType_GW)method uploadFileProgress:(void (^)(NSProgress *))uploadFileProgress success:(void (^)(id, NSURLResponse *))success failure:(void (^)(NSError *))failure{
    [self withoutLoadingRequest:requestUrl WithParam:param withMethod:method showView:nil uploadFileProgress:uploadFileProgress success:success failure:failure blockAction:nil];
}

//带进度条-可显示到指定view
+(void)request:(NSString *)requestUrl WithParam:(id)param withMethod:(HTTPRequestType_GW)method showView:(UIView *)showView uploadFileProgress:(void (^)(NSProgress *))uploadFileProgress success:(void (^)(id, NSURLResponse *))success failure:(void (^)(NSError *))failure blockAction:(ResultErrorBlock)blockAction{
    [self commentRequest:requestUrl WithParam:param withMethod:method showView:showView uploadFileProgress:uploadFileProgress success:success failure:failure blockAction:blockAction showLoading:YES];
}

// 带进度条-不带loading-可显示到指定view
+ (void)withoutLoadingRequest:(NSString *)requestUrl WithParam:(id)param withMethod:(HTTPRequestType_GW)method showView:(UIView *)showView uploadFileProgress:(void (^)(NSProgress *))uploadFileProgress success:(void (^)(id, NSURLResponse *))success failure:(void (^)(NSError *))failure blockAction:(ResultErrorBlock)blockAction{
    [self commentRequest:requestUrl WithParam:param withMethod:method showView:showView uploadFileProgress:uploadFileProgress success:success failure:failure blockAction:blockAction showLoading:NO];
}

#pragma mark - requestComment
+ (void)commentRequest:(NSString *)requestUrl WithParam:(id)param withMethod:(HTTPRequestType_GW)method showView:(UIView *)showView uploadFileProgress:(void (^)(NSProgress *))uploadFileProgress success:(void (^)(id, NSURLResponse *))success failure:(void (^)(NSError *))failure blockAction:(ResultErrorBlock)blockAction showLoading:(BOOL)showLoading{
    NSMutableURLRequest *request = [[GWNetWorking_Share sessionManager].requestSerializer requestWithMethod:[GWNetWorking_Share getStringForRequestType:method] URLString:[[NSURL URLWithString:requestUrl relativeToURL:[GWNetWorking_Share sessionManager].baseURL] absoluteString] parameters:param error:nil];
    [GWNetWorking_Share requestDataTask:request showView:showView  success:success failure:failure uploadFileProgress:uploadFileProgress blockAction:blockAction showLoading:showLoading];
}


+ (void)GWAsyncQueueRequest:(NSString*)requestUrl
                  WithParam:(id)param
                 withMethod:(HTTPRequestType_GW)method
         uploadFileProgress:(void(^)(NSProgress *uploadProgress))uploadFileProgress
                    success:(void(^)(id result,NSURLResponse *response))success
                    failure:(void(^)(NSError *error))failure{
    dispatch_group_enter(GWNetQueueGroup_Share->GW_Async_Group);
    dispatch_group_async(GWNetQueueGroup_Share->GW_Async_Group, GWNetQueueGroup_Share->GW_Async_Queue, ^{
        [self request:requestUrl WithParam:param withMethod:method uploadFileProgress:uploadFileProgress success:^(id result, NSURLResponse *response) {
            if (success) {
                success(result,response);
            }
            dispatch_group_leave(GWNetQueueGroup_Share->GW_Async_Group);
        } failure:^(NSError *error) {
            if (failure) {
                failure(error);
            }
            dispatch_group_leave(GWNetQueueGroup_Share->GW_Async_Group);
        }];
    });
}

+ (void)GWSyncQueueRequest:(NSString*)requestUrl
                 WithParam:(id)param
                withMethod:(HTTPRequestType_GW)method
        uploadFileProgress:(void(^)(NSProgress *uploadProgress))uploadFileProgress
                   success:(void(^)(id result,NSURLResponse *response))success
                   failure:(void(^)(NSError *error))failure{
    
    dispatch_group_async(GWNetQueueGroup_Share->GW_Sync_Group, GWNetQueueGroup_Share->GW_Sync_Queue, ^{
        [self request:requestUrl WithParam:param withMethod:method uploadFileProgress:uploadFileProgress success:^(id result, NSURLResponse *response) {
            if (success) {
                success(result,response);
            }
            dispatch_semaphore_signal(GWNetQueueGroup_Share->sema_t);
        } failure:^(NSError *error) {
            if (failure) {
                failure(error);
            }
            dispatch_semaphore_signal(GWNetQueueGroup_Share->sema_t);
        }];
        dispatch_semaphore_wait(GWNetQueueGroup_Share->sema_t, DISPATCH_TIME_FOREVER);
    });
    
}

+ (void)request:(NSString*)requestUrl
      WithParam:(NSDictionary*)param
     withMethod:(HTTPRequestType_GW)method
constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
uploadFileProgress:(void(^)(NSProgress *uploadProgress))uploadFileProgress
        success:(void (^)(id result,NSURLResponse *response))success
        failure:(void (^)(NSError* error))failure{
    
    
    NSMutableURLRequest *request = [[GWNetWorking_Share sessionManager].requestSerializer multipartFormRequestWithMethod:[GWNetWorking_Share getStringForRequestType:method] URLString:requestUrl parameters:param constructingBodyWithBlock:block error:nil];
    
    [GWNetWorking_Share requestDataTask:request showView:nil  success:success failure:failure uploadFileProgress:uploadFileProgress blockAction:nil showLoading:YES];
}

+ (void)GWAsyncQueueRequest:(NSString*)requestUrl
                  WithParam:(id)param
                 withMethod:(HTTPRequestType_GW)method
  constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
         uploadFileProgress:(void(^)(NSProgress *uploadProgress))uploadFileProgress
                    success:(void(^)(id result,NSURLResponse *response))success
                    failure:(void(^)(NSError *error))failure{
    dispatch_group_enter(GWNetQueueGroup_Share->GW_Async_Group);
    dispatch_group_async(GWNetQueueGroup_Share->GW_Async_Group, GWNetQueueGroup_Share->GW_Async_Queue, ^{
        [self request:requestUrl WithParam:param withMethod:method constructingBodyWithBlock:block uploadFileProgress:uploadFileProgress success:^(id result, NSURLResponse *response) {
            if (success) {
                success(result,response);
            }
            dispatch_group_leave(GWNetQueueGroup_Share->GW_Async_Group);
        } failure:^(NSError *error) {
            if (failure) {
                failure(error);
            }
            dispatch_group_leave(GWNetQueueGroup_Share->GW_Async_Group);
        }];
    });
}

+ (void)GWSyncQueueRequest:(NSString*)requestUrl
                 WithParam:(id)param
                withMethod:(HTTPRequestType_GW)method
 constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
        uploadFileProgress:(void(^)(NSProgress *uploadProgress))uploadFileProgress
                   success:(void(^)(id result,NSURLResponse *response))success
                   failure:(void(^)(NSError *error))failure{
    
    dispatch_group_async(GWNetQueueGroup_Share->GW_Sync_Group, GWNetQueueGroup_Share->GW_Sync_Queue, ^{
        [self request:requestUrl WithParam:param withMethod:method constructingBodyWithBlock:block uploadFileProgress:uploadFileProgress success:^(id result, NSURLResponse *response) {
            if (success) {
                success(result,response);
            }
            dispatch_semaphore_signal(GWNetQueueGroup_Share->sema_t);
        } failure:^(NSError *error) {
            if (failure) {
                failure(error);
            }
            dispatch_semaphore_signal(GWNetQueueGroup_Share->sema_t);
        }];
        dispatch_semaphore_wait(GWNetQueueGroup_Share->sema_t, DISPATCH_TIME_FOREVER);
    });
}

+ (void)request:(NSString*)requestUrl
      WithParam:(NSDictionary*)param
    withExParam:(NSDictionary*)Exparam
     withMethod:(HTTPRequestType_GW)method
uploadFileProgress:(void(^)(NSProgress *uploadProgress))uploadFileProgress
        success:(void (^)(id result,NSURLResponse *response))success
        failure:(void (^)(NSError* error))failure{
    
    setNetworkActivityIndicatorVisible(YES)
    
    NSMutableURLRequest *request = [[GWNetWorking_Share sessionManager].requestSerializer multipartFormRequestWithMethod:[GWNetWorking_Share getStringForRequestType:method] URLString:requestUrl parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        //图片上传
        if (Exparam) {
            for (NSString *key in [Exparam allKeys]) {
                //                设置图片的格式mimeType:@"image/jpeg"，@"image/jpg"
                id obj = [Exparam objectForKey:key];
                NSData *imageData = [self imageCompressToData:obj];
                if (!imageData) {
                    continue;
                }
                [formData appendPartWithFileData:imageData name:key fileName:[NSString stringWithFormat:@"%@.png",key] mimeType:@"image/jpeg"];
            }
        }
        
    } error:nil];
    
    [GWNetWorking_Share requestDataTask:request showView:nil  success:success failure:failure uploadFileProgress:uploadFileProgress blockAction:nil showLoading:YES];
}

+ (void)requestSoundFileRequest:(NSString*)requestUrl
                      WithParam:(NSDictionary *)param
                    withExParam:(NSDictionary*)Exparam
                     withMethod:(HTTPRequestType_GW)method
             uploadFileProgress:(void(^)(NSProgress *uploadProgress))uploadFileProgress
                        success:(void(^)(id result,NSURLResponse *response))success
                        failure:(void(^)(NSError *error))failure{

    setNetworkActivityIndicatorVisible(YES)

    NSMutableURLRequest *request = [[GWNetWorking_Share sessionManager].requestSerializer multipartFormRequestWithMethod:[GWNetWorking_Share getStringForRequestType:method] URLString:requestUrl parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        //上传
        if (Exparam) {
            for (NSString *key in [Exparam allKeys]) {
                id obj = [Exparam objectForKey:key];
                NSData *fileData = nil;
                if ([obj isKindOfClass:[NSString class]]) {
//                    是否需要转换-wav->amr 集成voiceConvert需要将enable bitcode设置成no；
                    NSString *filePath = [self audioWavToAmr:(NSString *)obj];
                    fileData = [NSData dataWithContentsOfFile:filePath];
                }else if ([obj isKindOfClass:[NSData class]]){
                    fileData = (NSData *)obj;
                }

                NSDateFormatter *formatter = [[NSDateFormatter alloc]init];

                formatter.dateFormat = @"yyyyMMddHHmmss";

                NSString *str = [formatter  stringFromDate:[NSDate date]];
                NSString  *fileName = [NSString  stringWithFormat:@"%@.wav",str];

//                设置音频的格式mimeType：@"audio/wav"，@"audio/mp3"
                [formData appendPartWithFileData:[Exparam objectForKey:key] name:key fileName:fileName mimeType:@"audio/wav"];

            }
        }

    } error:nil];

    [GWNetWorking_Share requestDataTask:request showView:nil success:success failure:failure uploadFileProgress:uploadFileProgress blockAction:nil showLoading:NO];

}

+ (void)requestUploadVideoWithURLString:(NSString *)URLString
                               WithParam:(NSDictionary *)param
                              withVideoPath:(NSString *)videoPath
                              withMethod:(HTTPRequestType_GW)method
                     uploadFileProgress:(void(^)(NSProgress *uploadProgress))uploadFileProgress
                                success:(void(^)(id result,NSURLResponse *response))success
                                failure:(void(^)(NSError *error))failure{
    __weak GWNetWorking *netW = GWNetWorking_Share;
//    进行视频转换，由高->中，如果录制时就是中质量，请将转换方法屏蔽；
    [self compressVideo:videoPath finish:^(NSString *path) {
        NSMutableURLRequest *request = [netW.sessionManager.requestSerializer multipartFormRequestWithMethod:[netW getStringForRequestType:method] URLString:URLString parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            [formData appendPartWithFileURL:[NSURL fileURLWithPath:path] name:@"" fileName:path mimeType:@"video/mpeg4" error:nil];

        } error:nil];
        
        [netW requestDataTask:request showView:nil success:success failure:failure uploadFileProgress:uploadFileProgress blockAction:nil showLoading:NO];
    }];

}

+ (void)requestDownloadFileWithURLString:(NSString *)URLString
                               WithParam:(NSDictionary *)param
                              withMethod:(HTTPRequestType_GW)method
                    downloadFileProgress:(void(^)(NSProgress *downloadProgress))downloadFileProgress
                           setupFilePath:(NSURL*(^)(NSURLResponse *response))setupFilePath
               downloadCompletionHandler:(void (^)(NSURL *filePath, NSError *error))downloadCompletionHandler{
    
    NSMutableURLRequest *request = [[GWNetWorking_Share sessionManager].requestSerializer requestWithMethod:[GWNetWorking_Share getStringForRequestType:method] URLString:[[NSURL URLWithString:URLString relativeToURL:[GWNetWorking_Share sessionManager].baseURL] absoluteString] parameters:param error:nil];
    __weak GWNetWorking *netW = GWNetWorking_Share;
    NSURLSessionDownloadTask *dataTask = [[GWNetWorking_Share sessionManager] downloadTaskWithRequest:request progress:nil destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        /**
         *  设置保存目录
         */
        //        NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        //        NSString *path = [cachesPath stringByAppendingPathComponent:response.suggestedFilename];
        //       return [NSURL fileURLWithPath:path]
        return setupFilePath(response);
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        /**
         *  下载完成
         */
        if (error) {
            [netW removeTaskFromArr:error.userInfo[@"NSErrorFailingURLStringKey"]];
        }else{
            [netW removeTaskFromArr:response.URL.absoluteString];
        }
        downloadCompletionHandler(filePath,error);
        
    }];
    
    [[GWNetWorking_Share taskArray] addObject:dataTask];
    [GWNetWorking_Share setCurrentTask:dataTask];
    [dataTask resume];
    
    
}

+ (void)GWAsyncQueueDownloadFileWithURLString:(NSString *)URLString
                                    WithParam:(NSDictionary *)param
                                   withMethod:(HTTPRequestType_GW)method
                         downloadFileProgress:(void(^)(NSProgress *downloadProgress))downloadFileProgress
                                setupFilePath:(NSURL * (^)(NSURL *targetPath, NSURLResponse *response))setupFilePath
                    downloadCompletionHandler:(void (^)(NSURL *filePath, NSError *error))downloadCompletionHandler{
    dispatch_group_enter(GWNetQueueGroup_Share->GW_Async_Group);
    dispatch_group_async(GWNetQueueGroup_Share->GW_Async_Group, GWNetQueueGroup_Share->GW_Async_Queue, ^{
        NSMutableURLRequest *request = [[GWNetWorking_Share sessionManager].requestSerializer requestWithMethod:[GWNetWorking_Share getStringForRequestType:method] URLString:[[NSURL URLWithString:URLString relativeToURL:[GWNetWorking_Share sessionManager].baseURL] absoluteString] parameters:param error:nil];
        
        NSURLSessionDownloadTask *dataTask = [[GWNetWorking_Share sessionManager] downloadTaskWithRequest:request progress:nil destination:setupFilePath completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            
            /**
             *  下载完成
             */
            downloadCompletionHandler(filePath,error);
            dispatch_group_leave(GWNetQueueGroup_Share->GW_Async_Group);
        }];
        [dataTask resume];
    });
}

+ (void)GWSyncQueueDownloadFileWithURLString:(NSString *)URLString
                                   WithParam:(NSDictionary *)param
                                  withMethod:(HTTPRequestType_GW)method
                        downloadFileProgress:(void(^)(NSProgress *downloadProgress))downloadFileProgress
                               setupFilePath:(NSURL * (^)(NSURL *targetPath, NSURLResponse *response))setupFilePath
                   downloadCompletionHandler:(void (^)(NSURL *filePath, NSError *error))downloadCompletionHandler{
    
    
    dispatch_group_async(GWNetQueueGroup_Share->GW_Sync_Group, GWNetQueueGroup_Share->GW_Sync_Queue, ^{
        NSMutableURLRequest *request = [[GWNetWorking_Share sessionManager].requestSerializer requestWithMethod:[GWNetWorking_Share getStringForRequestType:method] URLString:[[NSURL URLWithString:URLString relativeToURL:[GWNetWorking_Share sessionManager].baseURL] absoluteString] parameters:param error:nil];
        
        NSURLSessionDownloadTask *dataTask = [[GWNetWorking_Share sessionManager] downloadTaskWithRequest:request progress:nil destination:setupFilePath completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            
            /**
             *  下载完成
             */
            downloadCompletionHandler(filePath,error);
            dispatch_semaphore_signal(GWNetQueueGroup_Share->sema_t);
            
        }];
        [dataTask resume];
        dispatch_semaphore_wait(GWNetQueueGroup_Share->sema_t, DISPATCH_TIME_FOREVER);
    });
    
    
}

#pragma mark - commonAction
- (void)requestDataTask:(NSMutableURLRequest *)request
               showView:(UIView *)showView
                success:(void(^)(id result,NSURLResponse *response))success
                failure:(void(^)(NSError *error))failure
     uploadFileProgress:(void(^)(NSProgress *uploadProgress))uploadFileProgress
            blockAction:(ResultErrorBlock)blockAction
            showLoading:(BOOL)showLoading{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        setNetworkActivityIndicatorVisible(YES)
    });
    if (showLoading) {
        //        展示loadingview
        if (showView) {
//            [GW_HUD showHUDLoadingWithText:@"" inView:showView];
        }else{
//            [GW_HUD showHUDLoadingWithText:@""];
        }
        
    }
    
    __weak __typeof(&*self)weakSelf = self;
    NSURLSessionDataTask *dataTask = [self.sessionManager dataTaskWithRequest:request uploadProgress:uploadFileProgress downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        setNetworkActivityIndicatorVisible(NO)
        
        if (showLoading) {
            //            laodingView消失
            if (showView) {
                //                [GW_HUD HideHUDFrom:showView animated:NO];
            }else{
                //                [GW_HUD HideHUDAnimated:NO];
            }
            
        }
        
        
        if (error) {
            [weakSelf removeTaskFromArr:error.userInfo[@"NSErrorFailingURLStringKey"]];
            if (failure != nil){
                failure(error);
            }
            if (showView) {
                
                if (error.code == -1009) {
                    //                无网络
                    //                    backGroundV.viewType = DefaultBackgroundViewTypeNoNetWork;
                }else{
                    //                加载错误
                    //                    backGroundV.viewType = DefaultBackgroundViewTypeNetWorkError;
                }
            }
        } else {
            [weakSelf removeTaskFromArr:response.URL.absoluteString];
            if (success != nil){
                id result = responseObject;
                if ([responseObject isKindOfClass:[NSData class]]) {
                    result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:nil];
                    
                }
                
                if (result && [result isKindOfClass:[NSDictionary class]]) {
                    
                    success(result,response);
                }
                
            }
        }
    }];
   
    
    [self.taskArray addObject:dataTask];
    self.currentTask = dataTask;
    [dataTask resume];
    
}


- (NSString *)getStringForRequestType:(HTTPRequestType_GW)type {
    
    NSString *requestTypeString;
    
    switch (type) {
        case POST_GW:
            requestTypeString = @"POST";
            break;
            
        case GET_GW:
            requestTypeString = @"GET";
            break;
            
        case PUT_GW:
            requestTypeString = @"PUT";
            break;
            
        case DELETE_GW:
            requestTypeString = @"DELETE";
            break;
            
        default:
            requestTypeString = @"POST";
            break;
    }
    
    return requestTypeString;
}

- (void)removeTaskFromArr:(NSString *)urlStr{
    if (!urlStr) {
        return;
    }
    @synchronized (self) {
        if (self.taskArray.count) {
            for (NSURLSessionTask *task in self.taskArray) {
                if ([task.currentRequest.URL.absoluteString isEqualToString:urlStr]) {
                    [self.taskArray removeObject:task];
                    break;
                }
            }
        }
    }
}

- (NSURLSessionTask *)getCurrentTast:(NSString *)urlStr{
    @synchronized (self) {
        for (NSURLSessionTask *task in self.taskArray) {
            if ([task.currentRequest.URL.absoluteString isEqualToString:urlStr]) {
                return task;
            }
        }
    }
    return nil;
}

- (void)cancelAllTask{
    @synchronized (self) {
        for (NSURLSessionTask *task in self.taskArray) {
            [task cancel];
        }
    }
}

- (void)cancelCurrentTask{
    if (self.currentTask) {
        [self.currentTask cancel];
    }
}

- (void)cancelNoCurrentAllTask{
    @synchronized (self) {
        for (NSURLSessionTask *task in self.taskArray) {
            if ([task.currentRequest.URL isEqual:_currentTask.currentRequest.URL]) {
                continue;
            }
            [task cancel];
        }
    }
}

///压缩图片
+ (NSData *)imageCompressToData:(id)obj{
    
    UIImage *image = nil;
    NSData *data = nil;
    if ([obj isKindOfClass:[UIImage class]]) {
        image = (UIImage *)obj;
        data=UIImageJPEGRepresentation(image, 1.0);
    }else if ([obj isKindOfClass:[NSData class]]){
        data = (NSData *)obj;
        image = [UIImage imageWithData:data];
    }
    
    if (data.length>300*1024) {
        if (data.length>1024*1024) {//1M以及以上
            data=UIImageJPEGRepresentation(image, 0.1);
        }else if (data.length>512*1024) {//0.5M-1M
            data=UIImageJPEGRepresentation(image, 0.5);
        }else if (data.length>300*1024) {//0.25M-0.5M
            data=UIImageJPEGRepresentation(image, 0.9);
        }
    }
    return data;
}

+ (UIImage *)needCenterImage:(UIImage *)image size:(CGSize )size scale:(CGFloat )scale{
    UIImage *newImage = nil;
    //创建画板
    UIGraphicsBeginImageContext(size);
    
    //写入图片,在中间
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    //得到新的图片
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //释放画板
    UIGraphicsEndImageContext();
    
    //比例压缩
    newImage = [UIImage imageWithData:UIImageJPEGRepresentation(newImage, scale)];
    
    return newImage;
}

//转换wav到amr
+ (NSString *)audioWavToAmr:(NSString *)recordPath{
    // 音频转换
    NSString *amrPath = [[recordPath stringByDeletingPathExtension] stringByAppendingPathExtension:@"amr"];
    //格式转换需要和安卓端商定
    [VoiceConverter ConvertWavToAmr:recordPath amrSavePath:amrPath];
    return amrPath;
}

// compress video 文件压缩-高质量->中质量
+ (NSString *)compressVideo:(NSString *)path finish:(void(^)(NSString *path))finish
{
    NSURL *url = [NSURL fileURLWithPath:path];
    // 获取文件资源
    AVURLAsset *avAsset = [[AVURLAsset alloc] initWithURL:url options:nil];
    // 导出资源属性
    NSArray *presets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    // 是否包含中分辨率，如果是低分辨率AVAssetExportPresetLowQuality则不清晰
    if ([presets containsObject:AVAssetExportPresetMediumQuality]) {
        // 重定义资源属性

        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetMediumQuality];
        // 压缩后的文件路径
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-ddHH:mm:ss"];
        NSString *videoName = [formatter stringFromDate:[NSDate date]];
        NSString *outPutPath = [self videoPathWithFileName:videoName];
        exportSession.outputURL = [NSURL fileURLWithPath:outPutPath];
        exportSession.shouldOptimizeForNetworkUse = YES;// 是否对网络进行优化
        exportSession.outputFileType = AVFileTypeMPEG4; // 转成MP4
        // 导出

        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            if ([exportSession status] == AVAssetExportSessionStatusCompleted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (finish) {
                        finish(outPutPath);
                    }
                });
            }
        }];
        return outPutPath;
    }
    return nil;
}

// video的路径
+ (NSString *)videoPathWithFileName:(NSString *)videoName{
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"video"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirExist = [fileManager fileExistsAtPath:path];
    if (!isDirExist) {
        BOOL isCreatDir = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        if (!isCreatDir) {
            NSLog(@"create folder failed");
            return nil;
        }
    }
    return [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",videoName]];
}

@end


@implementation GWFormNetWorking

- (instancetype)init{
    if (self = [super init]) {
        // 创建全局并行
        
        self.taskArray = [[NSMutableArray alloc] init];
        
        self.sessionManager = [AFHTTPSessionManager manager];
        
        [self setSessionManagerConfigerIsJson:NO];
    }
    return self;
}

@end

@implementation GWJsonNetWorking

- (instancetype)init{
    if (self = [super init]) {
        // 创建全局并行
        
        self.taskArray = [[NSMutableArray alloc] init];
        
        self.sessionManager = [AFHTTPSessionManager manager];
        
        [self setSessionManagerConfigerIsJson:YES];
    }
    return self;
}

@end
