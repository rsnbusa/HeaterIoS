//
//  resetVC.h
//  MeterIoT
//
//  Created by Robert on 2/8/17.
//  Copyright © 2017 Colin Eberhardt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "AMTumblrHud.h"

@interface resetVC : UIViewController
{
    NSString *mis;
    AppDelegate* appDelegate;
    AMTumblrHud *tumblrHUD ;
    NSTimer *mitimer;
    UIAlertController* alert;
}

@property (strong) IBOutlet UIImageView *bffIcon,*hhud;
@property (strong) IBOutlet UISlider *ampSlider,*dispSlider;
@property (strong) IBOutlet UILabel *ampText,*dispT;
@end
