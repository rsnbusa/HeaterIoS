//
//  FirstViewController.m
//  FoodAuto
//
//  Created by Robert on 3/2/16.
//  Copyright © 2016 Robert. All rights reserved.
//

#import "FirstViewController.h"
#import <UIKit/UIKit.h>
#import "URBSegmentedControl.h"
#import "colorAvg.h"
#import "AppDelegate.h"
#import "petInfoViewController.h"
#import "miColl.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import "httpVC.h"
#import "btSimplePopUp.h"
#import "CCColorCube.h"
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import <NetworkExtension/NEHotspotHelper.h>

@interface FirstViewController ()

@end

#if 0 // set to 1 to enable logs
#define LogDebug(frmt, ...) NSLog([frmt stringByAppendingString:@"[%s]{%d}"], ##__VA_ARGS__,__PRETTY_FUNCTION__,__LINE__);
#else
#define LogDebug(frmt, ...) {}
#endif

@implementation FirstViewController

@synthesize host,answer,effects,petName,collect,picScroll,mqttServer,album,fotoSize,onOff,netServiceBrowser,passSW,addBut;

-(void)timeout
{
    if(tumblrHUD)
        [tumblrHUD hide];
    
    [self showMensaje:@"Heater Msg" withMessage:@"Comm Timeout" doExit:NO];
}

-(void)hud:(int)tim
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
        mitimer=[NSTimer scheduledTimerWithTimeInterval:tim
                                                 target:self
                                               selector:@selector(timeout)
                                               userInfo:nil
                                                repeats:NO];
}

-(void)oneTap:(id)sender
{
    UIStoryboard *storyboard=self.storyboard;
    petInfoViewController *myVC = (petInfoViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PetInfo"];
    appDelegate.addf=NO;
    [self presentViewController:myVC animated:YES completion:nil];
}

 -(void)showMensaje:(NSString*)title withMessage:(NSString*)mensaje doExit:(BOOL)salir
{
    if (alert)
    {
        [alert dismissViewControllerAnimated:YES completion:nil];
        alert=nil;
    }

    alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:mensaje
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                            //   if (salir) exit(0);
                                                          }];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [alert dismissViewControllerAnimated:YES completion:nil];
    });
}

-(void)sendMqtt:(NSString*)mis withNotification:(NSString*)notif
{
    [self hud:10];
    [appDelegate.chan enviaWithQue:mis notikey:notif];
}

-(void)confirmDelete
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Delete Heater"
                                                                   message:[NSString stringWithFormat:@"You really want to remove %@",[appDelegate.workingBFF valueForKey:@"bffName"]]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              NSString *mis=[NSString stringWithFormat:@"erase?bff=%@&password=zipo",
                                                                                [appDelegate.workingBFF valueForKey:@"bffName"]];
                                                              [self sendMqtt:mis withNotification:@"Mensaje"];
                                                              [self deleteAllEntity:@"Emails"];
                                                              [self deleteAllEntity:@"Servings"];
                                                              [appDelegate.bffs removeObject: appDelegate.workingBFF];
                                                              NSManagedObjectContext *context =
                                                              [appDelegate managedObjectContext];
                                                              
                                                              NSError *error;
                                                              [context deleteObject:appDelegate.workingBFF];
                                                              if(![context save:&error])
                                                              {
                                                                  LogDebug(@"Delete error %@",error);
                                                                  return;//if we cant save it return and dont send anything toi the esp8266
                                                              }
                                                              for(UIImageView *subview in picScroll.subviews) {
                                                                  [subview removeFromSuperview];
                                                              }
                                                              [appDelegate.imageArray removeObjectAtIndex:indexOfPage];

                                                              [self loadBffs];
                                                              [self getArrays];
                                                          }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                          }];
    
    [alert addAction:defaultAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}
-(IBAction)prepareForUnwindFirst:(UIStoryboardSegue *)segue {
    
}

