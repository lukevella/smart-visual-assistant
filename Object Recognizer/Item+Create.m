//
//  Item+Create.m
//  Object Recognizer
//
//  Created by Luke Vella on 3/29/12.
//  Copyright (c) 2012 N/A. All rights reserved.
//

#import "Item+Create.h"
#import "Image+Manage.h"
@implementation Item (Create)

+(Item *)itemWithName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSLog(@"Creating Object");
    Item *object = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Item"];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@",name];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    NSLog(@"Matches: %u", [matches count]);
    
    if (!matches || [matches count] > 1) {
        // error
        NSLog(@"Error: %@", error);
    } else if ([matches count] == 0) {
        object = (Item *)[NSEntityDescription insertNewObjectForEntityForName:@"Item" 
                                                         inManagedObjectContext:context];           
        object.name = name;
        NSError *saveError;
        if([context save:&saveError]){
            NSLog(@"Saved Changes");
        } else {
            NSLog(@"Save Error: %@",saveError);
        }
    } else {
        NSLog(@"Object Exists");
        object = [matches lastObject];
    }
    
    
    return object;
}

+(void)deleteItem:(Item *)item inManagedObjectContext:(NSManagedObjectContext *)context
{
    // Delete all images
    for (Image *image in item.images) {
        [Image deleteImage:image inManagedObjectContext:context];
    }
    [context deleteObject:item]; 
    NSError *saveError;
    if([context save:&saveError]){
        NSLog(@"Saved Changes");
    } else {
        NSLog(@"Save Error: %@",saveError);
    }
}


@end
