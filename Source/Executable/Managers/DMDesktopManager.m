#import "DMDesktopManager.h"

#define SECONDS_PER_DAY 86400.0

static DMDesktopManager *sharedDesktopManager = NULL;
static NSDictionary *sharedSettings = NULL;

@interface DMDesktopManager (Private)

#pragma mark Working with the image sequence

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
	
	NSArray *files = [[DMSequenceManager sequenceManager] imagesInDirectoryBookmark:[defaults objectForKey:DMUserDefaultsKeyImageDirectory]];
	if (!files) {
		NSLog(@"Couldn't load the images in your image sequence folder; not changing desktop.");
		[desktopOptions release];
		[defaults release];
		return;
	}
	
	DMSequenceLength sequenceLength = [(NSNumber *)[defaults objectForKey:DMUserDefaultsKeyPeriod] integerValue];
	
	NSUInteger imageNumber = [self imageNumber:[files count] forSequenceLength:sequenceLength];
	NSURL *URL = [files objectAtIndex:imageNumber];
	NSError *error = NULL;
	
	DMScreenSettings screenSetting = [(NSNumber *)[defaults objectForKey:DMUserDefaultsKeyDesktopScreens] unsignedIntegerValue];
	if (screenSetting == DMScreenSettingsAllScreens) {
		for (NSScreen *screen in [NSScreen screens])
			[[NSWorkspace sharedWorkspace] setDesktopImageURL:URL forScreen:screen options:desktopOptions error:&error];
	}
	else if (screenSetting == DMScreenSettingsMainScreenOnly)
		[[NSWorkspace sharedWorkspace] setDesktopImageURL:URL forScreen:[NSScreen mainScreen] options:desktopOptions error:&error];
	
	if (error) NSLog(@"Error while changing desktop: %@", [error localizedDescription]);
	
	[desktopOptions release];
	[defaults release];
}

@end

#pragma mark -

@implementation DMDesktopManager (Private)

#pragma mark Working with the image sequence

- (NSUInteger) imageNumber:(NSUInteger)imageCount forSequenceLength:(DMSequenceLength)sequenceLength {
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *start = NULL;
	switch (sequenceLength) {
		case DMSequenceLengthHour:
			start = [calendar components:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit) fromDate:[NSDate date]];
			break;
		case DMSequenceLengthWeek:
			start = [calendar components:(NSYearCalendarUnit|NSWeekCalendarUnit) fromDate:[NSDate date]];
			break;
		case DMSequenceLengthMonth:
			start = [calendar components:(NSYearCalendarUnit|NSMonthCalendarUnit) fromDate:[NSDate date]];
			break;
		case DMSequenceLengthYear:
			start = [calendar components:(NSYearCalendarUnit) fromDate:[NSDate date]];
			break;
		default: // DMSequenceLengthDay
			start = [calendar components:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:[NSDate date]];
			break;
	}
	NSDateComponents *end = [[NSDateComponents alloc] init];
	switch (sequenceLength) {
		case DMSequenceLengthHour:
			end.hour = 1;
			break;
		case DMSequenceLengthWeek:
			end.week = 1;
			break;
		case DMSequenceLengthMonth:
			end.month = 1;
			break;
		case DMSequenceLengthYear:
			end.year = 1;
			break;
		default: // DMSequenceLengthDay
			end.day = 1;
			break;
	}
	
	NSDate *startTime = [calendar dateFromComponents:start];
	NSDate *endTime = [calendar dateByAddingComponents:end toDate:startTime options:NULL];
	[end release];
	[calendar release];
	
	NSTimeInterval secondsSoFar = [[NSDate date] timeIntervalSinceDate:startTime];
	NSTimeInterval totalSeconds = [endTime timeIntervalSinceDate:startTime];
	
	return (NSUInteger)((secondsSoFar/totalSeconds)*imageCount);
}

@end
