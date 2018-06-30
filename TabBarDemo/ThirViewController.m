//
//  ThirViewController.m
//  FoodAuto
//
//  Created by Robert on 3/2/16.
//  Copyright © 2016 Robert. All rights reserved.
//

#import "ThirViewController.h"
#import "AppDelegate.h"
#import "FirstViewController.h"
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "HMSegmentedControl.h"
#import "feederViewController.h"
#import "TextFieldValidator.h"
#import "httpVc.h"
#import "btSimplePopUp.h"

#if 0 // set to 1 to enable logs
#define LogDebug(frmt, ...) NSLog([frmt stringByAppendingString:@"[%s]{%d}"], ##__VA_ARGS__,__PRETTY_FUNCTION__,__LINE__);
#else
#define LogDebug(frmt, ...) {}
#endif


@import UIKit;
@implementation ThirViewController
@synthesize datePicker,dias,dirtyt,dirtys,openT,waitT,name,lastSegment,theNum,bffIcon,hastaPicker,passww,notis,circleTemp,temp,lowTemp,lowTempLabel,once;

-(void)calcTimeToTemp
{
    int watts=(int)[[appDelegate.workingBFF valueForKey:@"bffWatts"] integerValue];
    int galons=(int)[[appDelegate.workingBFF valueForKey:@"bffGalons"] integerValue];
    CGFloat monton=4.19 * (galons*4)* ((int)circleTemp.currentValue- (int)lowTemp.currentValue)/18.0*5/watts; //hours
  //  LogDebug(@"Time in hours %f watts %d",monton,watts);
    hastaPicker.countDownDuration=(int)(monton*3600.0);
}

- (IBAction)arrowChange:(UIButton *)sender {
    
    
   if (arrowState==YES )
   {
       CABasicAnimation *crossFade = [CABasicAnimation animationWithKeyPath:@"contents"];
       crossFade.duration = 0.7;
       crossFade.fromValue = (id)arrowConnected.CGImage;
       crossFade.toValue = (id)arrowDisconnected.CGImage;
       crossFade.removedOnCompletion = NO;
       crossFade.fillMode = kCAFillModeForwards;
       [sender.imageView.layer addAnimation:crossFade forKey:@"animateContents"];
       //Make sure to add Image normally after so when the animation
       //is done it is set to the new Image
       lowTemp.userInteractionEnabled=NO;
       [UIView animateWithDuration:0.5f animations:^{
           lowTemp.alpha = 0.4f;
       } completion:^(BOOL finished){}];
       [UIView animateWithDuration:0.5f animations:^{
           circleTemp.alpha = 0.4f;
       } completion:^(BOOL finished){}];
       [sender setImage:arrowDisconnected forState:UIControlStateNormal];
       arrowState=NO;

   }
    else
    {
        CABasicAnimation *crossFade = [CABasicAnimation animationWithKeyPath:@"contents"];
        crossFade.duration = 0.7;
        crossFade.fromValue = (id)arrowDisconnected.CGImage;
        crossFade.toValue = (id)arrowConnected.CGImage;
        crossFade.removedOnCompletion = NO;
        crossFade.fillMode = kCAFillModeForwards;
        lowTemp.userInteractionEnabled=YES;
        circleTemp.userInteractionEnabled=YES;
        [UIView animateWithDuration:0.5f animations:^{
            lowTemp.alpha = 1.0f;
        } completion:^(BOOL finished){}];
        [UIView animateWithDuration:0.5f animations:^{
            circleTemp.alpha = 1.0f;
        } completion:^(BOOL finished){}];
        [sender.imageView.layer addAnimation:crossFade forKey:@"animateContents"];
        [sender setImage:arrowConnected forState:UIControlStateNormal];
        arrowState = YES;

    }
}

- (IBAction)tempChanged:(CircularPickerView *)sender {
    temp.text = [NSString stringWithFormat:@"%2d˚C",(int)sender.currentValue];
    [self calcTimeToTemp];
}

