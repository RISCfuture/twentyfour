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
	
	[panel beginSheetForDirectory:NULL file:NULL modalForWindow:window modalDelegate:self didEndSelector:@selector(openPanelDidEnd:returnCode:contextInfo:) contextInfo:NULL];
}

#pragma mark Open panel delegate

/*
 Sets the image directory to the folder returned by the open panel.
 */

- (void) openPanelDidEnd:(NSOpenPanel *)panel returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
	if (returnCode != NSOKButton) return;
	if ([[panel filenames] count] == 0) return;
	
	NSData *bookmark = [[DMSequenceManager sequenceManager] bookmarkForImageDirectory:[[panel filenames] objectAtIndex:0]];
	if (bookmark) {
		[[NSUserDefaults standardUserDefaults] setObject:bookmark forKey:DMUserDefaultsKeyImageDirectory];
		[launchAgentSettings toggleLaunchAgent:NO];
		[launchAgentSettings toggleLaunchAgent:YES];
	}
}

@end
