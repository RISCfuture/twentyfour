#import "DMDragDropBox.h"

@implementation DMDragDropBox

#pragma mark Initialization and deallocation

- (void) awakeFromNib {
	SEL selector = @selector(dragTypesForDragDropBox:);
	if (delegate && [delegate respondsToSelector:selector]) {
		NSMethodSignature *sig = [[delegate class] instanceMethodSignatureForSelector:selector];
		NSInvocation *invoc = [NSInvocation invocationWithMethodSignature:sig];
		[invoc setTarget:delegate];
		[invoc setSelector:selector];
		[invoc setArgument:&self atIndex:2];
		[invoc invoke];
		NSArray *types = NULL;
		[invoc getReturnValue:&types];
		[self registerForDraggedTypes:types];
	}
	
	focusRing = NO;
}

#pragma mark Drawing

- (void) drawRect:(NSRect)rect {
	[super drawRect:rect];
	if (focusRing) {
		NSRect focusRingFrame = rect;
		focusRingFrame.size.height -= 2.0;
		[NSGraphicsContext saveGraphicsState];
		NSSetFocusRingStyle(NSFocusRingOnly);
		[[NSBezierPath bezierPathWithRect:NSInsetRect(focusRingFrame,4,4)] fill];
		[NSGraphicsContext restoreGraphicsState];
	}
}

#pragma mark Drag and drop

/*
 Called when the drag enters the frame. Displays the focus ring and delegates
 the drag type.
 */

- (NSDragOperation) draggingEntered:(id<NSDraggingInfo>)sender {
	focusRing = YES;
	[self setNeedsDisplay:YES];
	
	SEL selector = @selector(dragDropBox:dragEntered:);
	if (delegate && [delegate respondsToSelector:selector]) {
		NSMethodSignature *sig = [[delegate class] instanceMethodSignatureForSelector:selector];
		NSInvocation *invoc = [NSInvocation invocationWithMethodSignature:sig];
		[invoc setTarget:delegate];
		[invoc setSelector:selector];
		[invoc setArgument:&self atIndex:2];
		[invoc setArgument:&sender atIndex:3];
		[invoc invoke];
		NSDragOperation dragType;
		[invoc getReturnValue:&dragType];
		return dragType;
	}
	else return NSDragOperationNone;
}

/*
 Called when the drag exits the frame. Hides the focus ring.
 */

- (void) draggingExited:(id<NSDraggingInfo>)sender {
	focusRing = NO;
	[self setNeedsDisplay:YES];
}

/*
 Called when the drag ends in a destination other than this view. Hides the
 focus ring.
 */

- (void) draggingEnded:(id<NSDraggingInfo>)sender {
	focusRing = NO;
	[self setNeedsDisplay:YES];
}

/*
 Called when the drag completes and should be either accepted or rejected.
 Delegates this operation.
 */

- (BOOL) prepareForDragOperation:(id<NSDraggingInfo>)sender {
	focusRing = NO;
	[self setNeedsDisplay:YES];
	
	SEL selector = @selector(dragDropBox:shouldPerformDrag:);
	if (delegate && [delegate respondsToSelector:selector]) {
		NSMethodSignature *sig = [[delegate class] instanceMethodSignatureForSelector:selector];
		NSInvocation *invoc = [NSInvocation invocationWithMethodSignature:sig];
		[invoc setTarget:delegate];
		[invoc setSelector:selector];
		[invoc setArgument:&self atIndex:2];
		[invoc setArgument:&sender atIndex:3];
		[invoc invoke];
		BOOL shouldPerform;
		[invoc getReturnValue:&shouldPerform];
		return shouldPerform;
	}
	else return NO;
}

/*
 Called when the drag operation should be performed. Delegates this operation.
 */

- (BOOL) performDragOperation:(id<NSDraggingInfo>)sender {
	SEL selector = @selector(dragDropBox:performDrag:);
	if (delegate && [delegate respondsToSelector:selector]) {
		NSMethodSignature *sig = [[delegate class] instanceMethodSignatureForSelector:selector];
		NSInvocation *invoc = [NSInvocation invocationWithMethodSignature:sig];
		[invoc setTarget:delegate];
		[invoc setSelector:selector];
		[invoc setArgument:&self atIndex:2];
		[invoc setArgument:&sender atIndex:3];
		[invoc invoke];
		BOOL didPerform;
		[invoc getReturnValue:&didPerform];
		return didPerform;
	}
	else return NO;
}

@end
