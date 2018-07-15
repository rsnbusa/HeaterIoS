//
//  Timings.m
//  FeedIoT
//
#import "Timings.h"
#import "servingCell.h"
#import "AppDelegate.h"
#import "ThirViewController.h"
#import "httpVc.h"
#import "blurLabel.h"
#import "btSimplePopUp.h"

#if 1 // set to 1 to enable logs
#define LogDebug(frmt, ...) NSLog([frmt stringByAppendingString:@"[%s]{%d}"], ##__VA_ARGS__,__PRETTY_FUNCTION__,__LINE__);
#else
#define LogDebug(frmt, ...) {}
#endif


@interface Timings ()

@end


@implementation Timings
@synthesize editab,bffIcon,marker,sunmoon,time,popUp,mini,fauceti,textimage,finalImage,fromLabel,totKwh,totValor,amps,ampslabel,tempHum,starter,l24,l6,l12,l18,statusb;
id yo,app;

//#define kWh 0.1232f
#define consumoHora 1.0

-(void)killBill
{
    if(tumblrHUD)
        [tumblrHUD hide];
    [self showMessage:@"HeatIoT Msg" withMessage:@"Comm Timeout"];
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

-(void)showErrorMessage
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"TimeOut"
                                                                   message:@"Maybe out of range or off. Still meal was deleted for later sync"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                       //       [self performSegueWithIdentifier:@"doneEditVC" sender:self];
                                                          }];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)showOkMessage
{
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Delete Timer"
                                                                   message:[NSString stringWithFormat:@"Confirmed by %@",[appDelegate.workingBFF valueForKey:@"bffName"]]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              //       [self performSegueWithIdentifier:@"doneEditVC" sender:self];
                                                          }];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)showMessage:(NSString*)title withMessage:(NSString*)que
{
    if(mitimer)
        [mitimer invalidate];
    dispatch_async(dispatch_get_main_queue(), ^{ [tumblrHUD hide];});
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:que
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              //       [self performSegueWithIdentifier:@"doneEditVC" sender:self];
                                                          }];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)manda:(int)a
{
//    tsync.text=[NSString stringWithFormat:@"%d",a];
    
    //add each entry again
    NSManagedObject *este=[appDelegate.servingsArray objectAtIndex:a-1];
    [este setValue:[NSDate date] forKey:@"dateAdded"];
    uint8_t days=[[este valueForKey:@"servDays"]integerValue];
    NSString *myNewString = [[este valueForKey:@"servName"] stringByReplacingOccurrencesOfString:@"\\s"
                                                                                      withString:@"%20"
                                                                                         options:NSRegularExpressionSearch
                                                                                           range:NSMakeRange(0, [[este valueForKey:@"servName"] length])];
    
    int diff=(int)[[este valueForKey:@"hastaDate"] timeIntervalSince1970]-(int)[[este valueForKey:@"servDate"]timeIntervalSince1970];
    //  LogDebug(@"Servdate %@ HastaDate %@ diff %lu",[este valueForKey:@"servDate"],[este valueForKey:@"hastaDate"],diff);
    
    mis=[NSString stringWithFormat:@"sync?pos=%d&day=%d&fromdate=%d&duration=%d&id=%@&notis=%d&onOff=%d&temp=%d",a-1,days,(int)[[este valueForKey:@"servDate"]timeIntervalSince1970],diff, myNewString,(int)[[este valueForKey:@"servNotis"] integerValue],(int)[[este valueForKey:@"servOnOff"] integerValue],(int)[[este valueForKey:@"servTempMax"] integerValue]];//multiple arguments
    if(appDelegate.client){
        viejo=appDelegate.client.messageHandler;
        [appDelegate.client setMessageHandler:NULL];//nada
    }
    [self hud];
    [comm lsender:mis andAnswer:NULL andTimeOut:[[[NSUserDefaults standardUserDefaults]objectForKey:@"txTimeOut"] intValue] vcController:self];
    
}

-(void)syncThem
{
//    tsync.hidden=NO;
 //   syncf=true;
    for (int a=(int)appDelegate.servingsArray.count; a>0; a--)
    {
            [self manda:a];

    }
    mis=[NSString stringWithFormat:@"reset?password=zipo"];//multiple aruments
    if(appDelegate.client){
        viejo=appDelegate.client.messageHandler;
        [appDelegate.client setMessageHandler:generalAnswer];
    }
    [comm lsender:mis andAnswer:NULL andTimeOut:[[[NSUserDefaults standardUserDefaults]objectForKey:@"txTimeOut"] intValue] vcController:self];


}

-(void)startSync
{
    int reply;
    
    if (appDelegate.servingsArray.count==0)
    {
        mis=[NSString stringWithFormat:@"Zerousers"];
        if(appDelegate.client){
            viejo=appDelegate.client.messageHandler;
            [appDelegate.client setMessageHandler:NULL];
        }
        [comm lsender:mis andAnswer:NULL andTimeOut:[[[NSUserDefaults standardUserDefaults]objectForKey:@"txTimeOut"] intValue] vcController:self];
    }
    else
    {
        mis=[NSString stringWithFormat:@"Zerousers"];
        if(appDelegate.client){
            viejo=appDelegate.client.messageHandler;
            [appDelegate.client setMessageHandler:NULL];
        }
        [comm lsender:mis andAnswer:NULL andTimeOut:[[[NSUserDefaults standardUserDefaults]objectForKey:@"txTimeOut"] intValue] vcController:self];
        [self performSelectorOnMainThread:@selector(syncThem) withObject:NULL waitUntilDone:NO];
    }
}


-(void)longPressTap:(UILongPressGestureRecognizer*)sender
{
    //  UIGestureRecognizer *recognizer = (UIGestureRecognizer*) sender;
    if (sender.state == UIGestureRecognizerStateEnded)
        [self startSync];
}

-(void)cloneTimers:(UILongPressGestureRecognizer*)sender
{
    //  UIGestureRecognizer *recognizer = (UIGestureRecognizer*) sender;
    if (sender.state == UIGestureRecognizerStateEnded)
        [self getTimersHeater];
}

-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue {
    
}

-(IBAction)editar:(UIBarButtonItem *)sender {
    if (!editf)
    {
        editab.tintColor=[UIColor redColor];

     //     [table setEditing:YES animated:YES];
    }
    else
    {
        editab.tintColor=[UIColor blueColor];
       // [table setEditing:NO animated:YES];
    }
    
    editf=!editf;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"servingsEditVC"]) {
        UINavigationController *destViewController = segue.destinationViewController;
        NSArray *viewControllers = destViewController.viewControllers;
        ThirViewController  *theVC = (ThirViewController *)[viewControllers objectAtIndex:0];
        theVC.theNum = (int)appDelegate.servingsArray.count;
    }
}

