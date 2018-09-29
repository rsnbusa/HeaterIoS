#import "resetVC.h"
#if 1 // set to 1 to enable logs
#define LogDebug(frmt, ...) NSLog([frmt stringByAppendingString:@"[%s]{%d}"], ##__VA_ARGS__,__PRETTY_FUNCTION__,__LINE__);
#else
#define LogDebug(frmt, ...) {}
#endif

@interface resetVC ()

@end

@implementation resetVC


-(void)timeout
{
    if(tumblrHUD)
        [tumblrHUD hide];
    [self showMessage:@"Heater Msg" withMessage:@"Comm Timeout"];
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

    alert = [UIAlertController alertControllerWithTitle:title message:que preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:nil];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [alert dismissViewControllerAnimated:YES completion:nil];
        });
    }


- (void) rxMessage:(NSNotification *) notification
{
    if(tumblrHUD)
        [tumblrHUD hide];
    if(mitimer)
        [mitimer invalidate];
    
    LogDebug (@"RX Successfull %@",notification.userInfo);
    
    if ([[notification name] isEqualToString:@"RShow"])
        [self showMessage:@"Meter Msg" withMessage:notification.userInfo[@"Answer"]];
}
-(void)sendMqtt:(NSString*)mis
{
    [self hud];
    [appDelegate.chan enviaWithQue:mis notikey:@"RShow"];
}

-(void)sendCmd:(NSString*)comando withTitle:(NSString*)title
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:@"Please Confirm" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self sendMqtt:comando];}];
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
    [self sendMqtt:mensa];
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
    [self sendMqtt:mensa];
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
}


-(void)viewDidAppear:(BOOL)animated
{
    NSDictionary *dic;
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(rxMessage:)
                                                 name:@"RShow"
                                               object:dic];
    [self workingIcon];
}

- (void)viewWillDisappear:(BOOL)animated { //Is used as a Save Options if anything was changed Instead of Buttons
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
