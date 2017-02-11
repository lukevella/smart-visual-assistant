//
//  SettingsViewController.m
//  Object Recognizer
//
//  Created by Luke Vella on 3/1/12.
//  Copyright (c) 2012 N/A. All rights reserved.
//

#import "SettingsViewController.h"
#define FEATURE_DETECTORS 0
#define OTHER 1

@implementation SettingsViewController

@synthesize featureDetectors = _featureDetectors;
@synthesize selectedFeatureDetector = _selectedFeatureDetector;
@synthesize sectionTitles = _sectionTitles;
@synthesize otherOptions = _otherOptions;
@synthesize selectedDescriptorExtractor = _selectedDescriptorExtractor;
@synthesize selectedMatcher = _selectedMatcher;
@synthesize distanceRatio = _distanceRatio;
@synthesize threshold = _threshold;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
    

    
    if (_featureDetectors == nil){
        _featureDetectors = [[NSArray alloc] initWithObjects:
                             [NSArray arrayWithObjects:@"SIFT",@"SIFT",@"FlannBased",[NSNumber numberWithFloat:0.7],[NSNumber numberWithFloat:7], nil],
                             [NSArray arrayWithObjects:@"SURF",@"SURF",@"FlannBased",[NSNumber numberWithFloat:0.6],[NSNumber numberWithFloat:5], nil],
                             [NSArray arrayWithObjects:@"ORB",@"ORB",@"BruteForce-Hamming",[NSNumber numberWithFloat:0.7],[NSNumber numberWithFloat:7], nil],
                             [NSArray arrayWithObjects:@"MSER",@"SURF",@"FlannBased",[NSNumber numberWithFloat:0.7],[NSNumber numberWithFloat:5], nil],
                             nil];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _selectedFeatureDetector = [defaults objectForKey:@"Feature Detector"];    
    
    _sectionTitles = [[NSArray alloc] initWithObjects:@"Presets", @"Other", nil];
    
    BOOL HUDEnabled = [[defaults objectForKey:@"HUD"] boolValue];
    _otherOptions = [[NSArray alloc] initWithObjects:[NSDictionary dictionaryWithObjectsAndKeys: 
                                                      [NSNumber numberWithBool:HUDEnabled], @"value",
                                                      @"HUD", @"name", nil], nil];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case FEATURE_DETECTORS:
            return [_featureDetectors count];
        case OTHER:
            return [_otherOptions count];
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = nil;
    UITableViewCell *cell = nil;
    
    
    switch (indexPath.section) {
        case FEATURE_DETECTORS:
            CellIdentifier = @"Algorithm";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            cell.textLabel.text = [[_featureDetectors objectAtIndex:indexPath.row] objectAtIndex:0];
            if ([cell.textLabel.text isEqualToString:_selectedFeatureDetector]){
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            break;
        case OTHER:
            CellIdentifier = @"Toggable";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            cell.textLabel.text = [[_otherOptions objectAtIndex:indexPath.row] objectForKey:@"name"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
            cell.accessoryView = switchView;
            cell.tag = indexPath.row;
            [switchView setOn:[[[_otherOptions objectAtIndex:indexPath.row] objectForKey:@"value"] boolValue] animated:NO];
            [switchView addTarget:self action:@selector(optionChanged:) forControlEvents:UIControlEventValueChanged];
            break;
    }
    
    return cell;
}

-(void)optionChanged:(id)sender
{
    UISwitch *switcher = sender;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithBool:switcher.on] forKey:[(NSDictionary *)[_otherOptions objectAtIndex:switcher.tag] objectForKey:@"name"]];
    [defaults synchronize];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [_sectionTitles objectAtIndex:section];
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    switch (indexPath.section) {
        case FEATURE_DETECTORS:
            _selectedFeatureDetector = [[_featureDetectors objectAtIndex:indexPath.row] objectAtIndex:0];
            _selectedDescriptorExtractor = [[_featureDetectors objectAtIndex:indexPath.row] objectAtIndex:1];
            _selectedMatcher = [[_featureDetectors objectAtIndex:indexPath.row] objectAtIndex:2];
            _distanceRatio = [[_featureDetectors objectAtIndex:indexPath.row] objectAtIndex:3];
            _threshold = [[_featureDetectors objectAtIndex:indexPath.row] objectAtIndex:4];
            [defaults setObject:_selectedFeatureDetector forKey:@"Feature Detector"];
            [defaults setObject:_selectedDescriptorExtractor forKey:@"Descriptor Extractor"];
            [defaults setObject:_selectedMatcher forKey:@"Matcher"];
            [defaults setObject:_distanceRatio forKey:@"Distance Ratio"];
            [defaults setObject:_threshold forKey:@"Threshold"];
            break;
        default:
            break;
    } 
    [defaults synchronize];
    [tableView reloadData];
}

@end
