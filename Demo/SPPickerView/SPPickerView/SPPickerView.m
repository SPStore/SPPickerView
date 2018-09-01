//
//  SPPickerView.m
//  SPPickerView
//
//  Created by 乐升平 on 2018/8/24.
//  Copyright © 2018年 iDress. All rights reserved.
//

#import "SPPickerView.h"

#define sp_customCell(n) [NSString stringWithFormat:@"sp_customCell%ld",n]
#define sp_hideSeparatorLineForAllComponentlsKey @"hideSeparatorLineForAllComponentls"
#define sp_showsVerticalScrollIndicatorsKey @"showsVerticalScrollIndicators"

@interface SPPickerView () <UITableViewDelegate,UITableViewDataSource> {
    UIScrollView *_scrollView;
}

@property (nonatomic, strong) NSMutableDictionary *cellClasses; // 保存某一列所注册的cell类型
@property (nonatomic, strong) NSMutableDictionary *cellNibs; // 保存某一列所注册的cell类型(xib)
@property (nonatomic, strong) NSMutableDictionary *hideSeparatorLines; // 保存某一列是否隐藏cell分割线的bool值
@property (nonatomic, strong) NSMutableDictionary *showsVerticalScrollIndicators; // 保存显示某一列talbeView的垂直滚动条的bool值
@property (nonatomic, strong) NSMutableDictionary *rowWidths;
@property (nonatomic, assign) CGFloat oldOffsetX;

@end


@implementation SPPickerView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.scrollView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self addSubview:self.scrollView];
    }
    return self;
}

#pragma mark - public

// 获取某一列的总行数
- (NSInteger)sp_numberOfRowsInComponent:(NSInteger)component {
    if ([self.delegate respondsToSelector:@selector(sp_pickerView:numberOfRowsInComponent:)]) {
        return [self.dataSource sp_pickerView:self numberOfRowsInComponent:component];
    }
    return 0;
}

// 获取某一列的行的大小
- (CGSize)sp_rowSizeForComponent:(NSInteger)component {
    CGSize rowSize = CGSizeMake(self.scrollView.bounds.size.width, 44); // 默认大小
    if ([self.delegate respondsToSelector:@selector(sp_pickerView:rowWidthForComponent:)]) {
        rowSize.width = [self.delegate sp_pickerView:self rowWidthForComponent:component];
    }
    if ([self.delegate respondsToSelector:@selector(sp_pickerView:rowHeightForComponent:)]) {
        rowSize.height = [self.delegate sp_pickerView:self rowHeightForComponent:component];
    }
    return rowSize;
}

// 获取某一列某一行的cell
- (nullable UITableViewCell *)sp_cellForRow:(NSInteger)row forComponent:(NSInteger)component {
    UITableView *tableView = [self tableViewAtComponent:component];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
    return cell;
}

// 获取某一列的tableView
- (nullable UITableView *)sp_tableViewForComponent:(NSInteger)component {
    return [self tableViewAtComponent:component];
}

// 刷新所有列
- (void)sp_reloadAllComponents {
    // 重新计算总列数
    self.numberOfComponents = [self.dataSource sp_numberOfComponentsInPickerView:self];
    for (UITableView *tableView in self.scrollView.subviews) {
        [tableView reloadData];
        NSInteger component = [self componentForTableView:tableView];
        [self layoutTableViewWithReloadingTableViewComponent:component];
    }
}

// 刷新单列
- (void)sp_reloadComponent:(NSInteger)component {
    if (component < self.numberOfComponents) {
        UITableView *tableView = [self tableViewAtComponent:component];
        [tableView reloadData];
        [self layoutTableViewWithReloadingTableViewComponent:component];
    }
}

