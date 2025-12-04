import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

class RealNameAuthLogic extends GetxController {
  final formKey = GlobalKey<FormState>();

  // Form controllers
  final realNameController = TextEditingController();
  final idCardNumberController = TextEditingController();

  // Focus nodes
  final realNameFocusNode = FocusNode();
  final idCardNumberFocusNode = FocusNode();

  // Observable variables
  final isLoading = false.obs;
  final authStatus =
      0.obs; // 0: not submitted, 1: under review, 2: approved, 3: rejected
  final authInfo = Rxn<Map<String, dynamic>>();

  final idCardFrontUrl = Rxn<String>();
  final idCardBackUrl = Rxn<String>();
  final idCardHandheldUrl = Rxn<String>();
  final showImageErrorFront = false.obs;
  final showImageErrorBack = false.obs;
  final showImageErrorHandheld = false.obs;

  final isSubmitButtonEnabled =
      false.obs; // Track if submit button should be enabled

  @override
  void onInit() {
    super.onInit();
    loadAuthInfo();

    // Listen to form changes to validate and enable/disable submit button
    realNameController.addListener(_validateForm);
    idCardNumberController.addListener(_validateForm);

    // Listen to image uploads
    ever(idCardFrontUrl, (_) => _validateForm());
    ever(idCardBackUrl, (_) => _validateForm());
    ever(idCardHandheldUrl, (_) => _validateForm());
  }

  /// Validate form and update button state
  void _validateForm() {
    final realName = realNameController.text.trim();
    final idCardNumber = idCardNumberController.text.trim();

    // Check if all required fields are filled and valid
    final isRealNameValid = realName.isNotEmpty && _isValidName(realName);
    final isIdCardValid =
        idCardNumber.isNotEmpty && validateIdCardNumber(idCardNumber);
    // Only front and back images are required (handheld is optional)
    final hasRequiredImages =
        idCardFrontUrl.value != null && idCardBackUrl.value != null;

    isSubmitButtonEnabled.value =
        isRealNameValid && isIdCardValid && hasRequiredImages;
  }

  /// Check if name is valid
  bool _isValidName(String value) {
    if (value.isEmpty || value.length > 20) {
      return false;
    }

    final allowPattern = RegExp(r"^[\u4e00-\u9fffA-Za-z\-\'·\s]+");
    if (!allowPattern.hasMatch(value)) {
      return false;
    }

    // Disallow any digits
    if (RegExp(r"\d").hasMatch(value)) {
      return false;
    }

    final emojiPattern = RegExp(
        r'[\u{1F300}-\u{1F6FF}\u{1F900}-\u{1F9FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]',
        unicode: true);
    if (emojiPattern.hasMatch(value)) {
      return false;
    }

    return true;
  }

  @override
  void onClose() {
    realNameController.dispose();
    idCardNumberController.dispose();
    realNameFocusNode.dispose();
    idCardNumberFocusNode.dispose();
    super.onClose();
  }

  /// 获取认证信息
  Future<void> loadAuthInfo(
      {bool checkSubmit = false, bool showLoading = true}) async {
    try {
      if (showLoading) isLoading.value = true;
      final result = await GatewayApi.getRealNameAuthInfo();
      authInfo.value = result;
      authStatus.value = result['status'] ?? 0;

      if ((authStatus.value == 1 || authStatus.value == 3) && checkSubmit) {
        IMViews.showToast(StrRes.submitSuccess);
      }

      // 如果已认证，填充显示信息
      if (authStatus.value >= 1) {
        realNameController.text = result['realName'] ?? '';
        idCardNumberController.text = result['idCardMasked'] ?? '';
      }
    } catch (e) {
      Logger.print('Error loading auth info: $e');
      // 如果是首次使用，可能没有数据，不显示错误
      if (!e.toString().contains('404')) {
        IMViews.showToast('${StrRes.getAuthInfoFailed}: $e');
      }
    } finally {
      if (showLoading) isLoading.value = false;
    }
  }

  /// 选择身份证正面照片
  void selectIdCardFrontImage() async {
    _unfocusAllFields();

    IMViews.openPhotoSheet(
        onlyImage: true,
        useNicknameAsAvatarEnabled: false,
        onData: (path, url) {
          if (url != null) {
            idCardFrontUrl.value = url;
            showImageErrorFront.value = false;
          }
        });
  }

