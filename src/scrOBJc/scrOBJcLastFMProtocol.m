//
//  scrOBJcLastFMProtocol.m
//  scrOBJc
//
//  Created by Matthieu Riolo on 24.07.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "scrOBJcLastFMProtocol.h"


@implementation scrOBJcLastFMProtocol

- (NSString*)serviceName {
	return @"LastFM";
}

- (NSString*)formatHandshake {
	return @"http://post.audioscrobbler.com/?hs=true&p=1.2&c=%@&v=%@&u=%@&t=%@&a=%@";
}

//allocing stuff
- (id)init {
	if(self = [super init]) {
		isConnected = NO;
		
		defaults = [NSUserDefaults standardUserDefaults];
		
		if(defaults) {
			[defaults registerDefaults:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:sizeLastFMDefaultQueueSubmission] forKey:[NSString stringWithFormat:@"scrOBJc%@SubmissionSize", [self serviceName]]]];
			queue = [[NSMutableArray alloc] initWithArray:[defaults objectForKey:[NSString stringWithFormat:@"scrOBJc%@Queue", [self serviceName]]]];
		}else
			queue = [[NSMutableArray alloc] init];
	}
	
	return self;
}

- (void)dealloc {
	[defaults setObject:queue forKey:[NSString stringWithFormat:@"scrOBJc%@Queue", [self serviceName]]];
	[defaults synchronize];
	
	[queue release];
	[self unshakeHands];
	[super dealloc];
}

//lastFM API
- (NSString*)protocolVersion {
	return @"1.2";
}

- (BOOL)addToQueueIfNeeded:(id)track {
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	if(![defaults boolForKey:[NSString stringWithFormat:@"scrOBJc%@Enabled", [self serviceName]]]) {
		[pool drain];
		return NO;
	}
	
	NSString* sourceType = [track valueForKey:@"sourceType"];
	
	if(!sourceType)
		[track setValue:sourceType = @"P" forKey:@"sourceType"];
	
	NSNumber* num = [track valueForKey:@"duration"];
	
	if([sourceType caseInsensitiveCompare:@"P"] == NSOrderedSame && !num) {
		NSLog(@"scrOBJc%@ Error: You must set up the duration of track if using the source type P.", [self serviceName]);
		[pool drain];
		return NO;
	}
	
	NSInteger t = (NSInteger)[track playedTime];
	
	if(num) {
		if([num integerValue] < 30) {
			NSLog(@"scrOBJc%@ Error: The duration of a track must be at least 30 seconds.", [self serviceName]);
			[pool drain];
			return NO;
		}
		
		if([num integerValue]/2 > t && t < 240) {
			[pool drain];
			return NO;
		}
	}else if(t < 240) {
		[pool drain];
		return NO;
	}
	
	[pool drain];
	return [self pushToQueue:track];
}


- (BOOL)shakeHands {
	[self unshakeHands];
	
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	NSString* LastFMClientID = [[NSBundle mainBundle] objectForInfoDictionaryKey:[NSString stringWithFormat:@"scrOBJc%@ClientID", [self serviceName]]];
	
	if(!LastFMClientID) {
		NSLog(@"scrOBJc%@ Error: No %@ Client ID found! Please set up correctly your info.plist file.", [self serviceName], [self serviceName]);
		[pool drain];
		return NO;
	}
	
	NSString* CFBundleVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:[NSString stringWithFormat:@"CFBundleVersion"]];
	
	if(!CFBundleVersion) {
		NSLog(@"scrOBJc%@ Error: No Bundle version found! Please set up correctly your info.plist file.", [self serviceName]);
		[pool drain];
		return NO;
	}
	
	NSString* username = [defaults objectForKey:[NSString stringWithFormat:@"scrOBJc%@Username", [self serviceName]]];
	
	if(!username) {
		NSLog(@"scrOBJc%@ Error: No username found for %@! Please set up correctly the user preferences.", [self serviceName], [self serviceName]);
		[pool drain];
		return NO;
	}
	
	NSString* password = [defaults objectForKey:[NSString stringWithFormat:@"scrOBJc%@Password", [self serviceName]]];
	
	if(!password) {
		NSLog(@"scrOBJc%@ Error: No password found for %@! Please set up correctly the user preferences.", [self serviceName], [self serviceName]);
		[pool drain];
		return NO;
	}
	
	NSString* strTime = [[NSNumber numberWithUnsignedInteger:(NSUInteger)time(NULL)] stringValue];
	NSString* auth = [[NSString stringWithFormat:@"%@%@", [password stringByCalculatingMD5Hash], strTime] stringByCalculatingMD5Hash];
	
	NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:[self formatHandshake], 
									   LastFMClientID,
									   CFBundleVersion,
									   username,
									   strTime,
									   auth]];
	
	NSString* response = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:NULL];
	if(!response) {
		NSLog(@"scrOBJc%@ Error: Could not make handshake. Used URL: %@", [self serviceName], [url description]);
		[pool drain];
		return NO;
	}
	
	NSArray* comps = [response componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
	
	if([comps count] < 4 || [[comps objectAtIndex:0] caseInsensitiveCompare:@"OK"] != NSOrderedSame) {
		NSLog(@"scrOBJc%@ Error: Handshake response error. Server response: %@", [self serviceName], response);
		[pool drain];
		return NO;
	}
	
	stringSessionID = [[comps objectAtIndex:1] retain];
	stringCurrentPlayingSubmitting = [[comps objectAtIndex:2] retain];
	stringQueueSubmitting = [[comps objectAtIndex:3] retain];
	
	[pool drain];
	return isConnected = YES;
}

