//
//  RootViewController.m
//  AudioVideo
//
//  Created by 刘冉 on 2021/6/21.
//

#import "RootViewController.h"

static NSString *CellIdentifier = @"CellIdentifier";

@interface RootViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) NSMutableArray <NSString *>*vcArray;
@property (nonatomic,strong) UITableView *vcTableView;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addVCSource];
    [self.vcTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
    [self.view addSubview:self.vcTableView];
}

- (void)dealloc {
    NSLog(@"DELLOC : %@",NSStringFromClass(self.class));
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (@available(iOS 11.0, *)) {
        self.vcTableView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - self.view.safeAreaInsets.bottom - self.view.safeAreaInsets.top);
    } else {
        // Fallback on earlier versions
        self.vcTableView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    }
}

- (void)addVCSource {
    [self.vcArray addObject:@"RecordViewController"];
    [self.vcArray addObject:@"SpeechViewController"];
    [self.vcArray addObject:@"KKVideoCameraViewController"];
    [self.vcArray addObject:@"PictureFilterViewController"];
}

#pragma UITableViewDelegate & UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableVieew numberOfRowsInSection:(NSInteger)section {
    return self.vcArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.textLabel.text = self.vcArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Class class = NSClassFromString(self.vcArray[indexPath.row]);
    id pushVC = [[class alloc] init];
    if ([pushVC isKindOfClass:[UIViewController class]]) {
        [self.navigationController pushViewController:(UIViewController *)pushVC animated:YES];
    }
}

- (UITableView *)vcTableView {
    if (!_vcTableView) {
        _vcTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _vcTableView.delegate = self;
        _vcTableView.dataSource = self;
    }
    return _vcTableView;
}

- (NSMutableArray<NSString *> *)vcArray {
    if (!_vcArray) {
        _vcArray = [NSMutableArray array];
    }
    return _vcArray;
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
