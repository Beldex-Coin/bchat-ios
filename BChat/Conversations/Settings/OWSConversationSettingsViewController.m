//
//  Copyright (c) 2019 Open Whisper Systems. All rights reserved.
//

#import "OWSConversationSettingsViewController.h"
#import "OWSSoundSettingsViewController.h"
#import "BChat-Swift.h"
#import "UIFont+OWS.h"
#import "UIView+OWS.h"
#import <Curve25519Kit/Curve25519.h>
#import <SignalCoreKit/NSDate+OWS.h>
#import <BChatMessagingKit/Environment.h>
#import <SignalUtilitiesKit/OWSProfileManager.h>
#import <BChatMessagingKit/OWSSounds.h>
#import <SignalUtilitiesKit/SignalUtilitiesKit-Swift.h>
#import <SignalUtilitiesKit/UIUtil.h>
#import <BChatMessagingKit/OWSDisappearingConfigurationUpdateInfoMessage.h>
#import <BChatMessagingKit/OWSDisappearingMessagesConfiguration.h>
#import <BChatMessagingKit/OWSPrimaryStorage.h>
#import <BChatMessagingKit/TSGroupThread.h>
#import <BChatMessagingKit/TSOutgoingMessage.h>
#import <BChatMessagingKit/TSThread.h>

@import ContactsUI;
@import PromiseKit;

NS_ASSUME_NONNULL_BEGIN

CGFloat kIconViewLength = 24;

@interface OWSConversationSettingsViewController () <OWSSheetViewControllerDelegate>

@property (nonatomic) TSThread *thread;
@property (nonatomic) YapDatabaseConnection *uiDatabaseConnection;
@property (nonatomic, readonly) YapDatabaseConnection *editingDatabaseConnection;
@property (nonatomic) NSArray<NSNumber *> *disappearingMessagesDurations;
@property (nonatomic) OWSDisappearingMessagesConfiguration *disappearingMessagesConfiguration;
@property (nullable, nonatomic) MediaGallery *mediaGallery;
@property (nonatomic, readonly) UIImageView *avatarView;
@property (nonatomic, readonly) UILabel *disappearingMessagesDurationLabel;
@property (nonatomic) UILabel *displayNameLabel;
@property (nonatomic) SNTextField *displayNameTextField;
@property (nonatomic) UIView *displayNameContainer;
@property (nonatomic) BOOL isEditingDisplayName;

@end

#pragma mark -

@implementation OWSConversationSettingsViewController

- (instancetype)init
{
    self = [super init];
    if (!self) {
        return self;
    }

    [self commonInit];

    return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (!self) {
        return self;
    }

    [self commonInit];

    return self;
}

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (!self) {
        return self;
    }

    [self commonInit];

    return self;
}

- (void)commonInit
{

    [self observeNotifications];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Dependencies

- (TSAccountManager *)tsAccountManager
{
    OWSAssertDebug(SSKEnvironment.shared.tsAccountManager);

    return SSKEnvironment.shared.tsAccountManager;
}

- (OWSProfileManager *)profileManager
{
    return [OWSProfileManager sharedManager];
}

#pragma mark

- (void)observeNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(identityStateDidChange:)
                                                 name:kNSNotificationName_IdentityStateDidChange
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(otherUsersProfileDidChange:)
                                                 name:kNSNotificationName_OtherUsersProfileDidChange
                                               object:nil];
}

- (YapDatabaseConnection *)editingDatabaseConnection
{
    return [OWSPrimaryStorage sharedManager].dbReadWriteConnection;
}

- (nullable NSString *)threadName
{
    NSString *threadName = self.thread.name;
    if ([self.thread isKindOfClass:TSContactThread.class]) {
        TSContactThread *thread = (TSContactThread *)self.thread;
        return [[LKStorage.shared getContactWithBChatID:thread.contactBChatID] displayNameFor:SNContactContextRegular] ?: @"Anonymous";
    } else if (threadName.length == 0 && [self isGroupThread]) {
        threadName = [MessageStrings newGroupDefaultTitle];
    }
    return threadName;
}

- (BOOL)isGroupThread
{
    return [self.thread isKindOfClass:[TSGroupThread class]];
}

- (BOOL)isOpenGroup
{
    if ([self isGroupThread]) {
        TSGroupThread *thread = (TSGroupThread *)self.thread;
        return thread.isOpenGroup;
    }
    return false;
}

-(BOOL)isClosedGroup
{
    if (self.isGroupThread) {
        TSGroupThread *thread = (TSGroupThread *)self.thread;
        return thread.groupModel.groupType == closedGroup;
    }
    return false;
}

- (void)configureWithThread:(TSThread *)thread uiDatabaseConnection:(YapDatabaseConnection *)uiDatabaseConnection
{
    OWSAssertDebug(thread);
    self.thread = thread;
    self.uiDatabaseConnection = uiDatabaseConnection;
}

#pragma mark - ContactEditingDelegate