  /// 从相册选择身份证正面
  void pickIdCardFrontFromGallery() async {
    _unfocusAllFields();

    IMViews.openPhotoSheet(
        onlyImage: true,
        useNicknameAsAvatarEnabled: false,
        onData: (path, url) {
          if (url != null) {
            idCardFrontUrl.value = url;
            showImageErrorFront.value = false;
          }
        });
  }

  /// 选择身份证背面照片
  void selectIdCardBackImage() async {
    _unfocusAllFields();

    IMViews.openPhotoSheet(
        onlyImage: true,
        useNicknameAsAvatarEnabled: false,
        onData: (path, url) {
          if (url != null) {
            idCardBackUrl.value = url;
            showImageErrorBack.value = false;
          }
        });
  }

  /// 从相册选择身份证背面
  void pickIdCardBackFromGallery() async {
    _unfocusAllFields();

    IMViews.openPhotoSheet(
        onlyImage: true,
        useNicknameAsAvatarEnabled: false,
        onData: (path, url) {
          if (url != null) {
            idCardBackUrl.value = url;
            showImageErrorBack.value = false;
          }
        });
  }

  /// 选择手持身份证照片
  void selectIdCardHandheldImage() async {
    _unfocusAllFields();

    IMViews.openPhotoSheet(
        onlyImage: true,
        useNicknameAsAvatarEnabled: false,
        onData: (path, url) {
          if (url != null) {
            idCardHandheldUrl.value = url;
            showImageErrorHandheld.value = false;
          }
        });
  }

  /// 从相册选择手持身份证
  void pickIdCardHandheldFromGallery() async {
    _unfocusAllFields();

    IMViews.openPhotoSheet(
        onlyImage: true,
        useNicknameAsAvatarEnabled: false,
        onData: (path, url) {
          if (url != null) {
            idCardHandheldUrl.value = url;
            showImageErrorHandheld.value = false;
          }
        });
  }

  void _unfocusAllFields() {
    realNameFocusNode.unfocus();
    idCardNumberFocusNode.unfocus();
  }

  /// 验证身份证号格式
  bool validateIdCardNumber(String idCardNumber) {
    // 移除空格和横线
    String cleanNumber =
        idCardNumber.replaceAll(RegExp(r'[\s-]'), '').toUpperCase();

    // 检查是否为18位
    if (cleanNumber.length != 18) {
      return false;
    }

    // 检查前17位是否为数字
    String first17 = cleanNumber.substring(0, 17);
    if (!RegExp(r'^\d{17}$').hasMatch(first17)) {
      return false;
    }

    // 检查最后一位是否为数字或X
    String lastChar = cleanNumber.substring(17);
    if (!RegExp(r'^[\dX]$').hasMatch(lastChar)) {
      return false;
    }

    // 验证地区码（前6位）
    String areaCode = cleanNumber.substring(0, 6);
    if (!_isValidAreaCode(areaCode)) {
      return false;
    }

    // 验证出生日期（第7-14位）
    String birthDate = cleanNumber.substring(6, 14);
    if (!_isValidBirthDate(birthDate)) {
      return false;
    }

    // 验证校验码（使用加权因子计算）
    if (!_isValidChecksum(cleanNumber)) {
      return false;
    }

    return true;
  }

  /// 验证地区码是否有效
  bool _isValidAreaCode(String areaCode) {
    // 前两位省份代码必须在有效范围内
    int provinceCode = int.parse(areaCode.substring(0, 2));

    // 中国有效的省份代码范围
    List<int> validProvinceCodes = [
      11, 12, 13, 14, 15, // 北京、天津、河北、山西、内蒙古
      21, 22, 23, // 辽宁、吉林、黑龙江
      31, 32, 33, 34, 35, 36, 37, // 上海、江苏、浙江、安徽、福建、江西、山东
      41, 42, 43, 44, 45, 46, // 河南、湖北、湖南、广东、广西、海南
      50, 51, 52, 53, 54, // 重庆、四川、贵州、云南、西藏
      61, 62, 63, 64, 65, // 陕西、甘肃、青海、宁夏、新疆
      71, // 台湾
      81, 82, // 香港、澳门
      91 // 国外
    ];

    return validProvinceCodes.contains(provinceCode);
  }

