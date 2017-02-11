//
//  Item+Create.h
//  Object Recognizer
//
//  Created by Luke Vella on 3/29/12.
//  Copyright (c) 2012 N/A. All rights reserved.
//

#import "Item.h"

@interface Item (Create)

+(Item *)itemWithName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context;

+(void)deleteItem:(Item *)item inManagedObjectContext:(NSManagedObjectContext *)context;

@end