- (IBAction)lowtempChanged:(CircularPickerView *)sender {
     lowTempLabel.text = [NSString stringWithFormat:@"%2d˚C",(int)sender.currentValue];
    [self calcTimeToTemp];
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


-(void)showErrorMessage
{
    [self blurScreen];
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"TimeOut"
                                                                   message:@"Maybe out of range or off. Still timer was added for later sync"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              [backGroundBlurr removeFromSuperview];
                                                              [self performSegueWithIdentifier:@"doneEditVC" sender:self];
                                                          }];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)showOkMessage
{
     [self blurScreen];
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Timer Added"
                                                                   message:[NSString stringWithFormat:@"Confirmed by %@",[appDelegate.workingBFF valueForKey:@"bffName"]]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                               [backGroundBlurr removeFromSuperview];
                                                              [self performSegueWithIdentifier:@"doneEditVC" sender:self];
                                                          }];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}


- (IBAction)pickerAction:(UIDatePicker*)sender{
    dirtyt=true;
 //   hastaPicker.date=datePicker.date;
}

- (IBAction)hastapickerAction:(UIDatePicker*)sender{
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    comps =[[NSCalendar currentCalendar] components:( NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:datePicker.date];
    int son=(int)(comps.hour*3600+comps.minute*60) + (int)hastaPicker.countDownDuration;
    if (son>86400)// start hour + time lapse can not exceed 24 hours or loop into a Next Day we DO NOT HAVE!!!!!
    {
        hastaPicker.countDownDuration=15*60;
        return;
    }
    dirtyt=true;
}

-(IBAction)editingEnded:(id)sender{
   
    [sender resignFirstResponder];
}

-(IBAction)editingChange:(UITextField*)sender{
    dirtyt=true;
}

-(void)workingIcon
{
    UIImage *licon;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  //  NSString *final=[NSString stringWithFormat:@"%@.png",[appDelegate.workingBFF valueForKey:@"bffName"]];
    NSString *final=[NSString stringWithFormat:@"%@.txt",[appDelegate.workingBFF valueForKey:@"bffName"]];

    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:final];
    licon=[UIImage imageWithContentsOfFile:filePath];
    if (licon==NULL)
        licon = [UIImage imageNamed:@"camera"];//need a photo
    bffIcon.image=licon;
}

