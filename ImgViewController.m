//
//  ImageViewController.m
//
//  Created by CS193p Instructor.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "ImgViewController.h"
#import "ImageScrollView.h"
#import "Image+Manage.h"
@interface ImgViewController()<UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet ImageScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation ImgViewController

@synthesize scrollView = _scrollView;
@synthesize imageView = _imageView;
@synthesize img = _img;

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    self.scrollView.delegate = self;
    self.scrollView.tileContainerView = self.imageView;
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

-(void)loadImage
{
    if (self.imageView) {
        dispatch_queue_t imageDownloadQ = dispatch_queue_create("Image Loader", NULL);
        dispatch_async(imageDownloadQ, ^{
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfFile:[self.img imageFilePath]]];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.imageView.image = image;
                self.imageView.frame = CGRectMake(0,0,image.size.width,image.size.height);
                self.scrollView.contentSize = image.size;
                
            });
        });
        dispatch_release(imageDownloadQ);
    }
}

-(void)setImg:(Image *)img
{
    if (!_img) {
        _img = img;
        [self loadImage];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.imageView.image && self.img) [self loadImage];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)viewDidUnload
{
    self.imageView = nil;
    [self setScrollView:nil];
    [super viewDidUnload];
}

@end
