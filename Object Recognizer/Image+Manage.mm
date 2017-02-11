//
//  Image+Manage.m
//  Object Recognizer
//
//  Created by Luke Vella on 4/2/12.
//  Copyright (c) 2012 N/A. All rights reserved.
//

#import "Image+Manage.h"
#import "UIImage+OpenCV.h"
using namespace cv;
using namespace std;

@implementation Image (Manage)

+(Image *)image:(UIImage *)image forItem:(Item *)item inManagedObjectContext:(NSManagedObjectContext *)context withUniqueID:(NSString *)uniqueID 
{    
    
    NSLog(@"Converting Image to Matrix");
    Mat cvImg = [image CVGrayscaleMat];
    Mat descriptors;
    NSArray *algorithms = [NSArray arrayWithObjects:@"SURF",@"ORB",@"SIFT",@"MSER", nil];
    Ptr<FeatureDetector> detector;
    Ptr<DescriptorExtractor>extractor;
    vector<KeyPoint>keypoints;  
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docs = [paths objectAtIndex:0];
    NSString *descriptorFilePath;  
    for (NSString *algorithm in algorithms) {
        detector = FeatureDetector::create([algorithm UTF8String]);
        detector->detect(cvImg, keypoints);
        if ([algorithm isEqualToString:@"MSER"]) {
            extractor = DescriptorExtractor::create("SURF");
        } else {
            extractor = DescriptorExtractor::create([algorithm UTF8String]);
        }
        
        extractor->compute(cvImg, keypoints, descriptors);
        descriptorFilePath = [docs stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@.yml",uniqueID,algorithm]];
        FileStorage fs([descriptorFilePath UTF8String], FileStorage::WRITE);
        // vocab is a CvMat object representing the vocabulary in my bag of features model
        fs << "descriptors" << descriptors;
        fs.release();
    }

    NSURL *documentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    NSURL *imageFilePath = [documentsDirectory URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",uniqueID]];
    NSError * error = nil;
    [imageData writeToURL:imageFilePath options:NSDataWritingAtomic error:&error];
    if ([[NSFileManager defaultManager] fileExistsAtPath:imageFilePath.absoluteString]) {
        NSLog(@"Image created successfully");
    }
    
    if (error != nil) {
        NSLog(@"Error: %@", error);
    } 
    
    // Insert into database
    NSLog(@"Creating Image");
    __block Image *object = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Image"];
    request.predicate = [NSPredicate predicateWithFormat:@"unique = %@",uniqueID];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"unique" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *matches = [context executeFetchRequest:request error:&error];
    NSLog(@"Matches: %u", [matches count]);
    
    if (!matches || [matches count] > 0) {
        // error
        NSLog(@"Error: %@", error);
    } else {
        [context performBlock:^{
            object = (Image *)[NSEntityDescription insertNewObjectForEntityForName:@"Image" 
                                                            inManagedObjectContext:context];           
            object.unique = uniqueID;
            NSLog(@"%u features found",descriptors.rows);
            object.ofItem = item;
            [context save:NULL];
        }];
    } 
    
    return object;
}

+(void)deleteImage:(Image *)image inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSError *error = nil;
    // Delete Image File
    [fileManager removeItemAtPath:[image imageFilePath] error:&error];
    if (error) {
        NSLog(@"Error: %@",error);
    }
    // Delete descriptor File
    [fileManager removeItemAtPath:[image descriptorsFilePath] error:&error];
    if (error) {
        NSLog(@"Error: %@",error);
    }
    
    // Delete from database
    [context deleteObject:image];
}


-(NSString *)imageFilePath
{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",self.unique]];
    
}

-(NSString *)descriptorsFilePath
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@.yml",self.unique,[defaults objectForKey:@"Descriptor Extractor"]]];

}


@end
