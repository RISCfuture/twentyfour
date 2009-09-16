/*!
 @class DMLaunchAgentSettings
 @abstract A class that supports reading from and writing to the Launch Agent
 property list file stored in ~/Library/LaunchAgents. Implements KVO to support
 Cocoa Bindings.
 */

@interface DMLaunchAgentSettings : NSObject {
	NSDictionary *plistSettings;
	NSString *plistPath;
}

#pragma mark Properties

/*!
 @property enabled
 @abstract YES if the launch agent is enabled; NO if it is not.
 @discussion This is a dynamic property whose value is taken from the property
 list file or its existence.
 */

@property (assign) BOOL enabled;

#pragma mark Working with the launch agent

/*!
 @method toggleLaunchAgent:
 @abstract Enables or disables the launch agent.
 @param enabled YES to enable or NO to disable the launch agent.
 */

- (void) toggleLaunchAgent:(BOOL)enabled;

@end
