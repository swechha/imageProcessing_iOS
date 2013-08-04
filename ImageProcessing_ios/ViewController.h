//
//  ViewController.h
//  ImageProcessing_ios
//
//  Created by Swechha Prakash on 27/06/13.
//  Copyright (c) 2013 Swechha Prakash. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UIButton *selectPhotoButton;
@property (nonatomic, retain) IBOutlet UISlider *brightness;
@property (readonly) UIImage *inputImage;

-(IBAction)selectPhoto:(id)sender;
-(IBAction)controlBrightness:(UISlider *)sender;

@end
