#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSTableCell.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface DR16RootListController : PSListController
@property (nonatomic, strong) UIView *dockHero;
@property (nonatomic, strong) CAGradientLayer *heroGradient;
@end

@implementation DR16RootListController

- (UITableViewStyle)tableViewStyle {
    return UITableViewStyleInsetGrouped;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"DockReflections16";
    UITableView *table = self.table;
    if (!table) return;
    table.backgroundColor = UIColor.systemGroupedBackgroundColor;

    UIView *header = [[UIView alloc] initWithFrame:
        CGRectMake(0, 0, CGRectGetWidth(table.bounds), 140)];
    header.autoresizingMask = UIViewAutoresizingFlexibleWidth;

    UIView *hero = [[UIView alloc] initWithFrame:
        CGRectMake(16, 16, MAX(0, CGRectGetWidth(header.bounds) - 32), 110)];
    hero.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    hero.layer.cornerRadius = 19.0;
    hero.layer.masksToBounds = YES;
    [header addSubview:hero];
    self.dockHero = hero;

    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.colors = @[
        (__bridge id)[UIColor colorWithRed:0.11 green:0.17 blue:0.25 alpha:1].CGColor,
        (__bridge id)[UIColor colorWithRed:0.16 green:0.30 blue:0.34 alpha:1].CGColor
    ];
    gradient.startPoint = CGPointMake(0, 0);
    gradient.endPoint = CGPointMake(1, 1);
    gradient.frame = hero.bounds;
    [hero.layer insertSublayer:gradient atIndex:0];
    self.heroGradient = gradient;

    UIView *emblem = [UIView new];
    emblem.translatesAutoresizingMaskIntoConstraints = NO;
    emblem.backgroundColor = [UIColor colorWithRed:0.08 green:0.67 blue:0.87 alpha:1.0];
    emblem.layer.cornerRadius = 15;
    [hero addSubview:emblem];

    UIImageView *symbol = [[UIImageView alloc] initWithImage:
        [UIImage systemImageNamed:@"square.stack.3d.up.fill"]];
    symbol.translatesAutoresizingMaskIntoConstraints = NO;
    symbol.tintColor = UIColor.whiteColor;
    symbol.contentMode = UIViewContentModeScaleAspectFit;
    [emblem addSubview:symbol];

    UILabel *heading = [UILabel new];
    heading.translatesAutoresizingMaskIntoConstraints = NO;
    heading.text = @"DockReflections16";
    heading.font = [UIFont systemFontOfSize:22 weight:UIFontWeightBold];
    heading.textColor = UIColor.whiteColor;
    heading.adjustsFontSizeToFitWidth = YES;
    heading.minimumScaleFactor = 0.65;
    [hero addSubview:heading];

    UILabel *subtitle = [UILabel new];
    subtitle.translatesAutoresizingMaskIntoConstraints = NO;
    subtitle.text = @"Reflections for your Dock.";
    subtitle.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
    subtitle.textColor = [UIColor colorWithWhite:1 alpha:0.70];
    subtitle.adjustsFontSizeToFitWidth = YES;
    subtitle.minimumScaleFactor = 0.8;
    [hero addSubview:subtitle];

    [NSLayoutConstraint activateConstraints:@[
        [emblem.leadingAnchor constraintEqualToAnchor:hero.leadingAnchor constant:18],
        [emblem.centerYAnchor constraintEqualToAnchor:hero.centerYAnchor],
        [emblem.widthAnchor constraintEqualToConstant:54],
        [emblem.heightAnchor constraintEqualToConstant:54],
        [symbol.centerXAnchor constraintEqualToAnchor:emblem.centerXAnchor],
        [symbol.centerYAnchor constraintEqualToAnchor:emblem.centerYAnchor],
        [symbol.widthAnchor constraintEqualToConstant:29],
        [symbol.heightAnchor constraintEqualToConstant:29],
        [heading.leadingAnchor constraintEqualToAnchor:emblem.trailingAnchor constant:15],
        [heading.trailingAnchor constraintLessThanOrEqualToAnchor:hero.trailingAnchor constant:-12],
        [heading.bottomAnchor constraintEqualToAnchor:hero.centerYAnchor constant:-2],
        [subtitle.leadingAnchor constraintEqualToAnchor:heading.leadingAnchor],
        [subtitle.topAnchor constraintEqualToAnchor:hero.centerYAnchor constant:6],
        [subtitle.trailingAnchor constraintLessThanOrEqualToAnchor:hero.trailingAnchor constant:-12]
    ]];
    table.tableHeaderView = header;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.heroGradient.frame = self.dockHero.bounds;
}

- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
    }
    return _specifiers;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    NSString *identifier = [[self specifierAtIndexPath:indexPath] propertyForKey:@"id"];
    if ([identifier isEqualToString:@"githubLink"]) {
        cell.textLabel.hidden = YES;
        if ([cell isKindOfClass:[PSTableCell class]]) {
            ((PSTableCell *)cell).titleLabel.hidden = YES;
        }
        if (![cell.contentView viewWithTag:55116]) {
            UIStackView *stack = [UIStackView new];
            stack.tag = 55116;
            stack.axis = UILayoutConstraintAxisHorizontal;
            stack.alignment = UIStackViewAlignmentCenter;
            stack.spacing = 9;
            stack.userInteractionEnabled = NO;
            stack.translatesAutoresizingMaskIntoConstraints = NO;

            UIImageView *glyph = [[UIImageView alloc] initWithImage:
                [UIImage systemImageNamed:@"chevron.left.forwardslash.chevron.right"]];
            glyph.tintColor = UIColor.systemTealColor;
            [glyph.widthAnchor constraintEqualToConstant:21].active = YES;
            [glyph.heightAnchor constraintEqualToConstant:20].active = YES;
            UILabel *label = [UILabel new];
            label.text = @"View on GitHub";
            label.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
            label.textColor = UIColor.systemTealColor;
            [stack addArrangedSubview:glyph];
            [stack addArrangedSubview:label];
            [cell.contentView addSubview:stack];
            [NSLayoutConstraint activateConstraints:@[
                [stack.centerXAnchor constraintEqualToAnchor:cell.contentView.centerXAnchor],
                [stack.centerYAnchor constraintEqualToAnchor:cell.contentView.centerYAnchor],
                [stack.leadingAnchor constraintGreaterThanOrEqualToAnchor:cell.contentView.leadingAnchor constant:16],
                [stack.trailingAnchor constraintLessThanOrEqualToAnchor:cell.contentView.trailingAnchor constant:-16]
            ]];
        }
        cell.accessibilityLabel = @"View DockReflections16 on GitHub";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView
  didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = [[self specifierAtIndexPath:indexPath] propertyForKey:@"id"];
    if ([identifier isEqualToString:@"githubLink"]) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self openRepository:nil];
        return;
    }
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (void)openRepository:(id)sender {
    NSURL *url = [NSURL URLWithString:@"https://github.com/551UK/DockReflections16"];
    [UIApplication.sharedApplication openURL:url options:@{} completionHandler:nil];
}

@end