- (IBAction)bffOnOff:(UIButton*)sender
{
    int cual=sender.tag?0:1;
    [self OnOffState:cual];
    NSString *cmd=[NSString stringWithFormat:@"OnOff?status=%d",cual];
    [self sendMqtt:cmd withNotification:@"Mensaje"];

    [appDelegate.workingBFF setValue:[NSNumber numberWithInteger:cual] forKey:@"bffOnOff"];
    NSError *error;
    if(![[appDelegate managedObjectContext] save:&error])
        LogDebug(@"Save error OnOff bff %@",error);
}

- (IBAction)fotoSizeSlider:(UISlider*)sender
{
    fotoHV=(int)sender.value;
    [album reloadData];
    
}


- (UIImage *)scaleAndRotateImage:(UIImage *) image {
    int kMaxResolution = 320;
    
    CGImageRef imgRef = image.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = bounds.size.width / ratio;
        }
        else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //You can retrieve the actual UIImage
    UIImage *estai = [info valueForKey:UIImagePickerControllerOriginalImage];
    UIImage *imagel = [self scaleAndRotateImage: [info objectForKey:UIImagePickerControllerOriginalImage]];
    // Create path.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *final=[NSString stringWithFormat:@"%@.txt",[appDelegate.workingBFF valueForKey:@"bffName"]];//.txt hasta que tengamos webiste ue nos permita usar .png
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:final];
       // Save image.
    [UIImagePNGRepresentation(imagel) writeToFile:filePath atomically:YES];
  //  [UIImageJPEGRepresentation(imagel,1.0) writeToFile:filePath atomically:YES];

    [picker dismissViewControllerAnimated:YES completion:nil];
    lscrollView.image=imagel;
    appDelegate.imageArray[indexOfPage]=imagel;

    if (appDelegate.workingBFF)
    {
        [appDelegate.workingBFF setValue:[appDelegate.workingBFF valueForKey:@"bffName"] forKey:@"bffImage"];
          NSError *error;
           if(![[appDelegate managedObjectContext] save:&error])
              LogDebug(@"Save error Image bff %@",error);
    }
   }

-(void)getPhoto
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.delegate = (id)self;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

