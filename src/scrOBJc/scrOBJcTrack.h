//
//  scrOBJcTrack.h
//  scrOBJc
//
//  Created by Matthieu Riolo on 23.07.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "scrOBJcLibreFMProtocol.h"
#import "scrOBJcLastFMProtocol.h"

@interface scrOBJcTrack : NSObject {
	NSMutableDictionary* trackInformations;
	NSMutableArray* playedTimes;
	NSArray* protocolObjects;
	NSUInteger lastPlayingStart;
}

+ (NSArray*)supportedProtocols;

- (id)init;
- (id)initWithProtocols:(NSArray*)objs;
- (id)initWithDictionary:(NSDictionary*)dict;
- (id)initWithDictionary:(NSDictionary*)dict andProtocols:(NSArray*)objs;

- (void)dealloc;

- (void)setValue:(id)value forKey:(NSString*)key;
- (id)valueForKey:(NSString*)key;
- (void)setNilValueForKey:(NSString *)key;
- (NSMutableDictionary*)dictionaryRepresentation;


- (void)startPlaying;
- (void)pausePlaying;

- (id)currentPlaying;
- (void)submit;

- (NSTimeInterval)playedTime;
@end