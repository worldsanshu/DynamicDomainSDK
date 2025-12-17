import 'dart:ui';

import 'package:get/get.dart';

import 'lang/en_US.dart';
import 'lang/zh_CN.dart';

class TranslationService extends Translations {
  static Locale? get locale => Get.deviceLocale;
  static const fallbackLocale = Locale('en', 'US');

  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': en_US,
        'zh_CN': zh_CN,
      };
}

class StrRes {
  StrRes._();

  static String get welcome => 'welcome'.tr;

  static String get phoneNumber => 'phoneNumber'.tr;
  static String get userID => 'userID'.tr;

  static String get inviteSuccessfully => 'inviteSuccessfully'.tr;
  static String get inviteFailed => 'inviteFailed'.tr;
  static String get plsEnterPhoneNumber => 'plsEnterPhoneNumber'.tr;

  static String get password => 'password'.tr;

  static String get plsEnterPassword => 'plsEnterPassword'.tr;

  static String get passwordMustLength => 'passwordMustLength'.tr;

  static String get account => 'account'.tr;

  static String get plsEnterAccount => 'plsEnterAccount'.tr;

  static String get registerSuccessfully => 'registerSuccessfully'.tr;

  static String get registerError => 'registerError'.tr;

  static String get plsEnterEmail => 'plsEnterEmail'.tr;

  static String get forgetPassword => 'forgetPassword'.tr;

  static String get forgotPassword => 'forgotPassword'.tr;

  static String get resetPassword => 'resetPassword'.tr;

  static String get login => 'login'.tr;
  static String get register => 'register'.tr;
  static String get newAction => 'newAction'.tr;
  static String get addFriendsAndGroups => 'addFriendsAndGroups'.tr;
  static String get flashUnavailable => 'flashUnavailable'.tr;
  static String get flashlightOff => 'flashlightOff'.tr;
  static String get flashlightOn => 'flashlightOn'.tr;
  static String get personalInformation => 'personalInformation'.tr;
  static String get securityAndPrivacy => 'securityAndPrivacy'.tr;
  static String get notAllowAddFriend => 'notAllowAddFriend'.tr;
  static String get cannotAddYourself => 'cannotAddYourself'.tr;
  static String get alreadyFriends => 'alreadyFriends'.tr;
  static String get manageGroupMembers => 'manageGroupMembers'.tr;
  static String get groupMemberStatus => 'groupMemberStatus'.tr;
  static String get addContacts => 'addContacts'.tr;

  static String get noAccountYet => 'noAccountYet'.tr;
  static String get accountYet => 'accountYet'.tr;

  static String get loginNow => 'loginNow'.tr;

  static String get registerNow => 'registerNow'.tr;

  static String get lockPwdErrorHint => 'lockPwdErrorHint'.tr;

  static String get newUserRegister => 'newUserRegister'.tr;

  static String get verificationCode => 'verificationCode'.tr;

  static String get plsEnterVerificationCodeImg =>
      'plsEnterVerificationCodeImg'.tr;

  static String get sendCode => 'sendCode'.tr;

  static String get resendVerificationCode => 'resendVerificationCode'.tr;

  static String get verificationCodeTimingReminder =>
      'verificationCodeTimingReminder'.tr;

  static String get verificationCodeTimingReminderfy =>
      'verificationCodeTimingReminderfy'.tr;

  static String get defaultVerificationCode => 'defaultVerificationCode'.tr;

  static String get plsEnterVerificationCode => 'plsEnterVerificationCode'.tr;

  static String get imageCode => 'imageCode'.tr;

  static String get plsEnterImageCode => 'plsEnterVerificationCode'.tr;

  static String get plsEnterInvitationCodeOptional =>
      'plsEnterInvitationCodeOptional'.tr;

  static String get enterEnterpriseCode => 'enterEnterpriseCode'.tr;

  static String get invalidEnterpriseCode => 'invalidEnterpriseCode'.tr;

  static String get enterpriseCodeNotExist => 'enterpriseCodeNotExist'.tr;

  static String get enterpriseCodeVerificationFailed =>
      'enterpriseCodeVerificationFailed'.tr;

  static String get invitationCode => 'invitationCode'.tr;

  static String get plsEnterInvitationCode => 'plsEnterInvitationCode'.tr;

  static String get myCompany => 'myCompany'.tr;
  static String get currentCompany => 'currentCompany'.tr;
  static String get unbindCompany => 'unbindCompany'.tr;
  static String get switchText => 'switchText'.tr;
  static String get enterText => 'enterText'.tr;
  static String get refresh => 'refresh'.tr;
  static String get agree => 'agree'.tr;
  static String get warmTips => 'warmTips'.tr;
  static String get rejectAndExit => 'rejectAndExit'.tr;
  static String get plsReadBeforeUse => 'plsReadBeforeUse'.tr;
  static String get userAgreement => 'userAgreement'.tr;
  static String get userAgreementDoc => 'userAgreementDoc'.tr;
  static String get privacyPolicy => 'privacyPolicy'.tr;
  static String get forbiddenTip => 'forbiddenTip'.tr;
  static String get enterpriseForbidden => 'enterpriseForbidden'.tr;
  static String get willUnbanAt => 'willUnbanAt'.tr;
  static String get forbiddenReason => 'forbiddenReason'.tr;
  static String get licenseExpiryTip => 'licenseExpiryTip'.tr;
  static String get enterpriseLicenseWillExpire =>
      'enterpriseLicenseWillExpire'.tr;
  static String get expire => 'expire'.tr;
  static String get forbiddenTime => 'forbiddenTime'.tr;
  static String get startTime => 'startTime'.tr;
  static String get unbanTime => 'unbanTime'.tr;
  static String get forbiddenDetails => 'forbiddenDetails'.tr;
  static String get noSupportedApp => 'noSupportedApp'.tr;
  static String get noPermissionAccess => 'noPermissionAccess'.tr;
  static String get fileInvalid => 'fileInvalid'.tr;
  static String get personalizedAdDescription => 'personalizedAdDescription'.tr;
  static String get personalizedAdContent => 'personalizedAdContent'.tr;
  static String get userPrivateProtocol => 'userPrivateProtocol'.tr;
  static String get scanFingerprintForAuth => 'scanFingerprintForAuth'.tr;
  static String get disagree => 'disagree'.tr;
  static String get agreeToUserAgreementAndPrivacyPolicy =>
      'agreeToUserAgreementAndPrivacyPolicy'.tr;
  static String get plsCenterCompanyCodeOrCompanyName =>
      'plsCenterCompanyCodeOrCompanyName'.tr;
  static String get searchCompany => 'searchCompany'.tr;
  static String get bind => 'bind'.tr;
  static String get exists => 'exists'.tr;
  static String get alreadyBind => 'alreadyBind'.tr;

  // Merchant related strings
  static String get searchCompanyCode => 'searchCompanyCode'.tr;
  static String get noCompanyBound => 'noCompanyBound'.tr;
  static String get noCompanyBoundHint => 'noCompanyBoundHint'.tr;
  static String get bindNow => 'bindNow'.tr;
  static String get companyId => 'companyId'.tr;
  static String get searchFor => 'searchFor'.tr;
  static String get confirmBindCompany => 'confirmBindCompany'.tr;
  static String get confirmBindCompanyContent => 'confirmBindCompanyContent'.tr;

  static String get optional => 'optional'.tr;

  static String get options => 'options'.tr;

  static String get nextStep => 'nextStep'.tr;

  static String get plsEnterRightPhone => 'plsEnterRightPhone'.tr;

  static String get plsEnterRightPhoneOrEmail => 'plsEnterRightPhoneOrEmail'.tr;

  static String get enterVerificationCode => 'enterVerificationCode'.tr;

  static String get setPassword => 'setPassword'.tr;

  static String get plsConfirmPasswordAgain => 'plsConfirmPasswordAgain'.tr;

  static String get confirmPassword => 'confirmPassword'.tr;

  static String get wrongPasswordFormat => 'wrongPasswordFormat'.tr;

  static String get plsCompleteInfo => 'plsCompleteInfo'.tr;

  static String get plsEnterYourNickname => 'plsEnterYourNickname'.tr;

  static String get setInfo => 'setInfo'.tr;

  static String get savedInviteCode => 'savedInviteCode'.tr;

  static String get loginPwdFormat => 'loginPwdFormat'.tr;

  static String get loginFailed => 'loginFailed'.tr;

