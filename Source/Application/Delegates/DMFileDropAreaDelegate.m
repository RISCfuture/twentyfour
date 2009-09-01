#import "DMFileDropAreaDelegate.h"

@implementation DMFileDropAreaDelegate

#pragma mark Drag and drop

/*
 Registers this object as receiving file drags.
 */

- (NSArray *) dragTypesForDragDropBox:(DMDragDropBox *)box {
	return [NSArray arrayWithObject:NSFilenamesPboardType];
}

/*
 Returns NSDragOperationGeneric.
 */

- (NSDragOperation) dragDropBox:(DMDragDropBox *)box dragEntered:(id<NSDraggingInfo>)drag {
	return NSDragOperationGeneric;
}

/*
 Returns YES if there is one and only one folder being dragged; no otherwise.
 */

- (BOOL) dragDropBox:(DMDragDropBox *)box shouldPerformDrag:(id<NSDraggingInfo>)drag {
	NSArray *URLs = [[drag draggingPasteboard] readObjectsForClasses:[NSArray arrayWithObject:[NSURL class]] options:NULL];
	
	if ([URLs count] == 1) {
		NSURL *URL = [URLs objectAtIndex:0];
		NSString *path = [URL path];
		BOOL directory = NO;
		if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&directory])
			return directory;
		else return NO;
	}
	else return NO;
}

/*
 Sets the image directory to the dragged directory.
 */

- (BOOL) dragDropBox:(DMDragDropBox *)box performDrag:(id<NSDraggingInfo>)drag {
	NSArray *URLs = [[drag draggingPasteboard] readObjectsForClasses:[NSArray arrayWithObject:[NSURL class]] options:NULL];
	NSURL *URL = [URLs objectAtIndex:0];
	NSString *path = [URL path];
	[[NSUserDefaults standardUserDefaults] setObject:path forKey:DMUserDefaultsKeyImageDirectory];
	return YES;
}

@end