-(BOOL)checkNoOverlap:(NSDate*)fromDate toDate:(NSDate*)todate andDays:(int)theDays
{
    NSManagedObject *matches = nil;

    for (int a=0;a<appDelegate.servingsArray.count;a++)
    {
        matches = [appDelegate.servingsArray objectAtIndex:a];
        // compare new endpoints inside timer lapse
    //    LogDebug(@"Compare fromDate %@ toDate %@ servDate %@ hastaDate %@",fromDate,todate,[matches valueForKey:@"servDate"],[matches valueForKey:@"hastaDate"]);
        int ld=[[matches valueForKey:@"servDays"] integerValue];
        LogDebug(@"Dias Required %x Existing %x Result %x",theDays,ld,ld&theDays);
        if([[matches valueForKey:@"servDate"] compare: fromDate]==NSOrderedAscending && [[matches valueForKey:@"hastaDate"] compare:fromDate]==NSOrderedDescending)
            return NO;
        if([[matches valueForKey:@"servDate"] compare: todate]==NSOrderedAscending && [[matches valueForKey:@"hastaDate"] compare:todate]==NSOrderedDescending)
            return NO;
        // compare existing inside new timer
        if([fromDate compare: [matches valueForKey:@"servDate"]]==NSOrderedAscending && [fromDate compare:[matches valueForKey:@"hastaDate"]]==NSOrderedDescending)
            return NO;
        if([todate compare: [matches valueForKey:@"servDate"]]==NSOrderedAscending && [ todate compare:[matches valueForKey:@"hastaDate"]]==NSOrderedDescending)
            return NO;
    }
    
    return YES;
}
-(void)saveChanges
{
    NSDate *fromDate;
    NSString *mis;
    NSMutableString *answer;
    answer=[NSMutableString string];
    NSDateComponents *comps;
    NSCalendar *calendar;
    
    calendar = [[NSCalendar alloc]
                initWithCalendarIdentifier:NSGregorianCalendar];//[NSCalendar currentCalendar];
    [calendar setLocale:[NSLocale currentLocale]];
    NSDate *theDate = datePicker.date;
  //  LogDebug(@"From before %@ %f arrow %d",theDate,hastaPicker.countDownDuration,arrowState);
    int como=arrowState?-1:1;
    theDate=[theDate dateByAddingTimeInterval:(int)(hastaPicker.countDownDuration*como)];
  //  LogDebug(@"From after %@",theDate);
    [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitMinute
                                    startDate:&theDate
                                     interval:NULL
                                      forDate:theDate]; // make date with 0 seconds
    if(arrowState)
    {
    comps =
    [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:theDate];
    //since meals will be sorted by date, and changes(plus or minus) can ocurr in differents Dates, set the date part to a static one. We are only interested in Time
    comps.year   = 2000;
    comps.month = 1;
    comps.day = 1;
    int hora=(int)comps.hour;
    int minu=(int)comps.minute;
 //   LogDebug(@"año %d month %d day %d Hora %d minus %d",comps.year,comps.month,comps.day,hora,minu);
    //btw get the time part to send the esp8266
    
    fromDate = [calendar dateFromComponents:comps];
    comps.year   = 2000;
    comps.month = 1;
    comps.day = 1;
    comps.hour=hora;
    comps.minute=minu;
    comps.second=0;
    fromDate = [calendar dateFromComponents:comps];
    }
    else
    {
        comps =
        [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:datePicker.date];
        fromDate = [calendar dateFromComponents:comps];
        comps.year   = 2000;
        comps.month = 1;
        comps.day = 1;
        comps.second=0;
        fromDate = [calendar dateFromComponents:comps];
    }
    int timeDiff=(int)hastaPicker.countDownDuration;
 //   comps =
  //  [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:fromDate];
  //  LogDebug(@"año %ld month %ld day %ld Hora %d minus %d",comps.year,comps.month,comps.day,hora,minu);
    
 //  LogDebug(@"Time from %@ %@ dif %d",fromDate,theDate,timeDiff);

    selectedIndices = dias.selectedSegmentIndexes;
    int ld=[self storeDays];//get byte with bit days set according to selection
    dirtys=dirtyt=false;

    NSManagedObjectContext *context =
    [appDelegate managedObjectContext];
    NSManagedObject *newServing;
    newServing = [NSEntityDescription
                  insertNewObjectForEntityForName:@"Servings"
                  inManagedObjectContext:context];
    
    
    
    [newServing setValue:name.text forKey:@"servName"];
 //   [newServing setValue:passww.text forKey:@"servPassword"];
    NSDate* newDate = [fromDate dateByAddingTimeInterval:hastaPicker.countDownDuration];
 //   LogDebug(@"From %@ New Date %@",fromDate,newDate);
    // with two dates, check they are valid
    if (![self checkNoOverlap:fromDate toDate:newDate andDays:ld])
    {
        [self blurScreen];
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Overlapping Timers"
                                                                       message:@"Current setting will overlap with other timers."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                   [backGroundBlurr removeFromSuperview];
                                                              }];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitMinute startDate:&newDate interval:NULL forDate:newDate];
    [newServing setValue: fromDate forKey:@"servDate"];
    [newServing setValue: newDate forKey:@"hastaDate"];
    [newServing setValue: [NSNumber numberWithInteger:ld] forKey:@"servDays"];
    [newServing setValue: [NSNumber numberWithInteger:notis.on] forKey:@"servNotis"];
    [newServing setValue: [NSNumber numberWithInteger:1] forKey:@"servOnOff"];
    [newServing setValue: [NSNumber numberWithInteger:40] forKey:@"servTempMin"];
    [newServing setValue: [NSNumber numberWithInteger:(int)circleTemp.currentValue==0?40:(int)circleTemp.currentValue] forKey:@"servTempMax"];
    [newServing setValue:  [appDelegate.workingBFF valueForKey:@"bffName"] forKey:@"servBFFName"];
  
    NSMutableSet *serv=[appDelegate.workingBFF mutableSetValueForKey:@"meals"];
    [serv addObject:newServing];
    [appDelegate.workingBFF setValue:serv forKey:@"meals"];
  //  newDate=nil;
    // do not add to servingsarray becuse Timings VC will reload data from Core Data and start fresh.
    NSString* result = [name.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];//left and right trim spaces
    NSString *myNewString = [result stringByReplacingOccurrencesOfString:@"\\s"
                                                                 withString:@"%20"
                                                                    options:NSRegularExpressionSearch
                                                                      range:NSMakeRange(0, [result length])];
    //send ESP8266 a New Meal, id=position in array, day=byte with bits for each day,hour-minute,Open time miliseconds and wait time
    mis=[NSString stringWithFormat:@"timerAdd?id=%@&day=%d&fromdate=%d&duration=%d&notis=%d&onOff=%d&temp=%d&once=%d",myNewString,ld,(int)[fromDate timeIntervalSince1970],(int)timeDiff,notis.on,1,(int)circleTemp.currentValue,once.on];//multiple arguments
    int reply=[comm lsender:mis andAnswer:NULL andTimeOut:[[[NSUserDefaults standardUserDefaults]objectForKey:@"txTimeOut"] intValue] vcController:self];
    if (!reply)
        [self showErrorMessage];
    else
    {
        [newServing setValue:[NSDate date] forKey:@"dateAdded"];// means it has been synced
        [self showOkMessage];
    }
    
    // save the data
    NSError *error;
    if(![context save:&error])
    {
        LogDebug(@"Save error %@",error);
        return;//if we cant save it return and dont send anything toi the esp8266
    }

}


