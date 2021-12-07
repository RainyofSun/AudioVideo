//
//  PictureFilterViewController.m
//  AudioVideo
//
//  Created by 刘冉 on 2021/9/16.
//

#import "PictureFilterViewController.h"
#import "GPUImageView.h"
#import "GPUImagePicture.h"
#import "GPUImageSobelEdgeDetectionFilter.h"

@interface PictureFilterViewController ()
{
    GPUImagePicture *sourcePicture;
    GPUImageOutput<GPUImageInput> *sepiaFilter;
}
@end

@implementation PictureFilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor orangeColor];
    [self setupUI];
}

- (void)setupUI {
    GPUImageView *primaryView = [[GPUImageView alloc] initWithFrame:self.view.frame];
    self.view = primaryView;
    [self setupDisplayFiltering];
}

- (void)setupDisplayFiltering {
    UIImage *inputImg = [UIImage imageNamed:@"save"];
    sourcePicture = [[GPUImagePicture alloc] initWithImage:inputImg smoothlyScaleOutput:YES];
    sepiaFilter = [[GPUImageSobelEdgeDetectionFilter alloc] init];
    
    GPUImageView *imageView = (GPUImageView *)self.view;
    [sepiaFilter forceProcessingAtSize:imageView.sizeInPixels];
    
    [sourcePicture addTarget:sepiaFilter];
    [sepiaFilter addTarget:imageView];
 
    [sourcePicture processImage];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
