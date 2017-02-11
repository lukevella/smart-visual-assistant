//
//  ObjectsTableViewController.m
//  Object Recognizer
//
//  Created by Luke Vella on 3/28/12.
//  Copyright (c) 2012 N/A. All rights reserved.
//

#import "ObjectsTableViewController.h"
#import "Item+Create.h"

@interface ObjectsTableViewController ()
@end

@implementation ObjectsTableViewController

@synthesize context = _context;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)setContext:(NSManagedObjectContext *)context
{
    _context = context;
    [self setupFetchedResultsController];
}

-(void)setupFetchedResultsController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Item"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request 
                                                                        managedObjectContext:self.context 
                                                                          sectionNameKeyPath:nil 
                                                                                   cacheName:nil];
    
    
}


-(void)viewWillAppear:(BOOL)animated
{
    NSIndexPath *selection = [self.tableView indexPathForSelectedRow];
	if (selection){
		[self.tableView deselectRowAtIndexPath:selection animated:YES];
    }
	[self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0 green:0.7 blue:0.9 alpha:1];
    UIButton *addObj = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    addObj.frame = CGRectMake(0, 15, 280, 40);
    [addObj setTitle:@"Add Object" forState:UIControlStateNormal];
    addObj.backgroundColor = [UIColor clearColor];
    [addObj setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [addObj addTarget:self action:@selector(addNewObject:) forControlEvents:UIControlEventTouchUpInside];
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(20, 0, 280, 100)];
    [footerView addSubview:addObj];
    self.tableView.tableFooterView = footerView;
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)addNewObject:(id)sender
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Create New Object" message:@"Enter the name of the object:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Create", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{ 
    if (buttonIndex == 1) {
        [self.context performBlock:^{
            Item *obj = [Item itemWithName:[[alertView textFieldAtIndex:0] text] inManagedObjectContext:self.context];;
            NSLog(@"New object %@ created",obj.name);
        } ];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{   
    [Item deleteItem:[self.fetchedResultsController objectAtIndexPath:indexPath] inManagedObjectContext:self.context];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Object Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    Item *obj = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = obj.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu Images",[obj.images count]];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    Item *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
    // be somewhat generic here (slightly advanced usage)
    // we'll segue to ANY view controller that has a photographer @property
    if ([segue.destinationViewController respondsToSelector:@selector(setItem:)]) {
        // use performSelector:withObject: to send without compiler checking
        // (which is acceptable here because we used introspection to be sure this is okay)
        [segue.destinationViewController performSelector:@selector(setItem:) withObject:item];
    } 
}

@end