-(void)createDefaults
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger: 0x11223344]  forKey:@"centinel"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:10] forKey:@"txTimeOut"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:@"transport"];
    [[NSUserDefaults standardUserDefaults] setObject:@"ht"  forKey:@"appId"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)deleteAllEntity:(NSString *)cualEntity
{
     NSError *error;
    NSManagedObjectContext *context =[appDelegate managedObjectContext];
    
    NSEntityDescription *entityDesc =
    [NSEntityDescription entityForName:cualEntity
                inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    NSBatchDeleteRequest *delete = [[NSBatchDeleteRequest alloc] initWithFetchRequest:request];
    [[appDelegate persistentStoreCoordinator] executeRequest:delete withContext:context error:&error];
    [context save:&error];
}

-(void)getUnitCount
{
    NSManagedObjectContext *context =[appDelegate managedObjectContext];
    
    NSEntityDescription *entityDesc =
    [NSEntityDescription entityForName:@"Servings"
                inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    //get count of current BFF
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"servDate" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"servBFFName", [appDelegate.workingBFF valueForKey:@"bffName"]];
    [request setPredicate:predicate];
    NSError *error;
    appDelegate.servingsArray = [[context executeFetchRequest:request
                                                        error:&error] mutableCopy];

    [[appDelegate.tabBarController.tabBar.items objectAtIndex:1] setBadgeValue:[NSString stringWithFormat:@"%ld",appDelegate.servingsArray.count]];
}

-(void)dmyTapMethod:(UITapGestureRecognizer *)gr {
    lscrollView=(UIImageView*)gr.view;
   [self getPhoto];
}

-(void)getArrays
{
    // Get emails, count and order them by address
    NSManagedObjectContext *context =[appDelegate managedObjectContext];
    NSEntityDescription *entityDesc =
    [NSEntityDescription entityForName:@"Emails"
                inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    //Sort them
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"address" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
  //  [request setSortDescriptors:sortDescriptors];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"bffName", [appDelegate.workingBFF valueForKey:@"bffName"]];
    [request setPredicate:predicate];
    NSError *error;
    appDelegate.emailsArray = [[context executeFetchRequest:request
                                                      error:&error] mutableCopy];
    // Get meals, count and order them by date
    entityDesc =[NSEntityDescription entityForName:@"Servings" inManagedObjectContext:context];
    request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    //Sort them
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"servDate" ascending:YES];
    sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"servBFFName", [appDelegate.workingBFF valueForKey:@"bffName"]];
    [request setPredicate:predicate];
    appDelegate.servingsArray = [[context executeFetchRequest:request
                                                        error:&error] mutableCopy];
    [[appDelegate.tabBarController.tabBar.items objectAtIndex:1] setBadgeValue:[NSString stringWithFormat:@"%ld",appDelegate.servingsArray.count]];
    [[appDelegate.tabBarController.tabBar.items objectAtIndex:0] setBadgeValue:[NSString stringWithFormat:@"%ld",(unsigned long)appDelegate.bffs.count]];

}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [appDelegate.chan unsubscribe];
    
    indexOfPage = roundf(scrollView.contentOffset.x / scrollView.frame.size.width);
    if (indexOfPage==appDelegate.lastpos)
        return; //Same position do nothing
    appDelegate.lastpos=indexOfPage;
    appDelegate.workingBFF=appDelegate.bffs[indexOfPage];
    // Subscribe new mqtt queues
    NSLog(@"Subscribe %@ %@",[appDelegate.workingBFF valueForKey:@"bffGroup"],[appDelegate.workingBFF valueForKey:@"bffName"]);
    [appDelegate.chan subscribeWithGrupo:[appDelegate.workingBFF valueForKey:@"bffGroup"] meter:[appDelegate.workingBFF valueForKey:@"bffName"] notif:nil];
    //Show name
    CATransition *transition = [CATransition animation];
    transition.duration = 0.80;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    [petName.layer addAnimation:transition forKey:nil];
    petName.text=[appDelegate.workingBFF valueForKey:@"bffName"];
    appDelegate.messageType=(int)[[appDelegate.workingBFF valueForKey:@"bffLimbo"]integerValue];
    NSInteger randomNumber = arc4random() % (appDelegate.appColors.count -1);
    petName.textColor=[appDelegate.appColors objectAtIndex:randomNumber];
    [self OnOffState:(int)[[appDelegate.workingBFF valueForKey:@"bffOnOff"] integerValue] ];
    [self getArrays];
}

-(void)loadBffs
{
    UIImage *licon,*l22;
    
    //get all BFFs in DB
    NSManagedObjectContext *context =[appDelegate managedObjectContext];
    NSEntityDescription *entityDesc =
    [NSEntityDescription entityForName:@"BFF"
                inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    //get all and sort them by name
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"bffName" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    [request setReturnsObjectsAsFaults:NO];
    NSError *error;
    appDelegate.bffs = [[context executeFetchRequest:request error:&error] mutableCopy];//get them
    //Now read images from files and insert them in the scrollView and set touch actions for single and double tap
    //Scrollview dimensions
    CGFloat width = picScroll.bounds.size.width;
    CGFloat heigth = picScroll.bounds.size.height;
    int van=0;
    
    for(NSManagedObject *pet in appDelegate.bffs)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *final=[NSString stringWithFormat:@"%@.txt",[pet valueForKey:@"bffName"]];
      //  NSString *final=[NSString stringWithFormat:@"%@.png",[pet valueForKey:@"bffName"]];

        NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:final];
        l22=[UIImage imageWithContentsOfFile:filePath];
        licon=[self scaleAndRotateImage:l22];
   //     licon = [[UIImage alloc] initWithCGImage:[UIImage imageWithContentsOfFile:filePath].CGImage scale:1.0 orientation:UIImageOrientationUp];
                              //    initialImage.CGImage, scale: 1, orientation: initialImage.imageOrientation)
       
        if (licon==NULL)
                licon = [UIImage imageNamed:@"camera"];//need a photo
        [appDelegate.imageArray addObject:licon];
        UITapGestureRecognizer *dobleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dmyTapMethod:)];//for chosing image
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(oneTap:)];//for chosing image
        UIImageView *limage = [[UIImageView alloc] initWithFrame:CGRectMake(van*width, 0, width,heigth)];
        dobleTap.numberOfTapsRequired = 2;
        [limage addGestureRecognizer:dobleTap];
        [limage addGestureRecognizer:singleTap];
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressTap:)];
        [limage addGestureRecognizer:longPress];
        limage.image=licon;
        limage.tag=van++;
        [limage setMultipleTouchEnabled:YES];
        [limage setUserInteractionEnabled:YES];
        [limage setContentMode:UIViewContentModeScaleAspectFit];
        [singleTap requireGestureRecognizerToFail:dobleTap];
        [picScroll addSubview:limage];
   //     [pet setValue:@"" forKey:@"bffLastIpPort"];
    }

    //Scroll to first position and show name
    
    if (appDelegate.bffs.count>0)
            appDelegate.workingBFF=appDelegate.bffs[0]; //First record is the working record
    appDelegate.lastpos=0;
    picScroll.contentSize = CGSizeMake(width * appDelegate.bffs.count, heigth);

    [picScroll scrollRectToVisible: CGRectMake(0, 0, width, heigth) animated: true];
    petName.text=[appDelegate.workingBFF valueForKey:@"bffName"];
    NSInteger randomNumber = arc4random() % (appDelegate.appColors.count -1);
    petName.textColor=[appDelegate.appColors objectAtIndex:randomNumber];
}

