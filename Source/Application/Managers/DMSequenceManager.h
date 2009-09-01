/*!
 @class DMSequenceManager
 @abstract Singleton class that provides convenience methods for getting
 information about the image sequence.
 */

@interface DMSequenceManager : NSObject {
	
}

#pragma mark Working with the singleton instance

/*!
 @method sequenceManager
 @abstract Returns the shared instance.
 @result The shared instance.
 */

+ (DMSequenceManager *) sequenceManager;

#pragma mark Getting information about the image sequence

/*!
 @method imageCount
 @abstract Returns the total number of images in the currently set sequence.
 @result The number of images in the sequence.
 */

- (NSUInteger) imageCount;

@end
