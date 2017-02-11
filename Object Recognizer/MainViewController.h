//
//  MainViewController.h
//  Object Recognizer
//
//  Created by Luke Vella on 2/29/12.
//  Copyright (c) 2012 N/A. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenEars/FliteController.h>
#import "ActionProtocol.h"
#import "VideoCaptureViewController.h"
@interface MainViewController : VideoCaptureViewController

@property (strong, nonatomic) NSString *featureDetector;
@property (strong, nonatomic) NSString *descriptorExtractor;
@property (strong, nonatomic) FliteController *fliteController;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *progressIndicator;
@property (strong, nonatomic) id<ActionProtocol>action;
@property (strong, nonatomic) NSNumber *distanceRatio;
@property (strong, nonatomic) NSNumber *threshold;

@property (weak, nonatomic) IBOutlet UILabel *display;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *torchButton;

@end
