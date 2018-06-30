//
//  webBrowserViewController.h
//  HeatIoT
//
//  Created by Robert on 9/6/16.
//  Copyright © 2016 Colin Eberhardt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "httpVC.h"

@interface webBrowserViewController : UIViewController<UIWebViewDelegate>
{
    httpVC *comm;
    NSString *filePath;
}
@property (strong) IBOutlet UIWebView *browser;
@end
