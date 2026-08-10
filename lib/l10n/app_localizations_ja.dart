// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class SJa extends S {
  SJa([String locale = 'ja']) : super(locale);

  @override
  String get appSubtitle => 'メキシコの賃貸リアルレビュー';

  @override
  String get emailLabel => 'メールアドレス';

  @override
  String get passwordLabel => 'パスワード';

  @override
  String get confirmPasswordLabel => 'パスワード確認';

  @override
  String get loginButton => 'ログイン';

  @override
  String get registerButton => '登録';

  @override
  String get createAccount => '新しいアカウント作成';

  @override
  String get passwordMismatch => 'パスワードが一致しません';

  @override
  String get passwordMinLength => '6文字以上必要です';

  @override
  String get emailInvalid => '有効なメールアドレスを入力してください';

  @override
  String get tabHome => 'ホーム';

  @override
  String get tabMap => 'マップ';

  @override
  String get tabMyReviews => 'マイレビュー';

  @override
  String get newReview => '新規レビュー';

  @override
  String get searchHint => '住所または地区で検索…';

  @override
  String get noReviewsYet => 'まだレビューはありません';

  @override
  String noResultsFor(String query) {
    return '「$query」の検索結果なし';
  }

  @override
  String get mapTitle => 'レビューマップ';

  @override
  String reviewCount(int count) {
    return '$count件のレビュー';
  }

  @override
  String get legendGood => '★ 4–5  良い';

  @override
  String get legendRegular => '★ 3–4  普通';

  @override
  String get legendBad => '★ 1–3  悪い';

  @override
  String get centerMap => 'マップを中心に';

  @override
  String get myReviewsEmpty => 'まだレビューを書いていません';

  @override
  String get myReviewsEmptyHint => '「新規レビュー」をタップして始めましょう';

  @override
  String get editReview => 'レビューを編集';

  @override
  String get deleteReview => 'レビューを削除';

  @override
  String get deleteConfirmTitle => 'レビューを削除';

  @override
  String get deleteConfirmBody => 'このレビューを削除してもよろしいですか？';

  @override
  String get cancel => 'キャンセル';

  @override
  String get delete => '削除';

  @override
  String get logout => 'ログアウト';

  @override
  String get settingsTitle => '設定';

  @override
  String get languageLabel => '言語';

  @override
  String get detailTitle => 'レビュー詳細';

  @override
  String get overallOf5 => '/ 5.0';

  @override
  String get moveIn => '入居';

  @override
  String get moveOut => '退去';

  @override
  String get rent => '家賃';

  @override
  String get contractSection => '契約詳細';

  @override
  String get comprobanteSection => '支払い証明書';

  @override
  String get comprobanteOptional => '任意 · レビューに「書類添付」バッジが表示されます';

  @override
  String get uploadComprobante => '支払い証明書をアップロード（画像またはPDF）';

  @override
  String get analyzingDoc => '書類を分析中…';

  @override
  String get removeDoc => '削除';

  @override
  String get pdfAttached => 'PDF添付済み（日付検証なし）';

  @override
  String get goodSection => 'よかった点は？';

  @override
  String get badSection => 'よくなかった点は？';

  @override
  String get photosSection => '写真';

  @override
  String get addPhotos => '写真を追加';

  @override
  String get publishButton => 'レビューを投稿';

  @override
  String get saveButton => '保存';

  @override
  String get publishAction => '投稿';

  @override
  String get addressLabel => '住所';

  @override
  String get addressHint => '例: Calle Morelos 123, Centro, Querétaro';

  @override
  String get periodLabel => '賃貸期間';

  @override
  String get rentLabel => '月額家賃（MXN）';

  @override
  String get ratingsLabel => '評価';

  @override
  String get landlordRating => '家主';

  @override
  String get conditionRating => '物件の状態';

  @override
  String get locationRating => '立地';

  @override
  String get securityRating => '安全性';

  @override
  String get formalContract => '正式契約書';

  @override
  String get avalRequired => '保証人必要';

  @override
  String get depositReturned => '敷金返還';

  @override
  String get utilitiesIncluded => '光熱費込み（水道・電気・ガス）';

  @override
  String get badgeVerified => '✓ 書類添付';

  @override
  String get badgeFormalContract => '正式契約書';

  @override
  String get badgeAvalRequired => '保証人必要';

  @override
  String get badgeDepositNotReturned => '敷金未返還';

  @override
  String get badgeUtilitiesIncluded => '光熱費込み';

  @override
  String get reviewPublished => 'レビューを投稿しました！';

  @override
  String get reviewUpdated => 'レビューを更新しました！';

  @override
  String get reviewDeleted => 'レビューを削除しました';

  @override
  String get selectDates => '入居日と退去日を選択してください';

  @override
  String get selectAddress => 'リストから住所を選択してください';

  @override
  String publishedOn(String date) {
    return '$dateに投稿';
  }

  @override
  String get useMyLocation => '現在地を使用';

  @override
  String get locationPermissionDenied => '設定で位置情報を許可してください';

  @override
  String get locationError => '位置情報を取得できませんでした';

  @override
  String get loginSignIn => 'すでにアカウントをお持ちの方 — ログイン';

  @override
  String get onb1Title => 'RentaVozへようこそ';

  @override
  String get onb1Body =>
      'メキシコの賃貸に関する実体験を共有するプラットフォームです。\n\n自由に意見を述べて、他の方のより良い選択を助けましょう。';

  @override
  String get onb2Title => 'レビューを書く';

  @override
  String get onb2Body =>
      '「新規レビュー」をタップして経験を共有しましょう。\n\n家主、物件状態、立地、安全性を評価してください。あなたの意見が大切です！';

  @override
  String get onb3Title => 'レビューを認証する';

  @override
  String get onb3Body =>
      '支払い証明書を添付するとレビューの信頼性が高まります。\n\n3ヶ月以内の書類は「書類添付」バッジを取得できます。';

  @override
  String get onb4Title => 'マップで探す';

  @override
  String get onb4Body =>
      '賃貸前にマップでレビューを確認しましょう。\n\n🟢 緑 = 優良  🟡 黄 = 普通  🔴 赤 = 悪い経験\n\nピンをタップして詳細を確認。';

  @override
  String get onb5Title => 'レビューを更新する';

  @override
  String get onb5Body =>
      '「マイレビュー」で状況が変わった時にレビューを編集できます — 例えば敷金が返ってきた（またはこなかった）時に。';

  @override
  String get skip => 'スキップ';

  @override
  String get next => '次へ';

  @override
  String get getStarted => '始める！';

  @override
  String get back => '戻る';

  @override
  String get loginNeedAccount => 'ログインしてマイレビューを確認';

  @override
  String get loginToSeeReviews => 'ログイン';

  @override
  String get swipeToDelete => '左にスワイプで削除 · 長押しで詳細オプション';

  @override
  String get translateButton => '翻訳する';

  @override
  String get showOriginal => '原文を表示';

  @override
  String get translating => '翻訳中…';

  @override
  String get translationLabel => '自動翻訳';

  @override
  String get translationError => '翻訳に失敗しました。もう一度お試しください。';

  @override
  String get authErrNotFound => 'そのメールアドレスのアカウントが見つかりません。';

  @override
  String get authErrWrongPw => 'メールアドレスまたはパスワードが正しくありません。';

  @override
  String get authErrInvalidEmail => '無効なメールアドレスです。';

  @override
  String get authErrTooMany => '試行回数が多すぎます。しばらくしてから再試行してください。';

  @override
  String get authErrDefault => 'ログインに失敗しました。もう一度お試しください。';

  @override
  String get authErrEmailInUse => 'そのメールアドレスは既に使用されています。';

  @override
  String get authErrWeakPw => 'パスワードが弱すぎます。';

  @override
  String get authErrRegDefault => 'アカウント作成に失敗しました。もう一度お試しください。';

  @override
  String get forgotPassword => 'パスワードをお忘れですか？';

  @override
  String get forgotPasswordTitle => 'パスワードをリセット';

  @override
  String get forgotPasswordBody => 'メールアドレスを入力すると、パスワードリセット用のリンクをお送りします。';

  @override
  String get forgotPasswordSend => 'リンクを送る';

  @override
  String get forgotPasswordSent => 'メールを送信しました。受信ボックスをご確認ください。';

  @override
  String get forgotPasswordErrNotFound => 'そのメールアドレスのアカウントが見つかりません。';

  @override
  String get forgotPasswordErrDefault => 'メールの送信に失敗しました。もう一度お試しください。';

  @override
  String get filterAll => 'すべて';

  @override
  String get filterHouse => '一戸建て';

  @override
  String get filterRoom => '個室';

  @override
  String get sortNewest => '新着順';

  @override
  String get sortHighest => '評価が高い順';

  @override
  String get sortLowest => '評価が低い順';

  @override
  String get rentalTypeLabel => '賃貸タイプ';

  @override
  String get rentalTypeHouse => '一戸建て全体';

  @override
  String get rentalTypeRoom => '個室';

  @override
  String get sharedBathroom => 'バス共用';

  @override
  String get sharedKitchen => 'キッチン共用';

  @override
  String get badgeRoom => '個室';

  @override
  String get reportButton => 'レビューを報告';

  @override
  String get reportTitle => 'このレビューを報告する理由を選んでください';

  @override
  String get reportReasonFalse => '虚偽または誤解を招く情報';

  @override
  String get reportReasonSpam => 'スパムまたは広告';

  @override
  String get reportReasonInappropriate => '不適切または不快なコンテンツ';

  @override
  String get reportReasonOther => 'その他';

  @override
  String get reportSubmit => '報告を送信';

  @override
  String get reportSuccess => '報告を受け付けました。確認後に対応します。';

  @override
  String get reportAlready => 'このレビューはすでに報告済みです。';

  @override
  String get reportOwnReview => '自分のレビューは報告できません。';

  @override
  String get reportError => '報告の送信に失敗しました。もう一度お試しください。';

  @override
  String get tabProfile => 'プロフィール';

  @override
  String get profileTitle => 'マイプロフィール';

  @override
  String get profileGuest => '匿名';

  @override
  String get profileEditNameTitle => '名前を編集';

  @override
  String get profileEditNameHint => 'お名前';

  @override
  String get profileSave => '保存';

  @override
  String get profileSaveSuccess => '名前を更新しました';

  @override
  String get profileSaveError => '名前の更新に失敗しました';

  @override
  String get profileEmailLabel => 'メール';

  @override
  String profileMemberSince(String date) {
    return '$dateから利用中';
  }

  @override
  String profileReviewCount(int count) {
    return 'レビュー$count件';
  }

  @override
  String get profileAvgRating => '平均評価';

  @override
  String get profileMyReviews => 'マイレビュー';

  @override
  String get profileNoReviews => 'まだレビューを書いていません';

  @override
  String get addressReviewsTitle => 'この住所のレビュー';

  @override
  String addressReviewsCount(int count) {
    return '合計$count件のレビュー';
  }

  @override
  String addressReviewsOther(int count) {
    return 'この住所の他のレビュー$count件を見る';
  }

  @override
  String get addressReviewsNone => 'この住所の他のレビューはありません';

  @override
  String get addressReviewsAvg => '総合平均';

  @override
  String get verifyEmailTitle => 'メールアドレスの確認';

  @override
  String verifyEmailBody(String email) {
    return '$emailに確認リンクを送りました。受信箱をご確認ください。';
  }

  @override
  String get verifyEmailResend => '確認メールを再送';

  @override
  String get verifyEmailResent => '確認メールを再送しました。受信箱をご確認ください。';

  @override
  String get verifyEmailContinue => '確認済み、続ける';

  @override
  String get verifyEmailNotYet => 'まだ確認が検出されていません。メールをご確認ください。';

  @override
  String get verifyEmailRequired => 'レビューを投稿するにはメールアドレスの確認が必要です。';

  @override
  String get verifyEmailLogout => 'サインアウトして戻る';

  @override
  String get bookmarkAdd => 'レビューを保存';

  @override
  String get bookmarkRemove => '保存を解除';

  @override
  String get bookmarkAdded => '保存しました';

  @override
  String get bookmarkRemoved => '保存を解除しました';

  @override
  String get profileSavedReviews => '保存済み';

  @override
  String get profileNoSavedReviews => '保存したレビューはありません';

  @override
  String get shareReviewSubject => 'RentaVozのレビュー';

  @override
  String get shareAppPromo => 'RentaVozアプリでメキシコの賃貸リアルレビューをチェック。';

  @override
  String get shareRent => '家賃';

  @override
  String get sharePeriod => '期間';

  @override
  String get privacyPolicy => 'プライバシーポリシー';

  @override
  String get termsOfService => '利用規約';

  @override
  String get legalSection => '法的情報';

  @override
  String registerTermsConsent(String privacy, String terms) {
    return '$privacyと$termsに同意します。';
  }

  @override
  String get registerTermsRequired => '利用規約に同意する必要があります。';
}
