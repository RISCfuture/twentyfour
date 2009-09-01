#import "DMLaunchAgentSettings.h"

#define DMLaunchAgentPlistPath @"~/Library/LaunchAgents/org.tmorgan.TwentyFourHourMovie.plist"

@interface DMLaunchAgentSettings (Private)

#pragma mark Working with the property list file

/*
 Returns the absolute path to the launch agent property list file.
 */

- (NSString *) plistPath;

/*
 Returns an NSDictionary representation of the contents of the launch agent
 property list file.
 */

- (NSDictionary *) plistSettings;

/*
 Loads the property list file into the local settings instance variable.
 */

- (void) reloadSettings;

/*
 Returns a set of default values from the property list file.
 */

- (NSDictionary *) defaults;

/*
 Writes out a new property list into the LaunchAgents directory.
 */

- (void) writePlistToFile:(NSDictionary *)settings;

@end

#pragma mark -

@implementation DMLaunchAgentSettings

#pragma mark Properties

@dynamic enabled;
@dynamic period;

#pragma mark Initializing and deallocating

/*
 - Registers this class as an NSTask completion observer.
 - Writes out a default LaunchAgent plist if none has been written.
 */

- (void) awakeFromNib {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskDidTerminate:) name:NSTaskDidTerminateNotification object:NULL];
	
	BOOL directory = NO;
	if ([[NSFileManager defaultManager] fileExistsAtPath:[self plistPath] isDirectory:&directory]) {
		if (directory) {
			// Display an error and quit
			NSAlert *alert = [[NSAlert alloc] init];
			[alert setAlertStyle:NSCriticalAlertStyle];
			[alert setMessageText:NSLocalizedString(@"There is a folder blocking a file I need to create.", NULL)];
			NSString *text = [[NSString alloc] initWithFormat:NSLocalizedString(@"Please move the folder at %@ and restart this program.", @"%@ = path to launch agent plist"), [self plistPath]];
			[alert setInformativeText:text];
			[text release];
			[alert addButtonWithTitle:NSLocalizedString(@"Quit", @"button")];
			[alert setShowsHelp:YES];
			[alert setHelpAnchor:@"folder_blocking"]; //TODO
			[alert runModal];
			[alert release];
			[NSApp terminate:self];
		}
		// otherwise we have our file; do nothing
	}
	else [self writePlistToFile:[self defaults]]; // create the plist file
}

#pragma mark Dynamic properties

/*
 Enables manual observer notification for all properties.
 */

+ (BOOL) automaticallyNotifiesObserversForKey:(NSString *)key {
	BOOL automatic = NO;
	if ([key isEqualToString:@"enabled"]) automatic = NO;
	if ([key isEqualToString:@"period"]) automatic = NO;
	else automatic = [super automaticallyNotifiesObserversForKey:key];
	return automatic;
}

- (BOOL) enabled {
	id disabledObject = [[self plistSettings] objectForKey:@"Disabled"];
	if (!disabledObject || disabledObject == [NSNull null]) return YES;
	else return ![disabledObject boolValue];
}

- (void) setEnabled:(BOOL)newValue {
	[self willChangeValueForKey:@"enabled"];
	// write the new value out to the plist file
	[[NSProcessInfo processInfo] disableSuddenTermination];
	@synchronized (plistSettings) {
		NSMutableDictionary *newSettings = [[NSMutableDictionary alloc] initWithDictionary:[self plistSettings]];
		[newSettings setObject:[NSNumber numberWithBool:(!newValue)] forKey:@"Disabled"];
		[self writePlistToFile:newSettings];
		[newSettings release];
		[self reloadSettings];
	}
	[self didChangeValueForKey:@"enabled"];
	[[NSProcessInfo processInfo] enableSuddenTermination];
	
	// start or stop the launch agent depending on the new value
	[self toggleLaunchAgent:newValue];
}

- (NSNumber *) period {
	return [[self plistSettings] objectForKey:@"StartInterval"];
}

- (void) setPeriod:(NSNumber *)newValue {
	[self willChangeValueForKey:@"period"];
	
	// check if its below the threshold
	if ([newValue unsignedIntegerValue] < DMPeriodThreshold) newValue = [NSNumber numberWithUnsignedInteger:DMPeriodThreshold];
	
	// write the new value out to the plist file
	[[NSProcessInfo processInfo] disableSuddenTermination];
	@synchronized (plistSettings) {
		NSMutableDictionary *newSettings = [[NSMutableDictionary alloc] initWithDictionary:[self plistSettings]];
		[newSettings setObject:newValue forKey:@"StartInterval"];
		[self writePlistToFile:newSettings];
		[newSettings release];
		[self reloadSettings];
	}
	[self didChangeValueForKey:@"period"];
	[[NSProcessInfo processInfo] enableSuddenTermination];
	
	// restart the launch agent if it is running
	if (self.enabled) {
		[self toggleLaunchAgent:NO];
		[self toggleLaunchAgent:YES];
	}
}