  static String get tooMuchRequestValidationCode =>
      'tooMuchRequestValidationCode'.tr;

  static String get notFoundAccount => 'notFoundAccount'.tr;

  static String get loginIncorrectPwd => 'loginIncorrectPwd'.tr;

  static String get passwordLogin => 'passwordLogin'.tr;

  static String get through => 'through'.tr;

  static String get home => 'home'.tr;

  static String get contacts => 'contacts'.tr;

  static String get workbench => 'workbench'.tr;

  static String get mine => 'mine'.tr;

  static String get information => 'information'.tr;

  static String get draftText => 'draftText'.tr;

  static String get everyone => 'everyone'.tr;

  static String get you => 'you'.tr;

  static String get someoneMentionYou => 'someoneMentionYou'.tr;

  static String get groupAc => 'groupAc'.tr;

  static String get createGroupNtf => 'createGroupNtf'.tr;

  static String get editGroupInfoNtf => 'editGroupInfoNtf'.tr;

  static String get quitGroupNtf => 'quitGroupNtf'.tr;

  static String get invitedJoinGroupNtf => 'invitedJoinGroupNtf'.tr;

  static String get kickedGroupNtf => 'kickedGroupNtf'.tr;

  static String get joinGroupNtf => 'joinGroupNtf'.tr;

  static String get dismissGroupNtf => 'dismissGroupNtf'.tr;

  static String get transferredGroupNtf => 'transferredGroupNtf'.tr;

  static String get muteMemberNtf => 'muteMemberNtf'.tr;

  static String get muteCancelMemberNtf => 'muteCancelMemberNtf'.tr;

  static String get muteGroupNtf => 'muteGroupNtf'.tr;

  static String get muteCancelGroupNtf => 'muteCancelGroupNtf'.tr;

  static String get friendAddedNtf => 'friendAddedNtf'.tr;

  static String get openPrivateChatNtf => 'openPrivateChatNtf'.tr;

  static String get closePrivateChatNtf => 'closePrivateChatNtf'.tr;

  static String get memberInfoChangedNtf => 'memberInfoChangedNtf'.tr;

  static String get unsupportedMessage => 'unsupportedMessage'.tr;

  static String get picture => 'picture'.tr;

  static String get video => 'video'.tr;

  static String get voice => 'voice'.tr;

  static String get file => 'file'.tr;

  static String get carte => 'carte'.tr;

  static String get emoji => 'emoji'.tr;

  static String get chatRecord => 'chatRecord'.tr;
  static String get mergedMessages => 'mergedMessages'.tr;
  static String get groupChat => 'groupChat'.tr;
  static String get and => 'and'.tr;

  static String get revokeMsg => 'revokeMsg'.tr;

  static String get aRevokeBMsg => 'aRevokeBMsg'.tr;

  static String get blockedByFriendHint => 'blockedByFriendHint'.tr;

  static String get deletedByFriendHint => 'deletedByFriendHint'.tr;

  static String get sendFriendVerification => 'sendFriendVerification'.tr;

  static String get removedFromGroupHint => 'removedFromGroupHint'.tr;

  static String get groupDisbanded => 'groupDisbanded'.tr;

  static String get search => 'search'.tr;

  static String get searchAddFriends => 'searchAddFriends'.tr;

  static String get searchJoinGroups => 'searchJoinGroups'.tr;

  static String get synchronizing => 'synchronizing'.tr;

  static String get syncFailed => 'syncFailed'.tr;

  static String get connecting => 'connecting'.tr;

  static String get connectionFailed => 'connectionFailed'.tr;

  static String get systemMaintenance => 'systemMaintenance'.tr;

  static String get top => 'top'.tr;

  static String get cancelTop => 'cancelTop'.tr;

  static String get markHasRead => 'markHasRead'.tr;

  static String get delete => 'delete'.tr;

  static String get nPieces => 'nPieces'.tr;

  static String get online => 'online'.tr;

  static String get offline => 'offline'.tr;

  static String get phoneOnline => 'phoneOnline'.tr;

  static String get pcOnline => 'pcOnline'.tr;

  static String get webOnline => 'webOnline'.tr;

  static String get webMiniOnline => 'webMiniOnline'.tr;

  static String get upgradeFind => 'upgradeFind'.tr;

  static String get upgradeVersion => 'upgradeVersion'.tr;

  static String get upgradeDescription => 'upgradeDescription'.tr;

  static String get upgradeIgnore => 'upgradeIgnore'.tr;

  static String get upgradeLater => 'upgradeLater'.tr;

  static String get upgradeNow => 'upgradeNow'.tr;

  static String get upgradePermissionTips => 'upgradePermissionTips'.tr;

  static String get inviteYouCall => 'inviteYouCall'.tr;

  static String get rejectCall => 'rejectCall'.tr;

  static String get acceptCall => 'acceptCall'.tr;

  static String get callVoice => 'callVoice'.tr;

  static String get callVideo => 'callVideo'.tr;

  static String get sentSuccessfully => 'sentSuccessfully'.tr;

  static String get failedToSendVerificationCode =>
      'failedToSendVerificationCode'.tr;

  static String get copySuccessfully => 'copySuccessfully'.tr;

  static String get day => 'day'.tr;

  static String get hour => 'hour'.tr;

  static String get hours => 'hours'.tr;

  static String get minute => 'minute'.tr;

  static String get seconds => 'seconds'.tr;

  static String get cancel => 'cancel'.tr;

  static String get determine => 'determine'.tr;

  static String get toolboxAlbum => 'toolboxAlbum'.tr;

  static String get toolboxCall => 'toolboxCall'.tr;

  static String get toolboxCamera => 'toolboxCamera'.tr;

  static String get toolboxCard => 'toolboxCard'.tr;

  static String get toolboxFile => 'toolboxFile'.tr;

  static String get send => 'send'.tr;

  static String get holdTalk => 'holdTalk'.tr;

  static String get releaseToSend => 'releaseToSend'.tr;

  static String get releaseToSendSwipeUpToCancel =>
      'releaseToSendSwipeUpToCancel'.tr;

  static String get liftFingerToCancel => 'liftFingerToCancel'.tr;

  static String get callDuration => 'callDuration'.tr;

  static String get cancelled => 'cancelled'.tr;

  static String get cancelledByCaller => 'cancelledByCaller'.tr;

  static String get rejectedByCaller => 'rejectedByCaller'.tr;

  static String get callTimeout => 'callTimeout'.tr;

  static String get rejected => 'rejected'.tr;

  static String get networkAnomaly => 'networkAnomaly'.tr;

  static String get forwardMaxCountHint => 'forwardMaxCountHint'.tr;

  static String get typing => 'typing'.tr;

  static String get addSuccessfully => 'addSuccessfully'.tr;

  static String get sentToAdminForVerification =>
      'sentToAdminForVerification'.tr;

  static String get addFailed => 'addFailed'.tr;

  static String get setSuccessfully => 'setSuccessfully'.tr;

  static String get callingBusy => 'callingBusy'.tr;

  static String get groupCallHint => 'groupCallHint'.tr;

  static String get joinIn => 'joinIn'.tr;

  static String get menuCopy => 'menuCopy'.tr;

  static String get menuDel => 'menuDel'.tr;

  static String get menuForward => 'menuForward'.tr;

  static String get menuReply => 'menuReply'.tr;

  static String get menuMulti => 'menuMulti'.tr;

  static String get menuRevoke => 'menuRevoke'.tr;

  static String get menuTopChat => 'menuTopChat'.tr;

  static String get pin => 'pin'.tr;

  static String get unpin => 'unpin'.tr;

  static String get menuAdd => 'menuAdd'.tr;

  static String get nMessage => 'nMessage'.tr;

  static String get groupAudioCallHint => 'groupAudioCallHint'.tr;

  static String get groupVideoCallHint => 'groupVideoCallHint'.tr;

  static String get reEdit => 'reEdit'.tr;

  static String get download => 'download'.tr;

  static String get playSpeed => 'playSpeed'.tr;

  static String get googleMap => 'googleMap'.tr;

  static String get appleMap => 'appleMap'.tr;

  static String get baiduMap => 'baiduMap'.tr;

  static String get amapMap => 'amapMap'.tr;

  static String get tencentMap => 'tencentMap'.tr;

  static String get offlineMessage => 'offlineMessage'.tr;

  static String get offlineCallMessage => 'offlineCallMessage'.tr;

  static String get logoutHint => 'logoutHint'.tr;