-(IBAction)deleteBFF:(id)sender
{
    [self confirmDelete];
}


-(IBAction)viewMode:(UIButton*)sender
{
    CATransition *t1,*t2,*t4;
;
    if (viewmodef)// Scroll is TRUE
    {
        t1 = [CATransition animation];
        t1.duration = 0.80;
        t1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        t1.type = kCATransitionFade;
        [picScroll.layer addAnimation:t1 forKey:nil];
        
        t2 = [CATransition animation];
        t2.duration = 0.80;
        t2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        t2.type = kCATransitionFade;
        [album.layer addAnimation:t2 forKey:nil];

    
        t4 = [CATransition animation];
        t4.duration = 0.80;
        t4.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        t4.type = kCATransitionFade;
        [fotoSize.layer addAnimation:t2 forKey:nil];
        
     //   [gridPano setImage:grid forState:UIControlStateNormal];
        album.hidden=YES;
        picScroll.hidden=NO;
        petName.hidden=NO;
        fotoSize.hidden=YES;
        if(appDelegate.bffs.count>0 )
        {
        //scroll to last selected item in Grid mode
        appDelegate.workingBFF=appDelegate.bffs[indexOfPage];
        CGFloat width = picScroll.bounds.size.width;
        CGFloat heigth = picScroll.bounds.size.height;
        [picScroll scrollRectToVisible: CGRectMake(indexOfPage*width, 0, width, heigth) animated: true];
        petName.text=[appDelegate.workingBFF valueForKey:@"bffName"];
        }
        
    }
    else
    {
        if (appDelegate.bffs.count<2) return; //no need Just one
        t1 = [CATransition animation];
        t1.duration = 0.80;
        t1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        t1.type = kCATransitionFade;
        [picScroll.layer addAnimation:t1 forKey:nil];
        
        t2 = [CATransition animation];
        t2.duration = 0.80;
        t2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        t2.type = kCATransitionFade;
        [album.layer addAnimation:t2 forKey:nil];
        
        t4 = [CATransition animation];
        t4.duration = 0.80;
        t4.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        t4.type = kCATransitionFade;
        [fotoSize.layer addAnimation:t2 forKey:nil];
        
       // [gridPano setImage:pano forState:UIControlStateNormal];
        album.hidden=NO;
        picScroll.hidden=YES;
        petName.hidden=YES;
        fotoSize.hidden=NO;
        
        if (appDelegate.bffs.count>0)
        {
        appDelegate.workingBFF=appDelegate.bffs[indexOfPage];
         NSIndexPath *selection = [NSIndexPath indexPathForItem:indexOfPage
         inSection:1];
         [album selectItemAtIndexPath:selection
         animated:YES
         scrollPosition:UICollectionViewScrollPositionNone];
        [album reloadData];
        [album
         selectItemAtIndexPath:[NSIndexPath indexPathForItem:indexOfPage inSection:0]
         animated:YES
         scrollPosition:UICollectionViewScrollPositionCenteredVertically];
        }
       
    }
    viewmodef= !viewmodef;
    
}
-(IBAction)batchBFF:(id)sender
{
    batchf=YES;
     [self performSegueWithIdentifier:@"localb" sender:self];
   
}

