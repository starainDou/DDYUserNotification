#import "ViewController.h"
#import "DDYAuthorityManager.h"

@interface ViewController ()

@property (nonatomic, strong) UIImage *imgNormal;

@property (nonatomic, strong) UIImage *imgSelect;

@property (nonatomic, strong) NSMutableArray *buttonArray;

@end

@implementation ViewController

- (NSMutableArray *)buttonArray {
    if (!_buttonArray) {
        _buttonArray = [NSMutableArray array];
    }
    return _buttonArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *authArray = @[@"务必打开工程Capabilities,Push Notifications"];
    for (NSInteger i = 0; i < authArray.count; i++) {
        @autoreleasepool {
            UIButton *button = [self generateButton:i title:authArray[i]];
            [self.buttonArray addObject:button];
            if ([[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"%ld_auth", button.tag]]) {
                [self performSelectorOnMainThread:@selector(handleClick:) withObject:button waitUntilDone:YES];
            }
        }
    }
}

- (UIButton *)generateButton:(NSInteger)tag title:(NSString *)title {
    CGFloat screenW = self.view.bounds.size.width;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor greenColor] forState:UIControlStateSelected];
    [button addTarget:self action:@selector(handleClick:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTag:tag+100];
    [self.view addSubview:button];
    button.titleLabel.font = [UIFont systemFontOfSize:screenW<320 ? 11 : (screenW>320 ? 15 : 13)];
    [button setFrame:CGRectMake(10, tag*45 + 100, screenW-20, 30)];
    button.layer.borderWidth = 1;
    button.layer.borderColor = [UIColor redColor].CGColor;
    return button;
}

- (void)handleClick:(UIButton *)sender {
    [DDYAuthorityManager ddy_PushNotificationAuthAlertShow:YES result:^(BOOL isAuthorized) {
        sender.selected = isAuthorized;
    }];
}

#pragma mark 绘制圆形图片
- (UIImage *)circleImageWithColor:(UIColor *)color radius:(CGFloat)radius
{
    CGRect rect = CGRectMake(0, 0, radius*2.0, radius*2.0);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,color.CGColor);
    CGContextFillEllipseInRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

#pragma mark 绘制圆形框
- (UIImage *)circleBorderWithColor:(UIColor *)color radius:(CGFloat)radius
{
    CGRect rect = CGRectMake(0, 0, radius*2.0, radius*2.0);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextAddArc(context, radius, radius, radius-1, 0, 2*M_PI, 0);
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextSetLineWidth(context, 1);
    CGContextStrokePath(context);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

@end
