//
//  webBrowserViewController.m
//  HeatIoT
//
//  Created by Robert on 9/6/16.
//  Copyright © 2016 Colin Eberhardt. All rights reserved.
//

#import "webBrowserViewController.h"
#import "httpVC.h"

@interface webBrowserViewController ()

@end

@implementation webBrowserViewController
@synthesize browser;

-(IBAction)reload:(id)sender
{
    [self loadPage];
}

-(void)loadPage
{
    NSString *answer=[NSString string];
    NSString *mis=@"HttpStatus?password=ziposimpson";
    int reply=[comm lsender:mis andAnswer:&answer andTimeOut:[[[NSUserDefaults standardUserDefaults]objectForKey:@"txTimeOut"] intValue] vcController:self];
    if (!reply)
    {
        // [self showErrorMessage];
    //    NSLog(@"No reply Web view");
        return;
    }
    [browser loadHTMLString:answer baseURL:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    comm=[httpVC new];
    browser.scalesPageToFit = YES;
    browser.contentMode = UIViewContentModeScaleAspectFit;
    browser.delegate=self;
   }

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self loadPage];

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

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    if(self.navigationController.navigationBar.translucent == YES)
    {
        
        webView.scrollView.contentOffset = CGPointMake(webView.frame.origin.x, webView.frame.origin.y - 54);
        
    }
}

@end
