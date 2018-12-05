//
//  QIMUserListVC.m
//  qunarChatIphone
//
//  Created by xueping on 15/7/16.
//
//

#import "QIMUserListVC.h"

#import "QIMDatasourceItem.h"
#import "QIMContactDatasourceManager.h"
#import "QIMBuddyTitleCell.h"
#import "QIMBuddyItemCell.h"
#import "SearchBar.h"
#import "QIMGroupListVC.h"
#import "NSBundle+QIMLibrary.h"

#define kKeywordSearchBarHeight 44

@interface QIMUserListVC ()<UITableViewDataSource,UITableViewDelegate,SearchBarDelgt,UIGestureRecognizerDelegate>

@end

@implementation QIMUserListVC

{
    UITableView *_tableView;
    NSMutableArray * _recentContactArray;
    NSMutableArray *_searchResults;
    SearchBar *_searchBarKeyTmp;
    
    NSMutableDictionary *_suggestOrganizationCacheDic;
    NSMutableArray *_searchTreeList;
    
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self.navigationItem setTitle:[NSBundle qim_localizedStringForKey:@"tab_title_contact"]];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTempClick)];
    [tap setDelegate:self];
    [self.view addGestureRecognizer:tap];
    
    [self loadContractList];
    [self initWithTableView];
    [self setupSearchBar];
    
    if (self.isTransfer) {
        UIBarButtonItem *rightBar = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(goBack:)];
        [[self navigationItem] setRightBarButtonItem:rightBar];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadContractList) name:kUserListUpdate object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if (_searchResults.count == 0) {
        _searchBarKeyTmp.text = nil;
        //    [self searchBar:_searchBarKeyTmp textDidChange:nil];
        [_searchBarKeyTmp resignFirstResponder];
    }
    return NO;
}

- (void)onTempClick{
}

- (void)goBack:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - init ui
-(void)setupSearchBar{
    //    [[QIMContactDatasourceManager getInstance] createUnMeregeDataSource];
    _searchBarKeyTmp = [[SearchBar alloc] initWithFrame:CGRectZero andButton:nil];
    [_searchBarKeyTmp setPlaceHolder:[NSBundle qim_localizedStringForKey:@"common_search_tips"]];
    [_searchBarKeyTmp setReturnKeyType:UIReturnKeySearch];
    [_searchBarKeyTmp setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [_searchBarKeyTmp setAutocorrectionType:UITextAutocorrectionTypeNo];
    [_searchBarKeyTmp setDelegate:self];
    [_searchBarKeyTmp setText:nil];
    [_searchBarKeyTmp setFrame:CGRectMake(0, 0, self.view.frame.size.width, kKeywordSearchBarHeight)];
    [_tableView setTableHeaderView:_searchBarKeyTmp];
}

- (void)initWithTableView{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height) style:UITableViewStylePlain];
    [_tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableView setShowsHorizontalScrollIndicator:NO];
    [_tableView setShowsVerticalScrollIndicator:NO];
    [self.view addSubview:_tableView];
}

#pragma mark - other method

-(void)loadContractList
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([[[QIMContactDatasourceManager getInstance] QtalkDataSourceItem] count] == 0) {
            [[QIMContactDatasourceManager getInstance] createUnMeregeDataSource];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tableView reloadData];
            });
        }
    });
}

