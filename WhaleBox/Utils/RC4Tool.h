//
//  RC4Tool.h
//  gerental
//
//  Created by 刘思源 on 2023/1/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RC4Tool : NSObject

+ (NSString *)rc4Encode:(NSString *)aInput key:(NSString *)aKey;

+ (NSString *)rc4Decode:(NSString *)data key:(NSString*)secret;

@end

NS_ASSUME_NONNULL_END
