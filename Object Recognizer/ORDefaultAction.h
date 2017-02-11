//
//  ORDefaultAction.h
//  Smart Visual Assistant
//
//  Created by Luke Vella on 5/13/12.
//  Copyright (c) 2012 N/A. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ActionProtocol.h"
#import <OpenEars/FliteController.h>

@interface ORDefaultAction : NSObject <ActionProtocol>

@property (strong, nonatomic) FliteController *fliteController;

@end