-(IBAction)batch:(id)sender
{
 //   NSLog(@"Batch");
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
    bffIcon.image=licon;
}

-(void) checkLogin
{
    if (!appDelegate.passwordf)
    {
        LogDebug(@"Need to get password again");
        [self performSegueWithIdentifier:@"getPassword" sender:self];
    }
}
-(void)blurScreen
{
CGRect screenSize = [UIScreen mainScreen].bounds;
UIImage *screenShot = [self.view screenshot];
UIImage *blurImage  = [screenShot blurredImageWithRadius:10.5 iterations:2 tintColor:nil];
backGroundBlurr = [[UIImageView alloc]initWithImage:blurImage];
backGroundBlurr.frame = CGRectMake(0, 0, screenSize.size.width, screenSize.size.height);
[self.view addSubview:backGroundBlurr];
}

- (void)delete
{
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Delete Timer"
                                                                   message:@"Please Confirm delete"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                                 [backGroundBlurr removeFromSuperview];
                                                              mis=[NSString stringWithFormat:@"timerDel?pos=%d&name=%@",globalSlice,[[appDelegate.servingsArray objectAtIndex:globalSlice] valueForKey:@"servName"]];
                                                              [context deleteObject:(NSManagedObject*)[appDelegate.servingsArray objectAtIndex:globalSlice]];
                                                              [appDelegate.servingsArray removeObjectAtIndex:globalSlice];
                                                              NSError *error;
                                                              if(![context save:&error])
                                                                  LogDebug(@"Save error %@",error);
                                                              
                                                              [[appDelegate.tabBarController.tabBar.items objectAtIndex:1] setBadgeValue:[NSString stringWithFormat:@"%ld",appDelegate.servingsArray.count]];
                                                              if(appDelegate.client){
                                                                  viejo=appDelegate.client.messageHandler;
                                                                  [appDelegate.client setMessageHandler:generalAnswer];
                                                              }
                                                              [self hud];
                                                             [comm lsender:mis andAnswer:NULL andTimeOut:[[[NSUserDefaults standardUserDefaults]objectForKey:@"txTimeOut"] intValue] vcController:self];
                                                              globalSlice=0;
                                                              [self makePie];
                                                              [self.chartContainer.chartView reloadData:YES];
                                                          }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                          }];
    
    [alert addAction:defaultAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    yo=self;
    [self.chartContainer.chartView setDelegate:(id)self];
    [self.chartContainer.chartView setDataSource:(id)self];
    self.chartContainer.chartView.radiusOffset=0.75;
    self.chartContainer.chartView.animationDuration=0.4;
    self.chartContainer.chartView.showLabel=YES;
    self.chartContainer.chartView.showPercentage=NO;
    editf=false;
    popUp.delegate=nil;
    popUp=nil;
    starter.tag=0;
    statusSend=1;
    colorActive=[UIColor colorWithRed:214/255.0 green:69/255.0 blue:65/255.0 alpha:1];
    normalColor=[UIColor colorWithRed:191/255.0 green:85/255.0 blue:236/255.0 alpha:1];
    cercaColor = [UIColor colorWithRed:248/255.0 green:148/255.0 blue:6/255.0 alpha:1];
    notTodayColor = [UIColor colorWithRed:109/255.0 green:121/255.0 blue:122/255.0 alpha:1];
    offColor=[UIColor colorWithRed:107/255.0 green:185/255.0 blue:240/255.0 alpha:1];
    onColor=[UIColor colorWithRed:191/255.0 green:85/255.0 blue:236/255.0 alpha:1];
    mini=  ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)?[UIImage imageNamed:@"markermini.png"]:[UIImage imageNamed:@"markermini1.png"];
    fauceti = [UIImage imageNamed:@"faucet1.png"];
    redHeat = [UIImage imageNamed:@"flamered.png"];
    blueHeat = [UIImage imageNamed:@"flameblue.png"];
    statusOn = [UIImage imageNamed:@"sync.png"];
    statusOff = [UIImage imageNamed:@"syncoff.png"];

    [starter setImage:blueHeat forState:UIControlStateNormal];
    comm=[httpVC new];
    wtemp=@" NA ";
    NSNumber *passw=[[NSUserDefaults standardUserDefaults]objectForKey:@"password"];
    if (passw.integerValue>0)
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkLogin)
                                                 name:UIApplicationWillEnterForegroundNotification object:nil];

    slices = [NSMutableArray arrayWithCapacity:20];
    sliceColors = [NSMutableArray arrayWithCapacity:20];
    sliceNames = [NSMutableArray arrayWithCapacity:20];
    answer=nil;
    answer=[NSMutableString string];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    context =[appDelegate managedObjectContext];

    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressTap:)];
    [sunmoon addGestureRecognizer:longPress];
    UILongPressGestureRecognizer *longTimers = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(cloneTimers:)];
    [bffIcon addGestureRecognizer:longTimers];
    theStatusTimer=nil;
    if(appDelegate.client)
        [appDelegate.client setMessageHandler:reloj];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
 //     [appDelegate.client setMessageHandler:viejo];
  //  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
    [slices removeAllObjects];
    [self.chartContainer.chartView reloadData:NO];
  //  });
    [self tranSunMonn:YES];
    [self horasSunMonn:YES];
    [self markerSunMonn:YES];
    if(theFirstTimer)
    {
        [theFirstTimer invalidate];
        theFirstTimer=nil;
    }
    
    if(theStatusTimer)
    {
        [theStatusTimer invalidate];
        theStatusTimer=nil;
    }
    
    
}
-(NSArray*)makeLocationArray:(int)theTemp
{
    NSArray *este;
    float cuanto=1.0;
 //   LogDebug(@"Temp %d",theTemp);
 //   theTemp -=20;
 //   if (theTemp<=0) theTemp=20; //expected min temp
    if (appDelegate.servingsArray.count>0)
     cuanto=1.0-((float)(theTemp)/[[appDelegate.servingsArray[globalSlice] valueForKey:@"servTempMax"] integerValue]);
 //   LogDebug(@"Max Temp %d cuanto %f temp %d",[[appDelegate.servingsArray[globalSlice] valueForKey:@"servTempMax"] integerValue],cuanto,theTemp);

    float desde=cuanto-0.2;
    if (desde<0.1)
    {
        desde=0.0;
        cuanto=0.0;
    }
    este=@[[NSNumber numberWithFloat:desde],[NSNumber numberWithFloat:cuanto]];
    return este;
}

