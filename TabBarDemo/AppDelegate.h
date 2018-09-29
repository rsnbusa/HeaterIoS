//
//  AppDelegate.h
//  FoodAuto
//
//  Created by Robert on 3/2/16.
//  Copyright © 2016 Robert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "HeatIoTIoS-Swift.h"
//

@interface AppDelegate : UIResponder <UIApplicationDelegate>


@property (strong, nonatomic) MQTTSwift *chan;
@property (strong, nonatomic) UIViewController *firstViewController,*secondViewController;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;
@property (strong, nonatomic) NSMutableArray *servingsArray,*bffs,*emailsArray,*appColors,*imageArray;
@property (strong, nonatomic) NSMutableDictionary *feed_addr,*queues;
@property int lastbutton;
@property (strong, nonatomic) NSManagedObject *workingBFF,*oldbff;
@property (strong, nonatomic) NSMutableArray* feeders, *logText;
@property (strong, nonatomic) NSMutableString *direccion,*deviceMqtt;
//@property (strong, nonatomic) NSArray *mqservers;

@property BOOL addf,passwordf,clonef,rxIn;
@property int lastpos,messageType;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (copy, nonatomic) NSNumber *cualMeter;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
-(void)startTelegramService:(NSString*)whichServer withPort:(NSString*)thisPort respuesta:(NSString*) response app:(NSString *)appID abrev:(NSString*)pref;
@end

