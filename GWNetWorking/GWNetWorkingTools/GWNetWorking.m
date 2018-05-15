//
//  GWNetWorking.m
//  gw_test
//
//  Created by gw on 2018/3/23.
//  Copyright © 2018年 gw. All rights reserved.
//

#import "GWNetWorking.h"
#import "AFNetworking.h"
#import "VoiceConverter.h"
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
        /*! 设置相应的缓存策略 */
//        _sessionManager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
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
    
    NSMutableURLRequest *request = [GWNetWorking_Share.sessionManager.requestSerializer requestWithMethod:[GWNetWorking_Share getStringForRequestType:method] URLString:[[NSURL URLWithString:taskID relativeToURL:GWNetWorking_Share.sessionManager.baseURL] absoluteString] parameters:param error:nil];
    
    [GWNetWorking_Share requestDataTask:request success:success failure:failure uploadFileProgress:uploadFileProgress];
}

+ (void)request:(NSString*)taskID
            WithParam:(NSDictionary*)param
          withExParam:(NSDictionary*)Exparam
           withMethod:(HTTPRequestType_GW)method
    uploadFileProgress:(void(^)(NSProgress *uploadProgress))uploadFileProgress
              success:(void (^)(id result))success
            failure:(void (^)(NSError* erro))failure{
    
    setNetworkActivityIndicatorVisible(YES)
    
    NSMutableURLRequest *request = [GWNetWorking_Share.sessionManager.requestSerializer multipartFormRequestWithMethod:[GWNetWorking_Share getStringForRequestType:method] URLString:taskID parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
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
    
    [GWNetWorking_Share requestDataTask:request success:success failure:failure uploadFileProgress:uploadFileProgress];
}


+ (void)requestSoundFileRequest:(NSString*)taskID
                      WithParam:(NSDictionary *)param
                    withExParam:(NSDictionary*)Exparam
                     withMethod:(HTTPRequestType_GW)method
             uploadFileProgress:(void(^)(NSProgress *uploadProgress))uploadFileProgress
                        success:(void(^)(id result))success
                        failure:(void(^)(NSError *erro))failure{
    
    setNetworkActivityIndicatorVisible(YES)
    
    NSMutableURLRequest *request = [GWNetWorking_Share.sessionManager.requestSerializer multipartFormRequestWithMethod:[GWNetWorking_Share getStringForRequestType:method] URLString:taskID parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
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
    

    [GWNetWorking_Share requestDataTask:request success:success failure:failure uploadFileProgress:uploadFileProgress];
    
}

+ (void)requestUploadVideoWithURLString:(NSString *)URLString
                               WithParam:(NSDictionary *)param
                              withVideoPath:(NSString *)videoPath
                              withMethod:(HTTPRequestType_GW)method
                     uploadFileProgress:(void(^)(NSProgress *uploadProgress))uploadFileProgress
                                success:(void(^)(id result))success
                                failure:(void(^)(NSError *erro))failure{
    __weak GWNetWorking *netW = GWNetWorking_Share;
//    进行视频转换，由高->中，如果录制时就是中质量，请将转换方法屏蔽；
    [self compressVideo:videoPath finish:^(NSString *path) {
        NSMutableURLRequest *request = [netW.sessionManager.requestSerializer multipartFormRequestWithMethod:[netW getStringForRequestType:method] URLString:URLString parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            [formData appendPartWithFileURL:[NSURL fileURLWithPath:path] name:@"" fileName:path mimeType:@"video/mpeg4" error:nil];
            
        } error:nil];
        [netW requestDataTask:request success:success failure:failure uploadFileProgress:uploadFileProgress];
    }];
    
}

+ (void)requestDownloadFileWithURLString:(NSString *)URLString
                               WithParam:(NSDictionary *)param
                              withMethod:(HTTPRequestType_GW)method
                    downloadFileProgress:(void(^)(NSProgress *downloadProgress))downloadFileProgress
                           setupFilePath:(NSURL*(^)(NSURLResponse *response))setupFilePath
               downloadCompletionHandler:(void (^)(NSURL *filePath, NSError *error))downloadCompletionHandler{
    
    NSMutableURLRequest *request = [GWNetWorking_Share.sessionManager.requestSerializer requestWithMethod:[GWNetWorking_Share getStringForRequestType:method] URLString:[[NSURL URLWithString:URLString relativeToURL:GWNetWorking_Share.sessionManager.baseURL] absoluteString] parameters:param error:nil];
    
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
- (void)requestDataTask:(NSMutableURLRequest *)request
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

- (void)cancelNoCurrentAllTask{
    for (NSURLSessionTask *task in self.taskArray) {
        if ([task.response.URL isEqual:_currentTask.response.URL]) {
            continue;
        }
        [task cancel];
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
//
//// video的路径
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
