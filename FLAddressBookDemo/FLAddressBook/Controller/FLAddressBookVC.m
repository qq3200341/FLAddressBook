//
//  PhoneAddressBookVC.m
//  UCAClient
//
//  Created by fuliang on 15/12/9.
//  Copyright © 2015年 fuliang. All rights reserved.
//

#import "FLAddressBookVC.h"
#import <AddressBook/AddressBook.h>
#import "NSString+Helper.h"
#define FLSCREENWIDTH [UIScreen mainScreen].bounds.size.width
#define FLSCREENHEIGHT [UIScreen mainScreen].bounds.size.height

@interface FLAddressBookVC ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (nonatomic,strong)UITableView *searchResultTableView;
@property (nonatomic,strong)NSMutableArray *searchResultArray;
@property (nonatomic,strong)NSArray *sectionTitleArray;

@property (nonatomic,strong)NSMutableArray *addressBookArray;

@property (nonatomic,strong)NSMutableDictionary *addressBookDic;

@property (nonatomic,strong)UILabel *showLable;
@end

@implementation FLAddressBookVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _myTableView.sectionIndexBackgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    _myTableView.sectionIndexColor = [UIColor whiteColor];
    _myTableView.sectionIndexTrackingBackgroundColor = [UIColor redColor];
    
    _myTableView.tableFooterView = [[UIView alloc] init];
    
    _searchResultArray = [NSMutableArray array];
    _addressBookArray = [NSMutableArray array];
    _addressBookDic = [NSMutableDictionary dictionary];
    [self getAddressBookData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark--功能方法
/**
 *  数组排序
 *
 *  @param array <#array description#>
 *  @param key   <#key description#>
 *
 *  @return <#return value description#>
 */
- (NSArray *)sortWithArray:(NSArray *)array key:(NSString *)key
{
    NSArray *resultArray = [array sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:key ascending:YES]]];
    return resultArray;
}
/**
 *  获取通讯录
 *
 *  @return <#return value description#>
 */
- (void)getAddressBookData
{
    //获取通讯录
    [_addressBookArray removeAllObjects];
    
    CFErrorRef errorRef = NULL;
    //第一个参数 系统保留字段 现在没用 以备后用 传null  第二个参数 错误信息外部变量方法内部赋值
    ABAddressBookRef addressBookRef =ABAddressBookCreateWithOptions(NULL, &errorRef);
    
    //请求访问通讯录 ^后面跟的是一个代码块 该代码块只有在用户点击后执行 addressBookRef也是在取得授权后有值
    ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
        if (granted) {
            NSLog(@"授权成功");
            //获取所有联系人信息
            CFArrayRef arrayRef = ABAddressBookCopyArrayOfAllPeople(addressBookRef);
            //强制转化为oc类型 强转只改表面 不改本质
            NSArray *array = (__bridge NSArray *)arrayRef;
            for (int i=0; i<array.count; i++)
            {
                //从中取出一条联系人信息
                ABRecordRef recordRef = (__bridge ABRecordRef)(array[i]);
                
                ABMultiValueRef multiValueRef = ABRecordCopyValue(recordRef, kABPersonPhoneProperty);
                NSString *uName = @"";
                //读取firstname
                ABMultiValueRef CFperson = ABRecordCopyValue(recordRef, kABPersonFirstNameProperty);
                NSString *personName = (__bridge NSString *)CFperson;
                if (personName && ![personName isEqualToString:@""])
                {
                    uName = personName;
                }
                //读取lastname
                ABMultiValueRef CFlast = ABRecordCopyValue(recordRef, kABPersonLastNameProperty);
                NSString *lastname = (__bridge NSString*)CFlast;
                if (lastname && ![lastname isEqualToString:@""])
                {
                    uName = [NSString stringWithFormat:@"%@%@",lastname,uName];
                }
                
                for(int i = 0; i < ABMultiValueGetCount(multiValueRef); i++)
                {
                    CFTypeRef CFNumber = ABMultiValueCopyValueAtIndex(multiValueRef, i);
                    NSString *phoneNumber = (__bridge NSString *)CFNumber;
                    NSString *newPhoneNum = [phoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
                    LinkMan *linkMan = [[LinkMan alloc] init];
                    linkMan.name = uName;
                    linkMan.phoneNumber = newPhoneNum;
                    CFRelease(CFNumber);
                    [_addressBookArray addObject:linkMan];
                }
                if(CFperson)
                {
                    CFRelease(CFperson);
                }
                if (CFlast)
                {
                    CFRelease(CFlast);
                }
                CFRelease(multiValueRef);
            }
            CFRelease(arrayRef);
        }else
        {
            [[[UIAlertView alloc] initWithTitle:@"提示" message:@"获取通讯录失败,请到[设置]-[隐私]-[通讯录],允许程序访问" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] show];
        }
        CFRelease(addressBookRef);
        [self addressArraySort];
    });

}
/**
 *  给通讯录排序
 */
