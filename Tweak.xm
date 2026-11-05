#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import <math.h>

// DockReflections16: standalone rootless reflection effect.
static char kReflectionHost;
static char kRefreshPending;

static UIView *IconImageView(UIView *icon) {
    SEL selector = NSSelectorFromString(@"iconImageView");
    if ([icon respondsToSelector:selector]) {
        id value = ((id (*)(id, SEL))objc_msgSend)(icon, selector);
        if ([value isKindOfClass:[UIView class]]) return value;
    }
    Class imageClass = objc_getClass("SBIconImageView");
    NSMutableArray *queue = [NSMutableArray arrayWithObject:icon];
    NSUInteger processed = 0;
    while (queue.count && processed++ < 80) {
        UIView *view = queue.firstObject;
        [queue removeObjectAtIndex:0];
        if (imageClass && [view isKindOfClass:imageClass]) return view;
        [queue addObjectsFromArray:view.subviews];
    }
    return nil;
}

static UIImage *CaptureIcon(UIView *view) {
    CGSize size = view.bounds.size;
    if (size.width < 12 || size.height < 12 || size.width > 240 || size.height > 240) return nil;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (!context) {
        UIGraphicsEndImageContext();
        return nil;
    }
    if (![view drawViewHierarchyInRect:(CGRect){CGPointZero, size} afterScreenUpdates:NO]) {
        [view.layer renderInContext:context];
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

static void CollectIcons(UIView *root, NSMutableArray *result, NSUInteger depth) {
    if (!root || depth > 12 || root.hidden || root.alpha < 0.01) return;
    Class iconClass = objc_getClass("SBIconView");
    if (iconClass && [root isKindOfClass:iconClass]) {
        [result addObject:root];
        return;
    }
    for (UIView *child in root.subviews) CollectIcons(child, result, depth + 1);
}

static void RemoveReflections(UIView *dock) {
    UIView *host = objc_getAssociatedObject(dock, &kReflectionHost);
    [host removeFromSuperview];
    objc_setAssociatedObject(dock, &kReflectionHost, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

static void DrawReflection(UIView *host, UIImage *image, CGRect frame) {
    CGFloat reflectionHeight = frame.size.height * 0.34;
    if (reflectionHeight < 2) return;
    UIView *clip = [[UIView alloc] initWithFrame:CGRectMake(frame.origin.x,
        CGRectGetMaxY(frame), frame.size.width, reflectionHeight)];
    clip.clipsToBounds = YES;
    clip.userInteractionEnabled = NO;

    UIImageView *mirror = [[UIImageView alloc] initWithImage:image];
    mirror.contentMode = UIViewContentModeScaleToFill;
    mirror.bounds = CGRectMake(0, 0, frame.size.width, frame.size.height);
    mirror.center = CGPointMake(frame.size.width / 2, frame.size.height / 2);
    mirror.transform = CGAffineTransformMakeScale(1, -1);
    [clip addSubview:mirror];

    CAGradientLayer *fade = [CAGradientLayer layer];
    fade.frame = clip.bounds;
    fade.startPoint = CGPointMake(0.5, 0);
    fade.endPoint = CGPointMake(0.5, 1);
    fade.colors = @[
        (__bridge id)[UIColor colorWithWhite:1 alpha:0.45].CGColor,
        (__bridge id)[UIColor colorWithWhite:1 alpha:0.17].CGColor,
        (__bridge id)[UIColor colorWithWhite:1 alpha:0].CGColor
    ];
    fade.locations = @[@0, @0.52, @1];
    clip.layer.mask = fade;
    [host addSubview:clip];
}

static void UpdateReflections(UIView *dock) {
    if (!dock.window || dock.hidden || dock.alpha < 0.01) {
        RemoveReflections(dock);
        return;
    }
    NSMutableArray *icons = [NSMutableArray array];
    CollectIcons(dock, icons, 0);
    if (!icons.count) {
        RemoveReflections(dock);
        return;
    }

    // Mount above the dock's icon list so reflections aren't clipped by it.
    UIView *parent = dock.superview;
    for (NSUInteger i = 0; parent && parent.clipsToBounds && i < 8 &&
         parent.superview; i++) parent = parent.superview;
    if (!parent) return;

    UIView *host = objc_getAssociatedObject(dock, &kReflectionHost);
    if (!host || host.superview != parent) {
        [host removeFromSuperview];
        host = [[UIView alloc] initWithFrame:parent.bounds];
        host.backgroundColor = UIColor.clearColor;
        host.userInteractionEnabled = NO;
        host.clipsToBounds = NO;
        host.autoresizingMask = UIViewAutoresizingFlexibleWidth |
                                 UIViewAutoresizingFlexibleHeight;
        [parent addSubview:host];
        objc_setAssociatedObject(dock, &kReflectionHost, host, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    for (UIView *subview in [host.subviews copy]) [subview removeFromSuperview];

    for (UIView *icon in icons) {
        UIView *image = IconImageView(icon);
        if (!image || image.hidden || image.alpha < 0.01) continue;
        CGRect inDock = [image convertRect:image.bounds toView:dock];
        if (!isfinite(inDock.origin.x) || !isfinite(inDock.origin.y) ||
            CGRectGetMaxX(inDock) <= 0 || CGRectGetMinX(inDock) >= dock.bounds.size.width) continue;
        UIImage *snapshot = CaptureIcon(image);
        if (!snapshot) continue;
        DrawReflection(host, snapshot, [image convertRect:image.bounds toView:parent]);
    }
}

static void ScheduleRefresh(UIView *dock) {
    if ([objc_getAssociatedObject(dock, &kRefreshPending) boolValue]) return;
    objc_setAssociatedObject(dock, &kRefreshPending, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    dispatch_async(dispatch_get_main_queue(), ^{
        objc_setAssociatedObject(dock, &kRefreshPending, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        UpdateReflections(dock);
    });
}

%group DockReflections
%hook SBDockIconListView
- (void)layoutSubviews {
    %orig;
    ScheduleRefresh((UIView *)self);
}
- (void)didMoveToWindow {
    %orig;
    ScheduleRefresh((UIView *)self);
}
%end
%end

%ctor {
    @autoreleasepool {
        if (@available(iOS 16.0, *)) {
            if (objc_getClass("SBDockIconListView")) %init(DockReflections);
        }
    }
}
