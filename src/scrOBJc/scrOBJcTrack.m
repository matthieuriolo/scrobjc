//
//  scrOBJcTrack.m
//  scrOBJc
//
//  Created by Matthieu Riolo on 23.07.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "scrOBJcTrack.h"


@implementation scrOBJcTrack

+ (NSArray*)supportedProtocols {
	static NSArray* objs = nil;
	if(!objs)
		objs = [NSArray arrayWithObjects:[scrOBJcLastFMProtocol default], [scrOBJcLibreFMProtocol default], nil];
	return objs;
}


- (id)init {
	if(self = [self initWithProtocols:nil])
		trackInformations = [[NSMutableDictionary alloc] init];
	return self;
}

- (id)initWithProtocols:(NSArray*)objs {
	if(self = [super init]) {
		playedTimes = [[NSMutableArray alloc] init];
		
		protocolObjects = objs ? objs : [[self class] supportedProtocols];
		[protocolObjects retain];
		
		trackInformations = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithUnsignedInteger:(NSUInteger)time(NULL)], @"startedAt", nil];
		lastPlayingStart = 0;
	}
	
	return self;
}

- (id)initWithDictionary:(NSDictionary*)dict {
	if(self = [self init])
		[trackInformations addEntriesFromDictionary:dict];
	
	return self;
}

- (id)initWithDictionary:(NSDictionary*)dict andProtocols:(NSArray*)objs {
	if(self = [self initWithProtocols:objs])
		[trackInformations addEntriesFromDictionary:dict];
	return self;
}

- (void)dealloc {
	[trackInformations release];
	[protocolObjects release];
	[playedTimes release];
	
	[super dealloc];
}

- (void)setValue:(id)value forKey:(NSString*)key {
	[trackInformations setObject:value forKey:key];
}

- (id)valueForKey:(NSString*)key {
	return [trackInformations objectForKey:key];
}

- (void)setNilValueForKey:(NSString *)key {
	[trackInformations removeObjectForKey:key];
}

- (NSMutableDictionary*)dictionaryRepresentation {
	return trackInformations;
}

- (void)startPlaying {
	if(!lastPlayingStart)
		lastPlayingStart = [NSDate timeIntervalSinceReferenceDate];
}

- (void)pausePlaying {
	if(lastPlayingStart) {
		[playedTimes addObject:[NSNumber numberWithDouble:[NSDate timeIntervalSinceReferenceDate]-lastPlayingStart]];
		lastPlayingStart = 0;
	}
}

- (void)submit {
	[protocolObjects makeObjectsPerformSelector:@selector(addToQueueIfNeeded:) withObject:self];
}

- (id)currentPlaying {
	[protocolObjects makeObjectsPerformSelector:@selector(submitCurrentPlaying:) withObject:self];
	return self;
}

- (NSTimeInterval)playedTime {
	NSTimeInterval i = 0.0;
	for(NSNumber* num in playedTimes)
		i += [num doubleValue];
	return i;
	
	//return 100.0;
}

@end
