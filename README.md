# FLAddressBook
实现简单的读取手机通讯录，按拼音排序。
使用方法：
```objc
FLAddressBookVC *fvc = [[FLAddressBookVC alloc] init];
fvc.delegate = self;
[self.navigationController pushViewController:fvc animated:YES];
```
实现代理方法
```objc
- (void)phoneAddressBookVC:(FLAddressBookVC *)pabvc didSelectRowWithLinkMan:(LinkMan *)linkMan
{
    NSLog(@"选中的联系人：%@", linkMan);
}
```
