//
//  SPPickerView.h
//  SPPickerView
//
//  Created by 乐升平 on 2018/8/24.
//  Copyright © 2018年 iDress. All rights reserved.
//

#import <UIKit/UIKit.h>

// 每一列中的行滚动位置，分上、中、下
typedef NS_ENUM(NSInteger, SPPickerViewRowScrollPosition) {
    SPPickerViewRowScrollPositionTop,    // 行滚动结束后，会定位到tableView的顶部
    SPPickerViewRowScrollPositionMiddle, // 行滚动结束后，会定位到tableView的中间
    SPPickerViewRowScrollPositionBottom, // 行滚动结束后，会定位到tableView的底部
    SPPickerViewRowScrollPositionDefault // 同SPPickerViewRowScrollPositionTop
};

// 列滚动位置，分左、中、右
typedef NS_ENUM(NSInteger, SPPickerViewComponentScrollPosition) {
    SPPickerViewComponentScrollPositionRight,  // 列滚动结束后，会定位到scrollView的右边
    SPPickerViewComponentScrollPositionLeft,   // 列滚动结束后，会定位到tableView的左边
    SPPickerViewComponentScrollPositionMiddle, // 列滚动结束后，会定位到tableView的中间
    SPPickerViewComponentScrollPositionDefault // 同SPPickerViewComponentScrollPositionRight
};



@class SPPickerView;
@protocol SPPickerViewDatasource<NSObject>
@required;
- (NSInteger)sp_numberOfComponentsInPickerView:(SPPickerView *)pickerView; // 返回多少列
- (NSInteger)sp_pickerView:(SPPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component; // 每一列返回多少行
@end


@protocol SPPickerViewDelegate<NSObject>
@optional;

- (CGFloat)sp_pickerView:(SPPickerView *)pickerView rowHeightForComponent:(NSInteger)component; // 返回每一列每一行的行高
- (CGFloat)sp_pickerView:(SPPickerView *)pickerView rowWidthForComponent:(NSInteger)component; // 返回每一列每一行的行宽

// 下面这3个代理方法，优先级逐次提高，即：如若以下3个代理方法同时实现，则会按照优先级较高的显示
- (nullable NSString *)sp_pickerView:(SPPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component; // 返回每一列每一行的普通文本
- (nullable NSAttributedString *)sp_pickerView:(SPPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component;  // 返回每一列每一行的富文本
- (UITableViewCell *)sp_pickerView:(SPPickerView *)pickerView cellForRow:(NSInteger)row forComponent:(NSInteger)component systemCell:(UITableViewCell *)systemCell; // 自定义某一列中的cell，如果不想自定义，可直接使用systemCell，对systemCell上的textLabel等控件设置内容

- (void)sp_pickerView:(SPPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component; // 选中了哪一列哪一行
@end


@interface SPPickerView : UIView
@property (nonatomic, weak) id <SPPickerViewDatasource> dataSource;
@property (nonatomic, weak) id <SPPickerViewDelegate> delegate;
@property (nonatomic, strong, readonly) UIScrollView *scrollView;
@property (nonatomic, assign, readonly) NSInteger numberOfComponents; // 总列数
@property (nonatomic, assign) BOOL pagingEnabledHorizontally; // 水平方向上是否分页，默认为YES

- (NSInteger)sp_numberOfRowsInComponent:(NSInteger)component; // 获取某一列的总行数
- (CGSize)sp_rowSizeForComponent:(NSInteger)component; // 获取某一列的行的大小

- (nullable UITableViewCell *)sp_cellForRow:(NSInteger)row forComponent:(NSInteger)component; // 获取某一列某一行的cell
- (nullable UITableView *)sp_tableViewForComponent:(NSInteger)component; // 获取某一列的tableView

- (void)sp_reloadAllComponents; // 刷新所有列
- (void)sp_reloadComponent:(NSInteger)component; // 刷新单列

/**
 滚动到第几列的第几行

 @param row 第几行
 @param component 第几列
 @param rowScrollPosition 行的位置，上、中、下
 @param componentScrollPosition 列的位置，左、中、右
 @param rowAnimated 行滚动动画,默认YES
 @param componentAnimated 列滚动动画,默认YES
 */
- (void)sp_scrollToRow:(NSInteger)row inComponent:(NSInteger)component atRowScrollPosition:(SPPickerViewRowScrollPosition)rowScrollPosition atComponentScrollPosition:(SPPickerViewComponentScrollPosition)componentScrollPosition rowAnimated:(BOOL)rowAnimated componentAnimated:(BOOL)componentAnimated;

/**
 滚动到第几列

 @param component 第几列
 @param componentScrollPosition 列的位置，左、中、右
 @param animated 滚动动画,默认YES
 */
- (void)sp_scrollToComponent:(NSInteger)component atComponentScrollPosition:(SPPickerViewComponentScrollPosition)componentScrollPosition animated:(BOOL)animated;

/**
 选中第几列的第几行

 @param row 第几行
 @param component 第几列
 @param rowScrollPosition 行的位置，上、中、下
 @param componentScrollPosition 列的位置，左、中、右
 @param rowAnimated 行滚动动画,默认YES
 @param componentAnimated 列滚动动画,默认YES
 */
- (void)sp_selectRow:(NSInteger)row inComponent:(NSInteger)component atRowScrollPosition:(SPPickerViewRowScrollPosition)rowScrollPosition atComponentScrollPosition:(SPPickerViewComponentScrollPosition)componentScrollPosition rowAnimated:(BOOL)rowAnimated componentAnimated:(BOOL)componentAnimated;

- (NSInteger)sp_selectedRowInComponent:(NSInteger)component; // 某一列选中行的行号

- (void)sp_hideSeparatorLineForAllComponentls; // 隐藏所有tableView的分割线
- (void)sp_hideSeparatorLineForComponent:(NSInteger)component; // 隐藏某一列tableView的分割线
- (void)sp_showsVerticalScrollIndicatorForAllComponentls; // 显示所有tableView的滚动条
- (void)sp_showsVerticalScrollIndicatorForComponent:(NSInteger)component;// 显示某一列的tableView的滚动条

// 下面3个方法用于自定义每一列tableView的cell
- (void)sp_registerClass:(nullable Class)cellClass forComponent:(NSInteger)component; // 向指定列注册某种类型的cell,不需要标识，内部会设置好标识
- (void)sp_registerNib:(nullable UINib *)nib forComponent:(NSInteger)component; // 向指定列注册某种类型的cell,不需要标识，内部会设置好标识（xib）
- (nullable __kindof UITableViewCell *)sp_dequeueReusableCellAtRow:(NSInteger)row atComponent:(NSInteger)component; // 创建cell，如果有可复用的cell，不会创建新的，会重用

// 用一个tableView代替component列对应的tableView
- (void)sp_replaceTableViewAtComponent:(NSInteger)component withTableView:(UITableView *)tableView;
@end


