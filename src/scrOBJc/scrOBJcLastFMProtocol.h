//
//  scrOBJcLastFMProtocol.h
//  scrOBJc
//
//  Created by Matthieu Riolo on 24.07.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "scrOBJcProtocol.h"
#import "scrOBJcSingleton.h"
#import "scrOBJcString.h"


#define sizeLastFMDefaultQueueSubmission 10
#define sizeLastFMMinimumQueueSubmission 1
#define sizeLastFMMaximumQueueSubmission 50

/*to do:
 -if the handshake fails, retry it in 1 minute again. if it fails again, try it in 2 hours again (written at the last.fm protocol page)
 */

@interface scrOBJcLastFMProtocol : scrOBJcSingleton <scrOBJcProtocol> {
	BOOL isConnected;
	
	NSString* stringSessionID;
	NSString* stringQueueSubmitting;
	NSString* stringCurrentPlayingSubmitting;
	
	NSUserDefaults* defaults;
	
	NSMutableArray* queue;
}

- (NSString*)serviceName;
- (NSString*)formatHandshake;

//allocing stuff
- (id)init;
- (void)dealloc;

//lastFM API
- (NSString*)protocolVersion;
- (BOOL)addToQueueIfNeeded:(id)track;


- (BOOL)shakeHands;
- (void)unshakeHands;

- (BOOL)submitCurrentPlaying:(id)track;

- (BOOL)pushToQueue:(id)track;
- (BOOL)submitQueueSequence:(NSInteger)size;

- (void)removeTrackFromQueue:(NSDictionary*)track;
- (NSArray*)queue;
- (void)setQueue:(NSArray*)list;

- (NSInteger)sequenceLengthForSubmitting;
@end


#import "scrOBJcTrack.h"