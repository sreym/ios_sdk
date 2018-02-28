//
//  spark-ios-sdk
//
//  Created by spark on 16/02/2018.
//  Copyright © 2018 Hola. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>

// Preview-enabled customized view controller.
// Inherit this class in your NotificationContentExtension.
@interface SparkPreviewNotificationViewController : UIViewController
@end
// Remote notification handler class (remote notifications only).
// Inherit this class in your NotificationServiceExtension.
@interface SparkPreviewNotificationService : UNNotificationServiceExtension
@end

@interface SparkAPI : NSObject

// Returns SparkAPI singleton instance. First call will initialize SDK, thus
// providing customer id is mandatory. Consequtive calls can omit passing extra
// argument.
//     @param customerId - id used during customer registration on
//         Spark Control Panel (https://holaspark.com/cp)
+ (SparkAPI *_Nonnull)getAPI:(NSString *_Nullable)customerId;

// Register your application within notification system. Call this method once
// in didFinishLaunchingWithOptions implementation of UIApplicationDelegate
// protocol.
//     @param options - list of authorization options, e.g.:
//         UNAuthorizationOptionAlert|UNAuthorizationOptionSound
//     @param usingRemoteNotifications - defines whether your app targets for
//         both local and remote notifications: YES=local+remote, NO=localonly
//         NOTE: if your app is intended to use remote notifications, you must
//         implement didRegisterForRemoteNotificationsWithDeviceToken and
//         didFailToRegisterForRemoteNotificationsWithError methods of
//         UIApplicationDelegate protocol.
//     @param withCompletionBlock - registration result providing you with
//         error object if operation failed.
- (void)registerForNotifications:(UNAuthorizationOptions)options
    usingRemoteNotifications:(BOOL)remote
    withCompletionBlock:(void (^_Nonnull)(NSError *_Nullable))ondone;

// Send local notification with preview for provided video url to the
// notification center.
//     @param forVideoUrl - media resource for which video preview is to be
//         generated and shown in the notification
//     @param withTitle - UNMutableNotificationContent.title
//     @param withSubtitle (optional) - UNMutableNotificationContent.subtitle
//     @param withBody - UNMutableNotificationContent.body
//     @param withTriggerOn - trigger that defines the moment of time when to
//         show this notification to the user, e.g. can be one of:
//         - UNTimeIntervalNotificationTrigger
//         - UNCalendarNotificationTrigger
//         - UNLocationNotificationTrigger
//         - UNPushNotificationTrigger
//     @param withBeforeSendBlock (optional) - code block called after preview
//         is loaded and just before the notification is scheduled to the
//         notification center; use it to perform custom operations upon
//         notification payload. Note: returning "NO" within the code block
//         will not send out the notification, this way you can take the full
//         control over notification yourself.
//     @param withCompletionBlock (optional) - code block called to indicate
//         the status of operation, NSError object will indicate the reason of
//         a failure (preview loading failed, notification unable to schedule
//         etc) or "nil" in case of the success.
- (void)sendPreviewNotification:(NSURL *_Nonnull)forVideoUrl
    withTitle:(NSString *_Nonnull)title
    withSubtitle:(NSString *_Nullable)subtitle
    withBody:(NSString *_Nonnull)body
    withTriggerOn:(UNNotificationTrigger *_Nonnull)trigger
    withBeforeSendBlock: (BOOL (^_Nullable)(
        UNMutableNotificationContent *_Nonnull,
        UNNotificationSettings *_Nonnull))onbeforesend
    withCompletionBlock: (void (^_Nullable)(NSError *_Nullable))ondone;

@end
