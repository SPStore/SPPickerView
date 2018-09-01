//
//  AddressView.m
//  SPPickerView
//
//  Created by Libo on 2018/8/31.
//  Copyright © 2018年 Cookie. All rights reserved.
//

#import "AddressView.h"
#import "SPPickerView.h"
#import "SPPageMenu.h"

#import "MyCell.h"
#import "MyXibCell.h"

@interface AddressView() <SPPickerViewDatasource,SPPickerViewDelegate, SPPageMenuDelegate>
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UILabel *topLabel;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) SPPageMenu *pageMenu;

@property (nonatomic, strong) NSMutableArray *provinces;
@property (nonatomic, strong) SPProvince *selectedProvince;
@property (nonatomic, strong) SPCity *selectedCity;
@property (nonatomic, strong) SPDistrict *selectedDistrict;

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) SPPickerView *pickerView;

@property (nonatomic, assign) NSInteger numerOfComponents;

@end

@implementation AddressView 

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.containerView];
    
        [self.containerView addSubview:self.topView];
        [self.topView addSubview:self.topLabel];
        [self.topView addSubview:self.pageMenu];
        [self.topView addSubview:self.closeButton];
        [self.containerView addSubview:self.pickerView];
        
        // 默认1列
        self.numerOfComponents = 1;
        
    }
    return self;
}

- (void)setDatas:(NSArray *)datas {
    _datas = datas;
    self.provinces = [NSMutableArray array];
    for (NSDictionary *dict in datas) {
        SPProvince *province = [[SPProvince alloc] init];
        [province setValuesForKeysWithDictionary:dict];
        [self.provinces addObject:province];
    }
    self.selectedProvince = self.provinces.firstObject;
    self.selectedCity = self.selectedProvince.children.firstObject;
    
    [self.pickerView sp_reloadAllComponents];
}

#pragma mark - SPPageMenuDelegate

- (void)pageMenu:(SPPageMenu *)pageMenu itemSelectedAtIndex:(NSInteger)index {
    [self.pickerView sp_scrollToComponent:index atComponentScrollPosition:SPPickerViewComponentScrollPositionDefault animated:YES];
}

#pragma mark - SPPickerViewDatasource,SPPickerViewDelegate
// 返回多少列
- (NSInteger)sp_numberOfComponentsInPickerView:(SPPickerView *)pickerView {
    return self.numerOfComponents;
}

// 每一列返回多少行
- (NSInteger)sp_pickerView:(SPPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return self.provinces.count;
    } else if (component == 1) {
        return self.selectedProvince.children.count;
    } else {
        return self.selectedCity.children.count;
    }
}

// ------------------------------  下面3个代理方法，优先级逐次提高，当同时实现时按照优先级较高的显示 --------------------------

// 每一列每一行的普通文本
- (nullable NSString *)sp_pickerView:(SPPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (component == 0) {
        SPProvince *province = self.provinces[row];
        if ([self isEspecialCity:province]) {
            return province.name;
        } else {
            return province.fullname;
        }
    } else if (component == 1) {
        SPCity *city = self.selectedProvince.children[row];
        return city.fullname;
    } else {
        SPDistrict *district = self.selectedCity.children[row];
        return district.fullname;
    }
}

// 每一列每一行的富文本
- (nullable NSAttributedString *)sp_pickerView:(SPPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *comString = @"";
    if (component == 0) {
        SPProvince *province = self.provinces[row];
        // 直辖市用简称，非直辖市用全称
        if ([self isEspecialCity:province]) {
            comString = province.name;
        } else {
            comString = province.fullname;
        }
    } else if (component == 1) {
        SPCity *city = self.selectedProvince.children[row];
        comString = city.fullname;
    } else {
        SPDistrict *district = self.selectedCity.children[row];
        comString = district.fullname;
    }
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:comString];
    NSRange range = NSMakeRange(0, comString.length);
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range];
    
    return attributedString;
}