#pragma mark - search List
- (void)updateSearchTreeList{
    _searchTreeList = [NSMutableArray array];
    for (QIMDatasourceItem *item in _searchResults) {
        [_searchTreeList addObject:item];
        if (item.isExpand) {
            [_searchTreeList addObjectsFromArray:item.childNodesArray];
        }
    }
}
#pragma mark - table delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.isTransfer == NO && _searchResults.count > 0) {
        return _searchResults.count;
    } else if (_searchResults.count > 0) {
        [self updateSearchTreeList];
        return _searchTreeList.count;
    } else {
        NSInteger count =  [[[QIMContactDatasourceManager getInstance] QtalkDataSourceItem] count];
        return count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.isTransfer == NO && _searchResults.count > 0) {
        return 60;
    } else if (_searchResults.count > 0) {
        QIMDatasourceItem *item = [_searchTreeList objectAtIndex:indexPath.row];
        CGFloat height  = item.isParentNode ? 38 : 60;
        return height;
    } else {
        QIMDatasourceItem * item  = [[[QIMContactDatasourceManager getInstance] QtalkDataSourceItem]  objectAtIndex:indexPath.row];
        CGFloat height  = item.isParentNode ? 38 : 60;
        return height;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.isTransfer == NO && _searchResults.count > 0) {
        static NSString *cellIdentifier2 = @"cell2";
        QIMBuddyItemCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier2];
        if (cell == nil) {
            cell = [[QIMBuddyItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier2];
        }
        [cell initSubControls];
        NSString *jid = [[_searchResults objectAtIndex:[indexPath row]] objectForKey:@"XmppId"];
        NSString * remarkName = [[QIMKit sharedInstance] getUserMarkupNameWithUserId:jid];
        [cell setUserName:remarkName?remarkName:[[_searchResults objectAtIndex:[indexPath row]] objectForKey:@"Name"]];
        [cell setJid:jid];
        [cell refrash];
        return  cell;
        
    } else {
        QIMDatasourceItem * item = nil;
        if (_searchResults.count > 0) {
            item = [_searchTreeList objectAtIndex:indexPath.row];
        } else {
            item = [[[QIMContactDatasourceManager getInstance] QtalkDataSourceItem] objectAtIndex:indexPath.row];
        }
        if (item.isParentNode ) {
            
            NSString *cellIdentifier1 = [NSString stringWithFormat:@"CONTACT_BUDDY_TITLE_%ld", (long)[item nLevel]];
            QIMBuddyTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier1];
            if (cell == nil) {
                cell = [[QIMBuddyTitleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier1];
                [cell initSubControls];
            } 
            NSString * userName  =  item.nodeName;
            [cell setUserName:userName];
            [cell setExpanded:item.isExpand];
            [cell setNLevel:(int32_t)item.nLevel];
            [cell refresh];
            
            return cell;
            
        }
        else
        {
            static NSString *cellIdentifier2 = @"CONTACT_BUDDY";
            QIMBuddyItemCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier2];
            if (cell == nil) {
                cell = [[QIMBuddyItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier2];
            }
            NSString * userName  =  item.nodeName;
            NSString *  jid      =   item.jid;
            NSString * remarkName = [[QIMKit sharedInstance] getUserMarkupNameWithUserId:jid];
            [cell initSubControls];
            [cell setNLevel:item.nLevel];
            [cell setUserName:remarkName?remarkName:userName];
            [cell setJid:jid];
            [cell refrash];
            
            return cell;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.isTransfer == NO && [_searchResults count] > 0) {
        [_searchBarKeyTmp resignFirstResponder];
        id cell = [tableView cellForRowAtIndexPath:indexPath];
        if ([self.delegate respondsToSelector:@selector(selectContactWithJid:)]) {
            [self.delegate selectContactWithJid:[cell jid]];
        }
        if (self.isTransfer) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:YES completion:nil];
            });
        }
    } else if (_searchResults.count > 0) {
        QIMDatasourceItem  * qtalkItem =    [_searchTreeList objectAtIndex:indexPath.row];
        if ([qtalkItem isParentNode]) {
            if ([qtalkItem isExpand]) {
                [qtalkItem setIsExpand:NO];
                [self updateSearchTreeList];
                id cell = [tableView cellForRowAtIndexPath:indexPath];
                if ([cell isKindOfClass: [QIMBuddyTitleCell class]]) {
                    [cell setExpanded:NO];
                    [_tableView reloadData];
                }
            }
            else
            {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    if (qtalkItem.childNodesArray.count <= 0) {
                        NSArray *result = [_suggestOrganizationCacheDic objectForKey:qtalkItem.jid];
                        if (result == nil) {
                            result = [[QIMKit sharedInstance] getSuggestOrganizationBySuggestId:qtalkItem.jid];
                            [_suggestOrganizationCacheDic setObject:result forKey:qtalkItem.jid];
                        }
                        [qtalkItem.childNodesArray removeAllObjects];
                        for (NSDictionary *infoDic in result) {
                            QIMDatasourceItem *item = [[QIMDatasourceItem alloc] init];
                            [item setIsParentNode:NO];
                            [item setNodeName:[infoDic objectForKey:@"W"]];
                            [item setJid:[[infoDic objectForKey:@"U"] stringByAppendingFormat:@"@%@",[[QIMKit sharedInstance] getDomain]]];
                            [item setNLevel:1];
                            [item setParentNode:qtalkItem];
                            [qtalkItem addChildNodesItem:item];
                        }
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [qtalkItem setIsExpand:YES];
                        [self updateSearchTreeList];
                        //                [[QIMContactDatasourceManager getInstance] expandBranchAtIndex:indexPath.row];
                        id cell = [tableView cellForRowAtIndexPath:indexPath];
                        if ([cell isKindOfClass: [QIMBuddyTitleCell class]]) {
                            
                            [cell setExpanded:YES];
                            [_tableView reloadData];
                        }
                    });
                });
            }
        }
        else
        {
            [_searchBarKeyTmp resignFirstResponder];
            id cell = [tableView cellForRowAtIndexPath:indexPath];
            if ([self.delegate respondsToSelector:@selector(selectContactWithJid:)]) {
                [self.delegate selectContactWithJid:[cell jid]];
            }
            if (self.isTransfer) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self dismissViewControllerAnimated:YES completion:nil];
                });
            }
        }
    } else if ([[[QIMContactDatasourceManager getInstance] QtalkDataSourceItem] count] > 0 ) {
        QIMDatasourceItem  * qtalkItem =    [[[QIMContactDatasourceManager getInstance] QtalkDataSourceItem] objectAtIndex:indexPath.row];
        if ([qtalkItem isParentNode]) {
            if ([qtalkItem isExpand]) {
                [[QIMContactDatasourceManager getInstance] collapseBranchAtIndex:indexPath.row];
                id cell = [tableView cellForRowAtIndexPath:indexPath];
                if ([cell isKindOfClass: [QIMBuddyTitleCell class]]) {
                    [cell setExpanded:NO];
                    [_tableView reloadData];
                }
            }
            else
            {
                [[QIMContactDatasourceManager getInstance] expandBranchAtIndex:indexPath.row];
                id cell = [tableView cellForRowAtIndexPath:indexPath];
                if ([cell isKindOfClass: [QIMBuddyTitleCell class]]) {
                    
                    [cell setExpanded:YES];
                    [_tableView reloadData];
                }
            }
        }
        else
        {
            [_searchBarKeyTmp resignFirstResponder];
            id cell = [tableView cellForRowAtIndexPath:indexPath];
            if ([self.delegate respondsToSelector:@selector(selectContactWithJid:)]) {
                [self.delegate selectContactWithJid:[cell jid]];
            }
            if (self.isTransfer) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self dismissViewControllerAnimated:YES completion:nil];
                });
            }
        }
    }
}

