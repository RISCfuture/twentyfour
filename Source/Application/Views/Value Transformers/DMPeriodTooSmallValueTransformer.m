#import "DMPeriodTooSmallValueTransformer.h"

@implementation DMPeriodTooSmallValueTransformer

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
	else return [NSNumber numberWithBool:([(NSNumber *)value unsignedIntegerValue] > DMPeriodThreshold)];
}

@end
