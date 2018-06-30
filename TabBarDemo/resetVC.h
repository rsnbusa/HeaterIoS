//
//  resetVC.h
//  MeterIoT
//
//  Created by Robert on 2/8/17.
//  Copyright © 2017 Colin Eberhardt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "httpVC.h"
#import "AppDelegate.h"

@interface resetVC : UIViewController
{
    httpVC *comm;
    NSString *mis;
    AppDelegate* appDelegate;
}

@property (strong) IBOutlet UIImageView *bffIcon;
@property (strong) IBOutlet UISlider *ampSlider,*dispSlider;
@property (strong) IBOutlet UILabel *ampText,*dispT;
@end