-(IBAction)addBFF:(id)sender
{
    // Create basic structure but do not save it
    appDelegate.oldbff=appDelegate.workingBFF;
    appDelegate.lastpos = picScroll.contentOffset.x / picScroll.bounds.size.width;
    NSManagedObjectContext *context =
    [appDelegate managedObjectContext];
    NSManagedObject *newBFF= [NSEntityDescription
                                    insertNewObjectForEntityForName:@"BFF"
                                            inManagedObjectContext:context];

    [newBFF setValue:@"Chillo" forKey:@"bffName"];
    [newBFF setValue:@"" forKey:@"bffEmail"];
    [newBFF setValue:@"" forKey:@"bffGroup"];
    [newBFF setValue: @"" forKey:@"bffDomain"];
    [newBFF setValue: @"" forKey:@"bffMQTT"];
    [newBFF setValue: @81 forKey:@"bffPort"];
    [newBFF setValue: @0 forKey:@"bffMQTTPort"];
    [newBFF setValue: @NO forKey:@"bffOnOff"];
    [newBFF setValue:@1500 forKey:@"bffWatts"];
    [newBFF setValue:@220 forKey:@"bffVolts"];
    [newBFF setValue:@"" forKey:@"bffGalons"];
    [newBFF setValue:@0.12 forKey:@"bffKwH"];
    [newBFF setValue:@"" forKey:@"bffWater"];
    [newBFF setValue:@"" forKey:@"bffMQTT"];
    [newBFF setValue:@"" forKey:@"bffMqttU"];
    [newBFF setValue: @NO forKey:@"bffAutoT"];
    [newBFF setValue:@"" forKey:@"bffMqttP"];
    [newBFF setValue: @NO forKey:@"bffMonitor"];
    [newBFF setValue:@1 forKey:@"bffMonMins"];
    [newBFF setValue:@30000 forKey:@"bffDisp"];
    [newBFF setValue: @NO forKey:@"bffSSL"];

    appDelegate.workingBFF=newBFF;
  
    CGFloat width = picScroll.bounds.size.width;
    CGFloat heigth = picScroll.bounds.size.height;

    int van=(int)appDelegate.bffs.count;
    UITapGestureRecognizer *dobleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dmyTapMethod:)];
    UIImageView *limage = [[UIImageView alloc] initWithFrame:CGRectMake((van)*(int)width, 0, width,heigth)];
    UIImage *licon= [UIImage imageNamed:@"camera"];
    [appDelegate.imageArray addObject:licon];
    limage.image=licon;
    limage.tag=van+1;
    dobleTap.numberOfTapsRequired = 2;
    [limage addGestureRecognizer:dobleTap];
    [limage setMultipleTouchEnabled:YES];
    [limage setUserInteractionEnabled:YES];
    [limage setContentMode:UIViewContentModeScaleAspectFit];
    [picScroll addSubview:limage];

    picScroll.contentSize = CGSizeMake(width * (van+1), heigth);
    [picScroll scrollRectToVisible: CGRectMake(width * van, 0, width, heigth) animated: true];
    [self OnOffState:(int)[[appDelegate.workingBFF valueForKey:@"bffOnOff"] integerValue]];
    UIStoryboard *storyboard=self.storyboard;
    petInfoViewController *myVC = (petInfoViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PetInfo"];
    appDelegate.addf=YES;
    [self presentViewController:myVC animated:YES completion:nil];
}

-(void) checkLogin
{
    LogDebug(@"passf check %d",appDelegate.passwordf);
if (!appDelegate.passwordf)
{
    LogDebug(@"Need to get password again");
    [self performSegueWithIdentifier:@"getPassword" sender:self];
}
}