-(void)showSettings:(NSString*)lanswer
{
    int ambient,humidy,waterTemp,waterFlow,ambientTemp,relativeHumidity;
    NSArray *partes;
    NSString *tmph;
    BOOL refreshf,waterf=NO;

    if(mitimer)
        [mitimer invalidate];
    dispatch_async(dispatch_get_main_queue(), ^{ [tumblrHUD hide];});
    
    if(appDelegate.client)
        [appDelegate.client setMessageHandler:viejo];
    
          LogDebug(@"Answer %@",lanswer);

              partes=[lanswer componentsSeparatedByString:@":"];
              if(partes.count>=8)
              {
             //      LogDebug(@"status %@",partes);
                  ambient=      [partes[0] intValue];
                  humidy=       [partes[1] intValue];
                  waterTemp=    [partes[2] intValue];
                  waterFlow=    [partes[3] intValue];
                  int workingf= [partes[4] intValue];
                  int heaterOnOff=  [partes[5] intValue];
               //   NSLog(@"Status set onoff %d",heaterOnOff);
                  starter.tag=heaterOnOff;
                  waterf=[partes[3] intValue];
                  wtemp=[NSString stringWithFormat:@" %@˚C ",partes[2]];
                  stateMachine= (int)[partes[5] integerValue];
                  [starter setImage:stateMachine?redHeat:blueHeat forState:UIControlStateNormal];
                  [appDelegate.workingBFF setValue:[NSNumber numberWithInteger:workingf] forKey:@"bffOnOff"];
                  ambientTemp=(int)[partes[0] integerValue];
                  relativeHumidity=(int)[partes[1] integerValue];
                  tmph=[NSString stringWithFormat:@"%d˚C-%d%%",ambientTemp,relativeHumidity ];
                  totValor.text=[NSString stringWithFormat:@"$%@", partes[7]];
                  totKwh.text=partes[6];
                  if (stateMachine)
                  {
                      amps.hidden=NO;
                      ampslabel.hidden=NO;
                      amps.text=partes[8];
                  }
                  else{
                      amps.hidden=ampslabel.hidden=YES;
                  }
                  tempHum.text=nil;
                  tempHum.text=tmph;
              //    LogDebug(@"TMpHum %@",tmph);
              }

    
    NSManagedObject *matches = nil;
    CGFloat radius,xx,yy,xx2,yy2,xx3,yy3;
    
    //remove previous views if any Otherwise it will keep adding images
    
    UIImageView *myImageView = (UIImageView *)[self.view viewWithTag:123];// our uiview is tagged as 123
    if (myImageView !=NULL)
        [myImageView removeFromSuperview];
    
    myImageView = (UIImageView *)[self.view viewWithTag:124];
    if (myImageView !=NULL)
        [myImageView removeFromSuperview];
    
    myImageView = (UIImageView *)[self.view viewWithTag:125];
    if (myImageView !=NULL)
        [myImageView removeFromSuperview];
    
    // given time of day calculate angle to a 24 hour watch
    firstMakeHour=NO;
    NSDate *ahora=[NSDate date];// right now
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    comps =[[NSCalendar currentCalendar] components:( NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:ahora];
    comps.year=2000;
    comps.month=1;
    comps.day=1;
    comps.second=0;
    NSDate *now = [[NSCalendar currentCalendar] dateFromComponents:comps];
    int nowsecs=[now timeIntervalSince1970];
    CGPoint centro=CGPointMake(CGRectGetMidX([_chartContainer frame]), CGRectGetMidY([_chartContainer  frame]));// our container is our radius
    CGFloat angle=(float)(comps.hour*3600+comps.minute*60)/86400.0* M_PI*2; // current degrees from time in a 360 wheel
    
    // draw markers 24-6-12-18
    time.text=nil;
    time.text=[NSString stringWithFormat:@"%d:%02d",(int)comps.hour,(int)comps.minute];
  
    // current hour X and Y coordinates in the Doughnut
  //  radius=_chartContainer.frame.size.width/2;
    radius=_xyview.frame.size.width/2;

    xx=radius*sin(angle)+(float)centro.x;
    yy=(radius*cos(angle))*-1+(float)centro.y;
    
    //temp+faucet level is OVER the mini marker so add height to radius to get new X and Y
    xx2=(radius+mini.size.height)*sin(angle)+(float)centro.x;
    yy2=((radius+mini.size.height)*cos(angle))*-1+(float)centro.y;
    
    // Inner raidus for tank is radius - widht of radiusoffset
    CGFloat inner=radius*(1.0- self.chartContainer.chartView.radiusOffset);

    // heater icon in the inner circle -4 is a cleareance distance
    xx3=(radius-inner-4)*sin(angle)+(float)centro.x;
    yy3=((radius-inner-4)*cos(angle))*-1+(float)centro.y;

    //  read temperature to Text as image
    int tsize=([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)? 26:16 ;
    CGRect frame = [wtemp boundingRectWithSize:CGSizeMake(200,200) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica-Bold" size:tsize]} context:nil];
    float height = frame.size.height;
    float widlabel=frame.size.width;
    CGSize size = CGSizeMake(widlabel, height );
    fromLabel=nil;
    fromLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, widlabel, height)];
    fromLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:tsize]; //custom font
    fromLabel.numberOfLines = 1;
    fromLabel.baselineAdjustment = YES;
    fromLabel.adjustsFontSizeToFitWidth = YES;
 //   fromLabel.adjustsLetterSpacingToFitWidth = YES;
    fromLabel.clipsToBounds = YES;
    fromLabel.backgroundColor = [UIColor clearColor];
    fromLabel.textAlignment = NSTextAlignmentCenter;
    fromLabel.textColor = stateMachine? [UIColor colorWithRed:227/255.0 green:90/255.0 blue:102/255.0 alpha:1]:[UIColor colorWithRed:107/255.0 green:185/255.0 blue:240/255.0 alpha:1];
    fromLabel.text=wtemp;
    fromLabel.hidden=NO;
   
    UIGraphicsBeginImageContext(size);
    if(UIGraphicsGetCurrentContext()==nil)
    {
        LogDebug(@"Label context %@ w %f h %f %@",UIGraphicsGetCurrentContext(),size.width,size.height,wtemp);
        return;
    }

    [[fromLabel layer] renderInContext:UIGraphicsGetCurrentContext() ];
    textimage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
// Merge images horizontally if necessary, ie, TEmp in text + faucet image
    if (waterf)
        size = CGSizeMake(textimage.size.width+fauceti.size.width+10, fauceti.size.height+10 );
    else
        size = CGSizeMake(textimage.size.width+10, textimage.size.height+10 );
    // draw it so we can make an Image out of it
    finalImage=nil;
    UIGraphicsBeginImageContext(size);
    if(UIGraphicsGetCurrentContext()==nil)
    {
      //  LogDebug(@"Final context %@ w %f h %f",UIGraphicsGetCurrentContext(),size.width,size.height);
    return;
    }
    [textimage drawInRect:CGRectMake(0,0,textimage.size.width,textimage.size.height)];
    if (waterf)
        [fauceti drawInRect:CGRectMake(textimage.size.width,0,fauceti.size.width, fauceti.size.height)];
    finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // need to flip it to make it readable at certrain angle range
    if((angle>M_PI*2/4) && (angle<M_PI*2*3/4))
       {
    finalImage = [UIImage imageWithCGImage:finalImage.CGImage
                                                scale:finalImage.scale
                                          orientation:UIImageOrientationDown];
       }
    // view coordinates are xx2-yy2. Center it in the bottom middle
    tempFaucet = [[UIView alloc] initWithFrame:CGRectMake(xx2-finalImage.size.width/2, yy2-finalImage.size.height, finalImage.size.width, finalImage.size.height)];// shift rectangle half width and all height, midpoint bottom
    // view coordinates are xx-yy. Bottom middle
    markerView = [[UIView alloc] initWithFrame:CGRectMake(xx-mini.size.width/2, yy-mini.size.height, mini.size.width, mini.size.height)];// shift rectangle half width and all height, midpoint

    //
    if(waterf)
    {
    heater = [[UIView alloc] initWithFrame:CGRectMake(xx3-6, yy3-(int)inner, 12, (int)inner)];// shift rectangle half width and all height, midpoint bottom
 
    gradient = [CAGradientLayer layer];
    gradient.frame = heater.bounds;
    gradient.startPoint = CGPointMake(0.5,1.0);
    gradient.endPoint = CGPointMake(0.5, 0.0);
    gradient.locations=[self makeLocationArray:(int)wtemp.integerValue];
  //  LogDebug(@"Locations %@",gradient.locations);
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:49.0/255.0 green:130.0/255.0 blue:217.0/255.0 alpha:1.0] CGColor],
                                            (id)[[UIColor colorWithRed:172.0/255.0 green:40.0/255.0 blue:28.0/255.0 alpha:1.0] CGColor], nil];
    [heater.layer insertSublayer:gradient atIndex:0];
    }
    
    markerView.hidden=YES;
    tempFaucet.hidden=YES;
    if (waterf)
        heater.hidden=YES;
    tempFaucet.tag=124;// id 124 for removal
    tempFaucet.backgroundColor=[UIColor colorWithPatternImage:finalImage];
    markerView.tag=123;// uiview id 123
    markerView.backgroundColor = [UIColor colorWithPatternImage:mini];
    if(waterf)
        heater.tag=125;
    
    [self.view addSubview:markerView];
    [self.view addSubview:tempFaucet];
    if(stateMachine)
        [self.view addSubview:heater];
    
    markerView.layer.anchorPoint =  CGPointMake(0.5f,1.0f); //set the anchor point in the VIew- midx bottom
    tempFaucet.layer.anchorPoint =      CGPointMake(0.5f,1.0f); //set the anchor point in the VIew- midx bottom
    heater.layer.anchorPoint =      CGPointMake(0.5f,1.0f);
    // Rotate around this point in the SUperview !!!!!
    markerView.layer.position =     CGPointMake(xx, yy);
    markerView.transform  =         CGAffineTransformMakeRotation(angle);
    tempFaucet.layer.position =         CGPointMake(xx2, yy2);
    tempFaucet.transform  =             CGAffineTransformMakeRotation(angle);
    if(waterf)
    {
        heater.layer.position =         CGPointMake(xx3, yy3);
        heater.transform  =             CGAffineTransformMakeRotation(angle-M_PI);
    }
  
    refreshf=NO;
    runningf=NO;
    long long mascerca=999999999999;
    cualcerca=-1;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSArray *namesDays= [dateFormatter shortWeekdaySymbols];
    CFAbsoluteTime at = CFAbsoluteTimeGetCurrent();
    CFTimeZoneRef tz = CFTimeZoneCopySystem();
    SInt32 WeekdayNumber = CFAbsoluteTimeGetDayOfWeek(at, tz);
    if (WeekdayNumber>6) WeekdayNumber=0;
  //  LogDebug(@"Today is %@",namesDays[WeekdayNumber]);
    _dayName.text=namesDays[WeekdayNumber];
    tempFaucet.hidden=NO;
    markerView.hidden=NO;
    if(waterf)
        heater.hidden=NO;

    for(int a=0;a<appDelegate.servingsArray.count;a++)
    {
        matches=appDelegate.servingsArray[a];
        int pos=a*2+1;

        uint8_t days=[[appDelegate.servingsArray[a] valueForKey:@"servDays"]integerValue];
        uint8_t vale=days & (1<<WeekdayNumber);
     //   LogDebug(@"DOW %d %d %x %@",WeekdayNumber,vale,days,[appDelegate.servingsArray[a] valueForKey:@"servName"]);
        if(([now compare:[matches valueForKey:@"servDate"]]==NSOrderedDescending || [now compare:[matches valueForKey:@"servDate"]]==NSOrderedSame) && ([now compare:[matches valueForKey:@"hastaDate"]]==NSOrderedAscending || [now compare:[matches valueForKey:@"hastaDate"]]==NSOrderedSame) && vale)
        {
            runningf=YES;
            if(vale)
            {
                if (![sliceColors[pos] isEqual:colorActive])
                {
                    sliceColors[pos]=colorActive;
                    refreshf=YES;
                }
            }
            else
                if (![sliceColors[pos] isEqual:notTodayColor])
                {
                    sliceColors[pos]=notTodayColor;
                    refreshf=YES;
                }
        }
        else
        {
            if(vale)
            {
                if (![sliceColors[pos] isEqual:normalColor])
                {
                    sliceColors[pos]=normalColor;
                    refreshf=YES;
                }
            }
            else
                if (![sliceColors[pos] isEqual:notTodayColor])
                {
                    sliceColors[pos]=notTodayColor;
                    refreshf=YES;
                }
            
        }
        
        
        long long dist=[[matches valueForKey:@"servDate"] timeIntervalSince1970] -nowsecs;
     //   LogDebug(@"Dist %lld cerca %lld",dist,mascerca);
        if (vale)
        {
            if(dist>0 && mascerca<0)
            {
          //      LogDebug(@"cual %d vale %d",a,vale);
                mascerca=dist;
                cualcerca=a;
            }
            else
                if(dist<mascerca)
            {
                mascerca=dist;
                cualcerca=a;
            }
        }
    }
        
    
    if(!runningf && cualcerca>=0)
    {
        sliceColors[cualcerca*2+1]=cercaColor;
        refreshf=YES;
    }

        if(refreshf)
            [self.chartContainer.chartView reloadData:firstMakeHour?NO:YES];
  //  [self performSelector:@selector(markerSunMonn:) withObject:[NSNumber numberWithBool:NO] afterDelay:0.0 ]; //show them animated

}


