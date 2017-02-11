//
//  MainViewController.m
//  Object Recognizer
//
//  Created by Luke Vella on 2/29/12.
//  Copyright (c) 2012 N/A. All rights reserved.
//
#import "UIImage+OpenCV.h"
#import "MainViewController.h"
#import <AudioToolbox/AudioServices.h>
#import "ObjectsTableViewController.h"
#import "Image+Manage.h"

using namespace cv;
using namespace std;

Ptr<DescriptorMatcher> matcher;
vector<Mat> dbDescriptors;
Ptr<FeatureDetector> detector;
Ptr<DescriptorExtractor> extractor;

@interface MainViewController ()

@property (strong, nonatomic) UIManagedDocument *objectDatabase;
@property (strong, nonatomic) NSManagedObjectContext *context;
@property (strong, nonatomic) NSArray *images;
@property (strong, nonatomic) NSMutableArray *imageFeatureCount;

@end

@implementation MainViewController

@synthesize images = _images;
@synthesize context = _context;
@synthesize objectDatabase = _objectDatabase;
@synthesize featureDetector = _featureDetector;
@synthesize descriptorExtractor = _descriptorExtractor;
@synthesize display = _display;
@synthesize torchButton = _torchButton;
@synthesize imageFeatureCount = _imageFeatureCount;
@synthesize fliteController = _fliteController;
@synthesize progressIndicator = _progressIndicator;
@synthesize action = _action;
@synthesize distanceRatio = _distanceRatio;
@synthesize threshold = _threshold;

-(FliteController *)fliteController 
{
    if (_fliteController == nil) {
        _fliteController = [[FliteController alloc] init];
    }
    return  _fliteController;
}

- (IBAction)toggleTorch:(UIBarButtonItem *)sender {
    if (self.torchOn == YES) {
        self.torchOn = NO;
        sender.title = @"Light: OFF";
    } else {
        self.torchOn = YES;
        sender.title = @"Light: ON";
    }
}

-(void)setObjectDatabase:(UIManagedDocument *)objectDatabase
{
    if (_objectDatabase != objectDatabase) {
        _objectDatabase = objectDatabase;
        if (![[NSFileManager defaultManager] fileExistsAtPath:[self.objectDatabase.fileURL path]]) {
            [self.objectDatabase saveToURL:self.objectDatabase.fileURL 
                          forSaveOperation:UIDocumentSaveForCreating 
                         completionHandler:^(BOOL success){
                             if (success) NSLog(@"Database Created");
                                [self train];
                         }];
        } else if (self.objectDatabase.documentState == UIDocumentStateClosed) {
            [self.objectDatabase openWithCompletionHandler:^(BOOL success){
                if  (success) NSLog(@"Database Opened");
                [self train];
            }];
        } else  if (self.objectDatabase.documentState == UIDocumentStateNormal) {
            NSLog(@"Database already open.");
            [self train];
        }
        
    }
    self.context = objectDatabase.managedObjectContext;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView
 {
 }
 */

-(void)train
{
    matcher->clear();
    dbDescriptors.clear();
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Image"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"unique" ascending:YES]];
    NSUInteger totalDescriptors = 0;
    self.images = [self.context executeFetchRequest:request error:NULL];
    if (!self.images || [self.images count] == 0) {
        NSLog(@"No images");
    } else {
        Mat descriptors;
        self.imageFeatureCount = [[NSMutableArray alloc] init];
        for (Image *image in self.images) {
            if ([[NSFileManager defaultManager] fileExistsAtPath:[image descriptorsFilePath]]) {
                FileStorage fs([[image descriptorsFilePath] UTF8String],FileStorage::READ);
                fs["descriptors"] >> descriptors;
                totalDescriptors += descriptors.rows;
                [self.imageFeatureCount addObject:[NSNumber numberWithInt:descriptors.rows]];
                dbDescriptors.insert(dbDescriptors.end(), descriptors);
                fs.release();
            } else {
                NSLog(@"File Missing");
            }
            
        }
        matcher->add(dbDescriptors);
        matcher->train();
    }   
    dispatch_async(dispatch_get_main_queue(), ^{[self.progressIndicator stopAnimating];});

}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    self.captureGrayscale = YES;
    self.qualityPreset = AVCaptureSessionPresetMedium; 
}