  static String get myInfo => 'myInfo'.tr;

  static String get workingCircle => 'workingCircle'.tr;

  static String get accountSetup => 'accountSetup'.tr;

  static String get serviceAgreement => 'serviceAgreement'.tr;
  static String get deleteAccount => 'deleteAccount'.tr;

  static String get aboutUs => 'aboutUs'.tr;

  static String get logout => 'logout'.tr;

  static String get clearCache => 'clearCache'.tr;

  static String get clearCacheHint => 'clearCacheHint'.tr;

  static String get myOrganize => 'myOrganize'.tr;

  static String get qrcode => 'qrcode'.tr;

  static String get qrcodeHint => 'qrcodeHint'.tr;

  static String get favoriteFace => 'favoriteFace'.tr;

  static String get favoriteManage => 'favoriteManage'.tr;

  static String get favoriteCount => 'favoriteCount'.tr;

  static String get favoriteDel => 'favoriteDel'.tr;

  static String get hasRead => 'hasRead'.tr;

  static String get unread => 'unread'.tr;

  static String get received => 'received'.tr;

  static String get nPersonUnRead => 'nPersonUnRead'.tr;

  static String get allRead => 'allRead'.tr;

  static String get messageRecipientList => 'messageRecipientList'.tr;

  static String get hasReadCount => 'hasReadCount'.tr;

  static String get unreadCount => 'unreadCount'.tr;

  static String get newFriend => 'newFriend'.tr;

  static String get newGroup => 'newGroup'.tr;

  static String get newGroupRequest => 'newGroupRequest'.tr;

  static String get groupJoinRequests => 'groupJoinRequests'.tr;

  static String get groupJoinRequestDetails => 'groupJoinRequestDetails'.tr;

  static String get myFriend => 'myFriend'.tr;

  static String get myGroup => 'myGroup'.tr;

  static String get chooseFriends => 'chooseFriends'.tr;

  static String get chooseGroups => 'chooseGroups'.tr;

  static String get chooseFriendsHint => 'chooseFriendsHint'.tr;

  static String get chooseGroupsHint => 'chooseGroupsHint'.tr;

  static String get noFriendRequests => 'noFriendRequests'.tr;

  static String get noGroupRequests => 'noGroupRequests'.tr;

  static String get joinedGroup => 'joinedGroup'.tr;

  static String get noFriendsFound => 'noFriendsFound'.tr;

  static String get moreThan99 => 'moreThan99'.tr;

  static String get searchGroupsHint => 'searchGroupsHint'.tr;

  static String get noConversationsYet => 'noConversationsYet'.tr;

  static String get noCreatedGroupsYet => 'noCreatedGroupsYet'.tr;

  static String get noJoinedGroupsYet => 'noJoinedGroupsYet'.tr;

  static String get all => 'all'.tr;

  static String get add => 'add'.tr;

  static String get scan => 'scan'.tr;

  static String get scanHint => 'scanHint'.tr;

  static String get addFriend => 'addFriend'.tr;

  static String get addFriendHint => 'addFriendHint'.tr;

  static String get createGroup => 'createGroup'.tr;

  static String get createGroupHint => 'createGroupHint'.tr;

  static String get addGroup => 'addGroup'.tr;

  static String get addGroupHint => 'addGroupHint'.tr;

  static String get searchIDAddFriend => 'searchIDAddFriend'.tr;

  static String get searchIDAddGroup => 'searchIDAddGroup'.tr;

  static String get searchIDIs => 'searchIDIs'.tr;

  static String get searchPhoneIs => 'searchPhoneIs'.tr;

  static String get searchEmailIs => 'searchEmailIs'.tr;

  static String get searchNicknameIs => 'searchNicknameIs'.tr;

  static String get searchGroupNameIs => 'searchGroupNameIs'.tr;

  static String get noFoundUser => 'noFoundUser'.tr;

  static String get noFoundGroup => 'noFoundGroup'.tr;

  static String get joinGroupMethod => 'joinGroupMethod'.tr;

  static String get joinGroupDate => 'joinGroupDate'.tr;

  static String get byInviteJoinGroup => 'byInviteJoinGroup'.tr;

  static String get byIDJoinGroup => 'byIDJoinGroup'.tr;

  static String get byQrcodeJoinGroup => 'byQrcodeJoinGroup'.tr;

  static String get groupID => 'groupID'.tr;

  static String get setAsAdmin => 'setAsAdmin'.tr;

  static String get setMute => 'setMute'.tr;

  static String get organizationInfo => 'organizationInfo'.tr;

  static String get organization => 'organization'.tr;

  static String get department => 'department'.tr;

  static String get position => 'position'.tr;

  static String get personalInfo => 'personalInfo'.tr;

  static String get audioAndVideoCall => 'audioAndVideoCall'.tr;

  static String get audioCall => 'audioCall'.tr;

  static String get videoCall => 'videoCall'.tr;

  static String get sendMessage => 'sendMessage'.tr;

  static String get viewDynamics => 'viewDynamics'.tr;

  static String get avatar => 'avatar'.tr;

  static String get name => 'name'.tr;

  static String get nickname => 'nickname'.tr;

  static String get gender => 'gender'.tr;

  static String get englishName => 'englishName'.tr;

  static String get birthDay => 'birthDay'.tr;

  static String get tel => 'tel'.tr;

  static String get mobile => 'mobile'.tr;

  static String get email => 'email'.tr;

  static String get man => 'man'.tr;

  static String get woman => 'woman'.tr;

  static String get friendSetup => 'friendSetup'.tr;

  static String get friendSettingsPrivacy => 'friendSettingsPrivacy'.tr;

  static String get selectEmoji => 'selectEmoji'.tr;

  static String get setupRemark => 'setupRemark'.tr;

  static String get recommendToFriend => 'recommendToFriend'.tr;

  static String get addToBlacklist => 'addToBlacklist'.tr;

  static String get unfriend => 'unfriend'.tr;

  static String get areYouSureDelFriend => 'areYouSureDelFriend'.tr;

  static String get areYouSureAddBlacklist => 'areYouSureAddBlacklist'.tr;

  static String get areYouSureRemoveBlacklist => 'areYouSureRemoveBlacklist'.tr;

  static String get copySuccess => 'copySuccess'.tr;

  static String get remark => 'remark'.tr;

  static String get setRemarkName => 'setRemarkName'.tr;

  static String get enterRemarkName => 'enterRemarkName'.tr;

  static String get save => 'save'.tr;

  static String get saveSuccessfully => 'saveSuccessfully'.tr;

  static String get saveFailed => 'saveFailed'.tr;

  static String get groupVerification => 'groupVerification'.tr;

  static String get friendVerification => 'friendVerification'.tr;

  static String get sendEnterGroupApplication => 'sendEnterGroupApplication'.tr;

  static String get sendToBeFriendApplication => 'sendToBeFriendApplication'.tr;

  static String get sendSuccessfully => 'sendSuccessfully'.tr;

  static String get sendFailed => 'sendFailed'.tr;

  static String get canNotAddFriends => 'canNotAddFriends'.tr;

  static String get mutedAll => 'mutedAll'.tr;

  static String get tenMinutes => 'tenMinutes'.tr;

  static String get oneHour => 'oneHour'.tr;

  static String get twelveHours => 'twelveHours'.tr;

  static String get oneDay => 'oneDay'.tr;

  static String get custom => 'custom'.tr;

  static String get unmute => 'unmute'.tr;

  static String get youMuted => 'youMuted'.tr;

  static String get groupMuted => 'groupMuted'.tr;

  static String get notDisturbMode => 'notDisturbMode'.tr;

  static String get allowRing => 'allowRing'.tr;

  static String get allowVibrate => 'allowVibrate'.tr;

  static String get allowAddMeFried => 'allowAddMeFried'.tr;

  static String get scanToAddMe => 'scanToAddMe'.tr;

  static String get blacklist => 'blacklist'.tr;

  static String get unlockSettings => 'unlockSettings'.tr;

  static String get changePassword => 'changePassword'.tr;

  static String get clearChatHistory => 'clearChatHistory'.tr;

  static String get confirmClearChatHistory => 'confirmClearChatHistory'.tr;

  static String get confirmDeleteAccount => 'confirmDeleteAccount'.tr;
  static String get confirmDeleteAccountContent =>
      'confirmDeleteAccountContent'.tr;
  static String get confirmDeleteAccountTipsTitle =>
      'confirmDeleteAccountTipsTitle'.tr;
  static String get confirmDeleteAccountTipsContent =>
      'confirmDeleteAccountTipsContent'.tr;

