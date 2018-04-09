//
//  GWNetWorking.m
//  gw_test
//
//  Created by gw on 2018/3/23.
//  Copyright © 2018年 gw. All rights reserved.
//

#import "GWNetWorking.h"
#import "AFNetworking.h"

//设置超时时间
#define Time_Out_GWSet 60.0f

//是否显示手机状态栏loading标记
#define setNetworkActivityIndicatorVisible(x) [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:x];

#define GWNetWorking_Share [GWNetWorking shareGWNetWorking]

@interface GWNetWorking()
@property (strong, nonatomic) AFHTTPSessionManager *sessionManager;

@property (readwrite,strong, nonatomic) NSMutableArray *taskArray;

@property (strong, nonatomic) NSURLSessionTask *currentTask;
@end

@implementation GWNetWorking

static GWNetWorking *baseNet = nil;
+ (instancetype)shareGWNetWorking{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
//        [[self alloc] init] 与allocWithZone造成死锁 需要用父类的allocWithZone初始化
        baseNet = [[super allocWithZone:NULL] init];
    });
    return baseNet;
}

+(instancetype)allocWithZone:(struct _NSZone *)zone{
    return [GWNetWorking shareGWNetWorking];
}

- (id)copy{
    return [GWNetWorking shareGWNetWorking];
}

- (id)mutableCopy{
    return [GWNetWorking shareGWNetWorking];
}


- (instancetype)init{
    if (self = [super init]) {
        _taskArray = [[NSMutableArray alloc] init];
        
        _sessionManager = [AFHTTPSessionManager manager];
        
        _sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        //        响应服务器的文件格式
        _sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json",@"text/html", @"text/plain",@"text/javascript",nil];
        //是否需要cookies缓存
//        _sessionManager.requestSerializer.HTTPShouldHandleCookies = YES;
//        设置请求超时时间
        _sessionManager.requestSerializer.timeoutInterval = Time_Out_GWSet;
        
#pragma mark - 服务器安全链接ssl（https）
//        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
        
//        AFSSLPinningModeNone: 代表客户端无条件地信任服务器端返回的证书。
//        AFSSLPinningModePublicKey: 代表客户端会将服务器端返回的证书与本地保存的证书中，PublicKey的部分进行校验；如果正确，才继续进行。
//        AFSSLPinningModeCertificate: 代表客户端会将服务器端返回的证书和本地保存的证书中的所有内容，包括PublicKey和证书部分，全部进行校验；如果正确，才继续进行。
        

//        [securityPolicy setAllowInvalidCertificates:NO];//  allowInvalidCertificates 定义了客户端是否信任非法证书。
        
//        validatesDomainName 是指是否校验在证书中的domain这一个字段。每个证书都会包含一个DomainName, 它可以是一个IP地址，一个域名或者一端带有通配符的域名。如*.google.com, www.google.com 都可以成为这个证书的DomainName。设置validatesDomainName=YES将严格地保证其安全性。
//        [securityPolicy setValidatesDomainName:YES];

//          请求头格式设置，Content-Type代表发送端（客户端|服务器）发送的实体数据的数据类型，Accept代表发送端（客户端）希望接受的数据类型
//        [_HTTPManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//        [_HTTPManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        
        

        
        
    }
    return self;
}


+ (void)request:(NSString*)taskID
            WithParam:(id)param
           withMethod:(HTTPRequestType_GW)method
              success:(void(^)(id result))success
              failure:(void(^)(NSError *erro))failure{
    
    [self request:taskID WithParam:param withMethod:method uploadFileProgress:nil success:success failure:failure];
    
    
}

+ (void)request:(NSString*)taskID
      WithParam:(id)param
     withMethod:(HTTPRequestType_GW)method
    uploadFileProgress:(void(^)(NSProgress *uploadProgress))uploadFileProgress
        success:(void(^)(id result))success
        failure:(void(^)(NSError *erro))failure{
    
    setNetworkActivityIndicatorVisible(YES)
    
    NSMutableURLRequest *request = [GWNetWorking_Share.sessionManager.requestSerializer requestWithMethod:[self getStringForRequestType:method] URLString:[[NSURL URLWithString:taskID relativeToURL:GWNetWorking_Share.sessionManager.baseURL] absoluteString] parameters:param error:nil];
    
    [self requestDataTask:request success:success failure:failure uploadFileProgress:uploadFileProgress];
}

+ (void)request:(NSString*)taskID
            WithParam:(NSDictionary*)param
          withExParam:(NSDictionary*)Exparam
           withMethod:(HTTPRequestType_GW)method
    uploadFileProgress:(void(^)(NSProgress *uploadProgress))uploadFileProgress
              success:(void (^)(id result))success
            failure:(void (^)(NSError* erro))failure{
    
    setNetworkActivityIndicatorVisible(YES)
    
    NSMutableURLRequest *request = [GWNetWorking_Share.sessionManager.requestSerializer multipartFormRequestWithMethod:[self getStringForRequestType:method] URLString:taskID parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        //图片上传
        if (Exparam) {
            for (NSString *key in [Exparam allKeys]) {
//                设置图片的格式mimeType:@"image/jpeg"，@"image/jpg"
                [formData appendPartWithFileData:[Exparam objectForKey:key] name:key fileName:[NSString stringWithFormat:@"%@.png",key] mimeType:@"image/jpeg"];
            }
        }
        
    } error:nil];
    
    [self requestDataTask:request success:success failure:failure uploadFileProgress:uploadFileProgress];
}


