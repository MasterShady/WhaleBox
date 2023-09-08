//
//  RC4Tool.m
//  gerental
//
//  Created by 刘思源 on 2023/1/30.
//

#import "RC4Tool.h"

@implementation RC4Tool

// rc4加密
+ (NSString *)rc4Encode:(NSString *)aInput key:(NSString *)aKey {
    NSMutableArray *iS = [[NSMutableArray alloc] initWithCapacity:256];
        NSMutableArray *iK = [[NSMutableArray alloc] initWithCapacity:256];
        for (int i= 0; i<256; i++) {
            [iS addObject:[NSNumber numberWithInt:i]];
        }
        int j=1;
        for (short i=0; i<256; i++) {
            UniChar c = [aKey characterAtIndex:i%aKey.length];
            [iK addObject:[NSNumber numberWithChar:c]];
        }
        j=0;
        for (int i=0; i<256; i++) {
            int is = [[iS objectAtIndex:i] intValue];
            UniChar ik = (UniChar)[[iK objectAtIndex:i] charValue];
            j = (j + is + ik)%256;
            NSNumber *temp = [iS objectAtIndex:i];
            [iS replaceObjectAtIndex:i withObject:[iS objectAtIndex:j]];
            [iS replaceObjectAtIndex:j withObject:temp];
        }
        int i=0;
        j=0;
        Byte byteBuffer[aInput.length];
        for (short x=0; x<[aInput length]; x++) {
            i = (i+1)%256;
            int is = [[iS objectAtIndex:i] intValue];
            j = (j+is)%256;
            int is_i = [[iS objectAtIndex:i] intValue];
            int is_j = [[iS objectAtIndex:j] intValue];
            int t = (is_i+is_j) % 256;
            
            // 先交换位置，再取值
            [iS exchangeObjectAtIndex:i withObjectAtIndex:j];
            
            int iY = [[iS objectAtIndex:t] intValue];
            UniChar ch = (UniChar)[aInput characterAtIndex:x];
            UniChar ch_y = ch^iY;
            byteBuffer[x] = ch_y;
        }
    
    // 字节数组转16进制字符串输出
    NSString *resultString = [self stringFromByte:byteBuffer length:aInput.length];
    
//    NSData *adata = [[NSData alloc] initWithBytes:byteBuffer length:aInput.length];
//    NSString *string = [adata base64EncodedStringWithOptions:0]; // 以base64的加密结果输出
    return resultString;
}

//rc4解密
+ (NSString *)rc4Decode:(NSString *)data key:(NSString*)secret{
    // 如果是16进制字符串
//    NSData *raw = [self ByteDataFromString:data];
    
    // 如果是base64加密后字符串
    NSData *raw = [[NSData alloc] initWithBase64EncodedString:data options:0];
    
    int cipherLength = (int)raw.length;
    UInt8 *cipher = malloc(cipherLength);
    [raw getBytes:cipher length:cipherLength];
    NSData *kData = [secret dataUsingEncoding:NSUTF8StringEncoding];
    int keyLength = (int)kData.length;
    UInt8 *kBytes = malloc(kData.length);
    [kData getBytes:kBytes length:kData.length];
    UInt8 *decipher = malloc(cipherLength + 1);
    UInt8 iS[256];
    UInt8 iK[256];
    int i;
    for (i = 0; i < 256; i++){
        iS[i] = i;
        iK[i] = kBytes[i % keyLength];
    }
    int j = 0;
    for (i = 0; i < 256; i++){
        int is = iS[i];
        int ik = iK[i];
        j = (j + is + ik)% 256;
        UInt8 temp = iS[i];
        iS[i] = iS[j];
        iS[j] = temp;
    }
    int q = 0;
    int p = 0;
    for (int x = 0; x < cipherLength; x++){
        q = (q + 1)% 256;
        p = (p + iS[q])% 256;
        int k = iS[p];
        iS[p] = iS[q];
        iS[q] = k;
        k = iS[(iS[q] + iS[p])% 256];
        decipher[x] = cipher[x] ^ k;
    }
    free(kBytes);
    decipher[cipherLength] = '\0';
    return @((char *)decipher);
}

// 字节数组转
+ (NSString *)stringFromByte:(Byte *)byteBuffer length:(NSInteger)length {
    NSMutableString *hexString = [[NSMutableString alloc] init];
    for (int i = 0; i < length; i++) {
        [hexString appendString:[NSString stringWithFormat:@"%0.2hhx", byteBuffer[i]]];
    }
    return [hexString uppercaseString];
}

+ (NSData *)ByteDataFromString:(NSString *)targetStr {
    NSInteger len = [targetStr length] / 2;    // Target length
    unsigned char *buf = malloc(len);
    unsigned char *whole_byte = buf;
    char byte_chars[3] = {'\0','\0','\0'};

    int i;
    for (i=0; i < [targetStr length] / 2; i++) {
        byte_chars[0] = [targetStr characterAtIndex:i*2];
        byte_chars[1] = [targetStr characterAtIndex:i*2+1];
        *whole_byte = strtol(byte_chars, NULL, 16);
        whole_byte++;
    }

    NSData *data = [NSData dataWithBytes:buf length:len];
    free( buf );
    return data;
}

@end
