#import "DMDesktopManager.h"

#define SECONDS_PER_DAY 86400.0

static DMDesktopManager *sharedDesktopManager = NULL;
static NSDictionary *sharedSettings = NULL;

@interface DMDesktopManager (Private)

#pragma mark Working with the property list file

/*
 The path to the settings plist file.
 */

- (NSString *) settingsPath;

/*
 Returns a dictionary of the settings in the settings plist file.
 */

- (NSDictionary *) settings;

#pragma mark Working with the image sequence

/*
 Returns an array of matching desktop images in the image folder.
 */

- (NSArray *) files;

/*
 Returns the offset of the image to use, given a total number of images, based
 on the time of day.
 */

- (NSUInteger) imageNumber:(NSUInteger)imageCount;

@end

#pragma mark -

@implementation DMDesktopManager

#pragma mark Working with the singleton instance

+ (DMDesktopManager *) manager {
	@synchronized(self) {
		if (!sharedDesktopManager) [[self alloc] init];
	}
	return sharedDesktopManager;
}

+ (id) allocWithZone:(NSZone *)zone {
	@synchronized(self) {
		if (!sharedDesktopManager) {
			sharedDesktopManager = [super allocWithZone:zone];
			return sharedDesktopManager;
		}
	}
	return NULL;
}

+ (id) copyWithZone:(NSZone *)zone {
	return self;
}

- (id) retain {
	return self;
}

- (NSUInteger) retainCount {
	return UINT_MAX;
}

- (void) release {
	// do nothing
}

- (id) autorelease {
	return self;
}

#pragma mark Setting the desktop background

- (void) setBackground {
	NSArray *files = [self files];
	if (!files) return;
	NSUInteger imageNumber = [self imageNumber:[files count]];
	NSString *filename = [files objectAtIndex:imageNumber];
	if (!filename) return;
	
	NSURL *URL = [[NSURL alloc] initFileURLWithPath:filename];
	NSError *error = NULL;
	
	DMScreenSettings screenSetting = [(NSNumber *)[[self settings] objectForKey:DMUserDefaultsKeyDesktopScreens] unsignedIntegerValue];
	if (screenSetting == DMScreenSettingsAllScreens) {
		for (NSScreen *screen in [NSScreen screens])
			[[NSWorkspace sharedWorkspace] setDesktopImageURL:URL forScreen:screen options:[self settings] error:&error];
	}
	else if (screenSetting = DMScreenSettingsMainScreenOnly)
		[[NSWorkspace sharedWorkspace] setDesktopImageURL:URL forScreen:[NSScreen mainScreen] options:[self settings] error:&error];
	[URL release];
	
	if (error) NSLog(@"Error while changing desktop: %@", [error localizedDescription]);
}

@end

#pragma mark -

@implementation DMDesktopManager (Private)

#pragma mark Working with the property list file

- (NSString *) settingsPath {
	return [@"~/Library/Preferences/org.tmorgan.TwentyFourHourMovie.plist" stringByExpandingTildeInPath];
}

- (NSDictionary *) settings {
	if (!sharedSettings) {
		sharedSettings = [NSDictionary dictionaryWithContentsOfFile:[self settingsPath]];
		if (!sharedSettings) sharedSettings = [NSDictionary dictionary];
	}
	return sharedSettings;
}

#pragma mark Working with the image sequence

- (NSArray *) files {
	NSString *directoryPath = [[self settings] objectForKey:DMUserDefaultsKeyImageDirectory];
	if (!directoryPath) {
		NSLog(@"No image path specified in user defaults; not changing desktop.");
		exit(0);
	}
	directoryPath = [directoryPath stringByExpandingTildeInPath];
	
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

- (NSUInteger) imageNumber:(NSUInteger)imageCount {
	NSCalendarDate *now = [[NSCalendarDate alloc] init];
	NSCalendarDate *today = [[NSCalendarDate alloc] initWithYear:[now yearOfCommonEra] month:[now monthOfYear] day:[now dayOfMonth] hour:0 minute:0 second:0 timeZone:[now timeZone]];
	NSUInteger secondsToday = [now timeIntervalSinceDate:today];
	[today release];
	[now release];
	
	return (NSUInteger)((secondsToday/SECONDS_PER_DAY)*imageCount);
}

@end
