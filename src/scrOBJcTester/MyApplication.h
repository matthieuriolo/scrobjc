#import <Cocoa/Cocoa.h>
#import <scrOBJc/scrOBJc.h>

@interface MyApplication : NSObject {
	IBOutlet id api;
	IBOutlet id clientID;
	IBOutlet id clientVersion;
	
	IBOutlet id controller;
	scrOBJcTrack* track;
}

- (IBAction)addToQueue:(id)sender;
- (IBAction)newTrack:(id)sender;
- (IBAction)nowPlaying:(id)sender;

- (IBAction)cleanQueue:(id)sender;
@end