// 每一列每一行的cell，参数systemCell是系统自带的cell，如果想自定义cell，需要先调用- sp_registerClass: forComponent:方法进行注册
- (UITableViewCell *)sp_pickerView:(SPPickerView *)pickerView cellForRow:(NSInteger)row forComponent:(NSInteger)component systemCell:(UITableViewCell *)systemCell {
    if (component == 0) { // 第1列的cell自定义，纯代码创建的cell
        // 从缓存池里取出cell，如果取不到会创建新的
        MyCell *cell = [pickerView sp_dequeueReusableCellAtRow:row atComponent:component];
        SPProvince *province = self.provinces[row];
        // 四个直辖市的省名用简写
        if ([self isEspecialCity:province]) {
            cell.titleLabel.text = province.name;
        } else {
            cell.titleLabel.text = province.fullname;
        }
        return cell;
    } else if (component == 1) { // 第2列直接使用系统的cell
        SPCity *city = self.selectedProvince.children[row];
        systemCell.textLabel.text = city.fullname;
        systemCell.textLabel.font = [UIFont systemFontOfSize:14];
        systemCell.detailTextLabel.text = @"我是系统自带的cell";
        systemCell.detailTextLabel.font = [UIFont systemFontOfSize:11];
        return systemCell;
    } else { // 第3列的cell自定义，xib创建的cell
        MyXibCell *cell = [pickerView sp_dequeueReusableCellAtRow:row atComponent:component];
        SPDistrict *district = self.selectedCity.children[row];
        cell.titleLabel.text = district.fullname;
        return cell;
    }
}

// 行高
- (CGFloat)sp_pickerView:(SPPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 44;
}

// 行宽
- (CGFloat)sp_pickerView:(SPPickerView *)pickerView rowWidthForComponent:(NSInteger)component {
    return kScreenWidth;
}

// 点击了哪一列的哪一行
- (void)sp_pickerView:(SPPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    if (component == 0) {
        
        self.selectedProvince = self.provinces[row];
        self.selectedCity = [self.selectedProvince.children firstObject];
        self.selectedDistrict = [self.selectedCity.children firstObject];
        //[self.pickerView sp_reloadComponent:1];
        //[self.pickerView sp_reloadComponent:2];
        
        self.numerOfComponents = 2;
        [pickerView sp_reloadAllComponents]; // 列数改变一定要刷新所有列才生效
        if ([self isEspecialCity:self.selectedProvince]) {
            [self setupPageMenuWithName:self.selectedProvince.name atComponent:component];
        } else {
            [self setupPageMenuWithName:self.selectedProvince.fullname atComponent:component];
        }
        
    } else if (component == 1) {
        
        self.selectedCity = self.selectedProvince.children[row];
        self.selectedDistrict = [self.selectedCity.children firstObject];
        //[self.pickerView sp_reloadComponent:2];
        
        self.numerOfComponents = 3;
        [pickerView sp_reloadAllComponents]; // 列数改变一定要刷新所有列才生效
        [self setupPageMenuWithName:self.selectedCity.fullname atComponent:component];
        
    } else {
        self.selectedDistrict = self.selectedCity.children[row];
        [self.pageMenu setTitle:self.selectedDistrict.fullname forItemAtIndex:component];
        self.pageMenu.selectedItemIndex = component;
        
        if (self.lastComponentClickedBlock) {
            self.lastComponentClickedBlock(self.selectedProvince, self.selectedCity, self.selectedDistrict);
        }
    }
}

- (void)setupPageMenuWithName:(NSString *)name atComponent:(NSInteger)component {
    NSString *title = [self.pageMenu titleForItemAtIndex:component];
    if ([title isEqualToString:@"请选择"]) {
        [self.pageMenu insertItemWithTitle:name atIndex:component animated:YES];
    } else {
        // 改变当前item的标题
        [self.pageMenu setTitle:name forItemAtIndex:component];
        // 将下一个置为“请选择”
        [self.pageMenu setTitle:@"请选择" forItemAtIndex:component+1];
        NSInteger itemCount = (self.pageMenu.numberOfItems-1);
        // 保留2个item，2个之后的全部删除
        for (int i = 0; i < itemCount-(component+1); i++) {
            [self.pageMenu removeItemAtIndex:self.pageMenu.numberOfItems-1 animated:YES];
        }
    }
    // 切换选中的item，会执行pageMenu的代理方法，
    self.pageMenu.selectedItemIndex = component+1;
}

