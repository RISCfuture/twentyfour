#define DMPeriodThreshold 30

#pragma mark User defaults keys

/*!
 @const DMUserDefaultsKeyImageDirectory
 @abstract The user defaults key whose value is the directory in which the image
 sequence is located.
 */

NSString *DMUserDefaultsKeyImageDirectory;

/*!
 @const DMUserDefaultsKeyDesktopScreens
 @abstract The user defaults key whose value indicates which screens the desktop
 should be applied to. The value is taken from the
 @link DMScreenSettings DMScreenSettings @/link enumeration.
 */

NSString *DMUserDefaultsKeyDesktopScreens;

/*!
 @enum DMScreenSettings
 @abstract Possible screens onto which the desktop can be applied.
 @const DMScreenSettingsMainScreenOnly Apply the desktop to the main screen
 only.
 @const DMScreenSettingsAllScreens Apply the desktop to every screen.
 */

typedef enum _DMScreenSettings {
	DMScreenSettingsMainScreenOnly = 0,
	DMScreenSettingsAllScreens
} DMScreenSettings;


#pragma mark Executable

/*!
 @const DMExecutablePath
 @abstract The relative location where the twentyfour executable will be
 installed (using "~" to represent the user's home directory).
 */

NSString *DMExecutablePath;

#pragma mark Exceptions

/*!
 @const DMExceptionDictionaryMustBePerfect
 @abstract Raised by
 @link DMReversibleMappingValueTransformer DMReversibleMappingValueTransformer @/link
 if given a dictionary that is not symmetrically perfect.
 */

NSString *DMExceptionDictionaryMustBePerfect;