  static String get useNicknameAsAvatar => 'useNicknameAsAvatar'.tr;
  static String get useDefaultGroupAvatar => 'useDefaultGroupAvatar'.tr;
  static String get confirmUseNicknameAsAvatar =>
      'confirmUseNicknameAsAvatar'.tr;
  static String get confirmUseDefaultGroupAvatar =>
      'confirmUseDefaultGroupAvatar'.tr;

  static String get languageSetup => 'languageSetup'.tr;

  static String get language => 'language'.tr;

  static String get english => 'english'.tr;

  static String get chinese => 'chinese'.tr;

  static String get followSystem => 'followSystem'.tr;

  static String get blacklistEmpty => 'blacklistEmpty'.tr;

  static String get teenMode => 'teenMode'.tr;

  static String get remove => 'remove'.tr;

  static String get fingerprint => 'fingerprint'.tr;

  static String get gesture => 'gesture'.tr;

  static String get biometrics => 'biometrics'.tr;

  static String get plsEnterPwd => 'plsEnterPwd'.tr;

  static String get plsEnterOldPwd => 'plsEnterOldPwd'.tr;

  static String get plsEnterNewPwd => 'plsEnterNewPwd'.tr;

  static String get plsConfirmNewPwd => 'plsConfirmNewPwd'.tr;

  static String get reset => 'reset'.tr;

  static String get oldPwd => 'oldPwd'.tr;

  static String get newPwd => 'newPwd'.tr;

  static String get confirmNewPwd => 'confirmNewPwd'.tr;

  static String get plsEnterConfirmPwd => 'plsEnterConfirmPwd'.tr;

  static String get twicePwdNoSame => 'twicePwdNoSame'.tr;

  static String get changedSuccessfully => 'changedSuccessfully'.tr;

  static String get checkNewVersion => 'checkNewVersion'.tr;

  static String get chatContent => 'chatContent'.tr;

  static String get topContacts => 'topContacts'.tr;

  static String get messageNotDisturb => 'messageNotDisturb'.tr;

  static String get messageNotDisturbHint => 'messageNotDisturbHint'.tr;

  static String get timeSet => 'timeSet'.tr;

  static String get setChatBackground => 'setChatBackground'.tr;

  static String get setDefaultBackground => 'setDefaultBackground'.tr;

  static String get fontSize => 'fontSize'.tr;

  static String get little => 'little'.tr;

  static String get standard => 'standard'.tr;

  static String get big => 'big'.tr;

  static String get thirtySeconds => 'thirtySeconds'.tr;

  static String get fiveMinutes => 'fiveMinutes'.tr;

  static String get clearAll => 'clearAll'.tr;

  static String get clearSuccessfully => 'clearSuccessfully'.tr;

  static String get groupChatSetup => 'groupChatSetup'.tr;

  static String get viewAllGroupMembers => 'viewAllGroupMembers'.tr;

  static String get groupManage => 'groupManage'.tr;

  static String get myGroupMemberNickname => 'myGroupMemberNickname'.tr;

  static String get topChat => 'topChat'.tr;

  static String get muteAllMember => 'muteAllMember'.tr;

  static String get exitGroup => 'exitGroup'.tr;

  static String get dismissGroup => 'dismissGroup'.tr;

  static String get dismissGroupHint => 'dismissGroupHint'.tr;

  static String get quitGroupHint => 'quitGroupHint'.tr;

  static String get report => 'report'.tr;

  static String get reportSubmit => 'reportSubmit'.tr;

  static String get appealSubmit => 'appealSubmit'.tr;

  static String get joinGroupSet => 'joinGroupSet'.tr;

  static String get groupSettingsPrivacy => 'groupSettingsPrivacy'.tr;
  static String get groupControl => 'groupControl'.tr;
  static String get ownerSettings => 'ownerSettings'.tr;

  static String get allowAnyoneJoinGroup => 'allowAnyoneJoinGroup'.tr;

  static String get inviteNotVerification => 'inviteNotVerification'.tr;

  static String get needVerification => 'needVerification'.tr;

  static String get addMember => 'addMember'.tr;

  static String get delMember => 'delMember'.tr;

  static String get groupOwner => 'groupOwner'.tr;

  static String get groupAdmin => 'groupAdmin'.tr;

  static String get notAllowSeeMemberProfile => 'notAllowSeeMemberProfile'.tr;

  static String get notAllAddMemberToBeFriend => 'notAllAddMemberToBeFriend'.tr;

  static String get transferGroupOwnerRight => 'transferGroupOwnerRight'.tr;

  static String get plsEnterRightEmail => 'plsEnterRightEmail'.tr;

  static String get groupName => 'groupName'.tr;

  static String get groupNickname => 'groupNickname'.tr;

  static String get enterNewGroupName => 'enterNewGroupName'.tr;

  static String get enterGroupName => 'enterGroupName'.tr;

  static String get enterYourNicknameInGroup => 'enterYourNicknameInGroup'.tr;

  static String get enterYourGroupNickname => 'enterYourGroupNickname'.tr;

  static String get groupNameUpdatedSuccessfully =>
      'groupNameUpdatedSuccessfully'.tr;

  static String get failedToUpdateGroupName => 'failedToUpdateGroupName'.tr;

  static String get groupNicknameUpdatedSuccessfully =>
      'groupNicknameUpdatedSuccessfully'.tr;

  static String get failedToUpdateGroupNickname =>
      'failedToUpdateGroupNickname'.tr;

  static String get scanToJoinGroup => 'scanToJoinGroup'.tr;

  static String get shareQRCodeToJoinGroup => 'shareQRCodeToJoinGroup'.tr;

  static String get member => 'member'.tr;

  static String get members => 'members'.tr;

  static String get anyoneCanJoinWithoutApproval =>
      'anyoneCanJoinWithoutApproval'.tr;

  static String get membersCanInviteAdminApprovalRequired =>
      'membersCanInviteAdminApprovalRequired'.tr;

  static String get allRequestsRequireAdminApproval =>
      'allRequestsRequireAdminApproval'.tr;

  static String get groupAcPermissionTips => 'groupAcPermissionTips'.tr;

  static String get plsEnterGroupAc => 'plsEnterGroupAc'.tr;

  static String get edit => 'edit'.tr;

  static String get publish => 'publish'.tr;

  static String get groupMember => 'groupMember'.tr;

  static String get selectedPeopleCount => 'selectedPeopleCount'.tr;

  static String get confirmSelectedPeople => 'confirmSelectedPeople'.tr;

  static String get confirm => 'confirm'.tr;

  static String get confirmTransferGroupToUser =>
      'confirmTransferGroupToUser'.tr;

  static String get removeGroupMember => 'removeGroupMember'.tr;

  static String get searchNotResult => 'searchNotResult'.tr;

  static String get groupQrcode => 'groupQrcode'.tr;

  static String get groupQrcodeHint => 'groupQrcodeHint'.tr;

  static String get approved => 'approved'.tr;

  static String get waiting => 'waiting'.tr;

  static String get requests => 'requests'.tr;

  static String get accept => 'accept'.tr;

  static String get reject => 'reject'.tr;

  static String get waitingForVerification => 'waitingForVerification'.tr;

  static String get rejectSuccessfully => 'rejectSuccessfully'.tr;

  static String get rejectFailed => 'rejectFailed'.tr;

  static String get applyJoin => 'applyJoin'.tr;

  static String get applicationPending => 'applicationPending'.tr;

  static String get requested => 'requested'.tr;

  static String get enterGroup => 'enterGroup'.tr;

  static String get applyReason => 'applyReason'.tr;

  static String get invite => 'invite'.tr;

  static String get sourceFrom => 'sourceFrom'.tr;

  static String get byMemberInvite => 'byMemberInvite'.tr;

  static String get bySearch => 'bySearch'.tr;

  static String get byScanQrcode => 'byScanQrcode'.tr;

  static String get iCreatedGroup => 'iCreatedGroup'.tr;

  static String get iJoinedGroup => 'iJoinedGroup'.tr;

  static String get nPerson => 'nPerson'.tr;

