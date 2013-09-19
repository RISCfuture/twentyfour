#import "DMMainWindowController.h"

@implementation DMMainWindowController

#pragma mark Actions

- (IBAction) openDesktopPreferences:(id)sender {
	NSString *scriptPath = [[NSBundle mainBundle] pathForResource:@"OpenDesktopPreferencePane" ofType:@"scpt"];
	NSURL *scriptURL = [[NSURL alloc] initFileURLWithPath:scriptPath];
	NSDictionary *error = NULL;
	NSAppleScript *script = [[NSAppleScript alloc] initWithContentsOfURL:scriptURL error:&error];
	if (script) {
		NSAppleEventDescriptor *result = [script executeAndReturnError:&error];
		if (!result) NSBeep();
	}
	else NSBeep();
	
	[script release];
	[scriptURL release];
}

- (IBAction) openHelp:(id)sender {
	NSString *helpBook = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleHelpBookName"];
	if (launchAgentSettings.enabled) [[NSHelpManager sharedHelpManager] openHelpAnchor:@"settings" inBook:helpBook]; //TODO
	else [[NSHelpManager sharedHelpManager] openHelpAnchor:@"setting_desktop" inBook:helpBook]; //TODO
}

- (IBAction) chooseFolder:(id)sender {
	NSOpenPanel *panel = [NSOpenPanel openPanel];
	[panel setCanChooseFiles:NO];
	[panel setCanChooseDirectories:YES];
	[panel setCanCreateDirectories:YES];
	[panel setAllowsMultipleSelection:NO];
    
    [panel beginSheetModalForWindow:window completionHandler:^(NSInteger returnCode) {
        if (returnCode != NSFileHandlingPanelOKButton) return;
        if ([[panel URLs] count] == 0) return;
        
        NSData *bookmark = [[DMSequenceManager sequenceManager] bookmarkForImageDirectory:[[panel URLs] objectAtIndex:0]];
        if (bookmark) {
            [[NSUserDefaults standardUserDefaults] setObject:bookmark forKey:DMUserDefaultsKeyImageDirectory];
            [launchAgentSettings toggleLaunchAgent:NO];
            [launchAgentSettings toggleLaunchAgent:YES];
        }
    }];
}

@end
