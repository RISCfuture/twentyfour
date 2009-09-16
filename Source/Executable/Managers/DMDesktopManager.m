#import "DMDesktopManager.h"

#define SECONDS_PER_DAY 86400.0

static DMDesktopManager *sharedDesktopManager = NULL;
static NSDictionary *sharedSettings = NULL;

@interface DMDesktopManager (Private)

#pragma mark Working with the image sequence

/*
 Returns an array of matching desktop images in the image folder.
 */

- (NSArray *) files:(NSString *)directoryPath;

/*
 Returns the offset of the image to use, given a total number of images, based
 on the progress through a given sequence length.
 */

- (NSUInteger) imageNumber:(NSUInteger)imageCount forSequenceLength:(DMSequenceLength)sequenceLength;

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
	[DMUserDefaults initializeDefaults];
	NSMutableDictionary *defaults = [[NSMutableDictionary alloc] initWithDictionary:[[NSUserDefaults standardUserDefaults] volatileDomainForName:NSRegistrationDomain]];
	[defaults addEntriesFromDictionary:[[NSUserDefaults standardUserDefaults] persistentDomainForName:@"org.tmorgan.TwentyFourHourMovie"]];
	NSArray *keys = [[NSArray alloc] initWithObjects:NSWorkspaceDesktopImageScalingKey, NSWorkspaceDesktopImageAllowClippingKey, NSWorkspaceDesktopImageFillColorKey, NULL];
	NSMutableDictionary *desktopOptions = [[NSMutableDictionary alloc] initWithDictionary:[defaults dictionaryWithValuesForKeys:keys]];
	[keys release];
	NSData *colorData = [desktopOptions objectForKey:NSWorkspaceDesktopImageFillColorKey];
	if (colorData) [desktopOptions setObject:[NSUnarchiver unarchiveObjectWithData:colorData] forKey:NSWorkspaceDesktopImageFillColorKey];
	
	NSArray *files = [self files:[defaults objectForKey:DMUserDefaultsKeyImageDirectory]];
	if (!files) return;
	
	DMSequenceLength sequenceLength = [(NSNumber *)[defaults objectForKey:DMUserDefaultsKeyPeriod] integerValue];
	
	NSUInteger imageNumber = [self imageNumber:[files count] forSequenceLength:sequenceLength];
	NSString *filename = [files objectAtIndex:imageNumber];
	if (!filename) return;
	
	NSURL *URL = [[NSURL alloc] initFileURLWithPath:filename];
	NSError *error = NULL;
	
	DMScreenSettings screenSetting = [(NSNumber *)[defaults objectForKey:DMUserDefaultsKeyDesktopScreens] unsignedIntegerValue];
	if (screenSetting == DMScreenSettingsAllScreens) {
		for (NSScreen *screen in [NSScreen screens])
			[[NSWorkspace sharedWorkspace] setDesktopImageURL:URL forScreen:screen options:desktopOptions error:&error];
	}
	else if (screenSetting == DMScreenSettingsMainScreenOnly)
		[[NSWorkspace sharedWorkspace] setDesktopImageURL:URL forScreen:[NSScreen mainScreen] options:desktopOptions error:&error];
	[URL release];
	
	if (error) NSLog(@"Error while changing desktop: %@", [error localizedDescription]);
	
	[defaults release];
}

@end

#pragma mark -

@implementation DMDesktopManager (Private)

#pragma mark Working with the image sequence

- (NSArray *) files:(NSString *)directoryPath {
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

- (NSUInteger) imageNumber:(NSUInteger)imageCount forSequenceLength:(DMSequenceLength)sequenceLength {
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *current = [calendar components:(NSYearCalendarUnit|NSMonthCalendarUnit|NSWeekCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit) fromDate:[NSDate date]];
	NSDateComponents *start = [[NSDateComponents alloc] init];
	[start setEra:[current era]];
	[start setYear:[current year]];
	[start setMinute:0];
	[start setSecond:0];
	switch (sequenceLength) {
		case DMSequenceLengthHour:
			[start setMonth:[current month]];
			[start setDay:[current day]];
			[start setHour:[current hour]];
			break;
		case DMSequenceLengthWeek:
			[start setWeekday:1];
			[start setWeekdayOrdinal:[current weekdayOrdinal]];
			[start setHour:0];
			break;
		case DMSequenceLengthMonth:
			[start setMonth:[current month]];
			[start setDay:1];
			[start setHour:0];
			break;
		case DMSequenceLengthYear:
			[start setMonth:0];
			[start setDay:0];
			[start setHour:0];
			break;
		default: // DMSequenceLengthDay
			[start setMonth:[current month]];
			[start setDay:[current day]];
			[start setHour:0];
			break;
	}
	
	NSTimeInterval secondsSoFar = [[NSDate date] timeIntervalSinceDate:[calendar dateFromComponents:start]];
	NSTimeInterval totalSeconds = DMTimeIntervalForSequenceLength(sequenceLength);
	
	[start release];
	[calendar release];
	
	return (NSUInteger)((secondsSoFar/totalSeconds)*imageCount);
}

@end
