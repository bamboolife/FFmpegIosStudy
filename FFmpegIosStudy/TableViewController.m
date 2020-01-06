//
//  TableViewController.m
//  FFmpegIosStudy
//
//  Created by 蒋建伟 on 2020/1/6.
//  Copyright © 2020 蒋建伟. All rights reserved.
//

#import "TableViewController.h"

@interface TableViewController ()
@property(nonatomic,strong) NSArray *arrayData;
@end

@implementation TableViewController
@synthesize arrayData;


- (void)viewDidLoad {
    [super viewDidLoad];
    
   arrayData = [NSArray arrayWithObjects:@"FFmpeg Info",@"FFmpeg解码",@"FFmpeg编码",@"FFmpeg推流",@"简易视频播放器", nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return arrayData.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *indentifier=@"baseicCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:indentifier];
    }
    cell.textLabel.text=[arrayData objectAtIndex:indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //UIViewController *viewController=[]
   //1.创建UIAlertControler
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"标题" message:@"这是一些信息" preferredStyle:UIAlertControllerStyleAlert];
        /*
         参数说明：
         Title:弹框的标题
         message:弹框的消息内容
         preferredStyle:弹框样式：UIAlertControllerStyleAlert
         */
        
        //2.添加按钮动作
        //2.1 确认按钮
        UIAlertAction *conform = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"点击了确认按钮");
        }];
        //2.2 取消按钮
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"点击了取消按钮");
        }];
        //2.3 还可以添加文本框 通过 alert.textFields.firstObject 获得该文本框
//        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
//            textField.placeholder = @"请填写您的反馈信息";
//        }];
     
        //3.将动作按钮 添加到控制器中
        [alert addAction:conform];
        [alert addAction:cancel];
        
        //4.显示弹框
       // [self presentViewController:alert animated:YES completion:nil];
    
    if(indexPath.row==0){
       UIViewController *ffmpegInfo=[[self storyboard] instantiateViewControllerWithIdentifier:@"ffmpegInfo"];
       [[self navigationController] pushViewController:ffmpegInfo animated:true];
    }else if (indexPath.row==1){
        UIViewController *decoder=[[self storyboard] instantiateViewControllerWithIdentifier:@"decoder"];
        [[self navigationController] pushViewController:decoder animated:true];
    }else if (indexPath.row==2){
        
    }else if (indexPath.row==3){
        
    }else if (indexPath.row==4){
        UIViewController *videoPlay=[[self storyboard] instantiateViewControllerWithIdentifier:@"videoview"];
               [[self navigationController] pushViewController:videoPlay animated:true];
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