-(void)setCallBackNull
{
         [appDelegate.client setMessageHandler:NULL];
}

MQTTMessageHandler reloj=^(MQTTMessage *message)
{
    [yo setCallBackNull];
    LogDebug(@"Reloj msg %@ %@",message.payload,message.payloadString);
//    NSString *cmdstr=[message.payloadString substringToIndex:2];
    dispatch_async(dispatch_get_main_queue(), ^{
        [yo showSettings:message.payloadString];
                   });
    
};

MQTTMessageHandler generalAnswer=^(MQTTMessage *message)
{
    [yo setCallBackNull];
    LogDebug(@"General msg %@ %@",message.payload,message.payloadString);
    //    NSString *cmdstr=[message.payloadString substringToIndex:2];
    dispatch_async(dispatch_get_main_queue(), ^{
        [yo showMessage:@"Heater Messsage" withMessage:message.payloadString];
    });
    
};


-(void)makeHour
{
    NSString*mis=[NSString stringWithFormat:@"status"];
    if(statusSend)
    {
        if(appDelegate.client){
            viejo=appDelegate.client.messageHandler;
            [appDelegate.client setMessageHandler:reloj];
        }
        [self hud];
        [comm lsender:mis andAnswer:NULL andTimeOut:2 vcController:self];
    }
}
-(void)tranSunMonn:(BOOL) how
{
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
 //   sunmoon.hidden = !how;
    animation.duration = 1.0;
    [sunmoon.layer addAnimation:animation forKey:nil];
    [time.layer addAnimation:animation forKey:nil];
    sunmoon.hidden = how;
    time.hidden=how;
    _dayName.hidden=how;
}

