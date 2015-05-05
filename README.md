# scrOBJc

**imported from https://code.google.com/p/scrobjc/admin**


scrOBJc is an easy to use library for scrobbling. Currently the scrobbling system of [Last.FM](http://www.last.fm) and [Libre.FM](http://www.libre.fm) are supported.

The idea was to create a cocoa framework with following goals:

## Easy to use
```objective-c
//initialize a new track
scrOBJcTrack`*` newTrack = [[scrOBJcTrack alloc] init];

/*
submit the "now playing" and tell the framework that the track is started to play
(will count for us the played time - use pausePlaying if the sound is paused)
*/

[[track currentPlaying] startPlaying];


//configure the track with key-value coding

[track setValue:@"Band name" forKey:@"artist"];

//will add the informations to the queue and submit the queue if needed
[track submit];

//delete the track
[track release];
```


## Multiple scrobbling systems

Last.FM seems to work fine. Libre.FM is untested! But they should use the same system.

## Without CURL!

Cocoa contains everything that is needed to submit the informations! Why should we use an extern library?! NSURLConnection uses automatically the proxy settings in the preferences panel. Why making the stuff more complicated than it is already?!


