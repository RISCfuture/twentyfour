/*!
 @class DMPeriodNotTooSmallValueTransformer
 @abstract Value transformer that returns NO if the launch period is below a
 certain threshold. It does this by calculating the frequency of image changes
 given the current size of the image directory. If the frequency exceeds five
 minutes, images will be skipped, and the transformer returtns NO. If the
 sequence will run with all images being displayed, it returns YES.
 */

@interface DMPeriodNotTooSmallValueTransformer : NSValueTransformer {
	
}

@end
