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
    //int syncPatCount;
    float curTimestamp;
    //NSArray* values;
    AVAudioPlayer *audioPlayer;
    //bool first;
    BeMusic* bm;

}
@property (retain, nonatomic) IBOutlet UIImageView *KeyLine;
@end

@implementation SquareViewController


//需要保证线程安全？？？？  ----回调机制 
- (void) keylineAnimate {
    //_KeyLine.center = CGPointMake(_KeyLine.center.x, _KeyLine.center.y-keyline_speed);
    [mgr animate];
    curTimestamp += 0.7/60;
    // NSLog(@"curTimestamp:%lf  note.timestamp:%lf", curTimestamp, note->timestamp);
    
    Note* note = nil;

    if (timeline->curNotesPos != [timeline->notes count]) {
        note = [timeline->notes objectAtIndex:timeline->curNotesPos]; //FIXME: out of boundary
    }
    
    //此处有深意:1.7
    while ((note!=nil) && (curTimestamp + 1.41 /*+595/5*(0.7/60)*/ > note->timestamp)) {
        NSLog(@"note:timestamp:%lf channel:%d", note->timestamp, note->channel);
        [mgr newCommingOnChannel:(note->channel)%6];
        timeline->curNotesPos++;
        if (timeline->curNotesPos != [timeline->notes count]) {
            note = [timeline->notes objectAtIndex:timeline->curNotesPos];
        } else break;
    }

    for (int i=0; i<6; i++) {
        note = nil;
        if (timeline->curChannelsPos[i] != [timeline->channels[i] count]) {
            note = [timeline->channels[i] objectAtIndex:timeline->curChannelsPos[i]];
        }
        if ((note!=nil) && (curTimestamp + 2 > note->timestamp)) {
            timeline->isShow[i] = !timeline->isShow[i];
            timeline->curChannelsPos[i]++;
        }
        if (timeline->isShow[i]) {
            [mgr newCommingOnChannel:(note->channel)%6];
        }
    }
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
    //[mgr newComming;0];
}

- (void) timer_start
{
    curTimestamp = 0.0;
    //TODO:music start.
    
    if (keyTimer == nil) {
        keyTimer=[[NSTimer scheduledTimerWithTimeInterval: 0.7/60.0 target: self selector:@selector(keylineAnimate) userInfo:NULL repeats:YES] retain];
    }
    
    [audioPlayer play];
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
    bm = [[BeMusic alloc] initFromFile:@"test" ofType:@"bms"];
    if (nil == bm) {
        NSLog(@"oh failed to init bm");
        return;
    }
   
    timeline = [[TimelineNotes alloc]init];
    [bm timeSerilizeTo:timeline];
    //[bm dealloc];
    
    /*
    values = [timeline->timeBasedNotes allValues];
    [values retain];
    for (NSObject *obj in values) {
        NSLog(@"dedide:%@ %lf %d %d", obj, ((Note*)obj)->timestamp, ((Note*)obj)->channel, ((Note*)obj)->motion);
    }
    */
    [timeline arrange];
    
    //[timeline dealloc];  //XXX: auto release??
    NSLog(@"try to find where core is, and auto release.");
}

- (void)viewDidLoad
{
    //values = nil;
    [self openFile];
    [self preparePlay];
    
    self->mgr = [[KeyLineManager alloc] initWithView:self.view];
    //[getViewController->addSubview:image];
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self timer_start];
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
