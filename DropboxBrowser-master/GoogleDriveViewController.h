#import <UIKit/UIKit.h>

#import "GTMOAuth2ViewControllerTouch.h"
#import "GTLDrive.h"
#import "DrEditFileEditDelegate.h"

@interface GoogleDriveViewController : UITableViewController <DrEditFileEditDelegate>

@property (nonatomic,strong) NSString *strFilePath;
@property (nonatomic,strong) NSString *strFolderId;
@property (nonatomic, strong) GoogleDriveViewController *subdirectoryController;

- (IBAction)removeGoogleDrive:(id)sender;
- (void) logoutOfGoogleDrive;
@end