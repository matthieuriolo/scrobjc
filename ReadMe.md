#Explains in short how to use the library

# Integrating in your application #

You have to build a new _Copy build phase_ with the location _Frameworks_. Put the compiled framework into this build phase.




**Add to your info.plist following tokens:**

scrOBJcLastFMClientID and/or scrOBJcLibreFMClientID.

Your application must have an unique identifier. You have to ask the Last.FM/Libre.FM people for one.


**Make sure that the NSUserDefaults contains following tokens:**

scrOBJcLastFMEnabled - BOOL

scrOBJcLastFMUsername - NSString

scrOBJcLastFMPassword - NSString (not hashed!)


optional scrOBJcLastFMQueueSize - NSInteger


The same for Libre.FM...


**The track must contain following informations:**

artist - NSString - the band/group name

title - NSString - the name of the sound

duration - NSInteger - duration of the sound in seconds


optional:
startedAt - NSInteger - Unixtimestamp (will be set for you)

album - NSString - the album name

index - NSInteger - position on the album

mbid - NSString - Musicbrain Identifier

ratingType - NSString - (L)ove | (B)an | (S)kip

...


# Last.FM version 1.2! #
Right now the protocol version 1.2 is supported! Not the new one!

[Protocol 1.2.1](http://www.last.fm/api/submissions)