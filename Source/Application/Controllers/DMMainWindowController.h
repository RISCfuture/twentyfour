/*!
 @class DMFrontEndHelper
 @abstract Helper methods and actions for the main window of the application.
 */

@interface DMMainWindowController : NSObject {
	IBOutlet DMLaunchAgentSettings *launchAgentSettings;
	IBOutlet NSWindow *window;
}

#pragma mark Actions

/*!
 @method openDesktopPreferences:
 @abstract Launches System Preferences and opens the Desktop & Screen Saver
 preference pane.
 @param sender The object that initiated the action.
 */

- (IBAction) openDesktopPreferences:(id)sender;

/*!
 @method openHelp:
 @abstract Opens a relevant help page.
 @param sender The object that initiated the action.
 @discussion The help page opened will be dependent on whether or not the
 feature is enabled.
 */

- (IBAction) openHelp:(id)sender;

/*!
 @method chooseFolder:
 @abstract Displays a dialog where a folder containing an image sequence can be
 chosen.
 @param sender The object that initiated the action.
 */

- (IBAction) chooseFolder:(id)sender;

@end
