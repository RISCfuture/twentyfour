#import "DMFileIconValueTransformer.h"

@implementation DMFileIconValueTransformer

#pragma mark Transforming values

/*
 This transformer converts between different subclasses of NSObject.
 */

+ (Class) transformedValueClass {
	return [NSObject class];
}

/*
 This is a one-directional transformer.
 */

+ (BOOL) allowsReverseTransformation {
	return NO;
}

/*
 Converts a file path to an icon.
 */

- (id) transformedValue:(id)value {
	if (!value) return [NSImage imageNamed:@""];
	else return [[NSWorkspace sharedWorkspace] iconForFile:(NSString *)value];
}

@end