// 是否为直辖市
- (BOOL)isEspecialCity:(SPProvince *)province {
    if ([province.name isEqualToString:@"北京"] ||
        [province.name isEqualToString:@"天津"] ||
        [province.name isEqualToString:@"上海"] ||
        [province.name isEqualToString:@"重庆"])
    {
        return YES;
    }
    return NO;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.containerView.frame = self.bounds;
    
    CGFloat topViewX = 0;
    CGFloat topViewY = 0;
    CGFloat topViewH = 65;
    CGFloat topViewW = kScreenWidth;
    self.topView.frame = CGRectMake(topViewX, topViewY, topViewW, topViewH);
    
    CGFloat topLabelW = 120;
    CGFloat topLabelH = 30;
    CGFloat topLabelX = (topViewW-topLabelW)/2;
    CGFloat topLabelY = 5;
    self.topLabel.frame = CGRectMake(topLabelX, topLabelY, topLabelW, topLabelH);
    
    CGFloat closeButtonW = 30;
    CGFloat closeButtonH = closeButtonW;
    CGFloat closeButtonX = topViewW-closeButtonW-10;
    CGFloat closeButtonY = topLabelY;
    self.closeButton.frame = CGRectMake(closeButtonX, closeButtonY, closeButtonW, closeButtonH);
    
    CGFloat pageMenuX = 0;
    CGFloat pageMenuY = 35;
    CGFloat pageMenuW = topViewW;
    CGFloat pageMenuH = 30;
    self.pageMenu.frame = CGRectMake(pageMenuX, pageMenuY, pageMenuW, pageMenuH);
    
    CGFloat pickerViewX = 0;
    CGFloat pickerViewY = topViewH;
    CGFloat pickerViewW = topViewW;
    CGFloat pickerViewH = self.containerView.bounds.size.height-topViewH;
    self.pickerView.frame = CGRectMake(pickerViewX, pickerViewY, pickerViewW, pickerViewH);
}

// 关闭页面
- (void)closeButtonAction {
    
}

- (UIView *)topView {
    if (!_topView) {
        _topView = [[UIView alloc] init];
    }
    return  _topView;
}

- (UILabel *)topLabel {
    if (!_topLabel) {
        _topLabel = [[UILabel alloc] init];
        _topLabel.text = @"请选择收货地址";
        _topLabel.textAlignment = NSTextAlignmentCenter;
        _topLabel.font = [UIFont boldSystemFontOfSize:15];
    }
    return  _topLabel;
}

- (SPPageMenu *)pageMenu {
    if (!_pageMenu) {
        _pageMenu = [SPPageMenu pageMenuWithFrame:CGRectZero trackerStyle:SPPageMenuTrackerStyleLine];
        _pageMenu.delegate = self;
        [_pageMenu setItems:@[@"请选择"] selectedItemIndex:0];
        _pageMenu.itemTitleFont = [UIFont systemFontOfSize:14];
        _pageMenu.selectedItemTitleColor = [UIColor redColor];
        _pageMenu.unSelectedItemTitleColor = [UIColor grayColor];
        [_pageMenu setTrackerHeight:1 cornerRadius:0];
        _pageMenu.itemPadding = 50;
        _pageMenu.bridgeScrollView = self.pickerView.scrollView;
    }
    return  _pageMenu;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton addTarget:self action:@selector(closeButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return  _closeButton;
}

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
    }
    return  _containerView;
}

- (SPPickerView *)pickerView {
    if (!_pickerView) {
        _pickerView = [[SPPickerView alloc] init];
        _pickerView.dataSource = self;
        _pickerView.delegate = self;
        
        // 以下代码都可以放在设置代理之前
        [_pickerView sp_registerClass:[MyCell class] forComponent:0]; // 注册第1列cell
        [_pickerView sp_registerNib:[UINib nibWithNibName:NSStringFromClass([MyXibCell class]) bundle:nil] forComponent:2]; // 注册第3列cell,xib
        
//        [_pickerView sp_hideSeparatorLineForAllComponentls];
//        [_pickerView sp_hideSeparatorLineForComponent:1];
//        [_pickerView sp_showsVerticalScrollIndicatorForAllComponentls];
//        [_pickerView sp_showsVerticalScrollIndicatorForComponent:2];
    }
    return  _pickerView;
}

@end
