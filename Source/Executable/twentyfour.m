#import <Foundation/Foundation.h>

void displayHelp(void);

/*
 Called when the program is run. Initializes an autorelease pool and sets the
 desktop background.
 */

int main (int argc, const char * argv[]) {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	if (argc > 1 && strcmp(argv[1], "--help") == 0) displayHelp();
	else [[DMDesktopManager manager] setBackground];
	
	[pool drain];
	return 0;
}

/*
 Displays help information when the executable is called with the --help option.
 Meant to steer nosy or curious power users to the correct track.
 */

void displayHelp(void) {
	printf("This utility is used by The Twenty-Four Hour Movie.\n");
	printf("For more information, consult the help files for the application.\n");
}