-(void)horasSunMonn:(BOOL) how
{
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    animation.duration = 1.0;
     time.hidden = how;
    _dayName.hidden=how;

}

-(void)markerSunMonn:(BOOL) how
{
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    animation.duration = 1.0;
    [markerView.layer addAnimation:animation forKey:nil];
    [tempFaucet.layer addAnimation:animation forKey:nil];
    markerView.hidden = how;
    tempFaucet.hidden = how;
}


-(void)makePie
{
    UIColor *cualColor;
   
    [slices removeAllObjects];
    [sliceColors removeAllObjects];
    [sliceNames removeAllObjects];

    NSManagedObject *matches;
    NSNumber *one;
     long desde,duracion,dist,llevo,start;
  
    llevo=0;
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:1];
    [comps setMonth:1];
    [comps setYear:2000];
    [comps setHour:0];
    [comps setMinute:0];
    [comps setSecond:0];
    NSDate *midNight = [[NSCalendar currentCalendar] dateFromComponents:comps];
    unsigned long latest=[midNight timeIntervalSince1970];
    NSDate *ahora=[NSDate date];
    
   comps =
    [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:ahora];
    comps.year   = 2000;
    comps.month = 1;
    comps.day = 1;
    //btw get the time part to send the esp8266
    
    float costo=0;
    float kwh=0;
    for (matches in appDelegate.servingsArray)
    {
      //  if(([now compare:[matches valueForKey:@"servDate"]]==NSOrderedDescending) & ([now compare:[matches valueForKey:@"hastaDate"]]==NSOrderedAscending))
           // cualColor=activeColor;
      //  else
        cualColor=onColor;
            
        desde=[[matches valueForKey:@"servDate"] timeIntervalSince1970];
        duracion=[[matches valueForKey:@"hastaDate"] timeIntervalSince1970];
        start=desde-latest;
        dist=duracion-desde;
        latest=duracion;
        llevo=llevo+dist+start;
        one = [NSNumber numberWithInt:(int)start];
        [slices addObject:one];
        [sliceColors addObject:offColor];
        [sliceNames addObject:@""];
        one = [NSNumber numberWithInt:(int)dist];
        [slices addObject:one];
        [sliceColors addObject:cualColor];

        [sliceNames addObject:[NSString stringWithFormat:@"%2d˚",(int)[[matches valueForKey:@"servTempMax"] integerValue]]];

        costo=costo+(float)dist/3600.0*[[appDelegate.workingBFF valueForKey:@"bffKwH"]floatValue ]*(float)((float)[[appDelegate.workingBFF valueForKey:@"bffWatts"]integerValue ]/1000.0);
        kwh= (float)kwh+(float)dist/3600.0*consumoHora*(float)[[appDelegate.workingBFF valueForKey:@"bffWatts"]integerValue ]/1000.0;
    }
    
    one = [NSNumber numberWithInt:(int)(86400-llevo)];
    [slices addObject:one];
    [sliceColors addObject:offColor];
    [sliceNames addObject:@""];
    _costoDia.text=[NSString stringWithFormat:@"$%.2f",costo];
    costo *=30.0;
    _costoMes.text=[NSString stringWithFormat:@"$%.2f",costo];
    _kwhDia.text=[NSString stringWithFormat:@"%2.1f",kwh];
    kwh*=30;
    _kwhMes.text=[NSString stringWithFormat:@"%2.1f",kwh];
//    [self makeHour];// show current time and launch every 240secs thats the minimum 1 degree
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    yo=self;  //CRUCIAL for callbacks else its lost

    NSNumber *passw=[[NSUserDefaults standardUserDefaults]objectForKey:@"password"];
    if(passw.integerValue)
    {
     if (!appDelegate.passwordf)
     {
         LogDebug(@"Need to get password");
         [self performSegueWithIdentifier:@"getPassword" sender:self];
     }
    }
    
    [self workingIcon];
    if(appDelegate.client){
        //           viejo=appDelegate.client.messageHandler;
        [appDelegate.client setMessageHandler:reloj];
    /*
     [self.chartContainer.chartView setDelegate:(id)self];
     [self.chartContainer.chartView setDataSource:(id)self];
     self.chartContainer.chartView.radiusOffset=0.75;
     self.chartContainer.chartView.animationDuration=0.4;
     self.chartContainer.chartView.showLabel=YES;
     self.chartContainer.chartView.showPercentage=NO;
     editf=false;
     popUp.delegate=nil;
     popUp=nil;
     */
    //   context =[appDelegate managedObjectContext];
    [appDelegate.servingsArray removeAllObjects];
    NSEntityDescription *entityDesc =
    [NSEntityDescription entityForName:@"Servings" inManagedObjectContext:context];
     [starter setImage:blueHeat forState:UIControlStateNormal];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    [request setReturnsObjectsAsFaults:NO];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"servDate" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"servBFFName", [appDelegate.workingBFF valueForKey:@"bffName"]];
    [request setPredicate:predicate];
    NSError *error;
    appDelegate.servingsArray = [[context executeFetchRequest:request error:&error] mutableCopy];
    [[appDelegate.tabBarController.tabBar.items objectAtIndex:1] setBadgeValue:[NSString stringWithFormat:@"%ld",appDelegate.servingsArray.count]];
    [self makePie];
  //  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{});
    [self tranSunMonn:NO];
    [self horasSunMonn:NO];
    firstMakeHour=NO;
    [self.chartContainer.chartView reloadData:YES];
    if (!theStatusTimer)
    {
        NSDate *now=[NSDate date];
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        comps =[[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute| NSCalendarUnitSecond)
                                               fromDate:now];
        theFirstTimer=[NSTimer scheduledTimerWithTimeInterval:1 //60-(int)comps.second
                                         target:self
                                       selector:@selector(dispatcher)
                                       userInfo:nil
                                        repeats:NO];
          }

    }
   //   [appDelegate.client setMessageHandler:reloj];

}

