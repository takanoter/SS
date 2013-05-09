//
//  SquareViewController.m
//  Square
//
//  Created by takanoter on 13-3-20.
//  Copyright (c) 2013年 takanoter. All rights reserved.
//
#import "SquareAppDelegate.h"
#import "SquareViewController.h"
#import "KeyLineManager.h"
#import "BMS.h"
#import "TimelineNotes.h"

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
@interface SquareViewController ()
{
    NSTimer *keyTimer;
    NSTimer *musicTimer;
    KeyLineManager* mgr;
    UIViewController *UIVC;
    int syncPatCount;
    float curTimestamp;
    NSArray* values;
    AVAudioPlayer *audioPlayer;
    bool first;
    BeMusic* bm;

}
@property (retain, nonatomic) IBOutlet UIImageView *KeyLine;
@end

@implementation SquareViewController


//线程安全？？？？
- (void) keylineAnimate {
    //_KeyLine.center = CGPointMake(_KeyLine.center.x, _KeyLine.center.y-keyline_speed);
    [mgr animate];
    curTimestamp += 0.7/60;
    //NSLog(@"curTimestamp:%lf", curTimestamp);

    Note* note = [values objectAtIndex:syncPatCount]; //FIXME: out of boundary
   // NSLog(@"curTimestamp:%lf  note.timestamp:%lf", curTimestamp, note->timestamp);
    if (first) {
        first = false;
    }
    
    while ((note!=nil) && (curTimestamp + 2 /*+595/5*(0.7/60)*/ > note->timestamp)) {
        NSLog(@"note:timestamp:%lf", note->timestamp);
        [mgr newCommingOnChannel:(note->channel)%6];
        ++syncPatCount;
        note = [values objectAtIndex:syncPatCount];
        //note = (Note*)array[syncPatCount];
    }
    /*
    if (syncPatCount % 23 == 0) {
        [mgr newCommingOnChannel:4];
    } 
     */
}
-(void)preparePlay
{
    NSBundle *myBundle = [NSBundle mainBundle];
    NSString *musicFilePath=[myBundle pathForResource:@"test" ofType:@"mp3" ];
    
    if (nil != musicFilePath) {
        NSError *error;
        NSURL *musicURL= [[NSURL alloc]initFileURLWithPath:musicFilePath];
        audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:musicURL error:&error];
        //[musicURL release];
        [audioPlayer prepareToPlay];
        [audioPlayer setVolume:1];
        audioPlayer.numberOfLoops = -1;
        NSLog(@"haha:%@", [error localizedDescription]);
    }
}

- (void) readMusic {
    NSLog(@"haha");
    //[mgr newComming;0];
}

- (void) timer_start
{
    curTimestamp = 0.0;
    //TODO:music start.

    first = true;
    syncPatCount = 0;

    if (keyTimer == nil) {
        keyTimer=[[NSTimer scheduledTimerWithTimeInterval: 0.7/60.0 target: self selector:@selector(keylineAnimate) userInfo:NULL repeats:YES] retain];
    }
    
    [audioPlayer play];

    /*
    if (musicTimer == nil) {
        musicTimer=[[NSTimer scheduledTimerWithTimeInterval: 60.0/60.0 target: self selector:@selector(readMusic) userInfo:NULL repeats:YES] retain];
    }
     */
    //_KeyLine.hidden=NO;
}

- (void) stop{
    if (keyTimer!=nil) {
        [keyTimer invalidate];
        [keyTimer release];
        keyTimer = nil;
    }
    if (musicTimer!=nil) {
        [musicTimer invalidate];
        [musicTimer release];
        musicTimer = nil;
    }
    //_KeyLine.hidden=YES;
}

-(void)openFile
{
    bm = [[BeMusic alloc] initFromFile:@"Entrance -another Ver.-(EZ)" ofType:@"bms"];
    if (nil == bm) {
        NSLog(@"oh failed to init bm");
        return;
    }
   
    timeline = [[TimelineNotes alloc]init];
    [bm timeSerilizeTo:timeline];
    //[bm dealloc];
    
    values = [timeline->timeBasedNotes allValues];
    [values retain];
    for (NSObject *obj in values) {
        NSLog(@"dedide:%@ %lf %d %d", obj, ((Note*)obj)->timestamp, ((Note*)obj)->channel, ((Note*)obj)->motion);
    }
    
    //[timeline dealloc];  //XXX: auto release??
    NSLog(@"try to find where core is, and auto release.");
}

- (void)viewDidLoad
{
    /*
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(5.0, 590.0, 132.0, 8.0)];
    image.image = [UIImage imageNamed:@"Default.png"];
    image.tag = 19900;
    image.center = CGPointMake(120, 80);
    */
    //UIVC = self;
//  image.center ＝ CGPointMake(20,40);
    //[UIVC.view addSubview:image];
    values = nil;
    [self openFile];
    
    
    //NSURL *url = [NSURL fileURLWithPath:@"test.mp3"];
    //NSError *error;
    //audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
    //NSString *mp3 = [NSTemporaryDirectory() stringByAppendingPathComponent:@"test.mp3"];
    [self preparePlay];
    
    self->mgr = [[KeyLineManager alloc] initWithView:self.view];
    //[getViewController->addSubview:image];
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self timer_start];
    
    NSLog(@"hello");
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_KeyLine release];
    [super dealloc];
}
@end