+ (void)requestSoundFileRequest:(NSString*)taskID
                      WithParam:(NSDictionary *)param
                    withExParam:(NSDictionary*)Exparam
                     withMethod:(HTTPRequestType_GW)method
             uploadFileProgress:(void(^)(NSProgress *uploadProgress))uploadFileProgress
                        success:(void(^)(id result))success
                        failure:(void(^)(NSError *erro))failure{
    
    setNetworkActivityIndicatorVisible(YES)
    
    NSMutableURLRequest *request = [GWNetWorking_Share.sessionManager.requestSerializer multipartFormRequestWithMethod:[self getStringForRequestType:method] URLString:taskID parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        //上传
        if (Exparam) {
            for (NSString *key in [Exparam allKeys]) {
                
                NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
                
                formatter.dateFormat = @"yyyyMMddHHmmss";
                
                NSString *str = [formatter  stringFromDate:[NSDate date]];
                NSString  *fileName = [NSString  stringWithFormat:@"%@.wav",str];
                
//                设置音频的格式mimeType：@"audio/wav"，@"audio/mp3"
                [formData appendPartWithFileData:[Exparam objectForKey:key] name:key fileName:fileName mimeType:@"audio/wav"];
                
            }
        }
        
    } error:nil];
    

    [self requestDataTask:request success:success failure:failure uploadFileProgress:uploadFileProgress];
    
}

+ (void)requestDownloadFileWithURLString:(NSString *)URLString
                               WithParam:(NSDictionary *)param
                              withMethod:(HTTPRequestType_GW)method
                    downloadFileProgress:(void(^)(NSProgress *downloadProgress))downloadFileProgress
                           setupFilePath:(NSURL*(^)(NSURLResponse *response))setupFilePath
               downloadCompletionHandler:(void (^)(NSURL *filePath, NSError *error))downloadCompletionHandler{
    
    NSMutableURLRequest *request = [GWNetWorking_Share.sessionManager.requestSerializer requestWithMethod:[self getStringForRequestType:method] URLString:[[NSURL URLWithString:URLString relativeToURL:GWNetWorking_Share.sessionManager.baseURL] absoluteString] parameters:param error:nil];
    
    NSURLSessionDownloadTask *dataTask = [GWNetWorking_Share.sessionManager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
        /**
         *  下载进度
         */
        downloadFileProgress(downloadProgress);
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
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
        [GWNetWorking_Share removeTaskFromArr:response];
        downloadCompletionHandler(filePath,error);
        
    }];
    
    [GWNetWorking_Share.taskArray addObject:dataTask];
    GWNetWorking_Share.currentTask = dataTask;
    [dataTask resume];
    
    
}


#pragma mark - commonAction
+ (void)requestDataTask:(NSMutableURLRequest *)request
                success:(void(^)(id result))success
                failure:(void(^)(NSError *erro))failure
     uploadFileProgress:(void(^)(NSProgress *uploadProgress))uploadFileProgress{
    
    NSURLSessionDataTask *dataTask = [GWNetWorking_Share.sessionManager dataTaskWithRequest:request uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
        if (uploadProgress && uploadFileProgress) { //上传进度
            uploadFileProgress (uploadProgress);
        }
    } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
        
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        setNetworkActivityIndicatorVisible(NO)
                                           
        [GWNetWorking_Share removeTaskFromArr:response];
        
        if (error) {
            
            if (failure != nil){
                failure(error);
            }
            
        } else {
            
            if (success != nil){
                if ([responseObject isKindOfClass:[NSData class]]) {
                    id result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:nil];
                    success(result);
                }else{
                    success(responseObject);
                }
            }
        }
    }];
    
    [GWNetWorking_Share.taskArray addObject:dataTask];
    GWNetWorking_Share.currentTask = dataTask;
    [dataTask resume];
    
}


+(NSString *)getStringForRequestType:(HTTPRequestType_GW)type {
    
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

- (void)removeTaskFromArr:(NSURLResponse *)response{
    if (!response) {
        return;
    }
    if (GWNetWorking_Share.taskArray.count) {
        for (NSURLSessionTask *task in GWNetWorking_Share.taskArray) {
            if ([task.response.URL isEqual:response.URL]) {
                [GWNetWorking_Share.taskArray removeObject:task];
            }
        }
    }
}

- (void)cancelAllTask{
    for (NSURLSessionTask *task in self.taskArray) {
        [task cancel];
    }
}

- (void)cancelCurrentTask{
    [self.currentTask cancel];
}

- (void)cancelBeginAllTask{
    for (NSURLSessionTask *task in self.taskArray) {
        if ([task.response.URL isEqual:_currentTask.response.URL]) {
            continue;
        }
        [task cancel];
    }
}



@end
