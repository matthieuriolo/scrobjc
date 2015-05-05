//
//  scrOBJcLibreFM.m
//  scrOBJc
//
//  Created by Matthieu Riolo on 25.07.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "scrOBJcLibreFMProtocol.h"

@implementation scrOBJcLibreFMProtocol
- (NSString*)serviceName {
	return @"LibreFM";
}

- (NSString*)formatHandshake {
	return @"http://turtle.libre.fm/?hs=true&p=1.2&c=%@&v=%@&u=%@&t=%@&a=%@";
}
@end
