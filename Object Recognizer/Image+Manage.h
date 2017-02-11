//
//  Image+Manage.h
//  Object Recognizer
//
//  Created by Luke Vella on 4/2/12.
//  Copyright (c) 2012 N/A. All rights reserved.
//

#import "Image.h"
#import "Item.h"
@interface Image (Manage)

+(Image *)image:(UIImage *)image forItem:(Item *) item inManagedObjectContext:(NSManagedObjectContext *)context withUniqueID:(NSString *)uniqueID;

+(void)deleteImage:(Image *)image inManagedObjectContext:(NSManagedObjectContext *)context;


-(NSString *)imageFilePath;
-(NSString *)descriptorsFilePath;

@end