-(void)dispatcher
{
    [self makeHour];
    if (!theStatusTimer){
    theStatusTimer=[NSTimer scheduledTimerWithTimeInterval:10
                                     target:self
                                   selector:@selector(makeHour)
                                   userInfo:nil
                                    repeats:YES];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

  //    });

}


#pragma mark - XYDoughnutChart Data Source

- (NSInteger)numberOfSlicesInDoughnutChart:(XYDoughnutChart *)doughnutChart
{
    return slices.count;
}

- (CGFloat)doughnutChart:(XYDoughnutChart *)doughnutChart valueForSliceAtIndexPath:(NSIndexPath *)indexPath
{
 //   LogDebug(@"index %d count %d",indexPath.slice,slices.count);
    return [[slices objectAtIndex:(indexPath.slice % slices.count)] intValue];
   }

- (NSString*)doughnutChart:(XYDoughnutChart *)doughnutChart textForSliceAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *este=[sliceNames objectAtIndex:indexPath.slice];
    if (este.length>=3)
        return [[sliceNames objectAtIndex:indexPath.slice ] substringToIndex:3];
    else
        return[sliceNames objectAtIndex:indexPath.slice ];
}

#pragma mark - XYDoughnutChart Delegate

- (NSIndexPath *)doughnutChart:(XYDoughnutChart *)doughnutChart willSelectSliceAtIndex:(NSIndexPath *)indexPath
{
   // UIColor *offColor=[UIColor colorWithRed:107/255.0 green:185/255.0 blue:240/255.0 alpha:1];

    if(([[sliceColors objectAtIndex:indexPath.slice] isEqual:offColor])) return NULL;
 //   sunmoon.alpha=0.25;
    marker.alpha=0.25;
    return indexPath;
}

-(void)turnOn
{
    if([[appDelegate.workingBFF valueForKey:@"bffOnOff"] integerValue]==0)
    {
        [self showMessage:@"Heater is OFF" withMessage:@"Can not send Turn On"];
        return;
    }
    if(appDelegate.client){
        viejo=appDelegate.client.messageHandler;
        [appDelegate.client setMessageHandler:generalAnswer];
    }
    mis=[NSString stringWithFormat:@"manual?st=1"];
    [self hud];
   [comm lsender:mis andAnswer:NULL andTimeOut:[[[NSUserDefaults standardUserDefaults]objectForKey:@"txTimeOut"] intValue] vcController:self];
 

}

-(void)turnOff
{
    if([[appDelegate.workingBFF valueForKey:@"bffOnOff"] integerValue]==0)
    {
        [self showMessage:@"Heater is OFF" withMessage:@"Can not send Turn Off"];
        return;
    }

    if(appDelegate.client){
        viejo=appDelegate.client.messageHandler;
        [appDelegate.client setMessageHandler:generalAnswer];
    }
    mis=[NSString stringWithFormat:@"manual?st=0"];
    [self hud];
   [comm lsender:mis andAnswer:NULL andTimeOut:[[[NSUserDefaults standardUserDefaults]objectForKey:@"txTimeOut"] intValue] vcController:self];

}

-(void)changeTimer:(int)cual
{
    
    int estado=(int)[[appDelegate.servingsArray[cual] valueForKey:@"servOnOff"]integerValue];
    if(estado)
        estado=0;
    else
        estado=1;

    [appDelegate.servingsArray[cual] setValue:[NSNumber numberWithInteger:estado] forKey:@"servOnOff"];
    NSError *error;
    if(![context save:&error])
        LogDebug(@"Save error timerchange%@",error);
    if(appDelegate.client){
        viejo=appDelegate.client.messageHandler;
        [appDelegate.client setMessageHandler:generalAnswer];
    }
    mis=[NSString stringWithFormat:@"timerOnOff?pos=%d&st=%d&name=%@",cual,estado,[[appDelegate.servingsArray objectAtIndex:cual] valueForKey:@"servName"]];
    [self hud];
    [comm lsender:mis andAnswer:NULL andTimeOut:[[[NSUserDefaults standardUserDefaults]objectForKey:@"txTimeOut"] intValue] vcController:self];
  
}

