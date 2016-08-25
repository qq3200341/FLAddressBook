//
//  PhoneAddressBookVC.h
//  UCAClient
//
//  Created by fuliang on 15/12/9.
//  Copyright © 2015年 fuliang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LinkMan.h"

@protocol FLAddressBookVCDelegate;

@interface FLAddressBookVC : UIViewController

@property (nonatomic,assign)id<FLAddressBookVCDelegate>delegate;
@end

@protocol FLAddressBookVCDelegate <NSObject>

@optional
- (void)phoneAddressBookVC:(FLAddressBookVC *)pabvc didSelectRowWithLinkMan:(LinkMan *)linkMan;

@end