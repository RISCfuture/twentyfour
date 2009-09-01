#import "DMPeriodValueTransformer.h"

#define MINUTES 60
#define HOURS 60*MINUTES
#define DAYS 24*HOURS
#define WEEKS 7*DAYS
#define MONTHS 730*HOURS
#define YEARS 365*DAYS

@interface DMPeriodValueTransformer (Private)

#pragma mark Working with periods

/*
 Returns the calculated total time of the sequence in seconds, from the given
 period and the total number of images in the sequence.
 */

- (CGFloat) sequenceLength:(CGFloat)period;

/*
 Given a length of time, quantizes it to one of the values in the
 DMSequenceLength enum.
 */

- (NSUInteger) quantize:(CGFloat)length;

/*
 Given a DMSequenceLength value, returns the length of time in seconds of that
 interval.
 */

- (CGFloat) lengthInSeconds:(DMSequenceLength)length;

/*
 Given a total time for an image sequence, returns the period necessary for each
 image.
 */

- (CGFloat) periodForSequenceLength:(CGFloat)length;

@end

#pragma mark -

@implementation DMPeriodValueTransformer

#pragma mark Transforming values

/*
 This transformer converts between numbers.
 */

+ (Class) transformedValueClass {
	return [NSNumber class];
}

/*
 This is a bi-directional transformer.
 */

+ (BOOL) allowsReverseTransformation {
	return YES;
}

/*
 Converts a period to a menu item index.
 */

- (id) transformedValue:(id)value {
	if (!value) return NULL;
	else return [NSNumber numberWithUnsignedInteger:[self quantize:[self sequenceLength:[(NSNumber *)value floatValue]]]];
}

/*
 Converts a menu item index to a period.
 */

- (id) reverseTransformedValue:(id)value {
	if (!value) return NULL;
	else return [NSNumber numberWithUnsignedInteger:[self periodForSequenceLength:[self lengthInSeconds:[(NSNumber *)value floatValue]]]];
}

@end

#pragma mark -

@implementation DMPeriodValueTransformer (Private)

#pragma mark Working with periods

- (CGFloat) sequenceLength:(CGFloat)period {
	return period*[[DMSequenceManager sequenceManager] imageCount];
}

- (NSUInteger) quantize:(CGFloat)length {
	if (length >= 6.5*MONTHS) return DMSequenceLengthYear; // >= halfway between 1 month and 1 year
	else if (length >= 449*HOURS) return DMSequenceLengthMonth; // >= halfway between 1 week and 1 month
	else if (length >= 4*DAYS) return DMSequenceLengthWeek; // >= halfway between 1 day and 1 week
	else if (length >= 12*HOURS + 30*MINUTES) return DMSequenceLengthDay; // >= halfway between 1 hour and 1 day
	else return DMSequenceLengthHour;
}

- (CGFloat) lengthInSeconds:(DMSequenceLength)length {
	if (length == DMSequenceLengthHour) return 1.0*HOURS;
	else if (length == DMSequenceLengthDay) return 1.0*DAYS;
	else if (length == DMSequenceLengthWeek) return 1.0*WEEKS;
	else if (length == DMSequenceLengthMonth) return 1.0*MONTHS;
	else if (length == DMSequenceLengthYear) return 1.0*YEARS;
	else return 0.0;	
}

- (CGFloat) periodForSequenceLength:(CGFloat)length {
	if (length == 0.0) return 0.0;
	else return length/[[DMSequenceManager sequenceManager] imageCount];
}

@end
