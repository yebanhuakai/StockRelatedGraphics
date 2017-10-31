//
//  SHY_HttpRequest.h
//  AFNetworkTest
//
//  Created by Shenry on 2017/10/18.
//  Copyright © 2017年 Shenry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SHY_HttpRequest : NSObject

+ (void)requestGetWithUrl:(NSString *)url parameters:(id)para success:(void(^)(id responseObject))success failure:(void(^)(NSError *error))failure;

+ (void)requestPostWithUrl:(NSString *)url parameters:(id)para success:(void(^)(id responseObject))success failure:(void(^)(NSError *error))failure;

@end
