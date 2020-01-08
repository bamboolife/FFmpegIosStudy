//
//  ViewController.h
//  FFmpegIosStudy
//
//  Created by 蒋建伟 on 2020/1/5.
//  Copyright © 2020 蒋建伟. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *content;

- (IBAction)protocolButton:(id)sender;
- (IBAction)avformatButton:(id)sender;
- (IBAction)avcodecButton:(id)sender;
- (IBAction)avfilterButton:(id)sender;
- (IBAction)configureButton:(id)sender;
- (IBAction)bitStreamFilterButton:(id)sender;
- (IBAction)metadataButton:(id)sender;

@end

