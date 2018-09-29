//
//  Log.m
//  GarageIoT
//
//  Created by Robert on 6/15/17.
//  Copyright © 2017 Colin Eberhardt. All rights reserved.
//
#define LOGLEN 28           //Record is 4 date+2 code+2 code1+20 description=28
#import "Log.h"
#import "mlogCell.h"

@interface Log ()

@end

@implementation Log

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
    
     alert = [UIAlertController alertControllerWithTitle:title
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

-(NSDictionary*)getLogEntry:(NSData*) data from:(int)desde
{
    int integ;
    uint16_t code,code1;
    char texto[20];
    
    NSRange rango=NSMakeRange(desde, 4);
    [data getBytes:&integ range:rango];
    NSDate *date1 = [NSDate dateWithTimeIntervalSince1970:integ];
    
    rango=NSMakeRange(desde+4,2);
    [data getBytes:&code range:rango];
    NSNumber *codigo=[NSNumber numberWithInt:code];
    
    rango=NSMakeRange(desde+6,2);
    [data getBytes:&code1 range:rango];
    NSNumber *codigo1=[NSNumber numberWithInt:code1];
    
    rango=NSMakeRange(desde+8,20);
    [data getBytes:&texto range:rango];
    
    NSDictionary * dic =[[NSDictionary alloc]
                        initWithObjectsAndKeys:codigo,@"code",codigo1,@"code1",[appDelegate.logText objectAtIndex:code],@"mess",date1,@"date",nil] ;
    return(dic);
}

-(void)showlog:(NSData *)data
{
    uint16_t desde,len,codeid;
    if (data.length<32)
        return; // in case No Log Messages
    
    NSRange rango=NSMakeRange(0, 2);
    [data getBytes:&codeid range:rango];
    rango=NSMakeRange(2, 2);
    [data getBytes:&len range:rango];
    if(len!=0xa0a0 && codeid !=0x3939) //Centinel MSg is A0A0
    {
        NSLog(@"Wrong centinel\n");
        return;
    }
    long sobran=data.length-4;
    desde=4;
    while(sobran>0)
    {
        NSDictionary *entry=[self getLogEntry:data from:desde];
       len=[entry[@"len"] integerValue];
        desde+=LOGLEN;
        sobran-=LOGLEN;
        [entries addObject:entry];
        entry=nil;
   //    NSLog(@"Date %@ Code %@ Message:%@",entry[@"date"],entry[@"code"],entry[@"mess"]);
        
    }
    [_table reloadData];
}


- (void) rxMessage:(NSNotification *) notification
{
    if(tumblrHUD)
        [tumblrHUD hide];
    if(mitimer)
        [mitimer invalidate];
    
    if ([[notification name] isEqualToString:@"Log"])
        [self showlog:notification.userInfo[@"Data"]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    entries=[[NSMutableArray alloc] initWithCapacity:20];
}

- (void)viewDidAppear:(BOOL)animated {
    NSDictionary *texto;

    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(rxMessage:)
                                                 name:@"Log"
                                               object:texto];
    
    
    appDelegate =   (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self workingIcon];
    [entries removeAllObjects];
    [self hud];
    [appDelegate.chan enviaWithQue:@"readlog?password=zipo" notikey:@"Log"];
}

- (void)viewWillDisappear:(BOOL)animated { 
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath row] == entries.count-1){
        dispatch_async(dispatch_get_main_queue(), ^{[tumblrHUD hide]; });
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return entries.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int codenum;
    mlogCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mlogCell"];
    
    UIView * theContentView = [[UIView alloc]initWithFrame:CGRectMake(0,0,_table.bounds.size.width,5)];
    theContentView.backgroundColor = [UIColor grayColor];//contentColor
    [cell addSubview: theContentView];
     NSInteger randomNumber = arc4random() % (appDelegate.appColors.count -1);
   NSDictionary *entry = [entries objectAtIndex:indexPath.row] ;
    cell.mensaje.text = entry[@"mess"];
    codenum=[entry[@"code"] integerValue];
    cell.backgroundColor= [appDelegate.appColors objectAtIndex:codenum];
    NSString *rsimage=[NSString stringWithFormat:@"codeimg%d",codenum];
    cell.codeImage.image=[UIImage imageNamed:rsimage];
    if(cell.codeImage.image==NULL)
        cell.codeImage.image=[UIImage imageNamed:@"general"];
    codenum=[entry[@"code1"] integerValue];
    cell.code1.text=[NSString stringWithFormat:@"%d",codenum];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HH:mm:ss"];
    NSString *dateString = [dateFormat stringFromDate:entry[@"date"]];
    cell.hora.text=dateString;
    [dateFormat setDateFormat:@"dd/MM/yy"];
    dateString = [dateFormat stringFromDate:entry[@"date"]];
    cell.dia.text=dateString;
    return cell;
}
@end
