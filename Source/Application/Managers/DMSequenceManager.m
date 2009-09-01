#import "DMSequenceManager.h"

static DMSequenceManager *sharedSequenceManager = NULL;

@interface DMSequenceManager (Private)

#pragma mark Image files

/*
 Returns an array of matching desktop images in the image folder.
 */

- (NSArray *) files;

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

- (void) release {
	// do nothing
}

/*
 Do not allow this class to be memory managed.
 */

- (id) autorelease {
	return self;
}

#pragma mark Getting information about the image sequence

- (NSUInteger) imageCount {
	return [[self files] count];
}

@end

#pragma mark -

@implementation DMSequenceManager (Private)

#pragma mark Image files

- (NSArray *) files {
	NSString *directoryPath = [[[NSUserDefaults standardUserDefaults] objectForKey:DMUserDefaultsKeyImageDirectory] stringByExpandingTildeInPath];
	NSError *error = NULL;
	NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:&error];
	if (error || !files) return NULL;
	
	NSMutableArray *matchingFiles = [[NSMutableArray alloc] initWithCapacity:[files count]];
	for (NSString *file in files) {
		if (![[NSImage imageFileTypes] containsObject:[file pathExtension]]) continue;
		[matchingFiles addObject:[directoryPath stringByAppendingPathComponent:file]];
	}
	
	return [matchingFiles autorelease];
}

@end