- (void)didFinishEditingContact
{
    [self updateTableContents];

    OWSLogDebug(@"");
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - CNContactViewControllerDelegate

- (void)contactViewController:(CNContactViewController *)viewController
       didCompleteWithContact:(nullable CNContact *)contact
{
    [self updateTableContents];

    if (contact) {
        // Saving normally returns you to the "Show Contact" view
        // which we're not interested in, so we skip it here. There is
        // an unfortunate blip of the "Show Contact" view on slower devices.
        OWSLogDebug(@"completed editing contact.");
        [self dismissViewControllerAnimated:NO completion:nil];
    } else {
        OWSLogDebug(@"canceled editing contact.");
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.displayNameLabel = [UILabel new];
    self.displayNameLabel.textColor = LKColors.titleColor;//LKColors.text;
    self.displayNameLabel.font = [LKFonts boldOpenSansOfSize:18];//[UIFont boldSystemFontOfSize:LKValues.largeFontSize];
    self.displayNameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.displayNameLabel.textAlignment = NSTextAlignmentCenter;
        
    self.displayNameTextField = [[SNTextField alloc] initWithPlaceholder:@"Enter a name" usesDefaultHeight:NO];
    self.displayNameTextField.textAlignment = NSTextAlignmentCenter;
    self.displayNameTextField.accessibilityLabel = @"Edit name text field";
    self.displayNameTextField.alpha = 0;
    self.displayNameTextField.delegate = self;
    self.displayNameContainer = [UIView new];
    self.displayNameContainer.accessibilityLabel = @"Edit name text field";
    self.displayNameContainer.isAccessibilityElement = YES;
    [self.displayNameContainer autoSetDimension:ALDimensionWidth toSize:200];
    [self.displayNameContainer autoSetDimension:ALDimensionHeight toSize:40];
    [self.displayNameContainer addSubview:self.displayNameLabel];
    [self.displayNameLabel autoPinToEdgesOfView:self.displayNameContainer];
    [self.displayNameContainer addSubview:self.displayNameTextField];
    [self.displayNameTextField autoPinToEdgesOfView:self.displayNameContainer];
    
    if ([self.thread isKindOfClass:TSContactThread.class]) {
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showEditNameUI)];
        [self.displayNameContainer addGestureRecognizer:tapGestureRecognizer];
    }
    
    self.tableView.estimatedRowHeight = 45;
    self.tableView.rowHeight = UITableViewAutomaticDimension;

    _disappearingMessagesDurationLabel = [UILabel new];
    SET_SUBVIEW_ACCESSIBILITY_IDENTIFIER(self, _disappearingMessagesDurationLabel);

    self.disappearingMessagesDurations = [OWSDisappearingMessagesConfiguration validDurationsSeconds];

    self.disappearingMessagesConfiguration =
        [OWSDisappearingMessagesConfiguration fetchObjectWithUniqueID:self.thread.uniqueId];

    if (!self.disappearingMessagesConfiguration) {
        self.disappearingMessagesConfiguration =
            [[OWSDisappearingMessagesConfiguration alloc] initDefaultWithThreadId:self.thread.uniqueId];
    }

    [self updateTableContents];
    
    NSString *title;
    if ([self.thread isKindOfClass:[TSContactThread class]]) {
        title = @"Contact Info";//NSLocalizedString(@"Settings", @"");
    } else {
        title = @"Group Info";//NSLocalizedString(@"Group Settings", @"");
    }
    if (self.thread.isNoteToSelf) {
        title = @"Note to self";
    }
    
    [LKViewControllerUtilities setUpDefaultBChatStyleForVC:self withTitle:title customBackButton:YES];
    
    self.tableView.backgroundColor = [LKColors mainBackGroundColor2];//UIColor.clearColor;
    
    if ([self.thread isKindOfClass:TSContactThread.class]) {
        [self updateNavBarButtons];
    }
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    //limit the size :
    int limit = 26;
    return !([textField.text length]>limit && [string length] > range.length);
}