- (IBAction)segmentedAction:(UISegmentedControl*)sender
{
    dirtys=true;//touched now dirty
}

-(IBAction)emailNotice:(UISwitch*)sender
{
    dirtys=true;//touched now dirty
    CABasicAnimation *crossFade = [CABasicAnimation animationWithKeyPath:@"contents"];
    crossFade.duration = 0.7;
    crossFade.fromValue =sender.isOn? (id)[UIImage imageNamed:@"email.png"]:[UIImage imageNamed:@"emailno.png"];
    crossFade.toValue = sender.isOn?[UIImage imageNamed:@"emailno.png"]: (id)[UIImage imageNamed:@"email.png"];
    crossFade.removedOnCompletion = NO;
    crossFade.fillMode = kCAFillModeForwards;
    [_email.layer addAnimation:crossFade forKey:@"animateContents"];
    
    if (sender.isOn)
        _email.image=[UIImage imageNamed:@"email.png"];
    else
        _email.image=[UIImage imageNamed:@"emailno.png"];

}

-(void)pickerColors
{
  //  [self.datePicker setValue:[UIColor colorWithRed:246/255.0f green:243/255.0f blue:166/255.0f alpha:1.0f] forKeyPath:@"backgroundColor"];
    [self.datePicker setValue:[UIColor colorWithRed:251/255.0f green:199/255.0f blue:0/255.0f alpha:1.0f] forKeyPath:@"backgroundColor"];

    [self.datePicker setValue:[UIColor blueColor] forKeyPath:@"textColor"];
    SEL selector = NSSelectorFromString(@"setHighlightsToday:");
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDatePicker instanceMethodSignatureForSelector:selector]];
    BOOL no = NO;
    [invocation setSelector:selector];
    [invocation setArgument:&no atIndex:2];
    [invocation invokeWithTarget:self.datePicker];
    
    [self.hastaPicker setValue:[UIColor colorWithRed:251/255.0f green:199/255.0f blue:0/255.0f alpha:1.0f] forKeyPath:@"backgroundColor"];
    [self.hastaPicker setValue:[UIColor blueColor] forKeyPath:@"textColor"];
    SEL selector1 = NSSelectorFromString(@"setHighlightsToday:");
    NSInvocation *invocation1 = [NSInvocation invocationWithMethodSignature:[UIDatePicker instanceMethodSignatureForSelector:selector1]];
    [invocation1 setSelector:selector];
    [invocation1 setArgument:&no atIndex:2];
    [invocation1 invokeWithTarget:self.hastaPicker];
 //   NSTimeInterval seconds = ceil([[NSDate date] timeIntervalSinceReferenceDate]/900.0)*900.0;
 //   datePicker.date = [NSDate dateWithTimeIntervalSinceReferenceDate:seconds];
    
//    NSDate *currentDate = [[NSDate alloc] init];
  //  LogDebug(@"Start date %@ currente %@",datePicker.date, currentDate);
}