  static String get searchNotFound => 'searchNotFound'.tr;
  static String get noSearchResultsContacts => 'noSearchResultsContacts'.tr;
  static String get noSearchResultsGroup => 'noSearchResultsGroup'.tr;
  static String get noSearchResultsMessages => 'noSearchResultsMessages'.tr;
  static String get noSearchResultsFiles => 'noSearchResultsFiles'.tr;
  static String get pleaseEnterToSearchContacts =>
      'pleaseEnterToSearchContacts'.tr;
  static String get pleaseEnterToSearchGroup => 'pleaseEnterToSearchGroup'.tr;
  static String get pleaseEnterToSearchMessages =>
      'pleaseEnterToSearchMessages'.tr;
  static String get pleaseEnterToSearchFiles => 'pleaseEnterToSearchFiles'.tr;

  static String get organizationStructure => 'organizationStructure'.tr;

  static String get recentConversations => 'recentConversations'.tr;

  static String get selectAll => 'selectAll'.tr;

  static String get plsEnterGroupNameHint => 'plsEnterGroupNameHint'.tr;

  static String get completeCreation => 'completeCreation'.tr;

  static String get sendCarteConfirmHint => 'sendCarteConfirmHint'.tr;

  static String get sentSeparatelyTo => 'sentSeparatelyTo'.tr;

  static String get sentTo => 'sentTo'.tr;

  static String get leaveMessage => 'leaveMessage'.tr;

  static String get mergeForwardHint => 'mergeForwardHint'.tr;

  static String get mergeForward => 'mergeForward'.tr;

  static String get quicklyFindChatHistory => 'quicklyFindChatHistory'.tr;

  static String get notFoundChatHistory => 'notFoundChatHistory'.tr;

  static String get globalSearch => 'globalSearch'.tr;

  static String get globalSearchAll => 'globalSearchAll'.tr;

  static String get globalSearchContacts => 'globalSearchContacts'.tr;

  static String get globalSearchGroup => 'globalSearchGroup'.tr;

  static String get globalSearchChatHistory => 'globalSearchChatHistory'.tr;

  static String get globalSearchChatFile => 'globalSearchChatFile'.tr;

  static String get from => 'from'.tr;

  static String get relatedChatHistory => 'relatedChatHistory'.tr;

  static String get seeMoreRelatedContacts => 'seeMoreRelatedContacts'.tr;

  static String get seeMoreRelatedGroup => 'seeMoreRelatedGroup'.tr;

  static String get seeMoreRelatedChatHistory => 'seeMoreRelatedChatHistory'.tr;

  static String get seeMoreRelatedFile => 'seeMoreRelatedFile'.tr;

  static String get mentioned => 'mentioned'.tr;

  static String get comment => 'comment'.tr;

  static String get reply => 'reply'.tr;

  static String get rollUp => 'rollUp'.tr;

  static String get fullText => 'fullText'.tr;

  static String get selectAssetsFromCamera => 'selectAssetsFromCamera'.tr;

  static String get selectAssetsFromAlbum => 'selectAssetsFromAlbum'.tr;

  static String get selectAssetsFirst => 'selectAssetsFirst'.tr;

  static String get selectVideoLimit => 'selectVideoLimit'.tr;

  static String get selectContactsLimit => 'selectContactsLimit'.tr;
  static String get selectContacts => 'selectContacts'.tr;
  static String get selectContactsMinimum => 'selectContactsMinimum'.tr;
  static String get chooseFriendsAndGroups => 'chooseFriendsAndGroups'.tr;

  static String get quickActions => 'quickActions'.tr;

  static String get message => 'message'.tr;

  static String get messages => 'messages'.tr;

  static String get commentedYou => 'commentedYou'.tr;
  static String get commentedWho => 'commentedWho'.tr;

  static String get likedYou => 'likedYou'.tr;

  static String get mentionedYou => 'mentionedYou'.tr;
  static String get mentionedWho => 'mentionedWho'.tr;

  static String get replied => 'replied'.tr;

  static String get detail => 'detail'.tr;

  static String get totalNPicture => 'totalNPicture'.tr;

  static String get microphone => 'microphone'.tr;

  static String get speaker => 'speaker'.tr;

  static String get settings => 'settings'.tr;

  static String get notSendMessageNotInGroup => 'notSendMessageNotInGroup'.tr;

  static String get whoModifyGroupName => 'whoModifyGroupName'.tr;

  static String get accountWarn => 'accountWarn'.tr;

  static String get accountException => 'accountException'.tr;

  static String get tagGroup => 'tagGroup'.tr;

  static String get issueNotice => 'issueNotice'.tr;

  static String get createTagGroup => 'createTagGroup'.tr;

  static String get plsEnterTagGroupName => 'plsEnterTagGroupName'.tr;

  static String get tagGroupMember => 'tagGroupMember'.tr;

  static String get completeEdit => 'completeEdit'.tr;

  static String get emptyTagGroup => 'emptyTagGroup'.tr;

  static String get confirmDelTagGroupHint => 'confirmDelTagGroupHint'.tr;

  static String get editTagGroup => 'editTagGroup'.tr;

  static String get newBuild => 'newBuild'.tr;

  static String get receiveMember => 'receiveMember'.tr;

  static String get emptyNotification => 'emptyNotification'.tr;

  static String get notificationReceiver => 'notificationReceiver'.tr;

  static String get sendAnother => 'sendAnother'.tr;

  static String get confirmDelTagNotificationHint =>
      'confirmDelTagNotificationHint'.tr;

  static String get contentNotBlank => 'contentNotBlank'.tr;

  static String get plsEnterDescription => 'plsEnterDescription'.tr;

  static String get gifNotSupported => 'gifNotSupported'.tr;

  static String get lookOver => 'lookOver'.tr;

  static String get groupRequestHandled => 'groupRequestHandled'.tr;

  static String get talkTooShort => 'talkTooShort'.tr;

  static String get quoteContentBeRevoked => 'quoteContentBeRevoked'.tr;

  static String get tapTooShort => 'tapTooShort'.tr;
  static String get createGroupTips => 'createGroupTips'.tr;
  static String get likedWho => 'likedWho'.tr;
  static String get otherCallHandle => 'otherCallHandle'.tr;
  static String get uploadErrorLog => 'uploadErrorLog'.tr;
  static String get uploaded => 'uploaded'.tr;
  static String get uploadLogWithLine => 'uploadLogWithLine'.tr;
  static String get setLines => 'setLines'.tr;

  static String get sdkApiAddress => 'sdkApiAddress'.tr;
  static String get sdkWsAddress => 'sdkWsAddress'.tr;
  static String get appAddress => 'appAddress'.tr;
  static String get serverAddress => 'serverAddress'.tr;
  static String get switchToIP => 'switchToIP'.tr;
  static String get switchToDomain => 'switchToDomain'.tr;
  static String get serverSettingTips => 'serverSettingTips'.tr;
  static String get logLevel => 'logLevel'.tr;
  static String get callFail => 'callFail'.tr;
  static String get searchByPhoneAndUid => 'search_by_phone_and_uid'.tr;
  static String get specialMessage => 'special_message'.tr;
  static String get editGroupName => 'edit_group_name'.tr;
  static String get editGroupTips => 'edit_group_tips'.tr;
  static String get tokenInvalid => 'tokenInvalid'.tr;
  static String get supportsTypeHint => 'supportsTypeHint'.tr;
  static String get permissionDeniedTitle => 'permissionDeniedTitle'.tr;
  static String get permissionDeniedHint => 'permissionDeniedHint'.tr;
  static String get goToSettings => 'goToSettings'.tr;
  static String get camera => 'camera'.tr;
  static String get gallery => 'gallery'.tr;

  // Conversation page
  static String get selectAction => 'selectAction'.tr;
  static String get networkUnavailable => 'networkUnavailable'.tr;
  static String get checkNetworkSettings => 'checkNetworkSettings'.tr;
  static String get notification => 'notification'.tr;
  static String get externalStorage => 'externalStorage'.tr;
  static String get monday => 'monday'.tr;
  static String get tuesday => 'tuesday'.tr;
  static String get wednesday => 'wednesday'.tr;
  static String get thursday => 'thursday'.tr;
  static String get friday => 'friday'.tr;
  static String get saturday => 'saturday'.tr;
  static String get sunday => 'sunday'.tr;
  static String get hasBeenSet => 'hasBeenSet'.tr;

  static String get voiceMotivation => 'voiceMotivation'.tr;
  static String get voiceMotivationHint => 'voiceMotivationHint'.tr;

  static String get today => 'today'.tr;

