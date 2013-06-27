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
@property (nonatomic, retain) IBOutlet UIButton *effectButton;
@property (nonatomic, retain) IBOutlet UIButton *selectPhotoButton;

-(IBAction)selectPhoto:(id)sender;
-(IBAction)applyEffect:(id)sender;

@end
