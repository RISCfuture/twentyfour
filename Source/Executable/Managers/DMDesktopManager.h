/*!
 @class DMDesktopManager
 @abstract Singleton class that can set the desktop picture to an image from a
 directory of images according to the time of day.
 
 Settings are loaded from the
 ~/Library/Preferences/org.tmorgan.TwentyFourHourMovie.plist file. This plist
 should be a dictionary with the following keys:
 
 DMImageDirectorySettingKey: The directory where the images are located. The
 path can use a "~" character to represent the home directory.
 DMPrefixSettingKey: The filename prefix common to all image files that should
 be used as a desktop picture.
 
 The image chosen for the desktop will be according to the time of day, such
 that at midnight the first image is chosen, at noon the middle image, and the
 instant before midnight the last image.
 
 Images will be chosen as sorted by name.
 */

@interface DMDesktopManager : NSObject {
	
}

#pragma mark Working with the singleton instance

/*!
 @method manager
 @abstract Returns the singleton instance.
 @result The singleton instance.
 */

+ (DMDesktopManager *) manager;

#pragma mark Setting the desktop background

/*!
 @method setBackground
 @abstract Sets the desktop background to the appropriate image.
 */

- (void) setBackground;

@end
