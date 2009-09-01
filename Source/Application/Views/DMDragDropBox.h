/*!
 @class DMDragDropBox
 @abstract A subclass of @link //apple_ref/occ/cl/NSBox NSBox @/link that
 includes drag-and-drop support. This class will delegate drag and drop
 operations to another object and will display a focus ring when a drag hovers
 over its bounds.
 */

@interface DMDragDropBox : NSBox {
	IBOutlet id delegate;
	BOOL focusRing;
}

@end

/*!
 @category NSObject(DMDragDropBoxDelegate)
 @abstract Informal protocol describing delegates of
 @link DMDragDropBox DMDragDropBox @/link. These delegates respond to
 drag-and-drop operations.
 */

@interface NSObject (DMDragDropBoxDelegate)

/*!
 @method dragTypesForDragDropBox:
 @abstract This method should return an array of @link //apple_ref/doc/constant_group/Types_for_Standard_Data_Mac_OS_X_10.5_and_earlier_ pasteboard types @/link
 that this box will accept.
 @param box The @link DMDragDropBox DMDragDropBox @/link.
 @result An array of pasteboard type strings.
 */

- (NSArray *) dragTypesForDragDropBox:(DMDragDropBox *)box;

/*!
 @method dragDropBox:dragEntered:
 @abstract Called when the drag enters the bounds of the box. This method should
 return the type of drag operation.
 @param box The @link DMDragDropBox DMDragDropBox @/link.
 @param drag The drag information.
 @result The type of drag operation to perform.
 */

- (NSDragOperation) dragDropBox:(DMDragDropBox *)box dragEntered:(id<NSDraggingInfo>)drag;

/*!
 @method dragDropBox:shouldPerformDrag:
 @abstract Called when the drag has finished and the associated operation is
 about to perform. Should return whether or not to perform this drag.
 @param box The @link DMDragDropBox DMDragDropBox @/link.
 @param drag The drag information.
 @result YES if the drag should be performed; NO if it should be canceled.
 */

- (BOOL) dragDropBox:(DMDragDropBox *)box shouldPerformDrag:(id<NSDraggingInfo>)drag;

/*!
 @method dragDropBox:performDrag:
 @abstract Called when the drag is accepted and the associated operation should
 be performed. This method should perform the drag operation.
 @param box The @link DMDragDropBox DMDragDropBox @/link.
 @param drag The drag information.
 @result YES if an operation was performed; NO if nothing changed.
 */

- (BOOL) dragDropBox:(DMDragDropBox *)box performDrag:(id<NSDraggingInfo>)drag;

@end
