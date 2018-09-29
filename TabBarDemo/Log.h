//
//  Log.h
//  GarageIoT
//
//  Created by Robert on 6/15/17.
//  Copyright © 2017 Colin Eberhardt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "AMTumblrHud.h"
@interface Log : UIViewController
{
    NSString *mis;
    AppDelegate* appDelegate;
    bool save;
    NSMutableArray *entries;
    NSInteger randomNumber;
    AMTumblrHud *tumblrHUD ;
    NSTimer *mitimer;
    UIAlertController* alert;
}
@property (strong) IBOutlet UIImageView *bffIcon,*hhud;
@property (strong) IBOutlet UITableView *table;


@end
