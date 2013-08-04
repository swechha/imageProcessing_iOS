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
@synthesize selectPhotoButton = _selectPhotoButton;
@synthesize brightness = _brightness;
@synthesize inputImage = _inputImage;

- (void)viewDidLoad
{
    [super viewDidLoad];
    _brightness.minimumValue = 0.00;
    _brightness.maximumValue = 2.00;
    [_brightness setValue:1.00];
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
    _inputImage = info[UIImagePickerControllerEditedImage];
    
    self.imageView.image = _inputImage;
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

-(IBAction)controlBrightness:(UISlider *)sender
{
    if(_imageView.image == NULL)
        return;
    cv::Mat mat = [self cvMatFromUIImage:_inputImage];
    cv::Mat dest_mat(_inputImage.size.width, _inputImage.size.height, CV_8UC4);
    cv::Mat intermediate_mat(_inputImage.size.width, _inputImage.size.height, CV_8UC4);
    
    //cv::flip(mat, dest_mat, 1);
    float currentBrightness = sender.value;
    currentBrightness = currentBrightness-1.00;
    NSLog(@"%f",currentBrightness);
    
    if(currentBrightness < 0.00)
    {
        currentBrightness = fabsf(currentBrightness);
        cv::multiply(mat, currentBrightness, intermediate_mat);
        cv::subtract(mat, intermediate_mat, dest_mat);
    }
    else
    {
        cv::multiply(mat, currentBrightness, intermediate_mat);
        cv::add(mat, intermediate_mat, dest_mat);
    }
    UIImage *finalImage = [self UIImageFromCVMat:dest_mat];
    _imageView.image = finalImage;
}

@end
