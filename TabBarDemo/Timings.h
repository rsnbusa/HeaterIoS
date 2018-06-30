//
//  Timings.h
//  FeedIoT
//
//

#import <UIKit/UIKit.h>
#import "FirstViewController.h"
#import "AppDelegate.h"
#import "httpVc.h"
#import "DoughnutChartContainerView.h"
#import "blurLabel.h"
#import "btSimplePopUp.h"

@interface Timings : UIViewController <btSimplePopUpDelegate>
{
    FirstViewController *fc;
    BOOL changef,keyboardIsShown ;
    CGFloat animatedDistance;
    bool editf;
    NSManagedObjectContext *context;
    UIColor *redC,*greenC,*blueC,*settingC,*orangeC,*yellowC;
    NSIndexPath  *destIndexPath ,*originPath;
    AppDelegate *appDelegate;
    NSString *mis,*wtemp;
    NSMutableString *answer;
    httpVC *comm;
    float costoTm,costoTd;
    NSMutableArray *slices,*sliceNames;
    NSMutableArray *sliceColors;
    int globalSlice,cualcerca;
    UIView *markerView,*tempFaucet,*heater;
    blurLabel *copyTime;
    BOOL firstMakeHour,runningf;
    UIView *backGroundBlurr;
    NSTimer *theStatusTimer,*theFirstTimer;
    CAGradientLayer *gradient;
    int stateMachine;
    UIColor *colorActive,*normalColor,*cercaColor,*offColor,*onColor,*notTodayColor;
    UIImage *redHeat,*blueHeat,*statusOn,*statusOff;
    bool statusSend;
    MQTTMessageHandler viejo;
}
-(IBAction)editar:(UIBarButtonItem *)sender ;

//@property (strong) IBOutlet UITableView *table;
@property (nonatomic, retain) IBOutlet UIVisualEffectView *capa;
@property (strong) IBOutlet UIBarButtonItem *editab;
@property (strong) IBOutlet UIImageView *bffIcon,*marker,*dumb;
@property (strong) IBOutlet UIView *mainView;
@property (weak) IBOutlet DoughnutChartContainerView *chartContainer;
@property (weak) IBOutlet XYDoughnutChart *xyview;
@property (strong) IBOutlet UILabel *time,*mtitle,*costoDia,*costoMes,*kwhDia,*kwhMes,*totValor, *totKwh,*amps,*ampslabel,*tempHum,*dayName;
@property (strong) IBOutlet UILabel *l24,*l6,*l12,*l18;
@property (strong) IBOutlet UIButton *sunmoon,*starter,*statusb;
@property(nonatomic, retain) btSimplePopUP *popUp;
@property (strong) UIImage *mini,*textimage,*fauceti,*finalImage;
@property (strong) UILabel *fromLabel;

@end