- (void)updateTableContents
{
    OWSTableContents *contents = [OWSTableContents new];
    contents.title = NSLocalizedString(@"CONVERSATION_SETTINGS", @"title for conversation settings screen");

    BOOL isNoteToSelf = self.thread.isNoteToSelf;
    
    __weak OWSConversationSettingsViewController *weakSelf = self;

    OWSTableSection *section = [OWSTableSection new];

    section.customHeaderView = [self mainSectionHeader];
    section.customHeaderHeight = @(UITableViewAutomaticDimension);
    
    if ([self.thread isKindOfClass:TSContactThread.class]) {
        [section addItem:[OWSTableItem itemWithCustomCellBlock:^{
            UITableViewCell *cell =
            [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
            [OWSTableItem configureCell:cell];
            OWSConversationSettingsViewController *strongSelf = weakSelf;
            OWSCAssertDebug(strongSelf);
            cell.preservesSuperviewLayoutMargins = YES;
            cell.contentView.preservesSuperviewLayoutMargins = YES;
            
            UIImageView *iconView = [strongSelf viewForIconWithName:@"bchat_chat_setting"];
            
            UILabel *rowLabel = [UILabel new];
            rowLabel.text = ((TSContactThread *)self.thread).contactBChatID;//NSLocalizedString(@"SETTINGS_ITEM_NOTIFICATION_SOUND",
            //@"Label for settings view that allows user to change the notification sound.");
            rowLabel.textColor = LKColors.titleColor;
            rowLabel.font = [LKFonts OpenSansOfSize:16];
            rowLabel.lineBreakMode = NSLineBreakByTruncatingTail;
            rowLabel.numberOfLines = 2;
            
            UIStackView *contentRow =
            [[UIStackView alloc] initWithArrangedSubviews:@[ iconView, rowLabel ]];
            contentRow.spacing = strongSelf.iconSpacing;
            contentRow.alignment = UIStackViewAlignmentCenter;
            [cell.contentView addSubview:contentRow];
            [contentRow autoPinEdgesToSuperviewMargins];
            
            UIImageView *dot =[[UIImageView alloc] initWithFrame:CGRectMake(0,0,18,18)];
            dot.image=[UIImage imageNamed:@"chat_setting_copy"];
            cell.accessoryView = dot;
            cell.accessibilityIdentifier = ACCESSIBILITY_IDENTIFIER_WITH_NAME(
                                                                              OWSConversationSettingsViewController, @"copy_bchat_id");
            return cell;
        } actionBlock:^{
            [weakSelf copyBChatID];
        }]];
        
    }
        
    // All media
    [section addItem:[OWSTableItem itemWithCustomCellBlock:^{
        return [weakSelf
            disclosureCellWithName:MediaStrings.allMedia
                iconName:@"ic_allmedia"
           accessibilityIdentifier:ACCESSIBILITY_IDENTIFIER_WITH_NAME(OWSConversationSettingsViewController, @"all_media")];
    } actionBlock:^{
        [weakSelf showMediaGallery];
    }]];
    
    // Invite button
    if (self.isOpenGroup) {
        [section addItem:[OWSTableItem itemWithCustomCellBlock:^{
            return [weakSelf
                disclosureCellWithName:NSLocalizedString(@"vc_conversation_settings_invite_button_title", "")
                              iconName:@"ic_plus_24"
               accessibilityIdentifier:ACCESSIBILITY_IDENTIFIER_WITH_NAME(OWSConversationSettingsViewController, @"invite")];
        } actionBlock:^{
            [weakSelf inviteUsersToOpenGroup];
        }]];
    }

    // Search
    [section addItem:[OWSTableItem itemWithCustomCellBlock:^{
        NSString *title = NSLocalizedString(@"CONVERSATION_SETTINGS_SEARCH",
            @"Table cell label in conversation settings which returns the user to the "
            @"conversation with 'search mode' activated");
        return [weakSelf
            disclosureCellWithName:title
                iconName:@"ic_search_setting"
           accessibilityIdentifier:ACCESSIBILITY_IDENTIFIER_WITH_NAME(OWSConversationSettingsViewController, @"search")];
    } actionBlock:^{
        [weakSelf tappedConversationSearch];
    }]];
    
    // Disappearing messages
    if (![self isOpenGroup] && !self.thread.isBlocked) {
        [section addItem:[OWSTableItem itemWithCustomCellBlock:^{
            UITableViewCell *cell = [OWSTableItem newCell];
            OWSConversationSettingsViewController *strongSelf = weakSelf;
            OWSCAssertDebug(strongSelf);
            cell.preservesSuperviewLayoutMargins = YES;
            cell.contentView.preservesSuperviewLayoutMargins = YES;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

            NSString *iconName
                = (strongSelf.disappearingMessagesConfiguration.isEnabled ? @"ic_timer" : @"ic_timer_disabled");
            UIImageView *iconView = [strongSelf viewForIconWithName:iconName];

            UILabel *rowLabel = [UILabel new];
            rowLabel.text = NSLocalizedString(
                @"DISAPPEARING_MESSAGES", @"table cell label in conversation settings");
            rowLabel.textColor = LKColors.titleColor;
            rowLabel.font = [LKFonts OpenSansOfSize:16];
            rowLabel.lineBreakMode = NSLineBreakByTruncatingTail;

            UISwitch *switchView = [UISwitch new];
            switchView.on = strongSelf.disappearingMessagesConfiguration.isEnabled;
            [switchView addTarget:strongSelf action:@selector(disappearingMessagesSwitchValueDidChange:)
                forControlEvents:UIControlEventValueChanged];

            UIStackView *topRow =
                [[UIStackView alloc] initWithArrangedSubviews:@[ iconView, rowLabel, switchView ]];
            topRow.spacing = strongSelf.iconSpacing;
            topRow.alignment = UIStackViewAlignmentCenter;
            [cell.contentView addSubview:topRow];
            [topRow autoPinEdgesToSuperviewMarginsExcludingEdge:ALEdgeBottom];

            UILabel *subtitleLabel = [UILabel new];
            NSString *displayName;
            if (self.thread.isGroupThread) {
                displayName = @"the group";
            } else {
                TSContactThread *thread = (TSContactThread *)self.thread;
                displayName = [[LKStorage.shared getContactWithBChatID:thread.contactBChatID] displayNameFor:SNContactContextRegular] ?: @"anonymous";
            }
            subtitleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"When enabled, messages between you and %@ will disappear after they have been seen.", ""), displayName];
            subtitleLabel.textColor = LKColors.chatSettingsGrayColor;
            subtitleLabel.font = [LKFonts semiOpenSansOfSize:12];
            subtitleLabel.numberOfLines = 0;
            subtitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
            [cell.contentView addSubview:subtitleLabel];
            [subtitleLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:topRow withOffset:8];
            [subtitleLabel autoPinEdge:ALEdgeLeading toEdge:ALEdgeLeading ofView:rowLabel];
            [subtitleLabel autoPinTrailingToSuperviewMargin];
            [subtitleLabel autoPinBottomToSuperviewMargin];

            cell.userInteractionEnabled = !strongSelf.hasLeftGroup;

            cell.accessibilityIdentifier = ACCESSIBILITY_IDENTIFIER_WITH_NAME(OWSConversationSettingsViewController, @"disappearing_messages");

            return cell;
         } customRowHeight:UITableViewAutomaticDimension actionBlock:nil]];

        if (self.disappearingMessagesConfiguration.isEnabled) {
            [section addItem:[OWSTableItem itemWithCustomCellBlock:^{
                UITableViewCell *cell = [OWSTableItem newCell];
                OWSConversationSettingsViewController *strongSelf = weakSelf;
                OWSCAssertDebug(strongSelf);
                cell.preservesSuperviewLayoutMargins = YES;
                cell.contentView.preservesSuperviewLayoutMargins = YES;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;

                UIImageView *iconView = [strongSelf viewForIconWithName:@"ic_timer"];

                UILabel *rowLabel = strongSelf.disappearingMessagesDurationLabel;
                [strongSelf updateDisappearingMessagesDurationLabel];
                rowLabel.textColor = LKColors.titleColor;
                rowLabel.font = [LKFonts OpenSansOfSize:16];
                // don't truncate useful duration info which is in the tail
                rowLabel.lineBreakMode = NSLineBreakByTruncatingHead;

                UIStackView *topRow =
                    [[UIStackView alloc] initWithArrangedSubviews:@[ iconView, rowLabel ]];
                topRow.spacing = strongSelf.iconSpacing;
                topRow.alignment = UIStackViewAlignmentCenter;
                [cell.contentView addSubview:topRow];
                [topRow autoPinEdgesToSuperviewMarginsExcludingEdge:ALEdgeBottom];

                UISlider *slider = [UISlider new];
                slider.maximumValue = (float)(strongSelf.disappearingMessagesDurations.count - 1);
                slider.minimumValue = 0;
                slider.tintColor = LKColors.accent;
                slider.continuous = NO;
                slider.value = strongSelf.disappearingMessagesConfiguration.durationIndex;
                [slider addTarget:strongSelf action:@selector(durationSliderDidChange:)
                    forControlEvents:UIControlEventValueChanged];
                [cell.contentView addSubview:slider];
                [slider autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:topRow withOffset:6];
                [slider autoPinEdge:ALEdgeLeading toEdge:ALEdgeLeading ofView:rowLabel];
                [slider autoPinTrailingToSuperviewMargin];
                [slider autoPinBottomToSuperviewMargin];
                
                cell.userInteractionEnabled = !strongSelf.hasLeftGroup;

                cell.accessibilityIdentifier = ACCESSIBILITY_IDENTIFIER_WITH_NAME(
                    OWSConversationSettingsViewController, @"disappearing_messages_duration");

                return cell;
            } customRowHeight:UITableViewAutomaticDimension actionBlock:nil]];
        }
    }

    [contents addSection:section];

    // Closed group settings
    __block BOOL isUserMember = NO;
    if (self.isGroupThread) {
        NSString *userPublicKey = [SNGeneralUtilities getUserPublicKey];
        isUserMember = [(TSGroupThread *)self.thread isUserMemberInGroup:userPublicKey];
    }
    if (self.isGroupThread && self.isClosedGroup && isUserMember) {
        [section addItem:[OWSTableItem itemWithCustomCellBlock:^{
            UITableViewCell *cell =
                [weakSelf disclosureCellWithName:NSLocalizedString(@"EDIT_GROUP_ACTION", @"table cell label in conversation settings")
                    iconName:@"table_ic_group_edit"
                    accessibilityIdentifier:ACCESSIBILITY_IDENTIFIER_WITH_NAME(OWSConversationSettingsViewController, @"edit_group")];
            cell.userInteractionEnabled = !weakSelf.hasLeftGroup;
            return cell;
        } actionBlock:^{
            [weakSelf editGroup];
        }]];
        [section addItem:[OWSTableItem itemWithCustomCellBlock:^{
            UITableViewCell *cell =
                [weakSelf disclosureCellWithName:NSLocalizedString(@"LEAVE_GROUP_ACTION", @"table cell label in conversation settings")
                    iconName:@"table_ic_group_leave"
                    accessibilityIdentifier:ACCESSIBILITY_IDENTIFIER_WITH_NAME(OWSConversationSettingsViewController, @"leave_group")];
            cell.userInteractionEnabled = !weakSelf.hasLeftGroup;

            return cell;
        } actionBlock:^{
            [weakSelf didTapLeaveGroup];
        }]];
    }
    
    if (!isNoteToSelf) {
        // Notification sound
        [section addItem:[OWSTableItem itemWithCustomCellBlock:^{
            UITableViewCell *cell =
                [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
            [OWSTableItem configureCell:cell];
            OWSConversationSettingsViewController *strongSelf = weakSelf;
            OWSCAssertDebug(strongSelf);
            cell.preservesSuperviewLayoutMargins = YES;
            cell.contentView.preservesSuperviewLayoutMargins = YES;

            UIImageView *iconView = [strongSelf viewForIconWithName:@"table_ic_notification_sound"];

            UILabel *rowLabel = [UILabel new];
            rowLabel.text = NSLocalizedString(@"SETTINGS_ITEM_NOTIFICATION_SOUND",
                @"Label for settings view that allows user to change the notification sound.");
            rowLabel.textColor = LKColors.titleColor;
            rowLabel.font = [LKFonts OpenSansOfSize:16];
            rowLabel.lineBreakMode = NSLineBreakByTruncatingTail;

            UIStackView *contentRow =
                [[UIStackView alloc] initWithArrangedSubviews:@[ iconView, rowLabel ]];
            contentRow.spacing = strongSelf.iconSpacing;
            contentRow.alignment = UIStackViewAlignmentCenter;
            [cell.contentView addSubview:contentRow];
            [contentRow autoPinEdgesToSuperviewMargins];

            OWSSound sound = [OWSSounds notificationSoundForThread:strongSelf.thread];
            cell.detailTextLabel.text = [OWSSounds displayNameForSound:sound];

            cell.accessibilityIdentifier = ACCESSIBILITY_IDENTIFIER_WITH_NAME(
                OWSConversationSettingsViewController, @"notifications");

            return cell;
        }
        customRowHeight:UITableViewAutomaticDimension
        actionBlock:^{
            OWSSoundSettingsViewController *vc = [OWSSoundSettingsViewController new];
            vc.thread = weakSelf.thread;
            [weakSelf.navigationController pushViewController:vc animated:YES];
        }]];
        
        if (self.isGroupThread) {
            // Notification Settings
            [section addItem:[OWSTableItem itemWithCustomCellBlock:^{
                UITableViewCell *cell = [OWSTableItem newCell];
                OWSConversationSettingsViewController *strongSelf = weakSelf;
                OWSCAssertDebug(strongSelf);
                cell.preservesSuperviewLayoutMargins = YES;
                cell.contentView.preservesSuperviewLayoutMargins = YES;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;

                UIImageView *iconView = [strongSelf viewForIconWithName:@"NotifyMentions"];

                UILabel *rowLabel = [UILabel new];
                rowLabel.text = NSLocalizedString(@"vc_conversation_settings_notify_for_mentions_only_title", @"");
                rowLabel.textColor = LKColors.titleColor;
                rowLabel.font = [LKFonts OpenSansOfSize:16];
                rowLabel.lineBreakMode = NSLineBreakByTruncatingTail;

                UISwitch *switchView = [UISwitch new];
                switchView.on = ((TSGroupThread *)strongSelf.thread).isOnlyNotifyingForMentions;
                [switchView addTarget:strongSelf action:@selector(notifyForMentionsOnlySwitchValueDidChange:)
                    forControlEvents:UIControlEventValueChanged];

                UIStackView *topRow =
                    [[UIStackView alloc] initWithArrangedSubviews:@[ iconView, rowLabel, switchView ]];
                topRow.spacing = strongSelf.iconSpacing;
                topRow.alignment = UIStackViewAlignmentCenter;
                [cell.contentView addSubview:topRow];
                [topRow autoPinEdgesToSuperviewMarginsExcludingEdge:ALEdgeBottom];

                UILabel *subtitleLabel = [UILabel new];
                subtitleLabel.text = NSLocalizedString(@"vc_conversation_settings_notify_for_mentions_only_explanation", @"");
                subtitleLabel.textColor = LKColors.text;
                subtitleLabel.font = [UIFont systemFontOfSize:LKValues.smallFontSize];
                subtitleLabel.numberOfLines = 0;
                subtitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
                [cell.contentView addSubview:subtitleLabel];
                [subtitleLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:topRow withOffset:8];
                [subtitleLabel autoPinEdge:ALEdgeLeading toEdge:ALEdgeLeading ofView:rowLabel];
                [subtitleLabel autoPinTrailingToSuperviewMargin];
                [subtitleLabel autoPinBottomToSuperviewMargin];

                cell.userInteractionEnabled = !strongSelf.hasLeftGroup;

                cell.accessibilityIdentifier = ACCESSIBILITY_IDENTIFIER_WITH_NAME(OWSConversationSettingsViewController, @"notify_for_mentions_only");

                return cell;
             } customRowHeight:UITableViewAutomaticDimension actionBlock:nil]];
        }
        
        // Mute thread
        [section addItem:[OWSTableItem itemWithCustomCellBlock:^{
            OWSConversationSettingsViewController *strongSelf = weakSelf;
            if (!strongSelf) { return [UITableViewCell new]; }

            NSString *cellTitle = NSLocalizedString(@"CONVERSATION_SETTINGS_MUTE_LABEL", @"label for 'mute thread' cell in conversation settings");
            UITableViewCell *cell = [strongSelf disclosureCellWithName:cellTitle iconName:@"Mute"
                accessibilityIdentifier:ACCESSIBILITY_IDENTIFIER_WITH_NAME(OWSConversationSettingsViewController, @"mute")];

            cell.selectionStyle = UITableViewCellSelectionStyleNone;

            UISwitch *muteConversationSwitch = [UISwitch new];
            NSDate *mutedUntilDate = strongSelf.thread.mutedUntilDate;
            NSDate *now = [NSDate date];
            muteConversationSwitch.on = (mutedUntilDate != nil && [mutedUntilDate timeIntervalSinceDate:now] > 0);
            [muteConversationSwitch addTarget:strongSelf action:@selector(handleMuteSwitchToggled:)
                forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = muteConversationSwitch;

            return cell;
        } actionBlock:nil]];
    }
    
    // Block contact
    if (!isNoteToSelf && [self.thread isKindOfClass:TSContactThread.class]) {
        [section addItem:[OWSTableItem itemWithCustomCellBlock:^{
            OWSConversationSettingsViewController *strongSelf = weakSelf;
            if (!strongSelf) { return [UITableViewCell new]; }

            NSString *cellTitle = NSLocalizedString(@"CONVERSATION_SETTINGS_BLOCK_THIS_USER", @"table cell label in conversation settings");
            UITableViewCell *cell = [strongSelf disclosureCellWithName:cellTitle iconName:@"table_ic_block"
                accessibilityIdentifier:ACCESSIBILITY_IDENTIFIER_WITH_NAME(OWSConversationSettingsViewController, @"block")];

            cell.selectionStyle = UITableViewCellSelectionStyleNone;

            UISwitch *blockConversationSwitch = [UISwitch new];
            blockConversationSwitch.on = strongSelf.thread.isBlocked;
            [blockConversationSwitch addTarget:strongSelf action:@selector(blockConversationSwitchDidChange:)
                forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = blockConversationSwitch;

            return cell;
        } actionBlock:nil]];
    }
    
    if (!isNoteToSelf && [self.thread isKindOfClass:TSContactThread.class]) {
        [section addItem:[OWSTableItem itemWithCustomCellBlock:^{
          OWSConversationSettingsViewController *strongSelf = weakSelf;
          if (!strongSelf) { return [UITableViewCell new]; }
          NSString *displayName;
          TSContactThread *thread = (TSContactThread *)self.thread;
          displayName = [[LKStorage.shared getContactWithBChatID:thread.contactBChatID] displayNameFor:SNContactContextRegular];
          NSString *FulldisplayName;
          FulldisplayName = [NSString stringWithFormat:NSLocalizedString(@"Report %@ ", ""), displayName];
          NSString *cellTitle = FulldisplayName;
          UITableViewCell *cell = [strongSelf disclosureCellWithName:cellTitle iconName:@"about987"
            accessibilityIdentifier:ACCESSIBILITY_IDENTIFIER_WITH_NAME(OWSConversationSettingsViewController, @"block")];
          cell.selectionStyle = UITableViewCellSelectionStyleNone;
          return cell;
        } actionBlock:^{
          TSContactThread *thread = (TSContactThread *)self.thread;
          NSString *displayName = [[LKStorage.shared getContactWithBChatID:thread.contactBChatID] displayNameFor:SNContactContextRegular];
            NSString *FulldisplayName = [NSString stringWithFormat:NSLocalizedString(@"Report %@ ", ""), displayName];
          UIAlertController * alert = [UIAlertController
                           alertControllerWithTitle:FulldisplayName
                                       message:NSLocalizedString(@"This user will be reported to BChat Team.", @"")
                           preferredStyle:UIAlertControllerStyleAlert];
            //Add Buttons
            UIAlertAction* yesButton = [UIAlertAction
                          actionWithTitle:NSLocalizedString(@"Ok", @"")
                          style:UIAlertActionStyleDefault
                          handler:^(UIAlertAction * action) {
                            //Handle your yes please button action here
                          }];
            UIAlertAction* noButton = [UIAlertAction
                          actionWithTitle:NSLocalizedString(@"Cancel", @"")
                          style:UIAlertActionStyleDefault
                          handler:^(UIAlertAction * action) {
                            //Handle no, thanks button
                          }];
            //Add your buttons to alert controller
            [alert addAction:yesButton];
            [alert addAction:noButton];
            [self presentViewController:alert animated:YES completion:nil];
        }]];
      }
    self.contents = contents;
}

- (CGFloat)iconSpacing
{
    return 26.f;//return 12.f;
}

- (UITableViewCell *)cellWithName:(NSString *)name iconName:(NSString *)iconName
{
    OWSAssertDebug(iconName.length > 0);
    UIImageView *iconView = [self viewForIconWithName:iconName];
    return [self cellWithName:name iconView:iconView];
}

- (UITableViewCell *)cellWithName:(NSString *)name iconView:(UIView *)iconView
{
    OWSAssertDebug(name.length > 0);

    UITableViewCell *cell = [OWSTableItem newCell];
    cell.preservesSuperviewLayoutMargins = YES;
    cell.contentView.preservesSuperviewLayoutMargins = YES;

    UILabel *rowLabel = [UILabel new];
    rowLabel.text = name;
    rowLabel.textColor = LKColors.titleColor;
    rowLabel.font = [LKFonts OpenSansOfSize:16];
    rowLabel.lineBreakMode = NSLineBreakByTruncatingTail;

    UIStackView *contentRow = [[UIStackView alloc] initWithArrangedSubviews:@[ iconView, rowLabel ]];
    contentRow.spacing = self.iconSpacing;

    [cell.contentView addSubview:contentRow];
    [contentRow autoPinEdgesToSuperviewMargins];

    return cell;
}

- (UITableViewCell *)disclosureCellWithName:(NSString *)name
                                   iconName:(NSString *)iconName
                    accessibilityIdentifier:(NSString *)accessibilityIdentifier
{
    UITableViewCell *cell = [self cellWithName:name iconName:iconName];
    cell.accessibilityIdentifier = accessibilityIdentifier;
    return cell;
}

- (UITableViewCell *)labelCellWithName:(NSString *)name
                              iconName:(NSString *)iconName
               accessibilityIdentifier:(NSString *)accessibilityIdentifier
{
    UITableViewCell *cell = [self cellWithName:name iconName:iconName];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.accessibilityIdentifier = accessibilityIdentifier;
    return cell;
}

- (void)showProfilePicture:(UITapGestureRecognizer *)tapGesture
{
    LKProfilePictureView *profilePictureView = (LKProfilePictureView *)tapGesture.view;
    UIImage *image = [profilePictureView getProfilePicture];
    if (image == nil) { return; }
    NSString *title = (self.threadName != nil && self.threadName.length > 0) ? self.threadName : @"Anonymous";
    SNProfilePictureVC *profilePictureVC = [[SNProfilePictureVC alloc] initWithImage:image title:title];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:profilePictureVC];
    navController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navController animated:YES completion:nil];
}

