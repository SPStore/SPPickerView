//
//  MyCell.m
//  SPPickerView
//
//  Created by develop1 on 2018/8/28.
//  Copyright © 2018年 Cookie. All rights reserved.
//

#import "MyCell.h"

@interface MyCell()
@property (nonatomic, strong) UILabel *detailLabel;
@end

@implementation MyCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.detailLabel];
    }
    return self;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:14];
    }
    return  _titleLabel;
}

- (UILabel *)detailLabel {
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.font = [UIFont systemFontOfSize:11];
        _detailLabel.text = @"我是纯代码创建的自定义cell";
        _detailLabel.textColor = [UIColor lightGrayColor];
        _detailLabel.textAlignment = NSTextAlignmentRight;
    }
    return  _detailLabel;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.titleLabel.frame = CGRectMake(15, 0, self.bounds.size.width/2.0, self.bounds.size.height);

    self.detailLabel.frame = CGRectMake(self.bounds.size.width-self.bounds.size.width/2.0-10, (self.bounds.size.height-30)/2, self.bounds.size.width/2.0, 30);
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
