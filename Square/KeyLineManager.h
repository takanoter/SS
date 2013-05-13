//
//  KeyLineManager.h
//  Square
//
//  Created by takanoter on 13-3-20.
//  Copyright (c) 2013年 takanoter. All rights reserved.
//
#import "SquareAppDelegate.h"
#define MAX_IMAGE_STAGE 12
#define BASE_LOC_X 400
#define BASE_START_LOC_Y 65
#define BASE_DISAPPEAR_LOC_Y -100
#define BASE_LOC_ENDFRONT_Y 518
@interface KeyLine:NSObject {
    UIImageView *image;
    UIImageView *bloom[MAX_IMAGE_STAGE];  //TODO:FIXME:属于channel，not key
    UIImageView *touch;
    @public bool isShow;
    float dx,dy;
    int tagID;
    int channel;
    UIView* gView;
    bool isShort;
    int stage;
}
- (KeyLine*)initWithView:(UIView*)theView onChannel:(int)_channel ofKey:(int)keyID;
- (void)reset;
- (void)move:(float)speed;
- (void)show;
@end

#define KEY_SLOT_COUNT 25
#define END_FRONT_COUNT 2
@interface KeyLineManager:NSObject {
    //TODO:全局池化
    KeyLine* keys[6][KEY_SLOT_COUNT]; //[channel][slot pool]
    float speed;
    UIImageView *endFront[END_FRONT_COUNT];
    int curEndFront;
}
- (KeyLineManager*) initWithView:(UIView*)theView;
- (bool) newCommingOnChannel:(int)channel;
- (void)animate ;
- (int)getActorFromChannel:(int)channel;


@end