- (void)viewWillAppear:(BOOL)animated
{
    [self.progressIndicator startAnimating];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.showDebugInfo = [[defaults objectForKey:@"HUD"] boolValue];
    self.featureDetector = [defaults objectForKey:@"Feature Detector"];
    self.descriptorExtractor = [defaults objectForKey:@"Descriptor Extractor"];
    self.action = [[NSClassFromString([defaults objectForKey:@"Action"]) alloc] init];
    self.distanceRatio = [defaults objectForKey:@"Distance Ratio"];
    self.threshold = [defaults objectForKey:@"Threshold"];
    detector = FeatureDetector::create([_featureDetector UTF8String]);
    extractor = DescriptorExtractor::create([_descriptorExtractor UTF8String]);
    matcher = DescriptorMatcher::create([[defaults objectForKey:@"Matcher"] UTF8String]);
    
    
    if (self.objectDatabase == nil) {
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:@"default"];
        self.objectDatabase = [[UIManagedDocument alloc] initWithFileURL:url];
    } else {
        dispatch_queue_t trainQ = dispatch_queue_create("Training Queue", NULL);
        dispatch_async(trainQ, ^{
            [self train];    
        });
        dispatch_release(trainQ);
    }
    [super viewWillAppear:animated];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
    [self setDisplay:nil];
    [self setProgressIndicator:nil];
    [self setTorchButton:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)processFrame:(cv::Mat &)mat videoRect:(CGRect)rect videoOrientation:(AVCaptureVideoOrientation)videOrientation
{
    // Shrink video frame to 320X240
    cv::resize(mat, mat, cv::Size(), 0.5f, 0.5f, CV_INTER_LINEAR);
    rect.size.width /= 2.0f;
    rect.size.height /= 2.0f;
    
    // Rotate video frame by 90deg to portrait by combining a transpose and a flip
    // Note that AVCaptureVideoDataOutput connection does NOT support hardware-accelerated
    // rotation and mirroring via videoOrientation and setVideoMirrored properties so we
    // need to do the rotation in software here.
    cv::transpose(mat, mat);
    CGFloat temp = rect.size.width;
    rect.size.width = rect.size.height;
    rect.size.height = temp;
    
    if (videOrientation == AVCaptureVideoOrientationLandscapeRight)
    {
        // flip around y axis for back camera
        cv::flip(mat, mat, 1);
    }
    else {
        // Front camera output needs to be mirrored to match preview layer so no flip is required here
    }
    
    
    videOrientation = AVCaptureVideoOrientationPortrait;
    
    if (self.images && [self.images count] > 0) {
        vector<KeyPoint> keypoints;

        detector->detect(mat, keypoints);
        Mat descriptors;
        extractor->compute(mat, keypoints, descriptors);
  
        vector<vector <DMatch> >matches;
        matcher->knnMatch(descriptors, matches, 2);
        NSMutableDictionary *matchCount;
        matchCount = [[NSMutableDictionary alloc] init];
        for (vector<vector <DMatch> >::iterator it = matches.begin(); it != matches.end(); ++it)
        {   
            if ((*it)[0].distance < (*it)[1].distance * [_distanceRatio floatValue]) {
                NSNumber *key = [NSNumber numberWithInt:(*it)[0].imgIdx];
                if ([matchCount objectForKey:key]) {
                    int value = [[matchCount objectForKey:key ] intValue];
                    [matchCount setObject:[NSNumber numberWithInt:value+1 ] forKey:key];
                } else {
                    [matchCount setObject:[NSNumber numberWithInt:1] forKey:key];
                }
            }
        }
        NSUInteger imageIDWithMostMatches = 0;
        NSUInteger mostMatches = 0;
        for (NSNumber *imageID in matchCount) {
            if ([[matchCount objectForKey:imageID] intValue] > mostMatches) {
                imageIDWithMostMatches = [imageID intValue];
                mostMatches = [[matchCount objectForKey:imageID] intValue];
            }
        }
        NSString *result = @"";
        
        if (mostMatches > [_threshold intValue]) {
            Image *img = [self.images objectAtIndex:imageIDWithMostMatches];
            result = img.ofItem.name;
            [self.action action:img];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.display.text = result;
        });  
    }
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Show Objects"]) {
        [segue.destinationViewController setContext:self.context];
    }
}


@end
