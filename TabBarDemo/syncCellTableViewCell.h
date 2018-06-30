//
//  syncCellTableViewCell.h
//  FeedIoT
//

#import <UIKit/UIKit.h>

@interface syncCellTableViewCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *nameLabel,*dayLabel,*timeLabel;
@property (nonatomic, weak) IBOutlet UIImageView *servingView,*doneSync;
@end
