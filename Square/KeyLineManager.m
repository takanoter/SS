//
//  KeyLineManager.m
//  Square
//
//  Created by takanoter on 13-3-20.
//  Copyright (c) 2013年 takanoter. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "KeyLineManager.h"
#import "SquareViewController.h"
#import "SquareAppDelegate.h"

@implementation KeyLine

- (KeyLine*)initWithView:(UIView*)theView onChannel:(int)_channel ofKey:(int)keyID {
    int tag= _channel*6+keyID;
    image = [[UIImageView alloc] initWithFrame:CGRectMake(5.0+_channel*100, 590.0, 132.0, 8.0)];
    image.image = [UIImage imageNamed:@"Default.png"];
    image.tag = tag;
    self->tagID = tag;
    self->gView = theView;
    self->channel = _channel;
    [self reset];
    [theView addSubview:image];
    //NSLog(@"hihi %p %p", self->gView, theView);
    return self;
}
- (void) reset {
    //NSLog(@"only once");
    dx=66 + channel*100, dy=590;
    isShow=false;
    image.center = CGPointMake(dx, dy);
}
- (void)move:(float)speed {
    self->dy = self->dy - speed;
    image.center = CGPointMake(self->dx, self->dy);
    if (dy<0) [self reset];
}

- (void)show {
    //NSLog(@"only once once");
    dx=66 + channel*100, dy=595;
    isShow=true;
    image.center = CGPointMake(dx, dy);
}

@end

@implementation KeyLineManager
- (KeyLineManager*) initWithView:(UIView*)theView {
    //NSLog(@"init view:%p", theView);
    for (int i=0; i<6; i++) {
        for (int j=0; j<KEY_SLOT_COUNT; j++) {
            keys[i][j]= [[KeyLine alloc] initWithView:theView onChannel:i ofKey:j];
        }
    }
    speed = 5;
    return self;
}
//- (bool)newCommingOnChannel:(int)channel;

- (bool) newCommingOnChannel:(int)channel {
    int iid = [self getActorFromChannel:channel];
    //NSLog(@"id:%d", iid);
    if (100 == iid) return false;
    [keys[channel][iid] show ];
    return true;
}

- (void)animate {
    for (int i=0; i<6; i++) {
        for (int j=0; j<KEY_SLOT_COUNT; j++) {
            if (!keys[i][j]->isShow) continue;
            [keys[i][j] move:speed];
        }
    }
}

- (int)getActorFromChannel:(int)channel {
        for (int j=0; j<KEY_SLOT_COUNT; j++) {
            if (!(keys[channel][j]->isShow)) return j;
        }
    return 100;
}
@end
