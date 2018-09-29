//
//  mqttUser.h
//  MeterIoT
//
//  Created by Robert on 2/9/17.
//  Copyright © 2017 Colin Eberhardt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "AMTumblrHud.h"

@interface mqttUser : UIViewController
{
    NSString *mis;
    AppDelegate* appDelegate;
    AMTumblrHud *tumblrHUD ;
    NSTimer *mitimer;
    UIAlertController* alert;
}
@property (strong) IBOutlet UIImageView *bffIcon,*hhud;
@property (strong) IBOutlet UITextField *meterid,*startkwh,*server,*port;

@end
