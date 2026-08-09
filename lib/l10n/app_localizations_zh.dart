// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class SZh extends S {
  SZh([String locale = 'zh']) : super(locale);

  @override
  String get appSubtitle => '墨西哥租房真实评价';

  @override
  String get emailLabel => '电子邮件';

  @override
  String get passwordLabel => '密码';

  @override
  String get confirmPasswordLabel => '确认密码';

  @override
  String get loginButton => '登录';

  @override
  String get registerButton => '注册';

  @override
  String get createAccount => '创建新账户';

  @override
  String get passwordMismatch => '密码不匹配';

  @override
  String get passwordMinLength => '最少6个字符';

  @override
  String get emailInvalid => '请输入有效的电子邮件';

  @override
  String get tabHome => '首页';

  @override
  String get tabMap => '地图';

  @override
  String get tabMyReviews => '我的评价';

  @override
  String get newReview => '写评价';

  @override
  String get searchHint => '按地址或小区搜索…';

  @override
  String get noReviewsYet => '暂无评价';

  @override
  String noResultsFor(String query) {
    return '\"$query\"无搜索结果';
  }

  @override
  String get mapTitle => '评价地图';

  @override
  String reviewCount(int count) {
    return '$count条评价';
  }

  @override
  String get legendGood => '★ 4–5  好';

  @override
  String get legendRegular => '★ 3–4  一般';

  @override
  String get legendBad => '★ 1–3  差';

  @override
  String get centerMap => '居中地图';

  @override
  String get myReviewsEmpty => '您还没有写过评价';

  @override
  String get myReviewsEmptyHint => '点击「写评价」开始吧';

  @override
  String get editReview => '编辑评价';

  @override
  String get deleteReview => '删除评价';

  @override
  String get deleteConfirmTitle => '删除评价';

  @override
  String get deleteConfirmBody => '确定要删除这条评价吗？';

  @override
  String get cancel => '取消';

  @override
  String get delete => '删除';

  @override
  String get logout => '退出登录';

  @override
  String get settingsTitle => '设置';

  @override
  String get languageLabel => '语言';

  @override
  String get detailTitle => '评价详情';

  @override
  String get overallOf5 => '/ 5.0';

  @override
  String get moveIn => '入住';

  @override
  String get moveOut => '搬出';

  @override
  String get rent => '租金';

  @override
  String get contractSection => '合同详情';

  @override
  String get comprobanteSection => '付款证明';

  @override
  String get comprobanteOptional => '可选 · 您的评价将显示「已附文件」徽章';

  @override
  String get uploadComprobante => '上传付款证明（图片或PDF）';

  @override
  String get analyzingDoc => '正在分析文件…';

  @override
  String get removeDoc => '删除';

  @override
  String get pdfAttached => '已附PDF（无日期验证）';

  @override
  String get goodSection => '您喜欢什么？';

  @override
  String get badSection => '您不喜欢什么？';

  @override
  String get photosSection => '照片';

  @override
  String get addPhotos => '添加照片';

  @override
  String get publishButton => '发布评价';

  @override
  String get saveButton => '保存';

  @override
  String get publishAction => '发布';

  @override
  String get addressLabel => '地址';

  @override
  String get addressHint => '例：Calle Morelos 123, Centro, Querétaro';

  @override
  String get periodLabel => '租赁期间';

  @override
  String get rentLabel => '月租金（MXN）';

  @override
  String get ratingsLabel => '评分';

  @override
  String get landlordRating => '房东';

  @override
  String get conditionRating => '房屋状况';

  @override
  String get locationRating => '位置';

  @override
  String get securityRating => '安全';

  @override
  String get formalContract => '正式合同';

  @override
  String get avalRequired => '需要担保人';

  @override
  String get depositReturned => '押金已退还';

  @override
  String get utilitiesIncluded => '含水电气费';

  @override
  String get badgeVerified => '✓ 已附文件';

  @override
  String get badgeFormalContract => '正式合同';

  @override
  String get badgeAvalRequired => '需要担保人';

  @override
  String get badgeDepositNotReturned => '押金未退还';

  @override
  String get badgeUtilitiesIncluded => '含水电气费';

  @override
  String get reviewPublished => '评价已发布！';

  @override
  String get reviewUpdated => '评价已更新！';

  @override
  String get reviewDeleted => '评价已删除';

  @override
  String get selectDates => '请选择入住和搬出日期';

  @override
  String get selectAddress => '请从列表中选择地址';

  @override
  String publishedOn(String date) {
    return '发布于$date';
  }

  @override
  String get useMyLocation => '使用我的当前位置';

  @override
  String get locationPermissionDenied => '请在设置中开启位置权限';

  @override
  String get locationError => '无法获取位置';

  @override
  String get loginSignIn => '已有账户 — 登录';

  @override
  String get onb1Title => '欢迎使用RentaVoz';

  @override
  String get onb1Body => '这是租户分享墨西哥租房真实体验的平台。\n\n畅所欲言，帮助他人做出更好的决定。';

  @override
  String get onb2Title => '写评价';

  @override
  String get onb2Body => '点击「写评价」分享您的经历。\n\n对房东、房屋状况、位置和安全进行评分。您的意见很重要！';

  @override
  String get onb3Title => '验证您的评价';

  @override
  String get onb3Body => '附上付款证明让您的评价更可信。\n\n3个月内的文件将获得「已附文件」徽章。';

  @override
  String get onb4Title => '探索地图';

  @override
  String get onb4Body =>
      '租房前在地图上查看评价。\n\n🟢 绿色 = 优秀  🟡 黄色 = 一般  🔴 红色 = 差\n\n点击图钉查看详情。';

  @override
  String get onb5Title => '更新您的评价';

  @override
  String get onb5Body => '在「我的评价」中，当情况发生变化时可以编辑评价 — 例如当您收到（或没有收到）押金退还时。';

  @override
  String get skip => '跳过';

  @override
  String get next => '下一步';

  @override
  String get getStarted => '开始！';

  @override
  String get back => '返回';

  @override
  String get loginNeedAccount => '登录查看您的评价';

  @override
  String get loginToSeeReviews => '登录';

  @override
  String get swipeToDelete => '向左滑动删除 · 长按查看更多选项';

  @override
  String get translateButton => '翻译';

  @override
  String get showOriginal => '查看原文';

  @override
  String get translating => '翻译中…';

  @override
  String get translationLabel => '自动翻译';

  @override
  String get translationError => '翻译失败，请重试。';

  @override
  String get authErrNotFound => '找不到该邮箱对应的账户。';

  @override
  String get authErrWrongPw => '邮箱或密码不正确。';

  @override
  String get authErrInvalidEmail => '无效的邮箱地址。';

  @override
  String get authErrTooMany => '尝试次数过多，请稍后再试。';

  @override
  String get authErrDefault => '登录失败，请重试。';

  @override
  String get authErrEmailInUse => '该邮箱已被注册。';

  @override
  String get authErrWeakPw => '密码强度太弱。';

  @override
  String get authErrRegDefault => '账户创建失败，请重试。';

  @override
  String get forgotPassword => '忘记密码？';

  @override
  String get forgotPasswordTitle => '重置密码';

  @override
  String get forgotPasswordBody => '输入您的邮箱，我们将向您发送重置密码的链接。';

  @override
  String get forgotPasswordSend => '发送链接';

  @override
  String get forgotPasswordSent => '邮件已发送，请查看收件箱。';

  @override
  String get forgotPasswordErrNotFound => '该邮箱未注册。';

  @override
  String get forgotPasswordErrDefault => '发送失败，请重试。';

  @override
  String get rentalTypeLabel => '租赁类型';

  @override
  String get rentalTypeHouse => '整套房屋';

  @override
  String get rentalTypeRoom => '单间';

  @override
  String get sharedBathroom => '共用卫生间';

  @override
  String get sharedKitchen => '共用厨房';

  @override
  String get badgeRoom => '单间';
}
