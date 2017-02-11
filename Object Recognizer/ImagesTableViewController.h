//
//  ImagesTableViewController.h
//  Object Recognizer
//
//  Created by Luke Vella on 3/30/12.
//  Copyright (c) 2012 N/A. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"
#import "Item.h"
@interface ImagesTableViewController : CoreDataTableViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) Item *item;

@end
