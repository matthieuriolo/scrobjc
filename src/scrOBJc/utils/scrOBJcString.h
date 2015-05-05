//
//  scrOBJcString.h
//  scrOBJc
//
//  Created by Matthieu Riolo on 24.07.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CommonCrypto/CommonDigest.h>

@interface NSString (scrOBJcString)

+ (NSString*)stringWithData:(NSData*)data encoding:(NSStringEncoding)encode;
- (NSString*)stringByCalculatingMD5Hash;
- (NSString*)stringWithURLEncode;

@end