-(void)setDays:(int)ldias
{
    //from byte with each bit defining a day of the week set the selected indices
    NSMutableIndexSet *mutableIndexSet = [[NSMutableIndexSet alloc] init];
    for (int a=0;a<8;a++)
        if (ldias & (1<<a))
            [mutableIndexSet addIndex:a];
    [ dias setSelectedSegmentIndexes:mutableIndexSet];
}

-(int)storeDays
{
    int ldias=0,dummy;
    selectedItemsArray=nil;
    selectedItemsArray=[NSMutableArray array];
    [selectedIndices enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
    [selectedItemsArray addObject:[NSNumber numberWithInteger:idx]];
    }];
    for (int a=0; a<selectedItemsArray.count; a++) {
        dummy=(int)[[selectedItemsArray objectAtIndex:a]integerValue];
        ldias = ldias | (1<< dummy);
    }
    return ldias;
}

- (void)viewWillDisappear:(BOOL)animated { //Is used as a Save Options if anything was changed Instead of Buttons
    [super viewWillDisappear:animated];
    if (dontsavef) return;
   

   }
/*
-(void)segment
{
    return;
    CGFloat viewWidth = CGRectGetWidth(self.view.frame);
    
    segmentedControl2 = [[HMSegmentedControl alloc] initWithSectionImages:@[[UIImage imageNamed:@"serving1sbw.png"], [UIImage imageNamed:@"serving2sbw.png"],
                                                                            [UIImage imageNamed:@"serving3sbw.png"], [UIImage imageNamed:@"serving4sbw.png"],
                                                                            [UIImage imageNamed:@"serving5sbw.png"]] sectionSelectedImages:@[[UIImage imageNamed:@"serving1s-1.png"],
                                                                            [UIImage imageNamed:@"serving2s-1.png"], [UIImage imageNamed:@"serving3s-1.png"],
                                                                            [UIImage imageNamed:@"serving4s-1.png"], [UIImage imageNamed:@"serving5s-1.png"]]];

    segmentedControl2.frame = CGRectMake(0,390, viewWidth, 55);
    segmentedControl2.selectionIndicatorHeight = 2.0f;
    segmentedControl2.backgroundColor = [UIColor clearColor];
    segmentedControl2.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    segmentedControl2.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
    [segmentedControl2 addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:segmentedControl2];
    if(appDelegate.lastbutton<5)
        segmentedControl2.selectedSegmentIndex=appDelegate.lastbutton;

}
*/
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    LogDebug(@"Passf %d",appDelegate.passwordf);
    if (!appDelegate.passwordf)
    {
        LogDebug(@"Need to get password");
        [self performSegueWithIdentifier:@"getPassword" sender:self];
    }
    
    [self workingIcon];
    dontsavef=false;
   // [self segment];
    [name becomeFirstResponder];
    segmentedControl2.selectedSegmentIndex=0;//default
    NSString *cualo=[NSString stringWithFormat:@"serv%dOpen",1];
    NSString *cualw=[NSString stringWithFormat:@"serv%dWait",1];
    openT=(int)[[[NSUserDefaults standardUserDefaults]objectForKey:cualo] integerValue];
    waitT=(int)[[[NSUserDefaults standardUserDefaults]objectForKey:cualw] integerValue];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.lastbutton !=UISegmentedControlNoSegment )
    {
    segmentedControl2.selectedSegmentIndex=appDelegate.lastbutton;
        NSString *cualo=[NSString stringWithFormat:@"serv%dOpen",appDelegate.lastbutton];
        NSString *cualw=[NSString stringWithFormat:@"serv%dWait",appDelegate.lastbutton];
        openT=(int)[[[NSUserDefaults standardUserDefaults]objectForKey:cualo] integerValue];
        waitT=(int)[[[NSUserDefaults standardUserDefaults]objectForKey:cualw] integerValue];
    }
    datePicker.date=[NSDate date];
}