-(void)longPressTap:(UILongPressGestureRecognizer*)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
        [self viewMode:NULL];
}

-(void)cloneBut:(UILongPressGestureRecognizer*)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        appDelegate.clonef=YES;
        [self addBFF:NULL];
    }
}

-(void)showMensajeTimer:(NSString*)mensaje
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Server Information"
                                                                   message:mensaje
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
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
    
    if ([[notification name] isEqualToString:@"Mensaje"])
    {
        LogDebug (@"RX Successfull %@",notification.userInfo);
        [self showMensaje:@"Meter Message" withMessage:notification.userInfo[@"Answer"] doExit:NO];
    }
    
    if ([[notification name] isEqualToString:@"Unsolicited"])
    {
        LogDebug (@"Unsolicited %@",notification.userInfo);
        [self showMensaje:@"Meter Unsolicited Message" withMessage:notification.userInfo[@"Answer"] doExit:NO];
    }
}

- (void) validSubscribe:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"Subscribe"]){
        tumblrHUD.hudColor = UIColor.greenColor;
        LogDebug (@"Subscription Successfull %@",notification.userInfo);
        [appDelegate.chan enviaWithQue:@"session?password=zipo" notikey:@"Mensaje"];
    }
}

- (void) validConn:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"Connect"]){
        LogDebug (@"Connection Successfull %@",notification.userInfo);
        tumblrHUD.hudColor = UIColor.yellowColor;
        
        [appDelegate.chan subscribeWithGrupo:[appDelegate.workingBFF valueForKey:@"bffName"] meter:[appDelegate.workingBFF valueForKey:@"bffName"] notif:@"Subscribe"];
        
    }
}

- (void)viewDidLoad {
  
    [super viewDidLoad];
    NSNumber *centinel= [[NSUserDefaults standardUserDefaults]objectForKey:@"centinel"];
    if (centinel.integerValue !=0x11223344)
        [self createDefaults];

   [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:4] forKey:@"txTimeOut"];
  
    [album registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cvCell"];
    colorCube = [[CCColorCube alloc] init];
    viewmodef=NO;
    batchf=NO;
    fotoHV=100;
    picScroll.hidden=NO;
    petName.hidden=NO;
    album.hidden=YES;
    fotoSize.transform = CGAffineTransformScale(CGAffineTransformIdentity, .75, 0.75);
    mqttServer=[NSMutableString string];// blank
    
    appDelegate =   (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    heaterOn =       ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)?[UIImage imageNamed:@"onsmall.png"]:[UIImage imageNamed:@"oniphone.png"];
    heaterOff =      ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)?  [UIImage imageNamed:@"offsmall.png"]:[UIImage imageNamed:@"offiphone.png"];
    grid =           [UIImage imageNamed:@"grid.png"];
    pano =           [UIImage imageNamed:@"panorama.png"];
    passOn =         ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)?[UIImage imageNamed:@"lockedbig.png"]:[UIImage imageNamed:@"locked.png"];
    passOff =        ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)?  [UIImage imageNamed:@"unlockedbig.png"]:[UIImage imageNamed:@"unlocked.png"];

    appDelegate.messageType=0; //web service comm
    UILongPressGestureRecognizer *longPressBut = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(cloneBut:)];
    [addBut addGestureRecognizer:longPressBut];

    //Load all BFF and insert images into scroll view. Keep the first one as workingRecord
    [self loadBffs];
    loadFlag=NO;
    [self getArrays];
    
    if(appDelegate.workingBFF!=NULL)
    {
        [self hud:30];
        [appDelegate startTelegramService:[appDelegate.workingBFF valueForKey:@"bffMQTT"] withPort:[appDelegate.workingBFF valueForKey:@"bffMQTTPort"] respuesta:@"Connect" app:@"HeatIoT" abrev:@"ht"]; //connect to MQTT server
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction) passwordChange:(UIButton *)sw
{
    int cual=sw.tag?0:1;
    sw.tag=cual;
    [self OnOffStatePass:cual];
  }

