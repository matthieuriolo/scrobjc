//
//  scrOBJcString.m
//  scrOBJc
//
//  Created by Matthieu Riolo on 24.07.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "scrOBJcString.h"


@implementation NSString (scrOBJcString)
+ (NSString*)stringWithData:(NSData*)data encoding:(NSStringEncoding)encode {
	NSString* str = [[NSString alloc] initWithData:data encoding:encode];
	if(str)
		[NSAutoreleasePool addObject:str];
	return str;
}

- (NSString*)stringByCalculatingMD5Hash {
	NSData* d = [self dataUsingEncoding:NSUTF8StringEncoding];
	unsigned char dig[CC_MD5_DIGEST_LENGTH];
	
	CC_MD5([d bytes], [d length], dig);
	
	NSMutableString* str = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
	for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
		[str appendFormat:@"%02x", dig[i]];
	
	return str;//[str lowercaseString];
}


- (NSString*)stringWithURLEncode {
	NSString* str = (NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self, NULL,
															   (CFStringRef)@"!*'();:@&=+$,/?%#[] ", kCFStringEncodingUTF8);
	[NSAutoreleasePool addObject:str];
	return str;
}

@end
