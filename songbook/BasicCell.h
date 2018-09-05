//
//  BasicCell.h
//  songbook
//
//  Created by Paul Himes on 2/9/14.
//

#import <UIKit/UIKit.h>

@interface BasicCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *hiddenSpacerLabel;

@end
