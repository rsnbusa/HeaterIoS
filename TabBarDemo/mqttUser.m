//
//  mqttUser.m
//  MeterIoT
//
//  Created by Robert on 2/9/17.
//  Copyright © 2017 Colin Eberhardt. All rights reserved.
//

#import "mqttUser.h"
#import "httpVC.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#import "AppDelegate.h"

#if 1 // set to 1 to enable logs
#define LogDebug(frmt, ...) NSLog([frmt stringByAppendingString:@"[%s]{%d}"], ##__VA_ARGS__,__PRETTY_FUNCTION__,__LINE__);
#else
#define LogDebug(frmt, ...) {}
#endif

extern BOOL CheckWiFi();

@interface mqttUser ()

@end

@implementation mqttUser

-(void)timeout
{
    if(tumblrHUD)
        [tumblrHUD hide];
    [self showMessage:@"Meter Msg" withMessage:@"Comm Timeout"];
}

-(void)hud
{
    
    if(tumblrHUD)
    {
        [tumblrHUD hide];
        tumblrHUD=nil;
    }

        tumblrHUD = [[AMTumblrHud alloc] initWithFrame:CGRectMake((CGFloat) (_hhud.frame.origin.x),
                                                                  (CGFloat) (_hhud.frame.origin.y), 55, 20)];
        tumblrHUD.hudColor = _hhud.backgroundColor;
        [self.view addSubview:tumblrHUD];
        [tumblrHUD showAnimated:YES];
        mitimer=[NSTimer scheduledTimerWithTimeInterval:10
                                                 target:self
                                               selector:@selector(timeout)
                                               userInfo:nil
                                                repeats:NO];

}


-(void)showMessage:(NSString*)title withMessage:(NSString*)que
{
    if(alert)
    {
        [alert dismissViewControllerAnimated:YES completion:nil];
        alert=nil;
    }

        alert = [UIAlertController alertControllerWithTitle:title
                                                                       message:que
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:nil];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [alert dismissViewControllerAnimated:YES completion:nil];
        });
}

-(IBAction)update:(id)sender
{
    if([_meterid.text isEqualToString:@""] || [_startkwh.text isEqualToString:@""] || [_server.text isEqualToString:@""] || [_port.text isEqualToString:@""])
        return;
    [[NSUserDefaults standardUserDefaults] setObject:[_server.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] forKey:@"mqttserver"];
    [[NSUserDefaults standardUserDefaults] setObject:[_port.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] forKey:@"mqttport"];
    [[NSUserDefaults standardUserDefaults] setObject:[_meterid.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] forKey:@"mqttuser"];
    [[NSUserDefaults standardUserDefaults] setObject:[_startkwh.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] forKey:@"mqttpass"];
    [[NSUserDefaults standardUserDefaults]  synchronize];
    
    mis=[NSString stringWithFormat:@"mqtt?password=zipo&uupp=%@&passq=%@&qqqq=%@&port=%@",_meterid.text,_startkwh.text,_server.text,_port.text];
  //  [self hud];
    [appDelegate.chan enviaWithQue:mis notikey:nil];
}


-(void)workingIcon
{
    
    UIImage *licon;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *final=[NSString stringWithFormat:@"%@.txt",[appDelegate.workingBFF valueForKey:@"bffName"]];
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:final];
    licon=[UIImage imageWithContentsOfFile:filePath];
    if (licon==NULL)
        licon = [UIImage imageNamed:@"camera"];//need a photo
    _bffIcon.image=licon;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self workingIcon];
    _server.text= [appDelegate.workingBFF valueForKey:@"bffMQTT"];
    _port.text= [NSString stringWithFormat:@"%@",[appDelegate.workingBFF valueForKey:@"bffMQTTPort"]];
    _meterid.text= [appDelegate.workingBFF valueForKey:@"bffMqttU"];
    _startkwh.text= [appDelegate.workingBFF valueForKey:@"bffMqttP"];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self workingIcon];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    NSNumber *passw=[[NSUserDefaults standardUserDefaults]objectForKey:@"password"];
    if (passw.integerValue==0)
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