- (UIView *)mainSectionHeader
{
    UITapGestureRecognizer *profilePictureTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showProfilePicture:)];
    LKProfilePictureView *profilePictureView = [LKProfilePictureView new];
    CGFloat size = 86;//LKValues.largeProfilePictureSize;
    profilePictureView.size = size;
    [profilePictureView autoSetDimension:ALDimensionWidth toSize:size];
    [profilePictureView autoSetDimension:ALDimensionHeight toSize:size];
    [profilePictureView addGestureRecognizer:profilePictureTapGestureRecognizer];
    profilePictureView.layer.cornerRadius = 43;
    profilePictureView.layer.masksToBounds = YES;
    
    self.displayNameLabel.text = (self.threadName != nil && self.threadName.length > 0) ? self.threadName :NSLocalizedString(@"Anonymous", comment: "");
    if ([self.thread isKindOfClass:TSContactThread.class]) {
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showEditNameUI)];
        [self.displayNameContainer addGestureRecognizer:tapGestureRecognizer];
    }
    
    UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:@[ profilePictureView, self.displayNameContainer ]];
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.spacing = 8;//LKValues.mediumSpacing;
    stackView.distribution = UIStackViewDistributionEqualCentering; 
    stackView.alignment = UIStackViewAlignmentCenter;
    BOOL isSmallScreen = (UIScreen.mainScreen.bounds.size.height - 568) < 1;
    CGFloat horizontalSpacing = isSmallScreen ? LKValues.largeSpacing : LKValues.veryLargeSpacing;
    stackView.layoutMargins = UIEdgeInsetsMake(LKValues.mediumSpacing, horizontalSpacing, LKValues.mediumSpacing, horizontalSpacing);
    [stackView setLayoutMarginsRelativeArrangement:YES];
    
    [profilePictureView updateForThread:self.thread];
    
    return stackView;
}

