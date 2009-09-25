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

#pragma mark Storing and retrieving the image directory

/*!
 @method bookmarkForImageDirectory:
 @abstract Given the path to, or URL for, an image directory, returns bookmark
 data referencing that directory. This data will continue to reference the
 directory even if it is moved or its disk is unmounted. The data can be stored
 in the user defaults.
 @param directory either an @link //apple_ref/occ/cl/NSString NSString @/link
 path or an @link //apple_ref/occ/cl/NSURL NSURL @/link path to a folder.
 @result Bookmark data pointing to the directory.
 @discussion If for some reason the bookmark data could not be created, this
 method will display an alert to the user and return NULL.
 */

- (NSData *) bookmarkForImageDirectory:(id)directory;

/*!
 @method imageDirectoryURLFromBookmark:
 @abstract Given bookmark data created by
 @link bookmarkForImageDirectory: bookmarkForImageDirectory: @/link, this method
 returns an @link //apple_ref/occ/cl/NSURL NSURL @/link instance pointing to the
 bookmarked file.
 @param bookmark The file bookmark data.
 @result The file URL.
 @discussion If the bookmark is stale or the file couldn't be found, an alert is
 displayed to the user and NULL is returned.
 */

- (NSURL *) imageDirectoryURLFromBookmark:(NSData *)bookmark;

/*!
 @method imageDirectoryPathFromBookmark:
 @abstract Calls
 @link imageDirectoryURLFromBookmark: imageDirectoryURLFromBookmark: @/link and
 converts the resulting URL into a file path.
 @param bookmark The file bookmark data.
 @result The file path.
 */

- (NSString *) imageDirectoryPathFromBookmark:(NSData *)bookmark;

#pragma mark Getting information about the image sequence

/*!
 @method imageCount
 @abstract Returns the total number of images in the currently set sequence.
 @result The number of images in the sequence. Returns zero if an error occurs.
 */

- (NSUInteger) imageCount;

/*!
 @method imagesInDirectoryBookmark:
 @abstract Given a bookmark created from
 @link bookmarkForImageDirectory: bookmarkForImageDirectory: @/link, returns an
 array of @link //apple_ref/occ/cl/NSURL NSURLs @/link for each of the images
 within that folder.
 @param bookmark The data for an image directory bookmark.
 @result An array of file URL's for each image in the folder. Returns NULL if an
 error occurs (such as the image directory could not be found).
 */

- (NSArray *) imagesInDirectoryBookmark:(NSData *)bookmark;

@end