-(IBAction)regresa:(UIButton *)sender
{
    if (sender.tag==1)
    {
    dontsavef=YES;
     [self performSegueWithIdentifier:@"doneEditVC" sender:self];
        return;
    }
    
    if([name validate] )
    {
    [self saveChanges];
    dontsavef=NO;
    }
    
    
}
-(void)salta
{
    [segmentedControl2 setSelectedSegmentIndex:UISegmentedControlNoSegment];
    dontsavef=true;

    [self performSegueWithIdentifier:@"settingsVC" sender:self];
    
}
/*
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"settingsVC"]) { //going to custom timing, set timing values
        //pass the variable and context
        feederViewController *destViewController = segue.destinationViewController;
        destViewController.openT = openT;
        destViewController.waitT = waitT;
        destViewController.fc=self;
    }
}
*/
- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl {
    appDelegate.lastbutton=(int)segmentedControl.selectedSegmentIndex;
    NSString *cualo=[NSString stringWithFormat:@"serv%dOpen",appDelegate.lastbutton];
    NSString *cualw=[NSString stringWithFormat:@"serv%dWait",appDelegate.lastbutton];
    if (segmentedControl.selectedSegmentIndex==4)
        [self performSelectorOnMainThread:@selector(salta) withObject:NULL waitUntilDone:false];
    else
    { //get timing options from saved in NSDefaults
        openT=(int)[[[NSUserDefaults standardUserDefaults]objectForKey:cualo] integerValue];
        waitT=(int)[[[NSUserDefaults standardUserDefaults]objectForKey:cualw] integerValue];
   //     LogDebug(@"Cual %@=%d",cualo,openT);

    }
}

- (void)uisegmentedControlChangedValue:(UISegmentedControl *)segmentedControl {
    if (segmentedControl.selectedSegmentIndex==4)
    {
        appDelegate.lastbutton=5;
        [self performSegueWithIdentifier:@"settingsVC" sender:self];//jump to custom setting
    }
}


-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue {
  //our return segue
}

-(void) checkLogin
{
    if (!appDelegate.passwordf)
    {
        LogDebug(@"Need to get password again");
        [self performSegueWithIdentifier:@"getPassword" sender:self];
    }
}

- (void)viewDidLoad {

    [super viewDidLoad];
    comm=[httpVC new];
    [self pickerColors];
    arrowConnected=[UIImage imageNamed:@"arrow.png"];
    arrowDisconnected=[UIImage imageNamed:@"arrowbroken.png"];
    arrowState=YES;
    name.text=@"";
    [name addRegx:@"^.{3,20}$" withMsg:@"Serving name should have at leat 3 chars"];
    [passww addRegx:@"^.{4,10}$" withMsg:@"Password must have 3 to 8 chars"];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSNumber *passw=[[NSUserDefaults standardUserDefaults]objectForKey:@"password"];
    if (passw.integerValue>0)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkLogin)
                                                 name:UIApplicationWillEnterForegroundNotification object:nil];
     notis.transform = CGAffineTransformScale(CGAffineTransformIdentity, .75, 0.75);
    once.transform = CGAffineTransformScale(CGAffineTransformIdentity, .75, 0.75);

    dirtyt=dirtys=dontsavef= false;
    [[UISegmentedControl appearance] setTitleTextAttributes:
        @{NSForegroundColorAttributeName : [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f]} forState:UIControlStateSelected];
    segmentedControl2.selectedSegmentIndex=0;
    NSString *cualo=[NSString stringWithFormat:@"serv%dOpen",1];
    NSString *cualw=[NSString stringWithFormat:@"serv%dWait",1];
    openT=(int)[[[NSUserDefaults standardUserDefaults]objectForKey:cualo] integerValue];
    waitT=(int)[[[NSUserDefaults standardUserDefaults]objectForKey:cualw] integerValue];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"NL"];
    [datePicker setLocale:locale];
    NSMutableIndexSet *mutableIndexSet = [[NSMutableIndexSet alloc] init];
    hastaPicker.countDownDuration=15.0*60.0f;
    circleTemp.currentValue=(float)circleTemp.defaultValue;
    lowTemp.currentValue=(float)lowTemp.defaultValue;
    temp.text=[NSString stringWithFormat:@"%ld˚C",(long)circleTemp.defaultValue];
    lowTempLabel.text=[NSString stringWithFormat:@"%ld˚C",(long)lowTemp.defaultValue];
    [self calcTimeToTemp];
    //by default turn all days on
    for (int a=0;a<8;a++)
            [mutableIndexSet addIndex:a];
    [ dias setSelectedSegmentIndexes:mutableIndexSet];
  }

@end
