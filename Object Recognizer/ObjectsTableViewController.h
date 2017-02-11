//
//  ObjectsTableViewController.h
//  Object Recognizer
//
//  Created by Luke Vella on 3/28/12.
//  Copyright (c) 2012 N/A. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"

@interface ObjectsTableViewController : CoreDataTableViewController

@property (nonatomic, strong) NSManagedObjectContext *context;

@end
