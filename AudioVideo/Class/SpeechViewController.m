//
//  SpeechViewController.m
//  AudioVideo
//
//  Created by 刘冉 on 2021/7/1.
//

#import "SpeechViewController.h"
#import "SpeechController.h"

@interface SpeechViewController ()

@property (nonatomic,strong) SpeechController *speechController;
@property (nonatomic,strong) NSArray<NSString *>* texts;

@end

@implementation SpeechViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    _texts = @[@"how are you?",
               @"i am fine,thanks for asking",
               @"are you excited about the book?",
               @"Very! i have always felt so misunderstood",
               @"what is your favorite feature?",
               @"oh, they are all my babies,i could not possibly choose",
               @"it was great to speak with you",
               @"the pleasure was all mine! Have fun",];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(8, 30, self.view.frameWidth - 16, 300)];
    label.text = [_texts componentsJoinedByString:@"\n"];
    label.numberOfLines =  0;
    label.font = [UIFont systemFontOfSize:17];
    label.backgroundColor = [UIColor lightTextColor];
    [self.view addSubview:label];
    
    UIButton *playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [playBtn setTitle:@"play" forState:UIControlStateNormal];
    playBtn.backgroundColor = [UIColor purpleColor];
    playBtn.layer.cornerRadius = 5.f;
    playBtn.clipsToBounds = YES;
    [playBtn addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
    playBtn.frame = CGRectMake(8, label.frameY + label.frameHeight + 8, 80, 40);
    [self.view addSubview:playBtn];
}

- (void)play:(UIButton *)sender {
    [self.speechController beginConversion:_texts];
}

- (SpeechController *)speechController {
    if (!_speechController) {
        _speechController = [SpeechController speechController];
    }
    return _speechController;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
