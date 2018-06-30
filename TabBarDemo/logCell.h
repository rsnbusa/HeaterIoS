//
//  logCell.h
//  FeedIoT
//
//  Created by Robert on 5/6/16.
//  Copyright © 2016 Colin Eberhardt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface logCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *bffname,*fecha;
@property (nonatomic, weak) IBOutlet UIImageView *bffImage;

@end
