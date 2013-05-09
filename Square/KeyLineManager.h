//
//  KeyLineManager.h
//  Square
//
//  Created by takanoter on 13-3-20.
//  Copyright (c) 2013年 takanoter. All rights reserved.
//
#import "SquareAppDelegate.h"
#define MAX_IMAGE_STAGE 5
@interface KeyLine:NSObject {
    UIImageView *image;
    UIImageView *bloom[MAX_IMAGE_STAGE];
    @public bool isShow;
    float dx,dy;
    int tagID;
    int channel;
    UIView* gView;
    bool isShort;
    int stage;
}
- (KeyLine*)initWithView:(UIView*)theView onChannel:(int)_channel ofKey:(int)keyID;
//- (KeyLine*)initWithView:(UIView*)theView initWithView:(int)tag;
- (void)reset;
- (void)move:(float)speed;
- (void)show;
@end

#define KEY_SLOT_COUNT 10

@interface KeyLineManager:NSObject {
    KeyLine* keys[6][KEY_SLOT_COUNT]; //[channel][slot pool]
    float speed;
}
- (KeyLineManager*) initWithView:(UIView*)theView;
- (bool) newCommingOnChannel:(int)channel;
- (void)animate ;
- (int)getActorFromChannel:(int)channel;
    
//- (KeyLineManager*) initWithView:(UIView*)theView;
//- (bool)newCommingOnChannel:(int)channel;
//- (void)animate;
//- (int)getActor;
@end