// 选中某一列的某一行
- (void)sp_selectRow:(NSInteger)row inComponent:(NSInteger)component atRowScrollPosition:(SPPickerViewRowScrollPosition)rowScrollPosition atComponentScrollPosition:(SPPickerViewComponentScrollPosition)componentScrollPosition rowAnimated:(BOOL)rowAnimated componentAnimated:(BOOL)componentAnimated {
    if (component < self.numberOfComponents) {
        // 滚动到第几列的方法(代码抽离)
        [self scrollToComponent:component atComponent:componentScrollPosition animated:componentAnimated];

        UITableView *tableView = [self tableViewAtComponent:component];
        UITableViewScrollPosition scrollPosition = UITableViewScrollPositionTop;
        switch (rowScrollPosition) {
            case SPPickerViewRowScrollPositionTop:
            case SPPickerViewRowScrollPositionDefault:
                scrollPosition = UITableViewScrollPositionTop;
                break;
            case SPPickerViewRowScrollPositionMiddle:
                scrollPosition = UITableViewScrollPositionMiddle;
                break;
            case SPPickerViewRowScrollPositionBottom:
                scrollPosition = UITableViewScrollPositionBottom;
                break;
            default:
                break;
        }
        [tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] animated:rowAnimated scrollPosition:scrollPosition];
    } else {
        // 做退出页面的操作
        NSLog(@"没有下一级了");
    }
}

// 获取某一列选中行的行号
- (NSInteger)sp_selectedRowInComponent:(NSInteger)component {
    UITableView *tableView = [self tableViewAtComponent:component];
    NSIndexPath *indexPath = [tableView indexPathForSelectedRow];
    return indexPath.row;
}

// 滚动到某一列的某一行
- (void)sp_scrollToRow:(NSInteger)row inComponent:(NSInteger)component atRowScrollPosition:(SPPickerViewRowScrollPosition)rowScrollPosition atComponentScrollPosition:(SPPickerViewComponentScrollPosition)componentScrollPosition rowAnimated:(BOOL)rowAnimated componentAnimated:(BOOL)componentAnimated {
    if (component < self.numberOfComponents) { // 防止越界

        // 滚动到第几列的方法(代码抽离)
        [self scrollToComponent:component atComponent:componentScrollPosition animated:componentAnimated];

        UITableViewScrollPosition scrollPosition = UITableViewScrollPositionTop;
        switch (rowScrollPosition) {
            case SPPickerViewRowScrollPositionTop:
            case SPPickerViewRowScrollPositionDefault:
                scrollPosition = UITableViewScrollPositionTop;
                break;
            case SPPickerViewRowScrollPositionMiddle:
                scrollPosition = UITableViewScrollPositionMiddle;
                break;
            case SPPickerViewRowScrollPositionBottom:
                scrollPosition = UITableViewScrollPositionBottom;
                break;
            default:
                break;
        }
        // 找出当前列的tableView
        UITableView *tableView = [self tableViewAtComponent:component];
        // 如果传进来的行大于了当前列所有的行数，说明越界了
        NSInteger condition = row < [self.dataSource sp_pickerView:self numberOfRowsInComponent:component];
        NSString *desc = [NSString stringWithFormat:@"%s方法中的参数row大于了component对应的列中所有的行数",__func__];
        NSAssert(condition,desc);
        [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] atScrollPosition:scrollPosition animated:rowAnimated];
    }
}

// 滚动到某一列
- (void)sp_scrollToComponent:(NSInteger)component atComponentScrollPosition:(SPPickerViewComponentScrollPosition)componentScrollPosition animated:(BOOL)animated {
    if (component < self.numberOfComponents) { // 防止越界
        // 滚动到第几列的方法(代码抽离)
        [self scrollToComponent:component atComponent:componentScrollPosition animated:animated];
    }
}

// 注册某一列的cell
- (void)sp_registerClass:(nullable Class)cellClass forComponent:(NSInteger)component {
    // 保存列对应的标识
    [self.cellClasses setObject:cellClass forKey:@(component)];
    // 根据列取出tableView
    UITableView *tableView = [self tableViewAtComponent:component];
    if (tableView) {
        // 注册cell
        [tableView registerClass:cellClass forCellReuseIdentifier:sp_customCell(component)];
    }
}

