//
//  SettingsViewController.h
//  Object Recognizer
//
//  Created by Luke Vella on 3/1/12.
//  Copyright (c) 2012 N/A. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UITableViewController

@property (strong, nonatomic) NSArray *featureDetectors;
@property (strong, nonatomic) NSString *selectedFeatureDetector;
@property (strong, nonatomic) NSString *selectedDescriptorExtractor;
@property (strong, nonatomic) NSString *selectedMatcher;
@property (strong, nonatomic) NSArray *sectionTitles;
@property (strong, nonatomic) NSArray *otherOptions;
@property (strong, nonatomic) NSNumber *distanceRatio;
@property (strong, nonatomic) NSNumber *threshold;
-(void)optionChanged:(id)sender;
@end