- (void)doughnutChart:(XYDoughnutChart *)doughnutChart didSelectSliceAtIndexPath:(NSIndexPath *)indexPath
{
   // UIColor *offColor=[UIColor colorWithRed:107/255.0 green:185/255.0 blue:240/255.0 alpha:1];
    if(!([[sliceColors objectAtIndex:indexPath.slice] isEqual:offColor])) //Only timer colors (red)
    {
        globalSlice=(int)indexPath.slice/2;

        int secs=(int)[slices[indexPath.slice] integerValue];
        int pos=(int)indexPath.slice /2;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH:mm"];
        NSString *startTimeString = [formatter stringFromDate:[appDelegate.servingsArray[pos] valueForKey:@"servDate"]];
        NSString *hastaTimeString = [formatter stringFromDate:[appDelegate.servingsArray[pos] valueForKey:@"hastaDate"]];
  //      NSString *rango=[NSString stringWithFormat:@"%@-%@",startTimeString,hastaTimeString];
        float costo=(float)secs/3600.0*[[appDelegate.workingBFF valueForKey:@"bffKwH"]floatValue ]*(float)((float)[[appDelegate.workingBFF valueForKey:@"bffWatts"]integerValue ]/1000.0);
        NSString *costoDia=[NSString stringWithFormat:@"$%.2f",costo];
        costo *=30;
        NSString *costoMes=[NSString stringWithFormat:@"$%.2f",costo];
        CGSize theSize=_xyview.frame.size;
        uint8_t days=[[appDelegate.servingsArray[pos] valueForKey:@"servDays"]integerValue];
        int isOnOff=(int)[[appDelegate.servingsArray[pos] valueForKey:@"servOnOff"]integerValue];
        NSString *dias=[NSString stringWithFormat:@"%c%c%c%c%c%c%c",(days & 0x1)? 'S':'-',(days & 0x2)? 'M':'-',(days & 0x4)? 'T':'-',(days & 0x8)? 'W':'-',
                        (days & 0x10)? 'T':'-',(days & 0x20)? 'F':'-',(days & 0x40)? 'S':'-'];// Sunday Monday Tuesday Wednesday Thursday Friday Saturday
        
       popUp = [[btSimplePopUP alloc]initWithItemImage:@[
                                                                      isOnOff?[UIImage imageNamed:@"on"]:[UIImage imageNamed:@"off"],
                                                                      [UIImage imageNamed:@"start"],
                                                                      [UIImage imageNamed:@"stop"],
                                                                      [UIImage imageNamed:@"trashsmall"],
                                                                    //  [UIImage imageNamed:@"off"],
                                                                      ([[appDelegate.servingsArray[pos] valueForKey:@"servNotis"] integerValue]) ?
                                                                            [UIImage imageNamed:@"email"]:[UIImage imageNamed:@"emailno"],
                                                                      [UIImage imageNamed:@"thermoa"],
                                                                     // [UIImage imageNamed:@"on"],
                                                                      [UIImage imageNamed:@"day"],
                                                                      [UIImage imageNamed:@"month"],
                                                                      [UIImage imageNamed:@"week"],
                                                                 //    ([[appDelegate.servingsArray[pos] valueForKey:@"servNotis"] integerValue]) ?
                                                                   //         [UIImage imageNamed:@"email"]:[UIImage imageNamed:@"emailno"],
                                                                   //   [UIImage imageNamed:@"thermob"],
                                                                    //  [UIImage imageNamed:@"thermoa"]
                                                                      ]
                                                          andTitles:   /* @[
                                                                          [appDelegate.servingsArray[pos] valueForKey:@"servName"], startTimeString,hastaTimeString, @"Delete", @"TurnOff", @"TurnOn",
                                                                          costoDia,costoMes,dias,@"Mail",[NSString stringWithFormat:@"%2d˚",(int)[[appDelegate.servingsArray[pos] valueForKey:@"servTempMin"] integerValue]],[NSString stringWithFormat:@"%2d˚",(int)[[appDelegate.servingsArray[pos] valueForKey:@"servTempMax"] integerValue]]
                                                                          ]*/
                @[
                  [appDelegate.servingsArray[pos] valueForKey:@"servName"], startTimeString,hastaTimeString, @"Delete", @"Email", [NSString stringWithFormat:@"%2d˚",(int)[[appDelegate.servingsArray[pos] valueForKey:@"servTempMax"] integerValue]],
                  costoDia,costoMes,dias
                  ]
                
                                         andActionArray:nil addToViewController:self andSize:theSize];
        popUp.delegate = self;
        
        [self.view addSubview:popUp];
        [popUp setPopUpStyle:BTPopUpStyleDefault];
        [popUp setPopUpBorderStyle:BTPopUpBorderStyleDefaultNone];
        [popUp show:BTPopUPAnimateNone];
    }
}


#pragma -mark delegate btSimplePopUp

-(void) changeMail
{
    int como=(int)[[appDelegate.servingsArray[globalSlice] valueForKey:@"servNotis"] integerValue];
    como =!como;
    [appDelegate.servingsArray[globalSlice] setValue:[NSNumber numberWithInteger:como] forKey:@"servNotis"];
    mis=[NSString stringWithFormat:@"emailChange?pos=%d&st=%d",globalSlice,como];
    if(appDelegate.client){
        viejo=appDelegate.client.messageHandler;
        [appDelegate.client setMessageHandler:generalAnswer];
    }
    [self hud];
    [comm lsender:mis andAnswer:NULL andTimeOut:[[[NSUserDefaults standardUserDefaults]objectForKey:@"txTimeOut"] intValue] vcController:self];
  
    NSError *error;
    if(![context save:&error])
        LogDebug(@"Save error emailchange%@",error);

}

-(void)btSimplePopUP:(btSimplePopUP *)lpopUp didSelectItemAtIndex:(NSInteger)index{
    switch (index) {
        case 0:
            // change timer from availbale to not available. slicepos is the current selected Slice that needs to change
            [self changeTimer:globalSlice];
            break;
        case 3:
            [self delete];
            break;
        case 4:
            [self changeMail];
        default:
            break;// do nothing
    }
    [lpopUp dismiss:nil];
}



- (void)doughnutChart:(XYDoughnutChart *)doughnutChart didDeselectSliceAtIndexPath:(NSIndexPath *)indexPath
{
  //  LogDebug(@"did Deselect slice at index %ld", (long)indexPath.slice);
  //  sunmoon.alpha=1.0;
    marker.alpha=1.0;
  //  [self.popupMenu dismissAnimated:YES];
   
}


- (UIColor *)doughnutChart:(XYDoughnutChart *)doughnutChart colorForSliceAtIndexPath:(NSIndexPath *)indexPath
{
    return [sliceColors objectAtIndex:(indexPath.slice % sliceColors.count)];
}

- (UIColor *)doughnutChart:(XYDoughnutChart *)doughnutChart selectedStrokeColorForSliceAtIndexPath:(NSIndexPath *)indexPath
{
    return [UIColor whiteColor];
}