// =======================================================================
#pragma mark - SectionSearchBar代理函数
// =======================================================================

- (void)updateSearchResult{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray *result = [[QIMKit sharedInstance] searchSuggestWithKeyword:_searchBarKeyTmp.text];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_searchResults == nil) {
                _searchResults = [[NSMutableArray alloc]init];
            }
            [_searchResults removeAllObjects];
            if ([result isEqual:[NSNull null]]==NO) {
                for (NSDictionary *suggestDic in result) {
                    QIMDatasourceItem *item = [[QIMDatasourceItem alloc] init];
                    [item setJid:[suggestDic objectForKey:@"id"]];
                    [item setNodeName:[suggestDic objectForKey:@"name"]];
                    [item setIsParentNode:YES];
                    [_searchResults addObject:item];
                }
            }
            [_tableView reloadData];
        });
    });
}

- (void)searchBarTextDidBeginEditing:(SearchBar *)SectionSearchBar
{
    //[self enterInputSearchKeyWord];
}
- (void)searchBar:(SearchBar *)SectionSearchBar textDidChange:(NSString *)searchText
{
    if (self.isTransfer) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateSearchResult) object:nil];
        [self performSelector:@selector(updateSearchResult) withObject:nil afterDelay:0.1];
    } else {
        if (_searchResults == nil) {
            _searchResults = [[NSMutableArray alloc]init];
        }
        [_searchResults removeAllObjects];
        if (searchText.length > 0) {
            [_searchResults addObjectsFromArray:[[QIMKit sharedInstance] searchUserListBySearchStr:searchText]];
        }
        [_tableView reloadData];
    }
}

- (void)searchBarTextDidEndEditing:(SearchBar *)searchBar {
    //    if (searchBar.text.length <= 0) {
    //        [_searchResults removeAllObjects];
    //        [_tableView reloadData];
    //    }
}

- (BOOL)searchBar:(SearchBar *)SectionSearchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return YES;
}

- (void)searchBarBarButtonClicked:(SearchBar *)SectionSearchBar
{
    // 取消焦点
}

- (void)searchBarBackButtonClicked:(SearchBar *)SectionSearchBar
{
    
}

- (void)searchBarSearchButtonClicked:(SearchBar *)SectionSearchBar
{
    
}

- (void)searchBar:(SearchBar *)SectionSearchBar sectionDidChange:(NSInteger)index
{
    
}

- (void)searchBar:(SearchBar *)SectionSearchBar sectionDidClicked:(NSInteger)index
{
    // 取消焦点
    [self cancelInputSearchKeyWord:SectionSearchBar];
}

//取消搜索
- (void)cancelInputSearchKeyWord:(id)sender
{
    
}

// 进入搜索
- (void)enterInputSearchKeyWord
{
    
}

#pragma mark - save userinfo by user id

-(void)saveUserinfoByUserID:(NSString *)userID{
    
}

@end