  static String get restore => 'restore'.tr;
  static String get done => 'done'.tr;
  static String get networkNotStable => 'networkNotStable'.tr;
  static String get otherNetworkNotStableHint => 'otherNetworkNotStableHint'.tr;
  static String get callingInterruption => 'callingInterruption'.tr;

  static String get appeal => 'appeal'.tr;

  static String get tasks => 'tasks'.tr;

  static String get title => 'title'.tr;
  static String get content => 'Content'.tr;

  static String get noUnreadMessages => 'noUnreadMessages'.tr;

  static String get allMessagesRead => 'allMessagesRead'.tr;

  // Group Settings translations
  static String get groupMembers => 'groupMembers'.tr;
  static String get groupInformation => 'groupInformation'.tr;
  static String get memberSettings => 'memberSettings'.tr;
  static String get nicknameInGroup => 'nicknameInGroup'.tr;
  static String get chatSettings => 'chatSettings'.tr;
  static String get actions => 'actions'.tr;
  static String get idLabel => 'idLabel'.tr;

  static String get nOthers => 'nOthers'.tr;
  static String get personalChatSettings => 'personalChatSettings'.tr;
  static String get userInformation => 'userInformation'.tr;
  static String get appearance => 'appearance'.tr;
  static String get notificationSettings => 'notificationSettings'.tr;
  static String get privacySettings => 'privacySettings'.tr;
  static String get securitySettings => 'securitySettings'.tr;
  static String get dangerZone => 'dangerZone'.tr;

  // Blacklist related strings
  static String get removeFromBlacklist => 'removeFromBlacklist'.tr;
  static String get confirmRemoveFromBlacklist =>
      'confirmRemoveFromBlacklist'.tr;
  static String get noBlockedContactsFound => 'noBlockedContactsFound'.tr;

  static String get updatedAt => 'updatedAt'.tr;
  static String get fileNotFound => 'fileNotFound'.tr;
  static String get permissionDenied => 'permissionDenied'.tr;

  // Missing translations
  static String get editInfo => 'editInfo'.tr;
  static String get yourName => 'yourName'.tr;
  static String get yourNickname => 'yourNickname'.tr;
  static String get emailAddress => 'emailAddress'.tr;
  static String get enterYourName => 'enterYourName'.tr;
  static String get enterYourNickname => 'enterYourNickname'.tr;
  static String get enterYourPhoneNumber => 'enterYourPhoneNumber'.tr;
  static String get enterYourEmailAddress => 'enterYourEmailAddress'.tr;
  static String get enterInformation => 'enterInformation'.tr;
  static String get contactInfo => 'contactInfo'.tr;
  static String get playbackSpeed => 'playbackSpeed'.tr;
  static String get live => 'live'.tr;

  // Month names
  static String get january => 'january'.tr;
  static String get february => 'february'.tr;
  static String get march => 'march'.tr;
  static String get april => 'april'.tr;
  static String get may => 'may'.tr;
  static String get june => 'june'.tr;
  static String get july => 'july'.tr;
  static String get august => 'august'.tr;
  static String get september => 'september'.tr;
  static String get october => 'october'.tr;
  static String get november => 'november'.tr;
  static String get december => 'december'.tr;

  // Additional missing translations
  static String get profile => 'profile'.tr;
  static String get unknown => 'unknown'.tr;

  // New translations for hardcoded texts
  static String get knowledgeCard => 'knowledgeCard'.tr;
  static String get tryAnother => 'tryAnother'.tr;
  static String get idCopied => 'idCopied'.tr;
  static String get personalSettings => 'personalSettings'.tr;
  static String get aboutSection => 'aboutSection'.tr;
  static String get systemSection => 'systemSection'.tr;
  static String get userIdLabel => 'userIdLabel'.tr;
  static String get switchRoute => 'switchRoute'.tr;
  static String get enterPasswordToDisableTeenMode =>
      'enterPasswordToDisableTeenMode'.tr;
  static String get enterTeenModePassword => 'enterTeenModePassword'.tr;
  static String get resetInput => 'resetInput'.tr;
  static String get onlineInfo => 'onlineInfo'.tr;
  static String get neverExpires => 'neverExpires'.tr;
  static String get sevenDays => 'sevenDays'.tr;
  static String get thirtyDays => 'thirtyDays'.tr;
  static String get disableTeenMode => 'disableTeenMode'.tr;
  static String get confirmDisableTeenMode => 'confirmDisableTeenMode'.tr;
  static String get enableTeenMode => 'enableTeenMode'.tr;
  static String get confirmEnableTeenMode => 'confirmEnableTeenMode'.tr;
  static String get currentlyOnline => 'currentlyOnline'.tr;
  static String get onlineLast24Hours => 'onlineLast24Hours'.tr;
  static String get onlineLast3Days => 'onlineLast3Days'.tr;
  static String get onlineLast7Days => 'onlineLast7Days'.tr;

  // Login and registration screen translations
  static String get loginTitle => 'loginTitle'.tr;
  static String get loginSubtitle => 'loginSubtitle'.tr;
  static String get noAccountYetQuestion => 'noAccountYetQuestion'.tr;
  static String get goToRegister => 'goToRegister'.tr;
  static String get contactUs => 'contactUs'.tr;
  static String get phoneNumberHint => 'phoneNumberHint'.tr;
  static String get passwordHint => 'passwordHint'.tr;
  static String get nicknameHint => 'nicknameHint'.tr;
  static String get confirmPasswordHint => 'confirmPasswordHint'.tr;
  static String get smsVerificationCodeHint => 'smsVerificationCodeHint'.tr;
  static String get inviteCodeHint => 'inviteCodeHint'.tr;
  static String get forgotPasswordQuestion => 'forgotPasswordQuestion'.tr;
  static String get createAccount => 'createAccount'.tr;
  static String get createPassword => 'createPassword'.tr;
  static String get pleaseEnterPhoneNumber => 'pleaseEnterPhoneNumber'.tr;
  static String get pleaseEnterValidPhoneNumber =>
      'pleaseEnterValidPhoneNumber'.tr;
  static String get pleaseEnterValidName => 'pleaseEnterValidName'.tr;
  static String get nicknameIsLimited => 'nicknameIsLimited'.tr;
  static String get pleaseEnterValidPassword => 'pleaseEnterValidPassword'.tr;
  static String get pleaseEnterVerificationCode =>
      'pleaseEnterVerificationCode'.tr;
  static String get passwordMismatch => 'passwordMismatch'.tr;
  static String get termsAgree => 'termsAgree'.tr;
  static String get privacyPolicyDoc => 'privacyPolicyDoc'.tr;

  // Register screen translations
  static String get welcomeToJianXin => 'welcomeToJianXin'.tr;
  static String get registerSubtitle => 'registerSubtitle'.tr;
  static String get alreadyHaveAccount => 'alreadyHaveAccount'.tr;
  static String get loginLink => 'loginLink'.tr;