- (UIImageView *)viewForIconWithName:(NSString *)iconName
{
    UIImage *icon = [UIImage imageNamed:iconName];

    OWSAssertDebug(icon);
    UIImageView *iconView = [UIImageView new];
    iconView.image = [icon imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    iconView.tintColor = LKColors.text;
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    iconView.layer.minificationFilter = kCAFilterTrilinear;
    iconView.layer.magnificationFilter = kCAFilterTrilinear;

    [iconView autoSetDimensionsToSize:CGSizeMake(kIconViewLength, kIconViewLength)];

    return iconView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    NSIndexPath *_Nullable selectedPath = [self.tableView indexPathForSelectedRow];
    if (selectedPath) {
        // HACK to unselect rows when swiping back
        // http://stackoverflow.com/questions/19379510/uitableviewcell-doesnt-get-deselected-when-swiping-back-quickly
        [self.tableView deselectRowAtIndexPath:selectedPath animated:animated];
    }

    [self updateTableContents];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    if (self.disappearingMessagesConfiguration.isNewRecord && !self.disappearingMessagesConfiguration.isEnabled) {
        // don't save defaults, else we'll unintentionally save the configuration and notify the contact.
        return;
    }

    if (self.disappearingMessagesConfiguration.dictionaryValueDidChange) {
        [LKStorage writeWithBlock:^(YapDatabaseReadWriteTransaction *_Nonnull transaction) {
            [self.disappearingMessagesConfiguration saveWithTransaction:transaction];
            OWSDisappearingConfigurationUpdateInfoMessage *infoMessage = [[OWSDisappearingConfigurationUpdateInfoMessage alloc]
                         initWithTimestamp:[NSDate ows_millisecondTimeStamp]
                                    thread:self.thread
                             configuration:self.disappearingMessagesConfiguration
                       createdByRemoteName:nil
                    createdInExistingGroup:NO];
            [infoMessage saveWithTransaction:transaction];

            SNExpirationTimerUpdate *expirationTimerUpdate = [SNExpirationTimerUpdate new];
            BOOL isEnabled = self.disappearingMessagesConfiguration.enabled;
            expirationTimerUpdate.duration = isEnabled ? self.disappearingMessagesConfiguration.durationSeconds : 0;
            [SNMessageSender send:expirationTimerUpdate inThread:self.thread usingTransaction:transaction];
        }];
    }
}

#pragma mark - Actions

- (void)editGroup
{
    SNEditSecretGroupVC *editSecretGroupVC = [[SNEditSecretGroupVC alloc] initWithThreadID:self.thread.uniqueId];
    [self.navigationController pushViewController:editSecretGroupVC animated:YES completion:nil];
}
- (void)didTapLeaveGroup
{
    NSString *userPublicKey = [SNGeneralUtilities getUserPublicKey];
    NSString *message;
    if ([((TSGroupThread *)self.thread).groupModel.groupAdminIds containsObject:userPublicKey]) {
        message = NSLocalizedString(@"Because you are the creator of this group it will be deleted for everyone. This cannot be undone.", comment: "");
    } else {
        message = NSLocalizedString(@"CONFIRM_LEAVE_GROUP_DESCRIPTION", @"Alert body");
    }
    UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:NSLocalizedString(@"CONFIRM_LEAVE_GROUP_TITLE", @"Alert title")
                                            message:message
                                     preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *leaveAction = [UIAlertAction
                actionWithTitle:NSLocalizedString(@"LEAVE_BUTTON_TITLE", @"Confirmation button within contextual alert")
        accessibilityIdentifier:ACCESSIBILITY_IDENTIFIER_WITH_NAME(self, @"leave_group_confirm")
                          style:UIAlertActionStyleDestructive
                        handler:^(UIAlertAction *_Nonnull action) {
                            [self leaveGroup];
                        }];
    [alert addAction:leaveAction];
    [alert addAction:[OWSAlerts cancelAction]];
    [leaveAction setValue:[UIColor colorWithRed: 0.41 green: 2.53 blue: 0.46 alpha: 1] forKey:@"titleTextColor"];
    [self presentAlert:alert];
}
//
- (BOOL)hasLeftGroup
{
    if (self.isGroupThread) {
        TSGroupThread *groupThread = (TSGroupThread *)self.thread;
        return !groupThread.isCurrentUserMemberInGroup;
    }

    return NO;
}

- (void)leaveGroup
{
    TSGroupThread *gThread = (TSGroupThread *)self.thread;

    if (gThread.isClosedGroup) {
        NSString *groupPublicKey = [LKGroupUtilities getDecodedGroupID:gThread.groupModel.groupId];
        [LKStorage writeSyncWithBlock:^(YapDatabaseReadWriteTransaction *_Nonnull transaction) {
            [[SNMessageSender leaveClosedGroupWithPublicKey:groupPublicKey using:transaction] retainUntilComplete];
        }];
    }

    [self.navigationController popViewControllerAnimated:YES];
}

- (void)disappearingMessagesSwitchValueDidChange:(UISwitch *)sender
{
    UISwitch *disappearingMessagesSwitch = (UISwitch *)sender;

    [self toggleDisappearingMessages:disappearingMessagesSwitch.isOn];

    [self updateTableContents];
}

- (void)handleMuteSwitchToggled:(id)sender
{
    UISwitch *uiSwitch = (UISwitch *)sender;
    if (uiSwitch.isOn) {
        [LKStorage writeWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
            [self.thread updateWithMutedUntilDate:[NSDate distantFuture] transaction:transaction];
        }];
    } else {
        [LKStorage writeWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
            [self.thread updateWithMutedUntilDate:nil transaction:transaction];
        }];
    }
}