- (void)sp_registerNib:(UINib *)nib forComponent:(NSInteger)component {
    // 保存列对应的标识
    [self.cellNibs setObject:nib forKey:@(component)];
    // 根据列取出tableView
    UITableView *tableView = [self tableViewAtComponent:component];
    if (tableView) {
        
        // 注册cell
        [tableView registerNib:nib forCellReuseIdentifier:sp_customCell(component)];
    }
}

// 创建cell，可复用
- (nullable __kindof UITableViewCell *)sp_dequeueReusableCellAtRow:(NSInteger)row atComponent:(NSInteger)component {
    UITableView *tableView = [self tableViewAtComponent:component];
    UITableViewCell *cell = nil;
    NSAssert(self.cellClasses.allValues.count > 0 || self.cellNibs.allValues.count > 0, @"请先对您想要自定义cell的列注册cell");

    NSString *error = [NSString stringWithFormat:@"请对第%ld列注册cell",component];
    Class cellClass = [self.cellClasses objectForKey:@(component)];
    UINib *cellNib = [self.cellNibs objectForKey:@(component)];
    NSAssert(cellClass != nil || cellNib != nil, error);

    cell = [tableView dequeueReusableCellWithIdentifier:sp_customCell(component) forIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];

    return cell;
}

- (void)sp_hideSeparatorLineForAllComponentls {
    [self.hideSeparatorLines setObject:@(YES) forKey:sp_hideSeparatorLineForAllComponentlsKey];
    for (UITableView *tableView in self.scrollView.subviews) {
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
}

- (void)sp_hideSeparatorLineForComponent:(NSInteger)component {
    [self.hideSeparatorLines setObject:@(YES) forKey:@(component)];
    UITableView *tableView = [self tableViewAtComponent:component];
    if (tableView) {
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
}

// 显示所有tableView的滚动条
- (void)sp_showsVerticalScrollIndicatorForAllComponentls {
    [self.showsVerticalScrollIndicators setObject:@(YES) forKey:sp_showsVerticalScrollIndicatorsKey];
    for (UITableView *tableView in self.scrollView.subviews) {
        tableView.showsVerticalScrollIndicator = YES;
    }
}

// 显示单列tableView的滚动条
- (void)sp_showsVerticalScrollIndicatorForComponent:(NSInteger)component {
    [self.showsVerticalScrollIndicators setObject:@(YES) forKey:@(component)];
    UITableView *tableView = [self tableViewAtComponent:component];
    tableView.showsVerticalScrollIndicator = YES;
}

// 用一个tableView代替component列对应的tableView
- (void)sp_replaceTableViewAtComponent:(NSInteger)component withTableView:(UITableView *)tableView {

    UITableView *oldTableView = [self tableViewAtComponent:component];
    if (tableView == oldTableView) return;
    // 先删除旧的tableView
    [oldTableView removeFromSuperview];
    oldTableView = nil;
    // 在相同列插入新的tableView
    [self.scrollView insertSubview:tableView atIndex:component];

    [self setNeedsLayout];
    [self layoutIfNeeded];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // 找出该tableView所在的位置
    NSInteger component = [self componentForTableView:tableView];

    // 每一列返回的个数就是tableView中cell的个数
    NSInteger index = [self.dataSource sp_pickerView:self numberOfRowsInComponent:component];
    return index;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 计算tableView的所在列
    NSInteger component = [self componentForTableView:tableView];

    NSString *cellIdentifier = [NSString stringWithFormat:@"sp_systemCell%ld",component];

    UITableViewCell *systemCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (systemCell == nil) {
        systemCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    // 以下if语句决定3个代理方法的优先级
    if ([self.delegate respondsToSelector:@selector(sp_pickerView:cellForRow:forComponent:systemCell:)]) {
        Class cellClass = [self.cellClasses objectForKey:@(component)];
        UINib *cellNib = [self.cellNibs objectForKey:@(component)];
        if (cellClass || cellNib) { // 说明component列，有注册自定义cell
            UITableViewCell *customCell = [self.delegate sp_pickerView:self cellForRow:indexPath.row forComponent:component systemCell:systemCell];
            if (customCell.reuseIdentifier && ![customCell.reuseIdentifier isEqualToString:systemCell.reuseIdentifier] && customCell != nil) { // 说明外界注册了自定义的cell，并且有使用
                systemCell = customCell;
            }
        } else {
            systemCell =  [self.delegate sp_pickerView:self cellForRow:indexPath.row forComponent:component systemCell:systemCell];
        }
    } else if ([self.delegate respondsToSelector:@selector(sp_pickerView:attributedTitleForRow:forComponent:)]) {
        NSAttributedString *title = [self.delegate sp_pickerView:self attributedTitleForRow:indexPath.row forComponent:component];
        systemCell.textLabel.attributedText = title;
    }  else if ([self.delegate respondsToSelector:@selector(sp_pickerView:titleForRow:forComponent:)]) {
        NSString *title = [self.delegate sp_pickerView:self titleForRow:indexPath.row forComponent:component];
        systemCell.textLabel.text = title;
    }
    return systemCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSInteger component = [self componentForTableView:tableView];

    if ([self.delegate respondsToSelector:@selector(sp_pickerView:didSelectRow:inComponent:)]) {
        [self.delegate sp_pickerView:self didSelectRow:indexPath.row inComponent:component];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger component = [self componentForTableView:tableView];
    if ([self.delegate respondsToSelector:@selector(sp_pickerView:rowHeightForComponent:)]) {
        return [self.delegate sp_pickerView:self rowHeightForComponent:component];
    }
    [self layoutTableViewWithReloadingTableViewComponent:component];
    return 44;
}

#pragma mark - Private
// 滑动到第几列
- (void)scrollToComponent:(NSInteger)component atComponent:(SPPickerViewComponentScrollPosition)componentScrollPosition animated:(BOOL)animated {
    // 找出当前列的tableView
    UITableView *tableView = [self tableViewAtComponent:component];
    // 初始化偏移量
    CGFloat offsetX = 0;
    // 最小偏移量
    CGFloat minOffsetX = 0;
    // 最大偏移量
    CGFloat maxOffsetX = self.scrollView.contentSize.width-self.scrollView.bounds.size.width;
    switch (componentScrollPosition) {
        case SPPickerViewComponentScrollPositionRight:
        case SPPickerViewComponentScrollPositionDefault:
        {
            // 偏移量的计算根据行宽计算不太理想，因为每一列的行宽可能会不一致
            offsetX =  CGRectGetMaxX(tableView.frame)-self.bounds.size.width;
            // 如果小于了最小偏移量，会导致第一个tableView偏离scrollView左边界
            if (offsetX < minOffsetX) {
                offsetX = minOffsetX;
            }
        }
            break;
        case SPPickerViewComponentScrollPositionLeft:
        {
            // 偏移量的计算根据行宽计算不太理想，因为每一列的行宽可能会不一致
            offsetX = CGRectGetMinX(tableView.frame);
            // 如果大于了最大偏移量,会导最后一个tableView偏离scrollView右边界
            if (offsetX > maxOffsetX) {
                offsetX = maxOffsetX;
            }
        }
            break;
        case SPPickerViewComponentScrollPositionMiddle:
        {
            offsetX = CGRectGetMidX(tableView.frame)-CGRectGetMidX(self.scrollView.frame);
            if (offsetX < minOffsetX) {
                offsetX = minOffsetX;
            }
            if (offsetX > maxOffsetX) {
                offsetX = maxOffsetX;
            }
        }
            break;
        default:
            break;
    }
    self.oldOffsetX = offsetX;
    [self.scrollView setContentOffset:CGPointMake(offsetX, 0) animated:animated];
}

// 根据tableView找出第几列
- (NSInteger)componentForTableView:(UITableView *)tableView {
    return [self.scrollView.subviews indexOfObject:tableView];
}

// 根据列号返回tableView
- (UITableView *)tableViewAtComponent:(NSInteger)component {
    if (component < self.scrollView.subviews.count) {
        return [self.scrollView.subviews objectAtIndex:component];
    }
    return nil;
}

- (void)buildTableViewWithComponent:(NSInteger)component {
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.scrollsToTop = NO;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.showsHorizontalScrollIndicator = NO;
    if (self.cellClasses.allValues.count || self.cellNibs.allValues.count) { // 说明在设置数据源之前就调了本框架的注册方法
        Class cellClass = [self.cellClasses objectForKey:@(component)];
        if (cellClass) {
            [tableView registerClass:cellClass forCellReuseIdentifier:sp_customCell(component)];
        }
        UINib *cellNib = [self.cellNibs objectForKey:@(component)];
        if (cellNib) {
            [tableView registerNib:cellNib forCellReuseIdentifier:sp_customCell(component)];
        }
    }
    if (self.hideSeparatorLines.allValues.count) { // 说明在设置数据源之前就已经设置了隐藏某一个tableview或者隐藏所有tableView的分割线
        BOOL hideAllSeparatorLines = [self.hideSeparatorLines objectForKey:sp_hideSeparatorLineForAllComponentlsKey];
        if (hideAllSeparatorLines) { // 说明是隐藏所有talbeView的分割线
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        } else {
            BOOL hideCurrentTableViewSeparatorLine = [self.hideSeparatorLines objectForKey:@(component)];
            if (hideCurrentTableViewSeparatorLine) {
                tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            }
        }
    }
    if (self.showsVerticalScrollIndicators.allValues.count) {
        BOOL showsAllVerticalScrollIndicators = [self.showsVerticalScrollIndicators objectForKey:sp_showsVerticalScrollIndicatorsKey];
        if (showsAllVerticalScrollIndicators) {
            tableView.showsVerticalScrollIndicator = YES;
        } else {
            BOOL showsCurrentTableViewVerticalScrollIndicator = [self.showsVerticalScrollIndicators objectForKey:@(component)];
            if (showsCurrentTableViewVerticalScrollIndicator) {
                tableView.showsVerticalScrollIndicator = YES;
            }
        }
    }
    [self.scrollView addSubview:tableView];
}

#pragma mark - setter
- (void)setDataSource:(id<SPPickerViewDatasource>)dataSource {
    _dataSource = dataSource;
    // 共有多少列
    self.numberOfComponents = [self.dataSource sp_numberOfComponentsInPickerView:self];
}

- (void)setDelegate:(id<SPPickerViewDelegate>)delegate {
    _delegate = delegate;

}

- (void)setPagingEnabledHorizontally:(BOOL)pagingEnabledHorizontally {
    _pagingEnabledHorizontally = pagingEnabledHorizontally;
    self.scrollView.pagingEnabled = pagingEnabledHorizontally;
}

- (void)setNumberOfComponents:(NSInteger)numberOfComponents {
    if (numberOfComponents == _numberOfComponents) return;

    if (numberOfComponents > _numberOfComponents) { // 有可能外界返回的总列数会发生变化，如果大于了之前的总列数，则在原先已有列数的情况下再继续追加tableView
        for (NSInteger i = 0; i < numberOfComponents-_numberOfComponents; i++) {
            [self buildTableViewWithComponent:_numberOfComponents];
        }
    } else { // 小于之前的总列数
        for (int i = 0; i < _numberOfComponents-numberOfComponents; i++) {
            // 移除最后一个，移除（_numberOfComponents-numberOfComponents）次
            [self.scrollView.subviews.lastObject removeFromSuperview];
        }
    }
    _numberOfComponents = numberOfComponents;

    [self setNeedsLayout];
    [self layoutIfNeeded];
}

#pragma mark - getter

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.scrollsToTop = NO;
    }
    return  _scrollView;
}

- (NSMutableDictionary *)cellClasses {
    if (!_cellClasses) {
        _cellClasses = [NSMutableDictionary dictionary];
    }
    return  _cellClasses;
}

- (NSMutableDictionary *)cellNibs {
    if (!_cellNibs) {
        _cellNibs = [NSMutableDictionary dictionary];
    }
    return  _cellNibs;
}

- (NSMutableDictionary *)hideSeparatorLines {
    if (!_hideSeparatorLines) {
        _hideSeparatorLines = [NSMutableDictionary dictionary];
    }
    return _hideSeparatorLines;
}

- (NSMutableDictionary *)showsVerticalScrollIndicators {

    if (!_showsVerticalScrollIndicators) {
        _showsVerticalScrollIndicators = [NSMutableDictionary dictionary];
    }
    return _showsVerticalScrollIndicators;
}

- (NSMutableDictionary *)rowWidths {
    if (!_rowWidths) {
        _rowWidths = [NSMutableDictionary dictionary];
    }
    return  _rowWidths;
}

#pragma mark - 布局
// 参数为正在刷新的tableView的列号
- (void)layoutTableViewWithReloadingTableViewComponent:(NSInteger)component {

    CGFloat scrollViewH = self.scrollView.bounds.size.height;

    UITableView *lastTableView;
    CGFloat rowWidth;
    for (int i = 0; i < self.scrollView.subviews.count; i++) {
        UITableView *tableView = self.scrollView.subviews[i];
        if ([self.delegate respondsToSelector:@selector(sp_pickerView:rowWidthForComponent:)]) {
            rowWidth = [self.delegate sp_pickerView:self rowWidthForComponent:i]; // i就是列
            CGFloat oldRowWidth = [[self.rowWidths objectForKey:@(i)] floatValue];
            if (fabs(rowWidth-oldRowWidth) > 0.1) { // 说明宽度不同
                if (i == component) { // 根据设置tableView的宽度的代理方法修改正在刷新的tableView的宽度值
                    [UIView animateWithDuration:0.15 animations:^{
                        tableView.frame = CGRectMake(CGRectGetMaxX(lastTableView.frame), 0, rowWidth, scrollViewH);
                    }];
                } else if (i > component) { // 修改正在刷新的tableView之后的tableView的x值
                    rowWidth = tableView.bounds.size.width;
                    [UIView animateWithDuration:0.15 animations:^{
                        tableView.frame = CGRectMake(CGRectGetMaxX(lastTableView.frame), 0, rowWidth, scrollViewH);
                    }];
                }
            } else {
                rowWidth = tableView.bounds.size.width;
                tableView.frame = CGRectMake(CGRectGetMaxX(lastTableView.frame), 0, rowWidth, scrollViewH);
            }
        }
        lastTableView = tableView;
    }
    self.scrollView.contentSize = CGSizeMake(CGRectGetMaxX(lastTableView.frame), 0);
}


- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat scrollViewX = 0;
    CGFloat scrollViewY = 0;
    CGFloat scrollViewW = self.bounds.size.width;
    CGFloat scrollViewH = self.bounds.size.height;
    self.scrollView.frame = CGRectMake(scrollViewX, scrollViewY, scrollViewW, scrollViewH);
    // scrollView的frame一旦重新设置，其偏移量会还原的最开始的状态，这行代码的作用是让其偏移都上次偏移的地方
    self.scrollView.contentOffset = CGPointMake(self.oldOffsetX, 0);

    UITableView *lastTableView;
    CGFloat rowWidth;
    for (int i = 0; i < self.scrollView.subviews.count; i++) {
        UITableView *tableView = self.scrollView.subviews[i];
        if ([self.delegate respondsToSelector:@selector(sp_pickerView:rowWidthForComponent:)]) {
            rowWidth = [self.delegate sp_pickerView:self rowWidthForComponent:i]; // i就是列
        } else {
            rowWidth = scrollViewW;
        }
        tableView.frame = CGRectMake(CGRectGetMaxX(lastTableView.frame), 0, rowWidth, scrollViewH);
        [self.rowWidths setObject:@(rowWidth) forKey:@(i)];
        lastTableView = tableView;
        [tableView reloadData];
    }
    self.scrollView.contentSize = CGSizeMake(CGRectGetMaxX(lastTableView.frame), 0);
}

@end