- (void)unshakeHands {
	if(isConnected) {
		[stringSessionID release];
		[stringCurrentPlayingSubmitting release];
		[stringQueueSubmitting release];
		isConnected = NO;
	}
}

- (BOOL)submitCurrentPlaying:(id)track {
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	if(![defaults boolForKey:[NSString stringWithFormat:@"scrOBJc%@Enabled", [self serviceName]]]) {
		[pool drain];
		return NO;
	}
	
	if(!isConnected)
		if(![self shakeHands]) {
			NSLog(@"scrOBJc%@ Error: Could not submit the playing track.", [self serviceName]);
			return NO;
		}
	
	
	NSString* artist = [track valueForKey:@"artist"];
	
	if(!artist) {
		NSLog(@"scrOBJc%@ Error: The track must contain an artist name.", [self serviceName]);
		[pool drain];
		return NO;
	}
	
	NSString* title = [track valueForKey:@"title"];
	
	if(!title) {
		NSLog(@"scrOBJc%@ Error: The track must contain a title name.", [self serviceName]);
		[pool drain];
		return NO;
	}
	
	NSMutableString* body = [NSMutableString stringWithFormat:@"s=%@&a=%@&t=%@", [stringSessionID stringWithURLEncode], [artist stringWithURLEncode], [title stringWithURLEncode]];
	
	NSNumber* l = [track valueForKey:@"duration"];
	if(l)
		[body appendFormat:@"&l=%@", [l stringValue]];
	
	NSNumber* n = [track valueForKey:@"index"];
	if(n)
		[body appendFormat:@"&n=%@", [n stringValue]];
	
	NSString* mbid = [track valueForKey:@"mbid"];
	if(mbid)
		[body appendFormat:@"&m=%@", [mbid stringWithURLEncode]];
	
	NSURL* url = [NSURL URLWithString:stringCurrentPlayingSubmitting];
	NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
	
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
	
	NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:NULL error:NULL];
	
	if(!data) {
		NSLog(@"scrOBJc%@ Error: Could not submit the current playing track. Used URL: %@\n with body: %@", [self serviceName], [url description], body);
		[pool drain];
		return NO;
	}
	
	NSString* response = [NSString stringWithData:data encoding:NSUTF8StringEncoding];
	NSArray* comps = [response componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
	
	if([[comps objectAtIndex:0] caseInsensitiveCompare:@"OK"] != NSOrderedSame) {
		isConnected = NO;
		NSLog(@"scrOBJc%@ Error: Could not submit the current playing track. The server response with: %@", [self serviceName], response);
		[pool drain];
		return NO;
	}
	
	[pool drain];
	return YES;
}

- (BOOL)pushToQueue:(id)track {
	//check at first if the track contains all needed values
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	if(![track valueForKey:@"artist"]) {
		NSLog(@"scrOBJc%@ Error: The track must contain an artist name.", [self serviceName]);
		return NO;
	}
	
	if(![track valueForKey:@"title"]) {
		NSLog(@"scrOBJc%@ Error: The track must contain a title name.", [self serviceName]);
		[pool drain];
		return NO;
	}
	
	if(![track valueForKey:@"startedAt"]) {
		NSLog(@"scrOBJc%@ Error: The track must contain the unix timestamp descriping the start time.", [self serviceName]);
		[pool drain];
		return NO;
	}
	
	
	NSArray* srcs = [NSArray arrayWithObjects:@"P", @"R", @"E", @"L", @"U", nil];
	NSString* src = [track valueForKey:@"sourceType"];
	
	if(!src) {
		NSLog(@"scrOBJc%@ Error: The track must contain the source.", [self serviceName]);
		[pool drain];
		return NO;
	}
	
	NSInteger place = -1;
	for(NSInteger i = 0; i < [srcs count]; i++)
		if([src caseInsensitiveCompare:[srcs objectAtIndex:i]] == NSOrderedSame)
			place = i;
	
	if(place == -1) {
		NSLog(@"scrOBJc%@ Error: The track contains an invalid source type.", [self serviceName]);
		[pool drain];
		return NO;
	}
	
	
	NSString* rating = [track valueForKey:@"ratingType"];
	
	if(rating) {
		NSArray* rats = [NSArray arrayWithObjects:@"L", @"B", @"S", nil];
		NSInteger ratingPlace = -1;
		for(NSInteger i = 0; i < [rats count]; i++)
			if([rating caseInsensitiveCompare:[rats objectAtIndex:i]] == NSOrderedSame)
				ratingPlace = i;
		
		if(ratingPlace == -1) {
			NSLog(@"scrOBJc%@ Warning: The track contains an invalid rating type. It will be removed from the track!", [self serviceName]);
			[track setNilValueForKey:@"ratingType"];
		}else if(ratingPlace != 0 && place != 3) {
			NSLog(@"scrOBJc%@ Warning: The track contains an invalid rating type for the selected source type. It will be removed from the track!", [self serviceName]);
			[track setNilValueForKey:@"ratingType"];
		}
	}
	
	if(place == 0 && ![track valueForKey:@"duration"]) {
		NSLog(@"scrOBJc%@ Error: The track must contain the duration of the sound.", [self serviceName]);
		[pool drain];
		return NO;
	}
	
	[pool drain];
	
	[queue addObject:[track dictionaryRepresentation]];
	
	NSInteger size = [self sequenceLengthForSubmitting];
	
	if(size)
		return [self submitQueueSequence:size];
	
	return YES;
}


