//
//  scrOBJcSingleton.m
//  scrOBJc
//
//  Created by Matthieu Riolo on 24.07.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "scrOBJcSingleton.h"


@implementation scrOBJcSingleton

//singletonstuff
+ (id)default {
	static id singleton = nil;
	
	@synchronized(self) {
		if(!singleton) {
			singleton = [[self alloc] init];
			[[NSNotificationCenter defaultCenter] addObserver:singleton selector:@selector(applicationsQuit:) name:@"NSApplicationWillTerminateNotification" object:NSApp];
		}
	}
	
	return singleton;
}

- (id)retain {
	return self;
}

- (NSUInteger)retainCount {
	return NSUIntegerMax;
}

- (void)release {}

- (id)autorelease {
	return self;
}

- (void)applicationsQuit:(NSNotification*)aNotification {
	[self dealloc];
}
@end
