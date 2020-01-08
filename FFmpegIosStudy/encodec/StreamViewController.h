//
//  StreamViewController.h
//  FFmpegIosStudy
//
//  Created by 蒋建伟 on 2020/1/7.
//  Copyright © 2020 蒋建伟. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface StreamViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *inputPath;
@property (weak, nonatomic) IBOutlet UITextField *outPath;
@property (weak, nonatomic) IBOutlet UITextView *content;
- (IBAction)streamButton:(id)sender;

@end

NS_ASSUME_NONNULL_END
