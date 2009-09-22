#import "DMStartup.h"

@interface DMStartup (Private)

#pragma mark Working with the executable

/*
 Creates the Application Support subfolder for this program if it doesn't exist.
 */

- (void) createApplicationSupportFolder;

/*
 Installs the twentyfour executable into the Application Support directory if
 it has not yet been installed. Also checks if the executable needs to be
 updated.
 */

- (void) installOrUpdateExecutable;

/*
 Checks if the executable needs to be updated, and overwrites it if it does.
 */

- (void) checkExistingExecutableFile;

/*
 Copies the executable in the application's bundle to the application support
 subfolder.
 */

- (void) installExecutable;

@end

#pragma mark -

@implementation DMStartup

#pragma mark Initialization and deallocation

/*
 Initializes value transformers.
 */

+ (void) initialize {
	[DMUserDefaults initializeDefaults];
	
	[NSValueTransformer setValueTransformer:[[[DMFileNameValueTransformer alloc] init] autorelease] forName:@"DMFileName"];
	[NSValueTransformer setValueTransformer:[[[DMFileIconValueTransformer alloc] init] autorelease] forName:@"DMFileIcon"];
	[NSValueTransformer setValueTransformer:[[[DMPeriodNotTooSmallValueTransformer alloc] init] autorelease] forName:@"DMPeriodTooSmall"];
	NSDictionary *imageScalingPopupMappings = [[NSDictionary alloc] initWithObjectsAndKeys:
											   [NSNumber numberWithUnsignedInteger:0], [NSNumber numberWithUnsignedInteger:NSImageScaleNone],
											   [NSNumber numberWithUnsignedInteger:1], [NSNumber numberWithUnsignedInteger:NSImageScaleProportionallyUpOrDown],
											   [NSNumber numberWithUnsignedInteger:2], [NSNumber numberWithUnsignedInteger:NSImageScaleAxesIndependently],
											   NULL];
	[NSValueTransformer setValueTransformer:[[[DMReversibleMappingValueTransformer alloc] initWithDictionary:imageScalingPopupMappings] autorelease] forName:@"DMDesktopScaling"];
	[imageScalingPopupMappings release];
}

/*
 Initialize Application Support directory.
 */

- (void) awakeFromNib {
	executablePath = [DMExecutablePath stringByExpandingTildeInPath];
	[self createApplicationSupportFolder];
	[self installOrUpdateExecutable];
}

@end

#pragma mark -

@implementation DMStartup (Private)

#pragma mark Working with the executable

- (void) createApplicationSupportFolder {
	NSString *path = [executablePath stringByDeletingLastPathComponent];
	BOOL directory;
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&directory]) {
		if (!directory) {
			// there's a file in the way of where we want the Application Support subfolder to go
			NSAlert *alert = [[NSAlert alloc] init];
			[alert setAlertStyle:NSCriticalAlertStyle];
			[alert setMessageText:NSLocalizedString(@"There is a file blocking a folder I need to create.", NULL)];
			NSString *text = [[NSString alloc] initWithFormat:NSLocalizedString(@"Please move the %@ file.", @"%@ = file blocking a folder path"), path];
			[alert setInformativeText:text];
			[text release];
			[alert addButtonWithTitle:NSLocalizedString(@"Quit", @"button")];
			[alert setShowsHelp:YES];
			[alert setHelpAnchor:@"file_blocking"]; //TODO
			[alert runModal];
			[alert release];
			[NSApp terminate:self];
		}
	}
	else {
		// create the folder
		NSError *error = NULL;
		[[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:NULL error:&error];
		if (error) {
			NSAlert *alert = [[NSAlert alloc] init];
			[alert setAlertStyle:NSCriticalAlertStyle];
			NSString *text = [[NSString alloc] initWithFormat:NSLocalizedString(@"I couldn't create the %@ folder. I need to be able to create this folder to continue.", @"%@ = folder path"), path];
			[alert setMessageText:text];
			[text release];
			[alert setInformativeText:[error localizedDescription]];
			[alert addButtonWithTitle:NSLocalizedString(@"Quit", @"button")];
			[alert runModal];
			[alert release];
			[NSApp terminate:self];
		}
	}
}

- (void) installOrUpdateExecutable {
	BOOL directory;
	if ([[NSFileManager defaultManager] fileExistsAtPath:executablePath isDirectory:&directory]) {
		if (directory) {
			// there is a folder blocking where we want twentyfour to go
			NSAlert *alert = [[NSAlert alloc] init];
			[alert setAlertStyle:NSCriticalAlertStyle];
			[alert setMessageText:NSLocalizedString(@"There is a folder blocking a file I need to create.", NULL)];
			NSString *text = [[NSString alloc] initWithFormat:NSLocalizedString(@"Please move the folder at %@.", @"%@ = folder blocking a file"), DMExecutablePath];
			[alert setInformativeText:text];
			[text release];
			[alert addButtonWithTitle:NSLocalizedString(@"Quit", @"button")];
			[alert setShowsHelp:YES];
			[alert setHelpAnchor:@"folder_blocking"]; //TODO
			[alert runModal];
			[alert release];
			[NSApp terminate:self];
		}
		else {
			[self checkExistingExecutableFile];
		}
	}
	else {
		[self installExecutable];
	}
}

- (void) checkExistingExecutableFile {
	NSError *error = NULL;
	NSData *ourExecutable = [[NSData alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForAuxiliaryExecutable:@"twentyfour"] options:NSUncachedRead error:&error];
	if (error) {
		NSLog(@"Couldn't load the data for the reference twentyfour executable: %@", [error localizedDescription]);
		return;
	}
	
	NSData *wildExecutable = [[NSData alloc] initWithContentsOfFile:executablePath options:NSUncachedRead error:&error];
	if (error) {
		NSLog(@"Couldn't load the data for the installed twentyfour executable: %@", [error localizedDescription]);
		return;
	}
	
	if (![ourExecutable isEqualToData:wildExecutable]) {
		[[NSFileManager defaultManager] removeItemAtPath:executablePath error:&error];
		if (error) {
			NSLog(@"Couldn't remove the old twentyfour executable: %@", [error localizedDescription]);
			return;
		}
		[self installExecutable];
	}
	[ourExecutable release];
	[wildExecutable release];
}

- (void) installExecutable {
	NSError *error = NULL;
	[[NSFileManager defaultManager] copyItemAtPath:[[NSBundle mainBundle] pathForAuxiliaryExecutable:@"twentyfour"] toPath:executablePath error:&error];
	if (error) {
		// there is a folder blocking where we want twentyfour to go
		NSAlert *alert = [[NSAlert alloc] init];
		[alert setAlertStyle:NSCriticalAlertStyle];
		[alert setMessageText:NSLocalizedString(@"I couldn't install the helper application into this program's Application Support folder. I must be able to do so to continue.", NULL)];
		[alert setInformativeText:[error localizedDescription]];
		[alert addButtonWithTitle:NSLocalizedString(@"Quit", @"button")];
		[alert setShowsHelp:YES];
		[alert setHelpAnchor:@"helper_install_failed"]; //TODO
		[alert runModal];
		[alert release];
		[NSApp terminate:self];
	}
}

@end
