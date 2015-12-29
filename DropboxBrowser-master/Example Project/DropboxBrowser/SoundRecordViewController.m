//
//  ViewController.m
//  MyLife
//
//  Created by Huang Zhu on 9/27/14.
//  Copyright (c) 2014 FinanceApp.com. All rights reserved.
//

#import "SoundRecordViewController.h"

@interface SoundRecordViewController ()

@end

@implementation SoundRecordViewController

@synthesize strFilePath;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.title = @"MyLife";
    
    
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               @"MyAudioMemo.m4a",
                               nil];
    outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    // Setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    // Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    // Initiate and prepare the recorder
    recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:NULL];
    recorder.delegate = self;
    recorder.meteringEnabled = YES;
    [recorder prepareToRecord];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [btnStart setHidden:NO];
    [btnStop setHidden:YES];
}

- (IBAction)onClose:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onRecord:(id)sender{
    [btnClose setEnabled:NO];
    [btnStop setHidden:NO];
    [btnStart setHidden:YES];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
    
    // Stop the audio player before recording
    if (player.playing) {
        [player stop];
    }
    
    if (!recorder.recording) {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        
        // Start recording
        [recorder record];
    } else {
        
        // Pause recording
        [recorder pause];
    }
}

- (IBAction)onStop:(id)sender{
    [btnClose setEnabled:YES];
    [btnStart setHidden:NO];
    [btnStop setHidden:YES];

    if(timer)
    {
        [timer invalidate];
    }
    
    timer = nil;
    _ticks = 0;
    
    [recorder stop];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
}

- (void)timerTick:(NSTimer *)timer
{
    _ticks += 0.1;
    double seconds = fmod(_ticks, 60.0);
    double minutes = fmod(trunc(_ticks / 60.0), 60.0);
    double hours = trunc(_ticks / 3600.0);
    lblTimer.text = [NSString stringWithFormat:@"%02.0f:%02.0f:%04.1f", hours, minutes, seconds];
}

- (void)sendEmail{
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if ( !mailClass || ![mailClass canSendMail] )
    {
        launchMailAppOnDevice();
        return;
    }
    
    
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    NSArray *toRecipients = [NSArray arrayWithObject:@"Newcustomer@MyLife.community"];
    [picker setToRecipients:toRecipients];
    NSMutableString *emailBody = [NSMutableString stringWithString: @"Hi, Please check my attachment."];
    
    // Attach an image to the email
    NSString *path = [outputFileURL absoluteString]; //outputFileURL;
    NSData *data = [NSData dataWithContentsOfFile:path];
    [picker addAttachmentData:data mimeType:@"audio/m4a" fileName:@"MyAudioMemo.m4a"];
    
    [picker setSubject:self.strFilePath];
    [picker setMessageBody:emailBody isHTML:NO];
    [self presentViewController:picker animated:YES completion:nil];
}

void launchMailAppOnDevice()
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Mail Accounts"
                                                    message:@"Please set up a Mail account in order to send email." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
        {
            break;
        }
            
        case MFMailComposeResultSaved:
        {
            UIAlertView *stop = [[UIAlertView alloc] initWithTitle:@"" message:@"Mail saved." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [stop show];
            //			[stop release];
            break;
        }
            
        case MFMailComposeResultSent:
        {
            UIAlertView *stop = [[UIAlertView alloc] initWithTitle:@"" message:@"Mail sent." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [stop show];
            //			[stop release];
            break;
        }
            
        case MFMailComposeResultFailed:
        {
            UIAlertView *stop = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Mail send failed." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [stop show];
            //			[stop release];
            break;
        }
            
        default:
        {
            UIAlertView *stop = [[UIAlertView alloc] initWithTitle:@"" message:@"Mail not sent." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [stop show];
            //			[stop release];
            break;
        }
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark AVAudioRecorderDelegate Protocol

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag{
    [self sendEmail];
}
@end
