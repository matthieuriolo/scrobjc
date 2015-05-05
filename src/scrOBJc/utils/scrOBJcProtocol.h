/*
 *  scrOBJcProtocol.h
 *  scrOBJc
 *
 *  Created by Matthieu Riolo on 24.07.10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

@protocol scrOBJcProtocol

+ (id)default;

- (NSString*)protocolVersion;
- (BOOL)addToQueueIfNeeded:(id)track;

- (BOOL)submitCurrentPlaying:(id)track;

- (BOOL)pushToQueue:(id)track;
- (BOOL)submitQueueSequence:(NSInteger)size;

- (void)removeTrackFromQueue:(NSDictionary*)track;
- (NSArray*)queue;
- (void)setQueue:(NSArray*)list;
@end
