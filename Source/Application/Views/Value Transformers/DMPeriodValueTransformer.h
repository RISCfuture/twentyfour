/*!
 @enum Sequence Lengths
 @abstract Preset total sequence lengths ordered by their appearance in the
 popup menu.
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

/*!
 @class DMPeriodValueTransformer
 @abstract Value transformer that converts a launch period for the desktop
 switching tool into a popup menu item describing the total length of time over
 which the image sequence will be displayed.
 */

@interface DMPeriodValueTransformer : NSValueTransformer {
	
}

@end