- (void)blockConversationSwitchDidChange:(id)sender
{
    if (![sender isKindOfClass:[UISwitch class]]) {
        OWSFailDebug(@"Unexpected sender for block user switch: %@", sender);
    }
    if (![self.thread isKindOfClass:[TSContactThread class]]) {
        OWSFailDebug(@"unexpected thread type: %@", self.thread.class);
    }
    UISwitch *blockConversationSwitch = (UISwitch *)sender;
    TSContactThread *contactThread = (TSContactThread *)self.thread;

    BOOL isCurrentlyBlocked = contactThread.isBlocked;

    __weak OWSConversationSettingsViewController *weakSelf = self;
    if (blockConversationSwitch.isOn) {
        OWSAssertDebug(!isCurrentlyBlocked);
        if (isCurrentlyBlocked) {
            return;
        }
        [BlockListUIUtils showBlockThreadActionSheet:contactThread
                                                from:self
                                     completionBlock:^(BOOL isBlocked) {
                                         // If we successfully blocked then force a config sync
                                         if (isBlocked) {
                                             [SNMessageSender forceSyncConfigurationNow];
                                         }

                                         [weakSelf updateTableContents];
                                     }];

    } else {
        OWSAssertDebug(isCurrentlyBlocked);
        if (!isCurrentlyBlocked) {
            return;
        }
        [BlockListUIUtils showUnblockThreadActionSheet:contactThread
                                                  from:self
                                       completionBlock:^(BOOL isBlocked) {
                                           // If we successfully unblocked then force a config sync
                                           if (!isBlocked) {
                                               [SNMessageSender forceSyncConfigurationNow];
                                           }

                                           [weakSelf updateTableContents];
                                       }];
    }
}

