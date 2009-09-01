#import "DMFileNameValueTransformer.h"

@implementation DMFileNameValueTransformer

#pragma mark Transforming values

/*
 This transformer converts between strings.
 */

+ (Class) transformedValueClass {
	return [NSString class];
}

/*
 This is a one-directional transformer.
 */

+ (BOOL) allowsReverseTransformation {
	return NO;
}

/*
 Converts a file path to a file name.
 */

- (id) transformedValue:(id)value {
	if (!value) return NULL;
	else return [[NSFileManager defaultManager] displayNameAtPath:(NSString *)value];
}

@end
