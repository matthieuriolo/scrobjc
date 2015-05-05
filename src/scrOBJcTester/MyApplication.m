#import "MyApplication.h"

@implementation MyApplication

- (void) awakeFromNib {
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:@"scrOBJcLastFMEnabled"]];
	
	track = nil;
	
	[api setStringValue:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"scrOBJcLastFMAPIKey"]];
	[clientID setStringValue:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"scrOBJcLastFMClientID"]];
	[clientVersion setStringValue:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
}

- (IBAction)addToQueue:(id)sender {
    [track submit];
}

- (IBAction)newTrack:(id)sender {
    if(track) {
		[controller setContent:nil];
		[track release];
	}
	
	track = [[scrOBJcTrack alloc] initWithProtocols:[NSArray arrayWithObject:[scrOBJcLastFMProtocol default]]];
	
	[track setValue:@"1208" forKey:@"artist"];
	[track setValue:@"retire" forKey:@"title"];
	[track setValue:[NSNumber numberWithUnsignedInteger:144] forKey:@"duration"];
	
	[controller setContent:track];
}

- (IBAction)nowPlaying:(id)sender {
    [track currentPlaying];
}


- (id)currentTrack {
	return track;
}


- (IBAction)cleanQueue:(id)sender {
	[[scrOBJcLastFMProtocol default] setQueue:[NSArray array]];
}
@end
