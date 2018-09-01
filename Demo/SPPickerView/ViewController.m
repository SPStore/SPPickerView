//
//  ViewController.m
//  SPPickerView
//
//  Created by develop1 on 2018/8/24.
//  Copyright © 2018年 Cookie. All rights reserved.
//

#import "ViewController.h"
#import "AddressView.h"
#import "SPModalView.h"

@interface ViewController () 

@property (nonatomic, strong) UITextField *textField; // 显示选择后的省市区地址
@property (nonatomic, strong) UIButton *choiceAddressButton; // 点击该按钮弹出地址view

// 地址view，这个view上添加了本人封装的2大控件，一个是SPPageMenu，分页菜单;  另一个是本demo的主角:SPPickerView
@property (nonatomic, strong) AddressView *addressView;

// 这个view添加了addressView，采用动画的形式从下往上弹出
@property (nonatomic, strong) SPModalView *modalView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];

    [self.view addSubview:self.choiceAddressButton];
    [self.view addSubview:self.textField];
    
    // SPModalView是一个弹出视图
    self.modalView = [[SPModalView alloc] initWithView:self.addressView inBaseViewController:self];
    
    // 相当于网络请求
    [self configureData];
    
}

- (void)configureData {
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"pcd.plist" ofType:nil];
    NSArray *dictArray = [NSArray arrayWithContentsOfFile:path];
    
    // 给addressView传数据
    self.addressView.datas = dictArray;
}

- (void)choiceAddressButtonAction:(UIButton *)sender {
    [self.modalView show];
}

- (UIButton *)choiceAddressButton {
    
    if (!_choiceAddressButton) {
        _choiceAddressButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _choiceAddressButton.frame = CGRectMake((kScreenWidth-70)*0.5, 80, 70, 30);
        _choiceAddressButton.backgroundColor = [UIColor blueColor];
        [_choiceAddressButton setTitle:@"选择地址" forState:UIControlStateNormal];
        [_choiceAddressButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _choiceAddressButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _choiceAddressButton.layer.cornerRadius = 5;
        [_choiceAddressButton addTarget:self action:@selector(choiceAddressButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _choiceAddressButton;
}


- (UITextField *)textField {
    
    if (!_textField) {
        _textField = [[UITextField alloc] init];
        _textField.frame = CGRectMake((kScreenWidth-250)*0.5, CGRectGetMaxY(self.choiceAddressButton.frame)+15, 250, 30);
        _textField.borderStyle = UITextBorderStyleRoundedRect;
        _textField.textAlignment = NSTextAlignmentCenter;
        _textField.font = [UIFont systemFontOfSize:15];
    }
    return _textField;
}


- (AddressView *)addressView {
    
    if (!_addressView) {
        _addressView = [[AddressView alloc] init];
        _addressView.frame = CGRectMake(0, 0, kScreenWidth, 400);
        __weak __typeof(self) weakSelf = self;
        // 最后一列的行被点击的回调
        _addressView.lastComponentClickedBlock = ^(SPProvince *selectedProvince, SPCity *selectedCity, SPDistrict *selectedDistrict) {
            
            [weakSelf.modalView hide];
            
            weakSelf.textField.text = [NSString stringWithFormat:@"%@%@%@",selectedProvince.fullname,selectedCity.fullname,selectedDistrict.fullname];
        };
    }
    return _addressView;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.textField resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end






