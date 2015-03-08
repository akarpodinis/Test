//
//  ViewController.h
//  Test
//
//  Created by Neha Mittal on 3/6/15.
//  Copyright (c) 2015 Neha Mittal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UITextView *outputField;

@end

