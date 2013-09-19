#import "DMSequenceManager.h"

static DMSequenceManager *sharedSequenceManager = NULL;

@interface DMSequenceManager (Private)

/*
 Superset of functionality imageDirectoryURLFromBookmark: with the option to
 suppress the NSAlert.
 */

- (NSURL *) imageDirectoryURLFromBookmark:(NSData *)bookmark withAlert:(BOOL)alert;

@end

#pragma mark -

@implementation DMSequenceManager

#pragma mark Working with the singleton instance

+ (DMSequenceManager *) sequenceManager {
	@synchronized (self) {
		if (!sharedSequenceManager) [[self alloc] init]; // assignment not done here
	}
	return sharedSequenceManager;
}

/*
 Only allow memory for this class to be allocated once. The first time it is
 allocated, assign the static variable. On future attempts, disallow allocation.
 */

+ (id) allocWithZone:(NSZone *)zone {
	@synchronized (self) {
		if (!sharedSequenceManager) {
			sharedSequenceManager = [super allocWithZone:zone];
			return sharedSequenceManager;
			// assign and return on first allocation
		}
	}
	return NULL; // do not allow subsequent allocation attempts
}

/*
 Do not allow this class to be copied.
 */

- (id) copyWithZone:(NSZone *)zone {
	return self;
}

/*
 Do not allow this class to be memory managed.
 */

- (id) retain {
	return self;
}

/*
 Do not allow this class to be memory managed.
 */

- (NSUInteger) retainCount {
	return UINT_MAX; // denotes that an object cannot be released
}

/*
 Do not allow this class to be memory managed.
 */

- (oneway void) release {
	// do nothing
}

/*
 Do not allow this class to be memory managed.
 */

- (id) autorelease {
	return self;
}

#pragma mark Storing and retrieving the image directory

- (NSData *) bookmarkForImageDirectory:(id)directory {
	NSURL *directoryURL;
	if ([directory isKindOfClass:[NSString class]]) directoryURL = [[NSURL alloc] initFileURLWithPath:directory isDirectory:YES];
	else if ([directory isKindOfClass:[NSURL class]]) directoryURL = [directory retain];
	else [[NSException exceptionWithName:NSInvalidArgumentException reason:@"bookmarkForImageDirectory: must take an NSURL or NSString" userInfo:NULL] raise];
	
	NSError *error = NULL;
	NSData *bookmark = [directoryURL bookmarkDataWithOptions:0 includingResourceValuesForKeys:NULL relativeToURL:NULL error:&error];
	[directoryURL release];
	
	if (error) {
		NSAlert *alert = [[NSAlert alloc] init];
		[alert setAlertStyle:NSWarningAlertStyle];
		[alert setMessageText:NSLocalizedString(@"I wasn't able to change your image sequence folder. Please choose a different folder.", NULL)];
		[alert setInformativeText:[error localizedDescription]];
		[alert addButtonWithTitle:NSLocalizedString(@"OK", @"button")];
		[alert runModal];
		[alert release];
		return NULL;
	}
	
	[directory release];
	return bookmark;
}

- (NSURL *) imageDirectoryURLFromBookmark:(NSData *)bookmark {
	return [self imageDirectoryURLFromBookmark:bookmark withAlert:YES];
}

- (NSString *) imageDirectoryPathFromBookmark:(NSData *)bookmark {
	return [[self imageDirectoryURLFromBookmark:bookmark] path];
}

#pragma mark Getting information about the image sequence

- (NSUInteger) imageCount {
	NSArray *files = [self imagesInDirectoryBookmark:([[NSUserDefaults standardUserDefaults] objectForKey:DMUserDefaultsKeyImageDirectory])];
	if (!files) return 0;
	return [files count];
}

- (NSArray *) imagesInDirectoryBookmark:(NSData *)bookmark {
	NSURL *directoryURL = [self imageDirectoryURLFromBookmark:bookmark withAlert:NO];
	if (!directoryURL) return NULL;
	
	NSError *error = NULL;
	NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:directoryURL includingPropertiesForKeys:NULL options:(NSDirectoryEnumerationSkipsPackageDescendants|NSDirectoryEnumerationSkipsHiddenFiles) error:&error];
	if (error || !files) return NULL;
	
	NSMutableArray *matchingFiles = [[NSMutableArray alloc] initWithCapacity:[files count]];
	for (NSURL *file in files) {
		if (![[NSImage imageFileTypes] containsObject:[file pathExtension]]) continue;
		[matchingFiles addObject:file];
	}
	
	return [matchingFiles autorelease];
}

@end

#pragma mark -

@implementation DMSequenceManager (Private)

- (NSURL *) imageDirectoryURLFromBookmark:(NSData *)bookmark withAlert:(BOOL)alert {
	BOOL isStale = NO;
	NSError *error = NULL;
	NSURL *imageDirectoryURL = [NSURL URLByResolvingBookmarkData:bookmark options:0 relativeToURL:NULL bookmarkDataIsStale:&isStale error:&error];
	if (isStale) {
		if (alert) {
			NSAlert *alert = [[NSAlert alloc] init];
			[alert setAlertStyle:NSWarningAlertStyle];
			[alert setMessageText:NSLocalizedString(@"Your image sequence folder can no longer be found.", NULL)];
			[alert setInformativeText:NSLocalizedString(@"You will have to choose a different image sequence folder.", @"NULL")];
			[alert addButtonWithTitle:NSLocalizedString(@"OK", @"button")];
			[alert runModal];
			[alert release];
		}
		return NULL;
	}
	else if (error) {
		if (alert) {
			NSAlert *alert = [[NSAlert alloc] init];
			[alert setAlertStyle:NSWarningAlertStyle];
			[alert setMessageText:NSLocalizedString(@"I wasn't able to find your image sequence folder. Please choose a different folder.", NULL)];
			[alert setInformativeText:[error localizedDescription]];
			[alert addButtonWithTitle:NSLocalizedString(@"OK", @"button")];
			[alert runModal];
			[alert release];			
		}
		return NULL;
	}
	else return imageDirectoryURL;
}

@end
