//
//  petInfoViewController.h
//  FeedIoT
//
//  Created by Robert on 3/13/16.
//

#import <UIKit/UIKit.h>
#import "FirstViewController.h"
#import "AppDelegate.h"
#import "MultiSelectSegmentedControl.h"
#import "TextFieldValidator.h"
#import "httpVC.h"
#import "MBProgressHUD.h"


@interface petInfoViewController : UIViewController
{
    FirstViewController *fc;
    BOOL changef,keyboardIsShown,sslStatus ;
    CGFloat animatedDistance;
    AppDelegate *appDelegate;
    NSString *mis;
    NSMutableString *answer;
    NSIndexSet *selectedIndices;
    NSMutableArray *selectedItemsArray;
    NSArray *wifis;
    httpVC *comm;
    UIView *backGroundBlurr;
    NSMutableString *ap;
    MBProgressHUD *hud;
    UIImage *sslOn, *sslOff;
}

@property (strong) IBOutlet TextFieldValidator *petName,*phone,*email,*watts,*kwh,*galons,*volts,*water,*group,*mqttPort,*minutes;
@property (strong) IBOutlet UIImageView *bffIcon;
@property (strong) IBOutlet UIButton *sslbutton;
@property (strong) IBOutlet UISwitch *offline,*limit,*autot,*monitor;
@property (strong) IBOutlet UITableView *bjTable;
@property (strong) IBOutlet UILabel *bfname,*vetphone,*emaill,*birth,*opmode;
@property (strong) IBOutlet UISegmentedControl *transport;
@end