- (CGFloat)doughnutChart:(XYDoughnutChart *)doughnutChart selectedStrokeWidthForSliceAtIndexPath:(NSIndexPath *)indexPath
{
    return 2.0;
}
/*
-(void)deleteAllEntity:(NSString *)cualEntity
{
    NSError *error;
    context =[appDelegate managedObjectContext];
    
    NSEntityDescription *entityDesc =
    [NSEntityDescription entityForName:cualEntity
                inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    //    NSArray *nada=[context executeFetchRequest:request
    //                            error:&error] ;
    NSBatchDeleteRequest *delete = [[NSBatchDeleteRequest alloc] initWithFetchRequest:request];
    [[appDelegate persistentStoreCoordinator] executeRequest:delete withContext:context error:&error];
    [context save:&error];
}
*/
-(void)setTimers:(NSString *)lanswer
{
    NSDateComponents *comps;
    NSCalendar *calendar;
    NSError *error;
    
    NSMutableSet *serv=[appDelegate.workingBFF mutableSetValueForKey:@"meals"];
    context =[appDelegate managedObjectContext];
    // Insert Timers
    NSArray *theTimersString=[lanswer componentsSeparatedByString:@"@"];
    for (int a=0;a<theTimersString.count;a++)
    {
        
        NSArray *theTimer=[theTimersString[a] componentsSeparatedByString:@"|"];
        if(theTimer.count<7)
        {
            [self showErrorMessage];
            return;
        }
        NSManagedObject *newServing= [NSEntityDescription insertNewObjectForEntityForName:@"Servings" inManagedObjectContext:context];
        NSArray *tiempo=[theTimer[1] componentsSeparatedByString:@":"];// hour and minute
        if(tiempo.count<2)
        {
            [self showErrorMessage];
            return;
        }
        
        calendar = [[NSCalendar alloc]
                    initWithCalendarIdentifier:NSGregorianCalendar];//[NSCalendar currentCalendar];
        comps =
        [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:[NSDate date]];
        NSDate *fromDate = [calendar dateFromComponents:comps];
        comps.year   = 2000;
        comps.month = 1;
        comps.day = 1;
        comps.second=0;
        comps.hour=[tiempo[0] integerValue];
        comps.minute=[tiempo[1] integerValue];
        fromDate = [calendar dateFromComponents:comps];
        NSDate* newDate = [fromDate dateByAddingTimeInterval:[theTimer[2] integerValue]];// duration
        
        [newServing setValue: theTimer[0] forKey:@"servName"];
        [newServing setValue: fromDate forKey:@"servDate"];
        [newServing setValue: newDate forKey:@"hastaDate"];
        [newServing setValue: [NSNumber numberWithInteger:[theTimer[3] integerValue]] forKey:@"servDays"];
        [newServing setValue: [NSNumber numberWithInteger:[theTimer[4] integerValue]] forKey:@"servNotis"];
        [newServing setValue: [NSNumber numberWithInteger:[theTimer[5] integerValue]] forKey:@"servOnOff"];
        [newServing setValue: @40 forKey:@"servTempMin"];
        [newServing setValue: [NSNumber numberWithInteger:[theTimer[6] integerValue]] forKey:@"servTempMax"];
        [newServing setValue: [appDelegate.workingBFF valueForKey:@"bffName"] forKey:@"servBFFName"];
        [newServing setValue: [NSDate date] forKey:@"dateAdded"];
        [serv addObject:newServing];
    }
    
    if(![context save:&error])
    {
        LogDebug(@"Save error GetTimers %@",error);
        return;//if we cant save it return and dont send anything toi the esp8266
    }
}

MQTTMessageHandler timersRx=^(MQTTMessage *message)
{
    [yo setCallBackNull];
    LogDebug(@"Timers %@ %@",message.payload,message.payloadString);
    dispatch_async(dispatch_get_main_queue(), ^{
        [yo setTimers:message.payloadString];
    });
};


-(void)getTimersHeater
{
    NSEntityDescription *entityDesc =
    [NSEntityDescription entityForName:@"Servings"
                inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"servDate" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"servBFFName", [appDelegate.workingBFF valueForKey:@"bffName"]];
    [request setPredicate:predicate];
    NSError *error;
    NSArray *estosServings = [[context executeFetchRequest:request error:&error] mutableCopy];
    for (NSManagedObject *item in estosServings) {
        [context deleteObject:item];
    }
    if(![context save:&error])
    {
        LogDebug(@"Save error GetTimers %@",error);
        return;//if we cant save it return and dont send anything toi the esp8266
    }
 
    if(appDelegate.client)
        [appDelegate.client setMessageHandler:timersRx];
    mis=[NSString stringWithFormat:@"gettimers"];
    [self hud];
    [comm lsender:mis andAnswer:NULL andTimeOut:[[[NSUserDefaults standardUserDefaults]objectForKey:@"txTimeOut"] intValue] vcController:self];

}

/*
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

    if (editingStyle == UITableViewCellEditingStyleDelete) {
        mis=[NSString stringWithFormat:@"timerDel?pos=%ld",indexPath.row];
        [context deleteObject:(NSManagedObject*)[appDelegate.servingsArray objectAtIndex:indexPath.row]];
        [appDelegate.servingsArray removeObjectAtIndex:indexPath.row];
        NSError *error;
        if(![context save:&error])
            LogDebug(@"Save error %@",error);
    //    [table reloadData];
        
        [[appDelegate.tabBarController.tabBar.items objectAtIndex:1] setBadgeValue:[NSString stringWithFormat:@"%ld",appDelegate.servingsArray.count]];
      
        int reply=[comm lsender:mis andAnswer:answer andTimeOut:[[[NSUserDefaults standardUserDefaults]objectForKey:@"txTimeOut"] intValue] vcController:self];
        if (!reply)
            [self showErrorMessage];
        else
            [self showOkMessage];
    }
}
*/
/*
-(IBAction)statusB:(UIButton*)sender
{
    statusSend=!statusSend;
    NSLog(@"Status %d",statusSend);
}
*/
-(IBAction)statusMgr:(UIButton*)sender
{
    [UIView animateWithDuration:0.5 animations:^{
        statusb.alpha = 0.0f;
    } completion:^(BOOL finished) {
        if (statusb.tag==0)
        {
            statusb.imageView.animationImages = [NSArray arrayWithObjects:statusOff,nil];
            statusb.tag=1;
            statusSend=0;
        }
        else
        {
            statusb.imageView.animationImages = [NSArray arrayWithObjects:statusOn,nil];
            statusb.tag=0;
            statusSend=1;
        }
        [statusb.imageView startAnimating];
        [UIView animateWithDuration:0.5 animations:^{
            statusb.alpha = 1.0f;
        }];
    }];
    
}

-(IBAction)fireHeater:(UIButton*)sender
{
 //   NSLog(@"Start tag %lu starter %@ %@ %@",starter.tag,starter,[starter imageForState:UIControlStateNormal],redHeat);
    if (starter.tag==0)
    {
      //  [starter setImage:redHeat forState:UIControlStateSelected];
        sender.imageView.animationImages = [NSArray arrayWithObjects:redHeat,nil];
        starter.tag=1;
     //   NSLog(@"Starter 0 tag %lu",starter.tag);
        
        dispatch_async(dispatch_get_main_queue(), ^{[self turnOn];});
    }
    else
    {
      //  [starter setImage:blueHeat forState:UIControlStateSelected];

        sender.imageView.animationImages = [NSArray arrayWithObjects:blueHeat,nil];
        starter.tag=0;
  //      NSLog(@"Starter 1 tag %lu",starter.tag);
        
        dispatch_async(dispatch_get_main_queue(), ^{[self turnOff];});
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        starter.alpha = 0.0f;
    } completion:^(BOOL finished) {
      //  starter.imageView.animationImages = [NSArray arrayWithObjects:([sender imageForState:UIControlStateNormal]==blueHeat)?redHeat:blueHeat,nil];

        [starter.imageView startAnimating];
        [UIView animateWithDuration:0.5 animations:^{
            starter.alpha = 1.0f;
        }];
    }];

}

    -(IBAction)addTimer:(id)sender
    {
        [self performSegueWithIdentifier:@"servingsEditVC" sender:self];
    }

    - (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
    {
        return appDelegate.servingsArray.count;
    }

@end

