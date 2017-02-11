//
//  ORAction.h
//  Smart Visual Assistant
//
//  Created by Luke Vella on 5/13/12.
//  Copyright (c) 2012 N/A. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Image.h"
#import "Item.h"

@protocol ActionProtocol <NSObject>

-(void)action:(Image *)image;

@end