- (void)addressArraySort
{
    [_addressBookDic removeAllObjects];
    [_addressBookArray enumerateObjectsUsingBlock:^(LinkMan *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *pinyin = [obj.name pinyin];
        if (pinyin)
        {
            if ([pinyin characterAtIndex:0] < 'A' || [pinyin characterAtIndex:0] > 'Z')
            {
                pinyin = @"#";
            }
            NSArray *linkManArray = [_addressBookDic objectForKey:[pinyin substringToIndex:1]];
            NSMutableArray *mLinkManArray;
            if (linkManArray)
            {
                mLinkManArray = [NSMutableArray arrayWithArray:linkManArray];
                
            }
            else
            {
                mLinkManArray = [NSMutableArray array];
            }
            [mLinkManArray addObject:obj];
            [_addressBookDic setObject:mLinkManArray forKey:[pinyin substringToIndex:1]];
        }
    }];
    
    [_addressBookDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, NSArray *obj, BOOL * _Nonnull stop) {
        NSArray *array = [self customSortWithArray:obj];
        [_addressBookDic setObject:array forKey:key];
    }];
    
    _sectionTitleArray = [self sortWithArray:_addressBookDic.allKeys key:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [_myTableView reloadData];
    });
}
/**
 *  对LinkMan对象进行排序
 *
 *  @return <#return value description#>
 */
- (NSArray *)customSortWithArray:(NSArray<LinkMan *> *)array
{
    NSArray *results = [array sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
    return results;
}
/**
 *  显示当前选择的拼音索引
 *
 *  @param title <#title description#>
 */
- (void)showCurrentTitle:(NSString *)title
{
    if (_showLable == nil)
    {
        _showLable = [[UILabel alloc] initWithFrame:CGRectZero];
        _showLable.font = [UIFont systemFontOfSize:60];
        _showLable.textColor = [UIColor greenColor];
        _showLable.center = CGPointMake(FLSCREENWIDTH / 2, FLSCREENHEIGHT / 2);
        [self.view addSubview:_showLable];
    }
    _showLable.hidden = NO;
    _showLable.text = title;
    [_showLable sizeToFit];
    [self performSelector:@selector(showLableHidden) withObject:nil afterDelay:1];
}

- (void)showLableHidden
{
    _showLable.hidden = YES;
}
#pragma mark--UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == _myTableView || scrollView == _searchResultTableView)
    {
        [self.view endEditing:YES];
    }
}
#pragma mark--UITableViewDataSource
- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (tableView == _myTableView)
    {
        return _sectionTitleArray;
    }
    else
    {
        return nil;
    }
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == _myTableView)
    {
        return _sectionTitleArray.count;
    }
    else
    {
        return 1;
    }
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == _myTableView)
    {
        NSString *sectionTitle = _sectionTitleArray[section];
        return sectionTitle;
    }
    else
    {
        return nil;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _myTableView)
    {
        NSString *key = [_sectionTitleArray objectAtIndex:section];
        NSArray *array = [_addressBookDic objectForKey:key];
        return array.count;
    }
    else
    {
        return _searchResultArray.count;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        if (tableView == _myTableView)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        }
        else
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        }
    }
    cell.imageView.image = [UIImage imageNamed:@"gropu_default_icon"];
    if (tableView == _myTableView)
    {
        NSString *key = [_sectionTitleArray objectAtIndex:indexPath.section];
        NSArray *array = [_addressBookDic objectForKey:key];
        LinkMan *linkMan = array[indexPath.row];
        cell.textLabel.text = linkMan.name;
    }
    else
    {
        LinkMan *linkMan = _searchResultArray[indexPath.row];
        cell.textLabel.text = linkMan.name;
        cell.detailTextLabel.text = linkMan.phoneNumber;
        
        NSMutableAttributedString *nameAttStr = [[NSMutableAttributedString alloc] initWithString:cell.textLabel.text];
        [nameAttStr addAttributes:@{NSForegroundColorAttributeName:[UIColor redColor]} range:[cell.textLabel.text rangeOfString:_searchBar.text]];
        cell.textLabel.attributedText = nameAttStr;
        
        NSMutableAttributedString *phoneAttStr = [[NSMutableAttributedString alloc] initWithString:cell.detailTextLabel.text];
        [phoneAttStr addAttributes:@{NSForegroundColorAttributeName:[UIColor redColor]} range:[cell.detailTextLabel.text rangeOfString:_searchBar.text]];
        cell.detailTextLabel.attributedText = phoneAttStr;
    }
    
    
    
    return cell;
}
#pragma mark--UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    LinkMan *linkMan;
    if (tableView == _myTableView)
    {
        NSString *key = [_sectionTitleArray objectAtIndex:indexPath.section];
        NSArray *array = [_addressBookDic objectForKey:key];
        linkMan = array[indexPath.row];
    }
    else
    {
        linkMan = _searchResultArray[indexPath.row];
    }
    if ([_delegate respondsToSelector:@selector(phoneAddressBookVC:didSelectRowWithLinkMan:)])
    {
        [_delegate phoneAddressBookVC:self didSelectRowWithLinkMan:linkMan];
    }
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if (tableView == _myTableView)
    {
        [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        [self showCurrentTitle:title];
        return index;
    }
    else
    {
        return 0;
    }
}
#pragma mark--UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchText isEqualToString:@""])
    {
        [_searchResultTableView removeFromSuperview];
        _searchResultTableView = nil;
    }
    else
    {
        if (_searchResultTableView == nil)
        {
            _searchResultTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 106, FLSCREENWIDTH, FLSCREENHEIGHT - 106)];
            _searchResultTableView.delegate = self;
            _searchResultTableView.dataSource = self;
            _searchResultTableView.tableFooterView = [[UIView alloc] init];
            [self.view addSubview:_searchResultTableView];
        }
        
        [_searchResultArray removeAllObjects];
        [_addressBookArray enumerateObjectsUsingBlock:^(LinkMan *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.name containsString:searchText] || [obj.phoneNumber containsString:searchText])
            {
                [_searchResultArray addObject:obj];
            }
        }];
        
        [_searchResultTableView reloadData];
        
    }
}
@end