  // Additional hardcoded text translations
  static String get cannotRecognize => 'cannotRecognize'.tr;
  static String get scanResult => 'scanResult'.tr;
  static String get bindSuccess => 'bindSuccess'.tr;
  static String get pleaseEnterAppealContent => 'pleaseEnterAppealContent'.tr;
  static String get teenModeEnabled => 'teenModeEnabled'.tr;
  static String get pleaseEnterCorrectPhoneNumber =>
      'pleaseEnterCorrectPhoneNumber'.tr;
  static String get verificationCodeSent => 'verificationCodeSent'.tr;
  static String get verificationCodeSendFailed =>
      'verificationCodeSendFailed'.tr;
  static String get gentleReminder => 'gentleReminder'.tr;
  static String get confirmNoInviteCodeContent =>
      'confirmNoInviteCodeContent'.tr;
  static String get fillInvitationCode => 'fillInvitationCode'.tr;
  static String get yourVerificationCodeIs => 'yourVerificationCodeIs'.tr;
  static String get friendDeletedSuccessfully => 'friendDeletedSuccessfully'.tr;
  static String get addedBlacklistSuccessfully =>
      'addedBlacklistSuccessfully'.tr;
  static String get removedBlacklistSuccessfully =>
      'removedBlacklistSuccessfully'.tr;
  static String get avatarUpdatedSuccessfully => 'avatarUpdatedSuccessfully'.tr;
  static String get genderUpdatedSuccessfully => 'genderUpdatedSuccessfully'.tr;
  static String get birthdayUpdatedSuccessfully =>
      'birthdayUpdatedSuccessfully'.tr;
  static String get nicknameUpdatedSuccessfully =>
      'nicknameUpdatedSuccessfully'.tr;
  static String get phoneUpdatedSuccessfully => 'phoneUpdatedSuccessfully'.tr;
  static String get emailUpdatedSuccessfully => 'emailUpdatedSuccessfully'.tr;
  static String get groupAvatarUpdatedSuccessfully =>
      'groupAvatarUpdatedSuccessfully'.tr;
  static String get avatarUpdateFailed => 'avatarUpdateFailed'.tr;
  static String get genderUpdateFailed => 'genderUpdateFailed'.tr;
  static String get birthdayUpdateFailed => 'birthdayUpdateFailed'.tr;
  static String get nicknameUpdateFailed => 'nicknameUpdateFailed'.tr;
  static String get phoneUpdateFailed => 'phoneUpdateFailed'.tr;
  static String get emailUpdateFailed => 'emailUpdateFailed'.tr;
  static String get groupAvatarUpdateFailed => 'groupAvatarUpdateFailed'.tr;
  static String get pleaseEnterReportContent => 'pleaseEnterReportContent'.tr;
  static String get youHaveNotAgreed => 'youHaveNotAgreed'.tr;
  static String get resetSuccessful => 'resetSuccessful'.tr;
  static String get loginEnterpriseFailedNoCredentials =>
      'loginEnterpriseFailedNoCredentials'.tr;
  static String get domainChanged => 'domainChanged'.tr;
  static String get sendTooFrequent => 'sendTooFrequent'.tr;
  static String get noPermissionToRevoke => 'noPermissionToRevoke'.tr;
  static String get oneDayLabel => 'oneDay'.tr;
  static String get sevenDaysLabel => 'sevenDays'.tr;
  static String get thirtyDaysLabel => 'thirtyDays'.tr;
  static String get neverExpiresLabel => 'neverExpires'.tr;
  static String get unauthenticated => 'unauthenticated'.tr;
  static String get basicAuthentication => 'basicAuthentication'.tr;
  static String get advancedAuthentication => 'advancedAuthentication'.tr;
  static String get searchLabel => 'search'.tr;
  static String get todayLabel => 'todayLabel'.tr;
  static String get yesterdayLabel => 'yesterdayLabel'.tr;
  static String get weekdayPrefix => 'weekdayPrefix'.tr;
  static String get monthSuffix => 'monthSuffix'.tr;
  static String get liveLabel => 'live'.tr;
  static String get restrictedAccess => 'restrictedAccess'.tr;
  static String get restrictionPeriod => 'restrictionPeriod'.tr;
  static String get restrictionDetails => 'restrictionDetails'.tr;
  static String get newRouteDetected => 'newRouteDetected'.tr;
  static String get switchToThisRoute => 'switchToThisRoute'.tr;

  // Emoji Selector
  static String get loadingEmojis => 'loadingEmojis'.tr;
  static String get searchForEmojis => 'searchForEmojis'.tr;
  static String get smileysAndPeople => 'smileysAndPeople'.tr;
  static String get animalsAndNature => 'animalsAndNature'.tr;
  static String get foodAndDrink => 'foodAndDrink'.tr;
  static String get activity => 'activity'.tr;
  static String get travelAndPlaces => 'travelAndPlaces'.tr;
  static String get objects => 'objects'.tr;
  static String get symbols => 'symbols'.tr;
  static String get flags => 'flags'.tr;

  // QR Scanner and Hardcoded text translations
  static String get cameraFlashlightOff => 'camera_flashlight_off'.tr;
  static String get cameraFlashlightOn => 'camera_flashlight_on'.tr;

  // New messages count
  static String get newMessageCount => 'newMessageCount'.tr;
  static String get newMessagesCount => 'newMessagesCount'.tr;

  // Chat Analytics
  static String get chatAnalytics => 'chatAnalytics'.tr;
  static String get loadingChatData => 'loadingChatData'.tr;
  static String get onlineStatus => 'onlineStatus'.tr;
  static String get offlineStatus => 'offlineStatus'.tr;
  static String get totalMessages => 'totalMessages'.tr;
  static String get sent => 'sent'.tr;
  static String get conversations => 'conversations'.tr;
  static String get friends => 'friends'.tr;
  static String get groups => 'groups'.tr;
  static String get sevenDayActivity => 'sevenDayActivity'.tr;
  static String get messageTypes => 'messageTypes'.tr;
  static String get topFriends => 'topFriends'.tr;
  static String get noFriendData => 'noFriendData'.tr;
  static String get messagesCount => 'messagesCount'.tr;
  static String get topGroups => 'topGroups'.tr;
  static String get noGroupData => 'noGroupData'.tr;
  static String get noData => 'noData'.tr;
  static String get textMessages => 'textMessages'.tr;
  static String get imageMessages => 'imageMessages'.tr;
  static String get voiceMessages => 'voiceMessages'.tr;
  static String get videoMessages => 'videoMessages'.tr;
  static String get fileMessages => 'fileMessages'.tr;
  static String get otherMessages => 'otherMessages'.tr;

  // New translations for untranslated strings
  static String get appDescription => 'appDescription'.tr;
  static String get restrictedUseReason => 'restrictedUseReason'.tr;
  static String get enterAppealDetails => 'enterAppealDetails'.tr;
  static String get phoneLabel => 'phoneLabel'.tr;
  static String get passwordLabel => 'passwordLabel'.tr;

  // Report and Appeal Dialog Texts
  static String get reportImages => 'reportImages'.tr;
  static String get reportConfirmTitle => 'reportConfirmTitle'.tr;
  static String get reportSubmittedTitle => 'reportSubmittedTitle'.tr;
  static String get reportSubmittedContent => 'reportSubmittedContent'.tr;
  static String get appealSubmittedTitle => 'appealSubmittedTitle'.tr;
  static String get appealSubmittedContent => 'appealSubmittedContent'.tr;

  // Web Search translations
  static String get webSearch => 'webSearch'.tr;
  static String get searchOnWeb => 'searchOnWeb'.tr;
  static String get searchOrEnterUrl => 'searchOrEnterUrl'.tr;
  static String get browseHistory => 'browseHistory'.tr;
  static String get noHistory => 'noHistory'.tr;
  static String get searchHistory => 'searchHistory'.tr;
  static String get videoUnavailable => 'videoUnavailable'.tr;
  static String get openInOtherApp => 'openInOtherApp'.tr;
  static String get tryAgain => 'tryAgain'.tr;
  static String get videoFormatNotSupported => 'videoFormatNotSupported'.tr;
  static String get unableToOpenFile => 'unableToOpenFile'.tr;
  static String get fileOpenErrorMessage => 'fileOpenErrorMessage'.tr;
  static String get showWebSearchButton => 'showWebSearchButton'.tr;

  // Report reason selection titles
  static String get reportSelectGroupReason => 'reportSelectGroupReason'.tr;
  static String get reportSelectUserReason => 'reportSelectUserReason'.tr;

  // Report reason categories
  static String get reportCategorySpamAndAds => 'reportCategorySpamAndAds'.tr;
  static String get reportCategoryFraudAndSecurity =>
      'reportCategoryFraudAndSecurity'.tr;
  static String get reportCategoryInappropriateContent =>
      'reportCategoryInappropriateContent'.tr;
  static String get reportCategoryHarassmentAndBullying =>
      'reportCategoryHarassmentAndBullying'.tr;
  static String get reportCategoryPrivacyAndRights =>
      'reportCategoryPrivacyAndRights'.tr;
  static String get reportCategoryMinorProtection =>
      'reportCategoryMinorProtection'.tr;
  static String get reportCategoryOther => 'reportCategoryOther'.tr;

  // Report reasons (options)
  static String get reportReasonMaliciousAds => 'reportReasonMaliciousAds'.tr;
  static String get reportReasonMassSpamming => 'reportReasonMassSpamming'.tr;
  static String get reportReasonMisleadingAds => 'reportReasonMisleadingAds'.tr;
  static String get reportReasonMaliciousMassInvites =>
      'reportReasonMaliciousMassInvites'.tr;

  static String get reportReasonFraudImpersonation =>
      'reportReasonFraudImpersonation'.tr;
  static String get reportReasonPhishingMalware =>
      'reportReasonPhishingMalware'.tr;
  static String get reportReasonIdentityImpersonation =>
      'reportReasonIdentityImpersonation'.tr;

