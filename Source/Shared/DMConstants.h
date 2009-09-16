#pragma mark Preprocessor directives

#define DMLaunchDaemonInterval 2*60

#define MINUTES 60
#define HOURS 60*MINUTES
#define DAYS 24*HOURS
#define WEEKS 7*DAYS
#define MONTHS 730*HOURS
#define YEARS 365*DAYS
#define DMTimeIntervalForSequenceLength(var) \
	(var == DMSequenceLengthHour ? 1*HOURS : \
	(var == DMSequenceLengthDay ? 1*DAYS : \
	(var == DMSequenceLengthWeek ? 1*WEEKS : \
	(var == DMSequenceLengthMonth ? 1*MONTHS : \
	(var == DMSequenceLengthYear ? 1*YEARS : 1*DAYS \
	)))))

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
 @enum DMUserDefaultsKeyPeriod
 @abstract The total length of the sequence in seconds.
 */

NSString *DMUserDefaultsKeyPeriod;

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

#pragma mark Enumerations

/*!
 @enum Sequence Lengths
 @abstract Preset total sequence lengths ordered by their appearance in the
 popup menu and representing their use for the user defaults key
 @link DMUserDefaultsKeyPeriod DMUserDefaultsKeyPeriod @/link.
 @constant DMSequenceLengthHour One hour.
 @constant DMSequenceLengthDay One calendar day.
 @constant DMSequenceLengthWeek One calendar week.
 @constant DMSequenceLengthMonth One calendar month (length based on the current
 month).
 @constant DMSequenceLengthYear One calendar year.
 */

typedef enum _DMSequenceLength {
	DMSequenceLengthHour = 0,
	DMSequenceLengthDay,
	DMSequenceLengthWeek,
	DMSequenceLengthMonth,
	DMSequenceLengthYear
} DMSequenceLength;
