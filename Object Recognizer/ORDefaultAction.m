//
//  ORDefaultAction.m
//  Smart Visual Assistant
//
//  Created by Luke Vella on 5/13/12.
//  Copyright (c) 2012 N/A. All rights reserved.
//

#import "ORDefaultAction.h"
#import <AudioToolbox/AudioServices.h>

@implementation ORDefaultAction

@synthesize fliteController = _fliteController;

-(FliteController *)fliteController 
{
    if (_fliteController == nil) {
        _fliteController = [[FliteController alloc] init];
    }
    return  _fliteController;
}

-(void)action:(Image *)image
{
    [self.fliteController say:image.ofItem.name withVoice:@"cmu_us_slt"];
}

@end