  static String get reportReasonPornographicContent =>
      'reportReasonPornographicContent'.tr;
  static String get reportReasonViolentGoreContent =>
      'reportReasonViolentGoreContent'.tr;
  static String get reportReasonHateOrExtremistSpeech =>
      'reportReasonHateOrExtremistSpeech'.tr;
  static String get reportReasonPoliticallySensitiveViolation =>
      'reportReasonPoliticallySensitiveViolation'.tr;

  static String get reportReasonInsultsPersonalAttacks =>
      'reportReasonInsultsPersonalAttacks'.tr;
  static String get reportReasonHarassmentSexualHarassment =>
      'reportReasonHarassmentSexualHarassment'.tr;
  static String get reportReasonBaitingBehavior =>
      'reportReasonBaitingBehavior'.tr;

  static String get reportReasonPrivacyLeak => 'reportReasonPrivacyLeak'.tr;
  static String get reportReasonCopyrightInfringement =>
      'reportReasonCopyrightInfringement'.tr;

  static String get reportReasonInducingMinorViolation =>
      'reportReasonInducingMinorViolation'.tr;
  static String get reportReasonInappropriateForMinors =>
      'reportReasonInappropriateForMinors'.tr;

  static String get reportReasonAbuseReportingFunction =>
      'reportReasonAbuseReportingFunction'.tr;
  static String get reportReasonInsultPlatformAdmin =>
      'reportReasonInsultPlatformAdmin'.tr;
  static String get reportReasonSeriouslyAffectsExperience =>
      'reportReasonSeriouslyAffectsExperience'.tr;

  // Report submit page labels
  static String get reportReasonLabel => 'reportReasonLabel'.tr;
  static String get detailedDescriptionLabel => 'detailedDescriptionLabel'.tr;
  static String get enterDetailedReportContent =>
      'enterDetailedReportContent'.tr;

  // Search date picker
  static String get selectSearchDate => 'selectSearchDate'.tr;
  // Real-name Authentication strings
  static String get realNameAuth => 'realNameAuth'.tr;
  static String get identityVerification => 'identityVerification'.tr;
  static String get profileAndSettings => 'profileAndSettings'.tr;
  static String get updateYourPassword => 'updateYourPassword'.tr;
  static String get usageAnalyticsInsights => 'usageAnalyticsInsights'.tr;
  static String get editYourInformation => 'editYourInformation'.tr;
  static String get appInformation => 'appInformation'.tr;
  static String get settingsAndPrivacy => 'settingsAndPrivacy'.tr;
  static String get chooseYourLanguage => 'chooseYourLanguage'.tr;
  static String get blockedContacts => 'blockedContacts'.tr;
  static String get shareYourQRCode => 'shareYourQRCode'.tr;
  static String get groupBannedMessage => 'groupBannedMessage'.tr;
  static String get unreadConversations => 'unreadConversations'.tr;
  static String get unreadMessages => 'unreadMessages'.tr;
  static String get pinnedChats => 'pinnedChats'.tr;
  static String get chats => 'chats'.tr;
  static String get realNameAuthRequired => 'realNameAuthRequired'.tr;
  static String get realNameAuthStatus => 'realNameAuthStatus'.tr;
  static String get realNameAuthNotSubmitted => 'realNameAuthNotSubmitted'.tr;
  static String get realNameAuthUnderReview => 'realNameAuthUnderReview'.tr;
  static String get realNameAuthApproved => 'realNameAuthApproved'.tr;
  static String get realNameAuthRejected => 'realNameAuthRejected'.tr;
  static String get realNameAuthRequiredForGroup =>
      'realNameAuthRequiredForGroup'.tr;
  static String get goToRealNameAuth => 'goToRealNameAuth'.tr;

  // Real-name Authentication form strings
  static String get realNamePersonalInfo => 'realNamePersonalInfo'.tr;
  static String get realName => 'realName'.tr;
  static String get plsEnterRealName => 'plsEnterRealName'.tr;
  static String get realNameIdCardNumber => 'realNameIdCardNumber'.tr;
  static String get plsEnterIdCardNumber => 'plsEnterIdCardNumber'.tr;
  static String get plsEnter18DigitIdCard => 'plsEnter18DigitIdCard'.tr;
  static String get idCardPhotos => 'idCardPhotos'.tr;
  static String get idCardFront => 'idCardFront'.tr;
  static String get idCardBack => 'idCardBack'.tr;
  static String get idCardHolding => 'idCardHolding'.tr;
  static String get plsEnsurePhotoClarity => 'plsEnsurePhotoClarity'.tr;
  static String get submitAuth => 'submitAuth'.tr;
  static String get resubmitAuth => 'resubmitAuth'.tr;
  static String get authTime => 'authTime'.tr;
  static String get notSubmittedYet => 'notSubmittedYet'.tr;
  static String get underReview => 'underReview'.tr;
  static String get realNameApproved => 'realNameApproved'.tr;
  static String get realNameRejected => 'realNameRejected'.tr;
  static String get rejectionReason => 'rejectionReason'.tr;

  // Real-name Authentication validation strings
  static String get plsEnterRealNamePrompt => 'plsEnterRealNamePrompt'.tr;
  static String get plsEnterValidIdCardNumber => 'plsEnterValidIdCardNumber'.tr;
  static String get plsUploadIdCardFront => 'plsUploadIdCardFront'.tr;
  static String get plsUploadIdCardBack => 'plsUploadIdCardBack'.tr;
  static String get plsUploadIdCardHolding => 'plsUploadIdCardHolding'.tr;

  // Real-name Authentication messages
  static String get getAuthInfoFailed => 'getAuthInfoFailed'.tr;
  static String get uploadFailed => 'uploadFailed'.tr;
  static String get alreadySubmittedAuth => 'alreadySubmittedAuth'.tr;
  static String get submitSuccess => 'submitSuccess'.tr;
  static String get submitFailed => 'submitFailed'.tr;
  static String get clickToShoot => 'clickToShoot'.tr;
  static String get reviewFailedReason => 'reviewFailedReason'.tr;
  static String get noReasonProvided => 'noReasonProvided'.tr;
  static String get realNameAuthInfo => 'realNameAuthInfo'.tr;
  static String get realNameAuthName => 'realNameAuthName'.tr;
  static String get realNameIdNumber => 'realNameIdNumber'.tr;

  // AI Chat
  static String get aiAssistant => 'aiAssistant'.tr;
  static String get startConversationWithAI => 'startConversationWithAI'.tr;
  static String get typeYourMessage => 'typeYourMessage'.tr;
  static String get clearAIChatHistory => 'clearAIChatHistory'.tr;
  static String get clearAIChatHistoryConfirm => 'clearAIChatHistoryConfirm'.tr;
  static String get noGroupChatsYet => 'noGroupChatsYet'.tr;
  static String get noMessagesOnThatDay => 'noMessagesOnThatDay'.tr;
  static String get noFriendsYet => 'noFriendsYet'.tr;

  static String get pleaseEnterEnterpriseCodeToContinue =>
      'pleaseEnterEnterpriseCodeToContinue'.tr;
  static String get enter => 'enter'.tr;

  // Remember password
  static String get rememberPassword => 'rememberPassword'.tr;

  // Conversation list
  static String get loading => 'loading'.tr;
  static String get noMoreConversations => 'noMoreConversations'.tr;

  // Global search
  static String get pleaseEnterToSearch => 'pleaseEnterToSearch'.tr;
  static String get selectAllMaxUserHint => 'selectAllMaxUserHint'.tr;
  static String get selectAllMaxUserConfirm => 'selectAllMaxUserConfirm'.tr;

  static String get createGroupMinMemberHint => 'createGroupMinMemberHint'.tr;
  static String get maxAtUserHint => 'maxAtUserHint'.tr;
  static String get cannotSelectEveryoneWithOthers =>
      'cannotSelectEveryoneWithOthers'.tr;
  static String get cannotSelectEveryoneWithOthersContent =>
      'cannotSelectEveryoneWithOthersContent'.tr;
  static String get doYouWantToRemoveOtherMembers =>
      'doYouWantToRemoveOtherMembers'.tr;
  static String get addMeAsFriend => 'addMeAsFriend'.tr;
  static String get acceptMeJoin => 'acceptMeJoin'.tr;

  // QR Scan error messages
  static String get invalidQRCode => 'invalidQRCode'.tr;
  static String get invalidQRImage => 'invalidQRImage'.tr;
}
