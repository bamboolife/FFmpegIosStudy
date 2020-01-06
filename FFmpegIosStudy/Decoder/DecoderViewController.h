//
//  DecoderViewController.h
//  FFmpegIosStudy
//
//  Created by 蒋建伟 on 2020/1/6.
//  Copyright © 2020 蒋建伟. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DecoderViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *inputPath;
@property (weak, nonatomic) IBOutlet UITextField *outputPath;
@property (weak, nonatomic) IBOutlet UITextView *content;

- (IBAction)clickDecodeButton:(id)sender;
@end

NS_ASSUME_NONNULL_END