- (void)toggleDisappearingMessages:(BOOL)flag
{
    self.disappearingMessagesConfiguration.enabled = flag;

    [self updateTableContents];
}

- (void)durationSliderDidChange:(UISlider *)slider
{
    // snap the slider to a valid value
    NSUInteger index = (NSUInteger)(slider.value + 0.5);
    [slider setValue:index animated:YES];
    NSNumber *numberOfSeconds = self.disappearingMessagesDurations[index];
    self.disappearingMessagesConfiguration.durationSeconds = [numberOfSeconds unsignedIntValue];

    [self updateDisappearingMessagesDurationLabel];
}

- (void)updateDisappearingMessagesDurationLabel
{
    if (self.disappearingMessagesConfiguration.isEnabled) {
        NSString *keepForFormat = @"Disappear after %@";
        self.disappearingMessagesDurationLabel.text =
            [NSString stringWithFormat:keepForFormat, self.disappearingMessagesConfiguration.durationString];
    } else {
        self.disappearingMessagesDurationLabel.text
            = NSLocalizedString(@"KEEP_MESSAGES_FOREVER", @"Slider label when disappearing messages is off");
    }

    [self.disappearingMessagesDurationLabel setNeedsLayout];
    [self.disappearingMessagesDurationLabel.superview setNeedsLayout];
}

