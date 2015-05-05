//
//  scrOBJcSingleton.h
//  scrOBJc
//
//  Created by Matthieu Riolo on 24.07.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

//it's a pseudo singleton - one object for each application - should be hold until the applications quits
@interface scrOBJcSingleton : NSObject {

}

//singleton stuff
+ (id)default;
- (id)retain;
- (NSUInteger)retainCount;
- (void)release;
- (id)autorelease;

- (void)applicationsQuit:(NSNotification*)aNotification;
@end
