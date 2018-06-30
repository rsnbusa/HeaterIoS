//
//  emailCellTableViewCell.h
//  FeedIoT
//
//  Created by Robert on 4/28/16.
//  Copyright © 2016 Colin Eberhardt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface emailCellTableViewCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UISwitch *rule;
@property (nonatomic, weak) IBOutlet UITextField *emailAddress,*emailName;
@end