  /// 验证出生日期是否有效
  bool _isValidBirthDate(String birthDate) {
    if (!RegExp(r'^\d{8}$').hasMatch(birthDate)) return false;
    int year = int.parse(birthDate.substring(0, 4));
    int month = int.parse(birthDate.substring(4, 6));
    int day = int.parse(birthDate.substring(6, 8));
    int currentYear = DateTime.now().year;
    if (year < 1900 || year > currentYear) return false;
    if (month < 1 || month > 12) return false;
    if (day < 1 || day > 31) return false;
    try {
      DateTime date = DateTime(year, month, day);
      String check = date.year.toString().padLeft(4, '0') +
          date.month.toString().padLeft(2, '0') +
          date.day.toString().padLeft(2, '0');
      if (check != birthDate) return false;
      if (date.isAfter(DateTime.now())) return false;
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 验证校验码是否正确
  bool _isValidChecksum(String idCardNumber) {
    // 加权因子
    List<int> weights = [7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2];

    // 校验码对照表
    List<String> checksumTable = [
      '1',
      '0',
      'X',
      '9',
      '8',
      '7',
      '6',
      '5',
      '4',
      '3',
      '2'
    ];

    // 计算加权和
    int sum = 0;
    for (int i = 0; i < 17; i++) {
      sum += int.parse(idCardNumber[i]) * weights[i];
    }

    // 计算校验码
    int checksumIndex = sum % 11;
    String expectedChecksum = checksumTable[checksumIndex];
    String actualChecksum = idCardNumber[17].toUpperCase();
    return expectedChecksum == actualChecksum;
  }

  /// 验证表单 (for submit)
  bool _validateFormForSubmit() {
    !formKey.currentState!.validate();
    if (idCardFrontUrl.value == null) {
      showImageErrorFront.value = true;
    } else {
      showImageErrorFront.value = false;
    }
    if (idCardBackUrl.value == null) {
      showImageErrorBack.value = true;
    } else {
      showImageErrorBack.value = false;
    }
    if (!formKey.currentState!.validate()) {
      return false;
    }
    if (showImageErrorFront.value == true ||
        showImageErrorBack.value == true ||
        realNameController.text.trim().isEmpty ||
        !validateIdCardNumber(idCardNumberController.text.trim())) {
      return false;
    }

    return true;
  }

  // _uploadImage removed: IMViews.openPhotoSheet returns hosted URL directly.

  /// 提交实名认证
  void submitRealNameAuth() async {
    if (!(authStatus.value == 0 || authStatus.value == 3)) {
      IMViews.showToast(StrRes.alreadySubmittedAuth);
      return;
    }

    if (!_validateFormForSubmit()) {
      return;
    }

    LoadingView.singleton.wrap(asyncFunction: () async {
      try {
        final result = await GatewayApi.submitRealNameAuth(
          realName: realNameController.text.trim(),
          idCardNumber: idCardNumberController.text.trim(),
          idCardFrontUrl: idCardFrontUrl.value ?? '',
          idCardBackUrl: idCardBackUrl.value ?? '',
          idCardHandheldUrl: idCardHandheldUrl.value ?? '',
        );

        authStatus.value = result['status'] ?? 1;
        // 刷新认证信息
        await loadAuthInfo(checkSubmit: true, showLoading: false);
      } catch (e) {
        if (e is (int, String?, dynamic)) {
          LoadingView.singleton.dismiss();
          // final errCode = e.$1;
          final errMsg = e.$2;
          // final data = e.$3;
          IMViews.showToast(errMsg!);
        }
      }
    });
  }

  /// 重新提交认证 (当被拒绝时)
  void resubmitAuth() {
    authStatus.value = 0;
    idCardFrontUrl.value = null;
    idCardBackUrl.value = null;
    idCardHandheldUrl.value = null;
  }

  /// 获取状态文本
  String get statusText {
    switch (authStatus.value) {
      case 0:
        return StrRes.realNameAuthNotSubmitted;
      case 1:
        return StrRes.realNameAuthUnderReview;
      case 2:
        return StrRes.realNameAuthApproved;
      case 3:
        return StrRes.realNameAuthRejected;
      default:
        return 'Unknown';
    }
  }

  /// 获取状态颜色
  Color get statusColor {
    switch (authStatus.value) {
      case 0:
        return const Color(0xFF6B7280); // Gray
      case 1:
        return const Color(0xFFFBBF24); // Yellow
      case 2:
        return const Color(0xFF10B981); // Green
      case 3:
        return const Color(0xFFF87171); // Red
      default:
        return const Color(0xFF6B7280);
    }
  }

  /// 是否可以编辑
  bool get canEdit => authStatus.value == 0 || authStatus.value == 3;

  /// 获取拒绝原因
  String get rejectRemark => authInfo.value?['remark'] ?? '';
}
