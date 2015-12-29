//
//  ViewController.h
//  MyLife
//
//  Created by Huang Zhu on 9/27/14.
//  Copyright (c) 2014 FinanceApp.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>
#import <MessageUI/MessageUI.h>
#import <AVFoundation/AVFoundation.h>

@interface SoundRecordViewController : UIViewController<MFMailComposeViewControllerDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate>
{
    IBOutlet UIButton *btnStart;
    IBOutlet UIButton *btnStop;
    IBOutlet UIButton *btnClose;
    IBOutlet UILabel *lblTimer;
    
    NSTimer *timer;
    CFTimeInterval _ticks;
    
    NSURL *outputFileURL;
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
}

- (IBAction)onClose:(id)sender;
- (IBAction)onRecord:(id)sender;
- (IBAction)onStop:(id)sender;

@property (nonatomic, strong) NSString *strFilePath;

@end

