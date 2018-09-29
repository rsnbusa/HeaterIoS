//
//  FirstViewController.h
//  FoodAuto
//
//  Created by Robert on 3/2/16.
//  Copyright © 2016 Robert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "CCColorCube.h"
#import "httpVC.h"
#import "AMTumblrHud.h"

@interface FirstViewController : UIViewController <UIScrollViewDelegate, NSNetServiceDelegate, NSNetServiceBrowserDelegate,UICollectionViewDataSource, UICollectionViewDelegate,NSStreamDelegate >
{
    UIImage *wifiOnImage,*wifiOffImage,*imagel,*grid,*pano,*heaterOn,*heaterOff;
    AppDelegate *appDelegate;
    NSString *wmqtt;
   
    BOOL viewmodef,batchf,loadFlag;
    int fotoHV;
    int indexOfPage;
    CCColorCube *colorCube;
    UIView *backGroundBlurr;
    int oldcomo;
    UIImage *passOn,*passOff;
    UIImageView *lscrollView;
    AMTumblrHud *tumblrHUD ;
    NSTimer *mitimer;
    UIAlertController* alert;
}
//@property (strong,nonatomic) IBOutlet
@property (strong) NSMutableString *host,*answer,*mqttServer;
@property (strong) IBOutlet UILabel *petName;
@property  (strong) NSNumber *effects;
@property BOOL collect;
@property (strong, nonatomic) IBOutlet UIScrollView         *picScroll;
@property (strong, nonatomic) IBOutlet UIImageView          *hhud;
@property (strong, nonatomic) IBOutlet UICollectionView     *album;
@property (strong, nonatomic) IBOutlet UISlider             *fotoSize;
@property (strong, nonatomic) IBOutlet UIButton             *onOff,*passSW,*addBut;
@property (strong, nonatomic) NSNetServiceBrowser           *netServiceBrowser;
@property (nonatomic, strong, readwrite) NSOutputStream     *networkStream;
@property (nonatomic, strong, readwrite) NSInputStream      *fileStream;
@property (nonatomic, assign, readonly ) uint8_t            *buffer;
@property (nonatomic, assign, readwrite) size_t             bufferOffset;
@property (nonatomic, assign, readwrite) size_t             bufferLimit;
@end

