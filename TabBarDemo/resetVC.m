//
//  resetVC.m
//  MeterIoT
//
//  Created by Robert on 2/8/17.
//  Copyright © 2017 Colin Eberhardt. All rights reserved.
//

#import "resetVC.h"
#if 1 // set to 1 to enable logs
#define LogDebug(frmt, ...) NSLog([frmt stringByAppendingString:@"[%s]{%d}"], ##__VA_ARGS__,__PRETTY_FUNCTION__,__LINE__);
#else
#define LogDebug(frmt, ...) {}
#endif


@interface resetVC ()

@end

@implementation resetVC

id yo;

-(void)killBill
{
    if(tumblrHUD)
        [tumblrHUD hide];
    [self showMessage:@"Heater Msg" withMessage:@"Comm Timeout"];
}

-(void)hud
{
    dispatch_async(dispatch_get_main_queue(), ^{
        tumblrHUD = [[AMTumblrHud alloc] initWithFrame:CGRectMake((CGFloat) (_hhud.frame.origin.x),
                                                                  (CGFloat) (_hhud.frame.origin.y), 55, 20)];
        tumblrHUD.hudColor = _hhud.backgroundColor;
        [self.view addSubview:tumblrHUD];
        [tumblrHUD showAnimated:YES];
        mitimer=[NSTimer scheduledTimerWithTimeInterval:10
                                                 target:self
                                               selector:@selector(killBill)
                                               userInfo:nil
                                                repeats:NO];
    });
}
-(void)setCallBackNull
{
    [appDelegate.client setMessageHandler:NULL];
}

-(void)showMessage:(NSString*)title withMessage:(NSString*)que
{
    if(mitimer)
        [mitimer invalidate];
    dispatch_async(dispatch_get_main_queue(), ^{[tumblrHUD hide];});

        UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                       message:que
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  
                                                                  
                                                              }];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [alert dismissViewControllerAnimated:YES completion:nil];
        });
    }

MQTTMessageHandler resetx=^(MQTTMessage *message)
{
    LogDebug(@"Heater SettingsMsg %@ %@",message.payload,message.payloadString);
    dispatch_async(dispatch_get_main_queue(), ^{
        [yo showMessage:@"HeaterIoT Settings Msg" withMessage:message.payloadString];
    });
};
//extern BOOL CheckWiFi();

-(void)sendCmd:(NSString*)comando withTitle:(NSString*)title
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:@"Please Confirm" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self hud];
        yo=self;
        if(appDelegate.client)
            [appDelegate.client setMessageHandler:resetx];
        [comm lsender:comando andAnswer:NULL  andTimeOut:2 vcController:self];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:defaultAction];
    [alert addAction:cancelAction];
  
    // Present action where needed
        [self presentViewController:alert animated:YES completion:nil];
  
}

-(IBAction)displayTimer:(UISlider*)sender
{
    
    int son=sender.value;
    _dispT.text=[NSString stringWithFormat:@"%d Mins",son];
    [appDelegate.workingBFF setValue:[NSNumber numberWithInteger:son] forKey:@"bffDisp"];

}

- (IBAction)displaylengthSliderDidEndSliding:(UISlider*)sender {
    NSString *mensa;
    int son=sender.value;
    mensa=[NSString stringWithFormat:@"display?password=zipo&disptime=%d",son];
    [self hud];
    [comm lsender:mensa andAnswer:NULL  andTimeOut:2 vcController:self];
    NSManagedObjectContext *context =
    [appDelegate managedObjectContext];
    NSError *error;
    [context save:&error];
}

-(IBAction)amps:(UISlider*)sender
{
  
    int son=sender.value/0.5;
    float final=0.5 * (float)son;
    _ampText.text=[NSString stringWithFormat:@"%.1f",final];
    [appDelegate.workingBFF setValue:[NSNumber numberWithFloat:final] forKey:@"bffAmps"];
}

- (IBAction)lengthSliderDidEndSliding:(UISlider*)sender {
    NSString *mensa;
    int son=sender.value/0.5;
    float final=0.5 * (float)son;
    mensa=[NSString stringWithFormat:@"ampscalib?password=zipo&calib=%.1f",final];
    [self hud];
    [comm lsender:mensa andAnswer:NULL  andTimeOut:2 vcController:self];
    NSManagedObjectContext *context =
    [appDelegate managedObjectContext];
    NSError *error;
    [context save:&error];
}

-(IBAction)firmware:(id)sender
{
    [self sendCmd:@"firmware?password=zipo" withTitle:@"Update Firmware"];
}

-(IBAction)reset:(id)sender
{
    [self sendCmd:@"reset?password=zipo" withTitle:@"Reset System"];
}

-(IBAction)resetStats:(id)sender
{
    [self sendCmd:@"resetstats?password=zipo" withTitle:@"Reset Log"];
}

-(void)workingIcon
{
    UIImage *licon;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //   NSString *final=[NSString stringWithFormat:@"%@.png",[appDelegate.workingBFF valueForKey:@"bffName"]];
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
    comm=[httpVC new];
    if(appDelegate.client)
        [appDelegate.client setMessageHandler:resetx];
    _ampText.text=[NSString stringWithFormat:@"%.1f", (float)[[appDelegate.workingBFF valueForKey:@"bffAmps"]floatValue]];
    _ampSlider.value=(float)[[appDelegate.workingBFF valueForKey:@"bffAmps"]floatValue];
    _dispT.text=[NSString stringWithFormat:@"%d", [[appDelegate.workingBFF valueForKey:@"bffDisp"]integerValue]];
    _dispSlider.value=(float)[[appDelegate.workingBFF valueForKey:@"bffDisp"]integerValue];
    
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    yo=self;
    [self workingIcon];
    if(appDelegate.client)
        [appDelegate.client setMessageHandler:resetx];
}
 
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
