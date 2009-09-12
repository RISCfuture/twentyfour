#import "DMUserDefaults.h"

@implementation DMUserDefaults

#pragma mark Working with user defaults

+ (void) initializeDefaults {
	NSDictionary *defaults = [[NSDictionary alloc] initWithObjectsAndKeys:
							  [NSNumber numberWithUnsignedInteger:NSImageScaleProportionallyUpOrDown], NSWorkspaceDesktopImageScalingKey,
							  [NSNumber numberWithBool:NO], NSWorkspaceDesktopImageAllowClippingKey,
							  [NSArchiver archivedDataWithRootObject:[NSColor blackColor]], NSWorkspaceDesktopImageFillColorKey,
							  [NSNumber numberWithUnsignedInteger:DMScreenSettingsMainScreenOnly], DMUserDefaultsKeyDesktopScreens,
							  NULL];
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
	[defaults release];
}

@end
