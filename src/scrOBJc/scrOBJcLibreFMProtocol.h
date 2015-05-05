//
//  scrOBJcLibreFM.h
//  scrOBJc
//
//  Created by Matthieu Riolo on 25.07.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "scrOBJcLastFMProtocol.h"

//should be the same as lastFM ...
@interface scrOBJcLibreFMProtocol : scrOBJcLastFMProtocol {}

- (NSString*)serviceName;
- (NSString*)formatHandshake;

@end
