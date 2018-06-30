//
//  servingCell.h
//  FeedIoT
//

#import <UIKit/UIKit.h>

@interface servingCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *nameLabel,*dayLabel,*timeLabel,*hastaLabel,*durationLabel,*costLabel,*monthLabel;
@property (nonatomic, weak) IBOutlet UIImageView *servingView,*synced;

@end