- (void)copyBChatID
{
    UIPasteboard.generalPasteboard.string = ((TSContactThread *)self.thread).contactBChatID;
        UIAlertController *toast =[UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"Your BChat ID copied to clipboard", comment: "") preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:toast animated:YES completion:nil];
        int duration = 1.0; // in seconds
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [toast dismissViewControllerAnimated:YES completion:nil];
        });
}

- (void)inviteUsersToOpenGroup
{
    NSString *threadID = self.thread.uniqueId;
    SNOpenGroupV2 *openGroup = [LKStorage.shared getV2OpenGroupForThreadID:threadID];
    NSString *url = [NSString stringWithFormat:@"%@/%@?public_key=%@", openGroup.server, openGroup.room, openGroup.publicKey];
    SNUserSelectionVC *userSelectionVC = [[SNUserSelectionVC alloc] initWithTitle:NSLocalizedString(@"vc_conversation_settings_invite_button_title", @"")
                                                                        excluding:[NSSet new]
                                                                       completion:^(NSSet<NSString *> *selectedUsers) {
        for (NSString *user in selectedUsers) {
            SNVisibleMessage *message = [SNVisibleMessage new];
            message.sentTimestamp = [NSDate millisecondTimestamp];
            message.openGroupInvitation = [[SNOpenGroupInvitation alloc] initWithName:openGroup.name url:url];
            TSContactThread *thread = [TSContactThread getOrCreateThreadWithContactBChatID:user];
            TSOutgoingMessage *tsMessage = [TSOutgoingMessage from:message associatedWith:thread];
            [LKStorage writeWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
                [tsMessage saveWithTransaction:transaction];
            }];
            [LKStorage writeWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
                [SNMessageSender send:message inThread:thread usingTransaction:transaction];
            }];
        }
    }];
    [self.navigationController pushViewController:userSelectionVC animated:YES];
}

- (void)showMediaGallery
{
    OWSLogDebug(@"");
}

- (void)tappedConversationSearch
{
    [self.conversationSettingsViewDelegate conversationSettingsDidRequestConversationSearch:self];
}

- (void)notifyForMentionsOnlySwitchValueDidChange:(id)sender
{
    UISwitch *uiSwitch = (UISwitch *)sender;
    BOOL isEnabled = uiSwitch.isOn;
    [LKStorage writeWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [(TSGroupThread *)self.thread setIsOnlyNotifyingForMentions:isEnabled withTransaction:transaction];
    }];
}

- (void)hideEditNameUI
{
    self.isEditingDisplayName = NO;
}

- (void)showEditNameUI
{
    self.isEditingDisplayName = YES;
}

- (void)setIsEditingDisplayName:(BOOL)isEditingDisplayName
{
    _isEditingDisplayName = isEditingDisplayName;
    
    [self updateNavBarButtons];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.displayNameLabel.alpha = self.isEditingDisplayName ? 0 : 1;
        self.displayNameTextField.alpha = self.isEditingDisplayName ? 1 : 0;
    }];
    if (self.isEditingDisplayName) {
        [self.displayNameTextField becomeFirstResponder];
    } else {
        [self.displayNameTextField resignFirstResponder];
    }
}

- (void)saveName
{
    if (![self.thread isKindOfClass:TSContactThread.class]) { return; }
    NSString *bchatID = ((TSContactThread *)self.thread).contactBChatID;
    SNContact *contact = [LKStorage.shared getContactWithBChatID:bchatID];
    if (contact == nil) {
        contact = [[SNContact alloc] initWithBchatID:bchatID];
    }
    NSString *text = [self.displayNameTextField.text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    contact.nickname = text.length > 0 ? text : nil;
    [LKStorage writeWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [LKStorage.shared setContact:contact usingTransaction:transaction];
    }];
    self.displayNameLabel.text = text.length > 0 ? text : contact.name;
    [self hideEditNameUI];
}

- (void)updateNavBarButtons
{
    if (self.isEditingDisplayName) {
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(hideEditNameUI)];
        cancelButton.tintColor = LKColors.text;
        cancelButton.accessibilityLabel = @"Cancel button";
        cancelButton.isAccessibilityElement = YES;
        self.navigationItem.leftBarButtonItem = cancelButton;
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(saveName)];
        doneButton.tintColor = LKColors.text;
        doneButton.accessibilityLabel = @"Done button";
        doneButton.isAccessibilityElement = YES;
        self.navigationItem.rightBarButtonItem = doneButton;
    } else {
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = nil;
    }
}

#pragma mark - Notifications

- (void)identityStateDidChange:(NSNotification *)notification
{
    OWSAssertIsOnMainThread();

    [self updateTableContents];
}

- (void)otherUsersProfileDidChange:(NSNotification *)notification
{
    OWSAssertIsOnMainThread();

    NSString *recipientId = notification.userInfo[kNSNotificationKey_ProfileRecipientId];
    OWSAssertDebug(recipientId.length > 0);

    if (recipientId.length > 0 && [self.thread isKindOfClass:[TSContactThread class]] &&
        [((TSContactThread *)self.thread).contactBChatID isEqualToString:recipientId]) {
        [self updateTableContents];
    }
}

#pragma mark - OWSSheetViewController

- (void)sheetViewControllerRequestedDismiss:(OWSSheetViewController *)sheetViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

NS_ASSUME_NONNULL_END