-(void)OnOffStatePass:(int)como
{
    [UIView animateWithDuration:0.5 animations:^{
        passSW.alpha = 0.0f;
    } completion:^(BOOL finished) {
        passSW.imageView.animationImages = [NSArray arrayWithObjects:como?passOn:passOff,nil];
        [passSW.imageView startAnimating];
        [UIView animateWithDuration:0.5 animations:^{
            passSW.alpha = 1.0f;
        }];
    }];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:como ] forKey:@"password"];
    [[NSUserDefaults standardUserDefaults]  synchronize];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    NSNumber *passw=[[NSUserDefaults standardUserDefaults]objectForKey:@"password"];
    if (passw.integerValue==0)
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(void)viewDidAppear:(BOOL)animated
{
    NSDictionary *texto;

    if(!loadFlag)
    {
        [self loadBffs];
        loadFlag=YES;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(validConn:)
                                                 name:@"Connect"
                                               object:texto];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(rxMessage:)
                                                 name:@"Mensaje"
                                               object:texto];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(validSubscribe:)
                                                 name:@"Subscribe"
                                               object:texto];

    NSNumber *passw=[[NSUserDefaults standardUserDefaults]objectForKey:@"password"];
    [passSW setImage:passw.integerValue?passOn:passOff forState:UIControlStateNormal];
    if (passw.integerValue>0)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkLogin)
                                                     name:UIApplicationWillEnterForegroundNotification object:nil];
        LogDebug(@"passf %d",appDelegate.passwordf);
       if (!appDelegate.passwordf)
       {
           LogDebug(@"Need to get password");
           [self performSegueWithIdentifier:@"getPassword" sender:self];
       }
    }
  
    if(batchf)
    {
        [self loadBffs];
        batchf=NO;
    }

    [self performSelector:@selector(getUnitCount) withObject:NULL afterDelay:1.0];
    
    petName.text = [appDelegate.workingBFF valueForKey:@"bffName"];
    [[appDelegate.tabBarController.tabBar.items objectAtIndex:0] setBadgeValue:[NSString stringWithFormat:@"%ld",(unsigned long)appDelegate.bffs.count]];
    [self OnOffState:(int)[[appDelegate.workingBFF valueForKey:@"bffOnOff"] integerValue]];
    
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {

    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return appDelegate.imageArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    miColl *myCell = [album dequeueReusableCellWithReuseIdentifier:@"MyCell" forIndexPath:indexPath];
  
    UIImage *estaa=     [appDelegate.imageArray objectAtIndex:indexPath.row];
    myCell.im.image =   estaa;  //[appDelegate.imageArray objectAtIndex:indexPath.row];
                                //   NSArray *imgColors = [colorCube extractDarkColorsFromImage:estaa avoidColor:nil count:4];
    NSArray *imgColors = [colorCube extractColorsFromImage:estaa flags:CCAvoidBlack];

                                //  LogDebug(@"colors %@",imgColors);
                                //  UIImage *imm=[appDelegate.imageArray objectAtIndex:indexPath.row];
                                //  LogDebug(@"size %@",NSStringFromCGSize(imm.size));
    [myCell.im setContentMode:UIViewContentModeScaleAspectFill];
    myCell.name.text=[[appDelegate.bffs objectAtIndex:indexPath.row] valueForKey:@"bffName"];
    NSInteger randomNumber = arc4random() % (appDelegate.appColors.count -1);
    myCell.tag=indexPath.row;// using it?
    UITapGestureRecognizer *dobleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(oneTap:)];//for chosing image
  //  UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(oneTap:)];//for chosing image
    dobleTap.numberOfTapsRequired = 2;
    [myCell addGestureRecognizer:dobleTap];
 //   [myCell addGestureRecognizer:singleTap];
   // [singleTap requireGestureRecognizerToFail:dobleTap];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressTap:)];
    [myCell addGestureRecognizer:longPress];
    
    UIView* esta=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100,100)];
    
    UIBezierPath *overlayPath = [UIBezierPath bezierPathWithRect:self.view.bounds];
    CAShapeLayer *fillLayer = [CAShapeLayer layer];
    fillLayer.path = overlayPath.CGPath;
    fillLayer.fillRule = kCAFillRuleEvenOdd;
   // UIColor *este=[appDelegate.appColors objectAtIndex:randomNumber];
  //  NSInteger randomNumber2 = arc4random() % (imgColors.count-1);
    UIColor *este=imgColors[(imgColors.count-1)/2];
    myCell.name.textColor=[appDelegate.appColors objectAtIndex:randomNumber];
 //   myCell.name.textColor=[appDelegate.appColors objectAtIndex:indexPath.row];

   //  myCell.name.textColor=imgColors[(imgColors.count-1)/3];
  //  UIColor *otro=[este colorWithAlphaComponent:0.40];
  //  fillLayer.fillColor = otro.CGColor;
    fillLayer.fillColor = este.CGColor;
    [esta.layer addSublayer:fillLayer];
    myCell.selectedBackgroundView=esta;
  /*
    if([self findPartialKey:[[[appDelegate.bffs objectAtIndex:indexPath.row] valueForKey:@"bffName"] uppercaseString]]) //anything greater 0
        myCell.wifi.image = [UIImage imageNamed:@"rssblue.png"];
    else
        myCell.wifi.image = [UIImage imageNamed:@"rss.png"];
*/
    return myCell;
}


