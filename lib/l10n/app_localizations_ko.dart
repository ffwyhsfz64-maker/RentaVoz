// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class SKo extends S {
  SKo([String locale = 'ko']) : super(locale);

  @override
  String get appSubtitle => '멕시코 임대 솔직 후기';

  @override
  String get emailLabel => '이메일';

  @override
  String get passwordLabel => '비밀번호';

  @override
  String get confirmPasswordLabel => '비밀번호 확인';

  @override
  String get loginButton => '로그인';

  @override
  String get registerButton => '회원가입';

  @override
  String get createAccount => '새 계정 만들기';

  @override
  String get passwordMismatch => '비밀번호가 일치하지 않습니다';

  @override
  String get passwordMinLength => '최소 6자 이상';

  @override
  String get emailInvalid => '유효한 이메일을 입력해주세요';

  @override
  String get tabHome => '홈';

  @override
  String get tabMap => '지도';

  @override
  String get tabMyReviews => '내 리뷰';

  @override
  String get newReview => '리뷰 작성';

  @override
  String get searchHint => '주소 또는 동네로 검색…';

  @override
  String get noReviewsYet => '아직 리뷰가 없습니다';

  @override
  String noResultsFor(String query) {
    return '\"$query\" 검색 결과 없음';
  }

  @override
  String get mapTitle => '리뷰 지도';

  @override
  String reviewCount(int count) {
    return '$count개 리뷰';
  }

  @override
  String get legendGood => '★ 4–5  좋음';

  @override
  String get legendRegular => '★ 3–4  보통';

  @override
  String get legendBad => '★ 1–3  나쁨';

  @override
  String get centerMap => '지도 중심으로';

  @override
  String get myReviewsEmpty => '아직 작성한 리뷰가 없습니다';

  @override
  String get myReviewsEmptyHint => '\"리뷰 작성\"을 눌러 시작하세요';

  @override
  String get editReview => '리뷰 수정';

  @override
  String get deleteReview => '리뷰 삭제';

  @override
  String get deleteConfirmTitle => '리뷰 삭제';

  @override
  String get deleteConfirmBody => '이 리뷰를 삭제하시겠습니까?';

  @override
  String get cancel => '취소';

  @override
  String get delete => '삭제';

  @override
  String get logout => '로그아웃';

  @override
  String get settingsTitle => '설정';

  @override
  String get languageLabel => '언어';

  @override
  String get detailTitle => '리뷰 상세';

  @override
  String get overallOf5 => '/ 5.0';

  @override
  String get moveIn => '입주';

  @override
  String get moveOut => '퇴거';

  @override
  String get rent => '월세';

  @override
  String get contractSection => '계약 세부사항';

  @override
  String get comprobanteSection => '납부 증명서';

  @override
  String get comprobanteOptional => '선택 사항 · 리뷰에 \"서류 첨부\" 배지가 표시됩니다';

  @override
  String get uploadComprobante => '납부 증명서 업로드 (이미지 또는 PDF)';

  @override
  String get analyzingDoc => '문서 분석 중…';

  @override
  String get removeDoc => '제거';

  @override
  String get pdfAttached => 'PDF 첨부됨 (날짜 검증 없음)';

  @override
  String get goodSection => '좋았던 점은?';

  @override
  String get badSection => '아쉬웠던 점은?';

  @override
  String get photosSection => '사진';

  @override
  String get addPhotos => '사진 추가';

  @override
  String get publishButton => '리뷰 게시';

  @override
  String get saveButton => '저장';

  @override
  String get publishAction => '게시';

  @override
  String get addressLabel => '주소';

  @override
  String get addressHint => '예: Calle Morelos 123, Centro, Querétaro';

  @override
  String get periodLabel => '임대 기간';

  @override
  String get rentLabel => '월 임대료 (MXN)';

  @override
  String get ratingsLabel => '평점';

  @override
  String get landlordRating => '집주인';

  @override
  String get conditionRating => '집 상태';

  @override
  String get locationRating => '위치';

  @override
  String get securityRating => '안전';

  @override
  String get formalContract => '정식 계약서';

  @override
  String get avalRequired => '보증인 필요';

  @override
  String get depositReturned => '보증금 반환';

  @override
  String get utilitiesIncluded => '공과금 포함 (수도/전기/가스)';

  @override
  String get badgeVerified => '✓ 서류 첨부';

  @override
  String get badgeFormalContract => '정식 계약서';

  @override
  String get badgeAvalRequired => '보증인 필요';

  @override
  String get badgeDepositNotReturned => '보증금 미반환';

  @override
  String get badgeUtilitiesIncluded => '공과금 포함';

  @override
  String get reviewPublished => '리뷰가 게시되었습니다!';

  @override
  String get reviewUpdated => '리뷰가 수정되었습니다!';

  @override
  String get reviewDeleted => '리뷰가 삭제되었습니다';

  @override
  String get selectDates => '입주 및 퇴거 날짜를 선택해주세요';

  @override
  String get selectAddress => '목록에서 주소를 선택해주세요';

  @override
  String publishedOn(String date) {
    return '$date 게시됨';
  }

  @override
  String get useMyLocation => '현재 위치 사용';

  @override
  String get locationPermissionDenied => '설정에서 위치 권한을 허용해주세요';

  @override
  String get locationError => '위치를 가져올 수 없습니다';

  @override
  String get loginSignIn => '이미 계정이 있습니다 — 로그인';

  @override
  String get onb1Title => 'RentaVoz에 오신 것을 환영합니다';

  @override
  String get onb1Body =>
      '멕시코 임대 생활의 실제 경험을 공유하는 플랫폼입니다.\n\n자유롭게 의견을 나누고 다른 사람들이 더 나은 결정을 할 수 있도록 도와주세요.';

  @override
  String get onb2Title => '리뷰 작성하기';

  @override
  String get onb2Body =>
      '\"리뷰 작성\"을 눌러 경험을 공유하세요.\n\n집주인, 집 상태, 위치, 안전을 평가하세요. 당신의 의견이 중요합니다!';

  @override
  String get onb3Title => '리뷰 인증하기';

  @override
  String get onb3Body =>
      '납부 증명서를 첨부하면 리뷰의 신뢰도가 높아집니다.\n\n최근 3개월 이내 서류는 \"서류 첨부\" 배지를 받습니다.';

  @override
  String get onb4Title => '지도로 탐색하기';

  @override
  String get onb4Body =>
      '임대 전에 지도에서 리뷰를 확인하세요.\n\n🟢 초록 = 우수  🟡 노랑 = 보통  🔴 빨강 = 나쁜 경험\n\n핀을 눌러 상세 정보를 확인하세요.';

  @override
  String get onb5Title => '리뷰 업데이트하기';

  @override
  String get onb5Body =>
      '\"내 리뷰\"에서 상황이 바뀌면 리뷰를 수정할 수 있습니다 — 예를 들어 보증금을 돌려받거나 못 받았을 때.';

  @override
  String get skip => '건너뛰기';

  @override
  String get next => '다음';

  @override
  String get getStarted => '시작하기!';

  @override
  String get back => '이전';

  @override
  String get loginNeedAccount => '로그인하여 내 리뷰를 확인하세요';

  @override
  String get loginToSeeReviews => '로그인';

  @override
  String get swipeToDelete => '왼쪽으로 밀어 삭제 · 길게 눌러 더 보기';

  @override
  String get translateButton => '번역 보기';

  @override
  String get showOriginal => '원문 보기';

  @override
  String get translating => '번역 중…';

  @override
  String get translationLabel => '자동 번역됨';

  @override
  String get translationError => '번역에 실패했습니다. 다시 시도해주세요.';

  @override
  String get authErrNotFound => '해당 이메일로 등록된 계정이 없습니다.';

  @override
  String get authErrWrongPw => '이메일 또는 비밀번호가 올바르지 않습니다.';

  @override
  String get authErrInvalidEmail => '유효하지 않은 이메일 주소입니다.';

  @override
  String get authErrTooMany => '시도 횟수가 너무 많습니다. 잠시 후 다시 시도해주세요.';

  @override
  String get authErrDefault => '로그인에 실패했습니다. 다시 시도해주세요.';

  @override
  String get authErrEmailInUse => '이미 해당 이메일로 등록된 계정이 있습니다.';

  @override
  String get authErrWeakPw => '비밀번호가 너무 약합니다.';

  @override
  String get authErrRegDefault => '계정 생성에 실패했습니다. 다시 시도해주세요.';

  @override
  String get forgotPassword => '비밀번호를 잊으셨나요?';

  @override
  String get forgotPasswordTitle => '비밀번호 재설정';

  @override
  String get forgotPasswordBody => '이메일을 입력하면 비밀번호 재설정 링크를 보내드립니다.';

  @override
  String get forgotPasswordSend => '링크 보내기';

  @override
  String get forgotPasswordSent => '이메일을 전송했습니다. 받은 편지함을 확인해주세요.';

  @override
  String get forgotPasswordErrNotFound => '해당 이메일로 등록된 계정이 없습니다.';

  @override
  String get forgotPasswordErrDefault => '이메일 전송에 실패했습니다. 다시 시도해주세요.';

  @override
  String get filterAll => '전체';

  @override
  String get filterHouse => '집';

  @override
  String get filterRoom => '방';

  @override
  String get sortNewest => '최신순';

  @override
  String get sortHighest => '평점 높은순';

  @override
  String get sortLowest => '평점 낮은순';

  @override
  String get rentalTypeLabel => '임대 유형';

  @override
  String get rentalTypeHouse => '집 전체';

  @override
  String get rentalTypeRoom => '방 하나';

  @override
  String get sharedBathroom => '화장실 공유';

  @override
  String get sharedKitchen => '부엌 공유';

  @override
  String get badgeRoom => '방 임대';

  @override
  String get reportButton => '리뷰 신고';

  @override
  String get reportTitle => '이 리뷰를 신고하는 이유를 선택하세요';

  @override
  String get reportReasonFalse => '허위 또는 오해의 소지가 있는 정보';

  @override
  String get reportReasonSpam => '스팸 또는 광고';

  @override
  String get reportReasonInappropriate => '부적절하거나 불쾌한 내용';

  @override
  String get reportReasonOther => '기타';

  @override
  String get reportSubmit => '신고 제출';

  @override
  String get reportSuccess => '신고가 접수되었습니다. 검토 후 조치하겠습니다.';

  @override
  String get reportAlready => '이미 신고한 리뷰입니다.';

  @override
  String get reportOwnReview => '내 리뷰는 신고할 수 없습니다.';

  @override
  String get reportError => '신고 제출에 실패했습니다. 다시 시도해주세요.';

  @override
  String get tabProfile => '프로필';

  @override
  String get profileTitle => '내 프로필';

  @override
  String get profileGuest => '익명';

  @override
  String get profileEditNameTitle => '이름 편집';

  @override
  String get profileEditNameHint => '이름을 입력하세요';

  @override
  String get profileSave => '저장';

  @override
  String get profileSaveSuccess => '이름이 변경되었습니다';

  @override
  String get profileSaveError => '이름 변경에 실패했습니다';

  @override
  String get profileEmailLabel => '이메일';

  @override
  String profileMemberSince(String date) {
    return '$date부터 이용 중';
  }

  @override
  String profileReviewCount(int count) {
    return '리뷰 $count개';
  }

  @override
  String get profileAvgRating => '평균 별점';

  @override
  String get profileMyReviews => '내 리뷰';

  @override
  String get profileNoReviews => '아직 작성한 리뷰가 없습니다';

  @override
  String get addressReviewsTitle => '이 주소의 리뷰';

  @override
  String addressReviewsCount(int count) {
    return '총 $count개의 리뷰';
  }

  @override
  String addressReviewsOther(int count) {
    return '이 주소의 다른 리뷰 $count개 보기';
  }

  @override
  String get addressReviewsNone => '이 주소의 다른 리뷰가 없습니다';

  @override
  String get addressReviewsAvg => '전체 평균';

  @override
  String get verifyEmailTitle => '이메일 인증';

  @override
  String verifyEmailBody(String email) {
    return '$email으로 인증 링크를 보냈습니다. 받은편지함을 확인해주세요.';
  }

  @override
  String get verifyEmailResend => '인증 메일 재발송';

  @override
  String get verifyEmailResent => '인증 메일을 재발송했습니다. 받은편지함을 확인해주세요.';

  @override
  String get verifyEmailContinue => '인증 완료, 계속하기';

  @override
  String get verifyEmailNotYet => '아직 인증이 확인되지 않았습니다. 이메일을 확인해주세요.';

  @override
  String get verifyEmailRequired => '리뷰를 작성하려면 이메일 인증이 필요합니다.';

  @override
  String get verifyEmailLogout => '로그아웃하고 돌아가기';
}