- (BOOL)submitQueueSequence:(NSInteger)size {
	if(!isConnected)
		if(![self shakeHands]) {
			NSLog(@"scrOBJc%@ Error: Could not submit the queue sequence.", [self serviceName]);
			return NO;
		}
	
	
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	NSRange range = NSMakeRange(0, size);
	NSArray* tracks = [queue subarrayWithRange:range];
	[queue removeObjectsInRange:range];
	
	NSMutableString* body = [NSMutableString stringWithFormat:@"s=%@", stringSessionID];
	
	for(NSUInteger pos = 0; pos < size; pos++) {
		NSDictionary* track = [tracks objectAtIndex:pos];
		[body appendFormat:@"&a[%u]=%@&t[%u]=%@&i[%u]=%i&o[%u]=%@", pos, [[track objectForKey:@"artist"] stringWithURLEncode], 
		 pos, [[track objectForKey:@"title"] stringWithURLEncode],
		 pos, [[track objectForKey:@"startedAt"] integerValue],
		 pos, [[track objectForKey:@"sourceType"] stringWithURLEncode]];
		
		NSString* tmp = [track objectForKey:@"ratingType"];
		[body appendFormat:@"&r[%u]=%@", pos, tmp ? [tmp stringWithURLEncode] : @""];
		
		NSNumber* num = [track objectForKey:@"duration"];
		[body appendFormat:@"&l[%u]=%@", pos, num ? [num stringValue] : @""];
		
		tmp = [track objectForKey:@"album"];
		[body appendFormat:@"&b[%u]=%@", pos, tmp ? [tmp stringWithURLEncode] : @""];
		
		num = [track objectForKey:@"index"];
		[body appendFormat:@"&n[%u]=%i", pos, num ? [num stringValue] : @""];
		
		tmp = [track objectForKey:@"mbid"];
		[body appendFormat:@"&m[%u]=%@", pos, tmp ? [tmp stringWithURLEncode] : @""];
	}
	
	NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:stringQueueSubmitting]];
	
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
	
	NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:NULL error:NULL];
	
	if(!data) {
		NSLog(@"scrOBJc%@ Error: Could not execute the post request for submissing a queue sequence.", [self serviceName]);
		
		[queue addObjectsFromArray:tracks];
		
		[pool drain];
		return NO;
	}
	
	NSString* response = [NSString stringWithData:data encoding:NSUTF8StringEncoding];
	if(!response) {
		NSLog(@"scrOBJc%@ Error: Could not parse response.", [self serviceName]);
		
		[queue addObjectsFromArray:tracks];
		
		[pool drain];
		return NO;
	}
	
	NSArray* comps = [response componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
	
	if([[comps objectAtIndex:0] caseInsensitiveCompare:@"OK"] != NSOrderedSame) {
		NSLog(@"scrOBJc%@ Error: Server returned a failure message: %@", [self serviceName], response);
		NSLog(body);
		[queue addObjectsFromArray:tracks];
		
		[pool drain];
		return NO;
	}
	
	[pool drain];
	return YES;
}

- (void)removeTrackFromQueue:(NSDictionary*)track {
	[queue removeObject:track];
}


- (NSInteger)sequenceLengthForSubmitting {
	NSInteger size = [defaults integerForKey:[NSString stringWithFormat:@"scrOBJc%@SubmissionSize", [self serviceName]]];
	
	if(size < sizeLastFMMinimumQueueSubmission)
		NSLog(@"scrOBJc%@ Warning: Invalid count of tracks for submission. Use instead the default size proposed by the library: %i", [self serviceName], size = sizeLastFMDefaultQueueSubmission);
	else if(size > sizeLastFMMaximumQueueSubmission)
		NSLog(@"scrOBJc%@ Warning: Invalid count of tracks for submission. Use instead the maximum size proposed by the library: %i", [self serviceName], size = sizeLastFMMaximumQueueSubmission);
	if([queue count] >= size)
		return size;
	
	return 0;
}

- (NSArray*)queue {
	return queue;
}

- (void)setQueue:(NSArray*)list {
	[queue release];
	queue = [[NSMutableArray alloc] initWithArray:list];
}
@end