#pragma mark <UICollectionViewDelegate>

/*
 // Uncomment this method to specify if the specified item should be highlighted during tracking
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
 }
 */

/*
 // Uncomment this method to specify if the specified item should be selected
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
 return YES;
 }
 */

-(void)OnOffState:(int)como
{
    if (oldcomo==como) return;
    oldcomo=como;
    onOff.tag=como;
    [appDelegate.workingBFF setValue:[NSNumber numberWithInteger:como] forKey:@"bffOnOff"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [UIView animateWithDuration:0.5 animations:^{
        onOff.alpha = 0.0f;
    } completion:^(BOOL finished) {
        onOff.imageView.animationImages = [NSArray arrayWithObjects:como?heaterOn:heaterOff,nil];
        [onOff.imageView startAnimating];
        [UIView animateWithDuration:0.5 animations:^{
            onOff.alpha = 1.0f;
        }];
    }];

}

-(void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

//    [appDelegate unsubscribeMQTT:[NSString stringWithFormat:@"HeatIoT/%@/%@/%@/MSG",[appDelegate.workingBFF valueForKey:@"bffGroup"],[appDelegate.workingBFF valueForKey:@"bffName"], [[NSUserDefaults standardUserDefaults]objectForKey:@"bffUID"]]];
    indexOfPage=(int)indexPath.row;
    appDelegate.lastpos=indexOfPage;
    appDelegate.workingBFF=appDelegate.bffs[indexOfPage];
//    [appDelegate subscribeMQTT:[NSString stringWithFormat:@"HeatIoT/%@/%@/%@/MSG",[appDelegate.workingBFF valueForKey:@"bffGroup"],[appDelegate.workingBFF valueForKey:@"bffName"], [[NSUserDefaults standardUserDefaults]objectForKey:@"bffUID"]]];
  
    //only subscribe unsubscribe
//    [appDelegate startTelegramService:[appDelegate.workingBFF valueForKey:@"bffMQTT"] withPort:@"1883"]; //connect to MQTT server

    [self getArrays];

  /*  //Draw Online/Offline Icon
    [UIView transitionWithView:connected
                      duration:0.4
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:NULL
                    completion:NULL];
   */
}

-(void)collectionView:(UICollectionView *)collectionView
didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    
 //   miColl* datasetCell =(miColl*)[collectionView cellForItemAtIndexPath:indexPath];
    
    //  [datasetCell replaceHeaderGradientWith:[UIColor redColor]];
   // datasetCell.backgroundColor = [UIColor grayColor];
}

#pragma mark -
#pragma mark UICollectionViewFlowLayoutDelegate

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
   //   UIImage *imm=[appDelegate.imageArray objectAtIndex:indexPath.row];
    //  LogDebug(@"size %@",NSStringFromCGSize(imm.size));
        
     //   return imm.size;
        return CGSizeMake(fotoHV, fotoHV);
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 2.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 2.0;
}

@end
