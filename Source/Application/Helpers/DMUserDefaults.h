/*!
 @class DMUserDefaults
 @abstract Assigns default user defaults values upon initialization. Shared
 across the application and helper tool.
 */

@interface DMUserDefaults : NSObject {
	
}

#pragma mark Working with user defaults

/*!
 @method initializeDefaults
 @abstract Assigns user defaults in the registration domain.
 */

+ (void) initializeDefaults;

@end