#pragma mark Working with the launch agent

- (void) toggleLaunchAgent:(BOOL)enabled {
	NSMutableArray *arguments = [[NSMutableArray alloc] initWithCapacity:3];
	if (enabled) [arguments addObject:@"load"];
	else [arguments addObject:@"unload"];
	[arguments addObject:@"-w"];
	[arguments addObject:[self plistPath]];
	
	[NSTask launchedTaskWithLaunchPath:@"/bin/launchctl" arguments:arguments];
	
	[arguments release];
}

/*
 Called when the launch agent has finished starting or stopping. Updates the
 local cache of the plist settings.
 */

- (void) taskDidTerminate:(NSNotification *)notification {
	if ([[notification object] terminationStatus]) {
//		NSAlert *alert = [[NSAlert alloc] init];
//		[alert setAlertStyle:NSWarningAlertStyle];
//		[alert setMessageText:NSLocalizedString(@"I couldn't activate the launch agent. Your desktop picture will be unchanged.", NULL)];
//		[alert setInformativeText:NSLocalizedString(@"More information might be available from Console.", NULL)];
//		[alert addButtonWithTitle:NSLocalizedString(@"OK", @"button")];
//		[alert setShowsHelp:YES];
//		[alert setHelpAnchor:@"couldnt_activate_launch_agent"]; //TODO
//		[alert runModal];
//		[alert release];
		
		[self willChangeValueForKey:@"enabled"];
		[self willChangeValueForKey:@"period"];
		@synchronized (plistSettings) {
			plistSettings = [NSDictionary dictionaryWithContentsOfFile:[self plistPath]];
		}
		[self didChangeValueForKey:@"enabled"];
		[self didChangeValueForKey:@"period"];
	}
}

@end

#pragma mark -

@implementation DMLaunchAgentSettings (Private)

#pragma mark Working with the property list file

- (NSString *) plistPath {
	if (!plistPath) plistPath = [[DMLaunchAgentPlistPath stringByExpandingTildeInPath] retain];
	return plistPath;
}

- (NSDictionary *) plistSettings {
	if (!plistSettings) {
		[self reloadSettings];
	}
	return plistSettings;
}

- (void) reloadSettings {
	@synchronized (plistSettings) {
		plistSettings = [[NSDictionary dictionaryWithContentsOfFile:[self plistPath]] retain];
		if (!plistSettings) plistSettings = [[self defaults] retain]; // empty dictionary if the file doesn't exist
	}
}

- (NSDictionary *) defaults {
	NSArray *programArguments = [[NSArray alloc] initWithObjects:[DMExecutablePath stringByExpandingTildeInPath], NULL];
	NSDictionary *defaults = [[NSDictionary alloc] initWithObjectsAndKeys:
							  @"org.tmorgan.TwentyFourHourMovie", @"Label",
							  programArguments, @"ProgramArguments",
							  [NSNumber numberWithBool:YES], @"RunAtLoad",
							  [NSNumber numberWithUnsignedInteger:60], @"StartInterval",
							  [NSNumber numberWithBool:YES], @"Disabled",
							  NULL];
	[programArguments release];
	return [defaults autorelease];
}

- (void) writePlistToFile:(NSDictionary *)settings {
	NSString *error = NULL;
	NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:settings format:NSPropertyListXMLFormat_v1_0 errorDescription:&error];
	if (plistData) [plistData writeToFile:[self plistPath] atomically:YES];
	else {
		NSAlert *alert = [[NSAlert alloc] init];
		[alert setAlertStyle:NSCriticalAlertStyle];
		[alert setMessageText:NSLocalizedString(@"I wasn't able to write your settings to a launch agent file.", NULL)];
		[alert setInformativeText:error];
		[alert addButtonWithTitle:NSLocalizedString(@"Quit", @"button")];
		[alert setShowsHelp:YES];
		[alert setHelpAnchor:@"couldnt_write_launchagent_plist"]; //TODO
		[alert runModal];
		[error release];
		[alert release];
		[NSApp terminate:self];
	}
}

@end