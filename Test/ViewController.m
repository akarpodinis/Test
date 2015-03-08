//
//  ViewController.m
//  Test
//
//  Created by Neha Mittal on 3/6/15.
//  Copyright (c) 2015 Neha Mittal. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIView * container = [[UIView alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width, self.view.frame.size.height)];
    
    UILabel *inputLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 100, 20)];
    inputLabel.text = @"Input field";
    inputLabel.font = [UIFont systemFontOfSize:15];
    [container addSubview:inputLabel];
    
    self.textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 40, container.frame.size.width-30, 40)];
    self.textField.font = [UIFont systemFontOfSize:15];
    self.textField.returnKeyType = UIReturnKeyDone;
    self.textField.backgroundColor = [UIColor clearColor];
    self.textField.delegate = self;
    self.textField.borderStyle = UITextBorderStyleRoundedRect;
    self.textField.text = @"@bob @john (success) such a cool feature; https://google.com";
    [container addSubview:self.textField];
	
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self action:@selector(getJsonFromString:) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(10, self.textField.frame.size.height + self.textField.frame.origin.y + 10, container.frame.size.width, 44);
    [button setBackgroundColor:[UIColor clearColor]];
    [button setTitle:@"Done" forState:UIControlStateNormal];
    [container addSubview:button];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 140, 100, 20)];
    label.text = @"Output field";
    label.font = [UIFont systemFontOfSize:15];
    [container addSubview:label];
    
    self.outputField = [[UITextView alloc] initWithFrame:CGRectMake(10, 180, container.frame.size.width-30, 200)];
    self.outputField.font = [UIFont systemFontOfSize:15];
    self.outputField.backgroundColor = [UIColor clearColor];
    
    [container addSubview:self.outputField];
    [self.view addSubview:container];
    
}

- (void) getJsonFromString:(id) sender {
    NSString *inputStr = self.textField.text;
    NSArray *values = [ inputStr componentsSeparatedByCharactersInSet: [NSCharacterSet whitespaceCharacterSet]]; 
    values = [values filteredArrayUsingPredicate: [NSPredicate predicateWithFormat:@"SELF != ''"]];
    
    NSMutableArray *arrayNames=[[NSMutableArray alloc] init];
    NSMutableArray *arrayEmoticons=[[NSMutableArray alloc] init];
    NSMutableArray *arrayLinks=[[NSMutableArray alloc] init];
    
    for(NSString *str in values) {
        NSRange nameRange=[str rangeOfString:@"@" options:NSCaseInsensitiveSearch];
        NSRange emoticonRange=[str rangeOfString:@"(" options:NSCaseInsensitiveSearch];
        
        NSRange linkRange=[str rangeOfString:@"http" options:NSCaseInsensitiveSearch];
        
        if(nameRange.length == 1) {
            [arrayNames addObject:[str substringFromIndex:1]];
        } else if (emoticonRange.length == 1) {
            NSRange emoticonEndRange=[str rangeOfString:@")" options:NSCaseInsensitiveSearch];
            if(emoticonEndRange.length == 1){
                if(str.length < 17) {
                    [arrayEmoticons addObject:[str substringWithRange:NSMakeRange(1, str.length - 2)]];
                }
            }
        } else if (linkRange.location != NSNotFound) {
            NSURL *sUrl = [NSURL URLWithString:str];
            NSError *errorURL;
            NSString *s = [NSString stringWithContentsOfURL:sUrl encoding:NSASCIIStringEncoding error:&errorURL];
            if (!errorURL) {
                NSRange titleStartRange = [s rangeOfString:@"<title>" options:NSCaseInsensitiveSearch];
                NSRange titleEndRange = [s rangeOfString:@"</title>" options:NSCaseInsensitiveSearch];
                NSString *siteTitle = @"";
                if (titleStartRange.location != NSNotFound) {
                    siteTitle = [s substringWithRange:NSMakeRange(titleStartRange.location+titleStartRange.length, titleEndRange.location - titleStartRange.location - titleEndRange.length)];
                    if (![siteTitle isEqualToString:@""]) {
                        NSDictionary *linkDict = @{@"url":str, @"title":siteTitle};
                        [arrayLinks addObject:linkDict];
                    }
                }
            } else {
                NSDictionary *linkDict = @{@"url":str, @"title":@"Title not found"};
                [arrayLinks addObject:linkDict];
            }
            
        } else {
            continue;
        }
    }
    
    NSMutableDictionary *returnDictionary = [[NSMutableDictionary alloc] init];
    if([arrayLinks  count] > 0) {
        [returnDictionary  setObject:arrayLinks forKey:@"links"];
    }
    if([arrayEmoticons  count] > 0) {
        [returnDictionary  setObject:arrayEmoticons forKey:@"emoticons"];
    }
    if([arrayNames  count] > 0) {
        [returnDictionary  setObject:arrayNames forKey:@"mentions"];
    }
    
	NSError *error;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:returnDictionary options:0 error:&error];
    
	if(!error) {
	
		NSString * myString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        myString = [myString stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
        self.outputField.text = myString;
	}
}

@end
