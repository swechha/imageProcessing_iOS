//
//  ViewController.m
//  ImageProcessing_ios
//
//  Created by Swechha Prakash on 27/06/13.
//  Copyright (c) 2013 Swechha Prakash. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize imageView = _imageView;
@synthesize effectButton = _effectButton;
@synthesize selectPhotoButton = _selectPhotoButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    
    return cvMat;
}

-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}

-(IBAction)selectPhoto:(id)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    CGSize imageSize = chosenImage.size;
    
    
    //if (imageSize.height > _imageView.frame.size.height || imageSize.width > _imageView.frame.size.width)
    //{
        NSLog(@"Entering the if loop");
        float imageRatio = imageSize.width/imageSize.height;
        float viewRatio = _imageView.frame.size.width/_imageView.frame.size.height;
        float newWidth = 0.0;
        float newHeight = 0.0;
        if (imageRatio > viewRatio)
        {
            newWidth = _imageView.frame.size.width;
            newHeight = imageSize.height/(imageSize.width/newWidth);
        }
        else if (imageRatio < viewRatio)
        {
            newHeight = _imageView.frame.size.height;
            newWidth = imageSize.width/(imageSize.height/newHeight);
        }
        
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
        [chosenImage drawInRect:CGRectMake(0,0,newWidth,newHeight)];
        chosenImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    //}
    
    self.imageView.image = chosenImage;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

-(IBAction)applyEffect:(id)sender
{
    UIImage *inputImage = _imageView.image;
    cv::Mat mat = [self cvMatFromUIImage:inputImage];
    cv::Mat dest_mat(inputImage.size.width, inputImage.size.height, CV_8UC4);
    cv::Laplacian(mat, dest_mat, 3);
    UIImage *finalImage = [self UIImageFromCVMat:dest_mat];
    _imageView.image = finalImage;
}

@end
