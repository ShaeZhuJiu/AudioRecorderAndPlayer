//
//  ViewController.m
//  录音
//
//  Created by 谢鑫 on 2020/2/25.
//  Copyright © 2020 Shae. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
@interface ViewController ()<AVAudioPlayerDelegate>
@property (nonatomic,strong)NSURL *url;
@property (nonatomic,strong)AVAudioRecorder *recorder;
@property (nonatomic,strong)AVAudioPlayer *player;
@property (weak, nonatomic) IBOutlet UIButton *longPressBtn;

@end

@implementation ViewController
- (NSURL *)url{
    if (_url==nil) {
        NSString *tmpDir=NSTemporaryDirectory();//获取沙盒的TemporaryDirectory路径
        NSString *urlPath=[tmpDir stringByAppendingString:@"record.caf"];
        _url=[NSURL fileURLWithPath:urlPath];
        NSLog(@"_url:%@",_url);
    }
    return _url;
}
- (AVAudioPlayer *)player{
    if (_player==nil) {
        _player=[[AVAudioPlayer alloc] initWithContentsOfURL:self.url error:nil];
        _player.volume=1.0;
        _player.delegate=self;
    }
    return _player;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UILongPressGestureRecognizer *longPress=[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressToRecord:)];
    [_longPressBtn addGestureRecognizer:longPress];
}
- (IBAction)startRecord:(UIButton *)sender {
    [self startRecord];
}

- (IBAction)endRecord:(UIButton *)sender {
    [self endRecord];
}
- (IBAction)playRecord:(UIButton *)sender {
    
    [self.player play];
}

#pragma AVAudioPlayer的代理方法
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    NSLog(@"%s",__func__);
    self.player=nil;
}
# pragma  mark --自定义方法
-(void)longPressToRecord:(UILongPressGestureRecognizer *)gesture{
    if(gesture.state==UIGestureRecognizerStateBegan){
        //开始录音
        [self startRecord];
    }else{
        //结束录音
        [self endRecord];
    }
    
}
-(void)startRecord{
    NSLog(@"开始录音");
    NSError *error=nil;//
    //1.激活AVAudioSession
    AVAudioSession *session=[AVAudioSession sharedInstance];//单例类
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    if (session !=nil) {
        [session setActive:YES error:nil];
    }else{
        NSLog(@"session error :%@",error);
    }
    //2.设置AVAudioSession类的属性
    NSDictionary *recoderSettings=[[NSDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithFloat:16000.0],AVSampleRateKey,[NSNumber numberWithInt:kAudioFormatAppleIMA4],AVFormatIDKey,[NSNumber numberWithInt:1],AVNumberOfChannelsKey,[NSNumber numberWithInt:AVAudioQualityMax],AVEncoderAudioQualityKey, nil];//采样率，格式，Channel，采样质量
    //3.初始化recod对象
    self.recorder=[[AVAudioRecorder alloc]initWithURL:self.url settings:recoderSettings error:nil];
    //4.开始录音
    [self.recorder record];
}
-(void)endRecord{
    NSLog(@"结束录音");
    [self.recorder stop];
    self.recorder=nil;//停止录音需要将现有AVAudioRecorder释放掉，不然再次录音会录到之前的文件里
}
@end
