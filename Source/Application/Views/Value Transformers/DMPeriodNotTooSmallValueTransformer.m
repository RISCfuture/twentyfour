#import "DMPeriodNotTooSmallValueTransformer.h"

@interface DMPeriodNotTooSmallValueTransformer (Private)

#pragma mark Working with periods

/*
 Returns the calculated amount of time between image changes necessary to make
 the current number of images in the image directory last the total length of
 the image sequence.
 */

- (CGFloat) launchIntervalForSequenceLength:(NSTimeInterval)sequenceLength;

@end

#pragma mark -

@implementation DMPeriodNotTooSmallValueTransformer

#pragma mark Transforming values

/*
 This transformer converts between numbers.
 */

+ (Class) transformedValueClass {
	return [NSNumber class];
}

/*
 This is a one-directional transformer.
 */

+ (BOOL) allowsReverseTransformation {
	return NO;
}

/*
 Returns true if a number is below the threshold.
 */

- (id) transformedValue:(id)value {
	if (!value) return [NSNumber numberWithBool:NO];
	NSTimeInterval sequenceLength = DMTimeIntervalForSequenceLength([(NSNumber *)value integerValue]);
	return [NSNumber numberWithBool:([self launchIntervalForSequenceLength:sequenceLength] > DMLaunchDaemonInterval)];
}

@end

#pragma mark -

@implementation DMPeriodNotTooSmallValueTransformer (Private)

#pragma mark Working with periods

- (CGFloat) launchIntervalForSequenceLength:(NSTimeInterval)sequenceLength {
	if (sequenceLength == 0) return 0.0;
	NSUInteger imageCount = [[DMSequenceManager sequenceManager] imageCount];
	if (imageCount == 0) return 0.0;
	else return sequenceLength/((CGFloat)imageCount);
}

@end
