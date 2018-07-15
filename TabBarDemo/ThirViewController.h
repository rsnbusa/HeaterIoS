//
//  ThirViewController.h
//  FoodAuto
//
//  Created by Robert on 3/2/16.
//  Copyright © 2016 Robert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MultiSelectSegmentedControl.h"
#include "FirstViewController.h"
#import "HMSegmentedControl.h"
#import "AppDelegate.h"
#import "TextFieldValidator.h"
#import "httpVc.h"
#import "CircularPickerView.h"
#import "AMTumblrHud.h"

@interface ThirViewController : UIViewController
{
    NSIndexSet *selectedIndices;
    NSMutableArray *selectedItemsArray;
    FirstViewController  *fc;
    NSTimer *aTimer;
    HMSegmentedControl *segmentedControl2;
    bool dontsavef;
    int theNum;
    AppDelegate *appDelegate;
    httpVC *comm;
    UIView *backGroundBlurr;
    UIImage *arrowConnected, *arrowDisconnected;
    BOOL arrowState;
    AMTumblrHud *tumblrHUD ;
    NSTimer *mitimer;
}

@property int theNum;
@property (strong) IBOutlet UIDatePicker *datePicker,*hastaPicker;
@property (strong) IBOutlet MultiSelectSegmentedControl *dias;
@property (strong) IBOutlet TextFieldValidator *name,*passww;
@property (strong) IBOutlet UIImageView *bffIcon,*email,*hhud;
@property (strong) IBOutlet UISwitch *notis,*once;
@property (strong) IBOutlet UIButton *arrow;
@property (strong) IBOutlet UILabel *temp,*lowTempLabel;
@property (strong) IBOutlet CircularPickerView *circleTemp,*lowTemp;
@property BOOL dirtyt,dirtys;
@property int openT,waitT,lastSegment;
@end
