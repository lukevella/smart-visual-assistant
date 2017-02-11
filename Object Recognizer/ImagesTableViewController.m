//
//  ImagesTableViewController.m
//  Object Recognizer
//
//  Created by Luke Vella on 3/30/12.
//  Copyright (c) 2012 N/A. All rights reserved.
//

#import "ImagesTableViewController.h"
#import "NSString+Unique.h"
#import "Image+Manage.h"
#import "UIImage+Resize.h"
#import "ImgViewController.h"

@interface ImagesTableViewController ()
@property (strong,nonatomic) UIImagePickerController *imagePicker;
@end

@implementation ImagesTableViewController

@synthesize imagePicker = _imagePicker;
@synthesize item = _item;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)setItem:(Item *)item
{
    _item = item;
    self.title = item.name;
    [self setupFetchedResultsController];
}

-(void)setupFetchedResultsController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Image"];
    request.predicate = [NSPredicate predicateWithFormat:@"ofItem.name = %@",self.item.name];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"unique" ascending:YES]];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request 
                                                                        managedObjectContext:self.item.managedObjectContext 
                                                                          sectionNameKeyPath:nil 
                                                                                   cacheName:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0 green:0.7 blue:0.9 alpha:1];
    UIButton *addImg = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    addImg.frame = CGRectMake(0, 15, 280, 40);
    [addImg setTitle:@"Add Image From Camera" forState:UIControlStateNormal];
    addImg.backgroundColor = [UIColor clearColor];
    [addImg setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [addImg addTarget:self action:@selector(addNewImage:) forControlEvents:UIControlEventTouchUpInside];
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(20, 0, 280, 100)];
    [footerView addSubview:addImg];
    self.tableView.tableFooterView = footerView;
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
	// Do any additional setup after loading the view.
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObjectContext *context = self.item.managedObjectContext;
    [Image deleteImage:[self.fetchedResultsController objectAtIndexPath:indexPath] inManagedObjectContext:context];
}

-(void)addNewImage:(id)sender
{
    // Create image picker controller
    self.imagePicker = [[UIImagePickerController alloc] init];
    
    // Set source to the camera
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        self.imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
    } else {
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    }
    
    // Delegate is self
    self.imagePicker.delegate = self;
    
    // Allow editing of image ?
    self.imagePicker.allowsEditing = NO;
    
    // Show image picker
    [self presentModalViewController:self.imagePicker animated:YES];
    
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"Called the callback");
    // Access the uncropped image from info dictionary
    UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    UIImage *resizedImage = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(240, 180) interpolationQuality:kCGInterpolationDefault];
    image = nil;
    // Save image
    NSURL *documentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    
    NSString *uniqueID = [NSString getUniqueFilenameInFolder:[documentsDirectory description]];
    dispatch_queue_t imageProcQ = dispatch_queue_create("Image Processing", NULL);
    dispatch_async(imageProcQ, ^{
        [Image image:resizedImage forItem:self.item inManagedObjectContext:self.item.managedObjectContext withUniqueID:uniqueID];
    });
    dispatch_release(imageProcQ);
    
    //NSLog(@"New image created: %@",newImage.unique);
    [self dismissModalViewControllerAnimated:YES];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Image Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    Image *image = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.imageView.frame = CGRectMake(10, 10, 20, 20);
    cell.textLabel.text = [NSString stringWithFormat:@"%@",image.unique];
    cell.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfFile:[image imageFilePath]]];
    return cell;
}
- (void)viewDidUnload
{
    NSLog(@"Unloading View");
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    Image *image = [self.fetchedResultsController objectAtIndexPath:indexPath]; 
    NSLog(@"Image %u select",indexPath.row);
    if ([segue.identifier isEqualToString:@"Show Image"]) {
        [segue.destinationViewController setImg:image];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
