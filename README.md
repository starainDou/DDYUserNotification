# DDYUserNotification

![DDYUserNotification.png](https://github.com/starainDou/DDYDemoImage/blob/master/DDYUserNotification.png)
  

> # 注册远程通知

```
#pragma mark 远程推送通知
- (void)registerRemoteNotification {
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter *currentNotificationCenter = [UNUserNotificationCenter currentNotificationCenter];
        currentNotificationCenter.delegate = self;
        UNAuthorizationOptions options = UNAuthorizationOptionAlert | UNAuthorizationOptionSound | UNAuthorizationOptionBadge;
        [currentNotificationCenter requestAuthorizationWithOptions:options completionHandler:^(BOOL granted, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!error) [[UIApplication sharedApplication] registerForRemoteNotifications]; // 注册获得device Token
            });
        }];
    } else if (@available(iOS 8.0, *)) {
        UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeAlert | UIUserNotificationTypeSound;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications]; // 注册获得device Token
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        UIRemoteNotificationType types = UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
#pragma clang diagnostic pop
    }
}
```

> # 注册本地通知

```
#pragma mark 本地通知 最多允许最近本地通知数量是64个，超过限制的被iOS忽略
- (void)registerLocalNotificationWithAlertTime:(NSInteger)alertTime {
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter *currentNotificationCenter = [UNUserNotificationCenter currentNotificationCenter];
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        content.title = [NSString localizedUserNotificationStringForKey:@"本地通知" arguments:nil];
        content.body = [NSString localizedUserNotificationStringForKey:@"body:本地通知"  arguments:nil];
        content.sound = [UNNotificationSound defaultSound];
        // 在alertTime秒后推送本地推送
        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:alertTime repeats:NO];
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"FiveSecond"  content:content trigger:trigger];
        // 添加推送成功后的处理！
        [currentNotificationCenter addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"本地通知" message:@"成功添加推送" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
        }];
    } else {
        // 查看iOS10一下通知请运行后马上按home键进后台
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        // 在alertTime秒后推送本地推送（如果要立即触发，无需设置）
        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:alertTime];
        // 设置本地通知的时区
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        // 设置重复的间隔
        // localNotification.repeatInterval = kCFCalendarUnitSecond;
        // 通知重复提示的单位，可以是天、周、月
        // localNotification.repeatInterval = NSCalendarUnitDay;
        // 通知内容
        localNotification.alertBody =  @"本地通知";
        // 设置通知动作按钮的标题
        localNotification.alertAction = @"查看";
        // 角标数目
        localNotification.applicationIconBadgeNumber = 1;
        // 设置提醒的声音，可以自己添加声音文件，这里设置为默认提示声
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        //设置通知的相关参数信息，这个很重要，可以添加一些标记性内容，方便以后区分和获取通知的信息
        NSDictionary *infoDic = [NSDictionary dictionaryWithObjectsAndKeys:@"DDY",@"name",@"2018",@"time",@"1",@"aid",@"body:本地通知",@"key", nil];
        localNotification.userInfo = infoDic;
        // 将本地通知添加到调度池，定时发送
         [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        // 立即发送
        // [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    }
}
```

> # 取消本地通知

```
- (void)cancleLocalNotification {
    // 获取通知数组
    NSArray *notificaitons = [[UIApplication sharedApplication] scheduledLocalNotifications];
    // 无通知处理
    if (!notificaitons || notificaitons.count <= 0) {
        return;
    }
    // 取消一个特定的通知
    for (UILocalNotification *notify in notificaitons) {
        if ([[notify.userInfo objectForKey:@"name"] isEqualToString:@"DDY"]) {
            
            [[UIApplication sharedApplication] cancelLocalNotification:notify];
            break;
        }
    }
    // 取消所有的本地通知
    // [[UIApplication sharedApplication] cancelAllLocalNotifications];
}
```

> # 远程通知获取deviceToken


```
#pragma mark - 2.用户同意后，获取DeviceToken传给服务器保存
#pragma mark 此函数会在程序每次启动时调用(前提是用户允许通知)
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *token = [NSString stringWithFormat:@"%@", deviceToken];
    token = [token stringByReplacingOccurrencesOfString:@"<" withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@">" withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (token) NSLog(@"保存到本地并上传到服务器 token:%@",token);
    else NSLog(@"需要打开 target -> Capabilities —> Push Notifications 否则获取不到token");
}

#pragma mark 获取DeviceToken失败
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"DDYRegist Error: %@\n\n%@", error, error.code==3000 ? @"Open capabilities->Push Notification" : @" ");
}
```