// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SEn extends S {
  SEn([String locale = 'en']) : super(locale);

  @override
  String get appSubtitle => 'Honest rental reviews in Mexico';

  @override
  String get emailLabel => 'Email address';

  @override
  String get passwordLabel => 'Password';

  @override
  String get confirmPasswordLabel => 'Confirm password';

  @override
  String get loginButton => 'Sign in';

  @override
  String get registerButton => 'Register';

  @override
  String get createAccount => 'Create new account';

  @override
  String get passwordMismatch => 'Passwords do not match';

  @override
  String get passwordMinLength => 'Minimum 6 characters';

  @override
  String get emailInvalid => 'Enter a valid email';

  @override
  String get tabHome => 'Home';

  @override
  String get tabMap => 'Map';

  @override
  String get tabMyReviews => 'My reviews';

  @override
  String get newReview => 'New review';

  @override
  String get searchHint => 'Search by address or neighborhood…';

  @override
  String get noReviewsYet => 'No reviews yet';

  @override
  String noResultsFor(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String get mapTitle => 'Review map';

  @override
  String reviewCount(int count) {
    return '$count reviews';
  }

  @override
  String get legendGood => '★ 4–5  Good';

  @override
  String get legendRegular => '★ 3–4  Average';

  @override
  String get legendBad => '★ 1–3  Bad';

  @override
  String get centerMap => 'Center map';

  @override
  String get myReviewsEmpty => 'You haven\'t written any reviews yet';

  @override
  String get myReviewsEmptyHint => 'Tap \"New review\" to get started';

  @override
  String get editReview => 'Edit review';

  @override
  String get deleteReview => 'Delete review';

  @override
  String get deleteConfirmTitle => 'Delete review';

  @override
  String get deleteConfirmBody =>
      'Are you sure you want to delete this review?';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get logout => 'Sign out';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get languageLabel => 'Language';

  @override
  String get detailTitle => 'Review detail';

  @override
  String get overallOf5 => 'out of 5.0';

  @override
  String get moveIn => 'Move-in';

  @override
  String get moveOut => 'Move-out';

  @override
  String get rent => 'Rent';

  @override
  String get contractSection => 'Contract details';

  @override
  String get comprobanteSection => 'Proof of payment';

  @override
  String get comprobanteOptional =>
      'Optional · Your review will show the \"Document attached\" badge';

  @override
  String get uploadComprobante => 'Upload proof of payment (image or PDF)';

  @override
  String get analyzingDoc => 'Analyzing document…';

  @override
  String get removeDoc => 'Remove';

  @override
  String get pdfAttached => 'PDF attached (no date verification)';

  @override
  String get goodSection => 'What did you like?';

  @override
  String get badSection => 'What didn\'t you like?';

  @override
  String get photosSection => 'Photos';

  @override
  String get addPhotos => 'Add photos';

  @override
  String get publishButton => 'Publish review';

  @override
  String get saveButton => 'Save';

  @override
  String get publishAction => 'Publish';

  @override
  String get addressLabel => 'Address';

  @override
  String get addressHint => 'E.g. Calle Morelos 123, Centro, Querétaro';

  @override
  String get periodLabel => 'Rental period';

  @override
  String get rentLabel => 'Monthly rent (MXN)';

  @override
  String get ratingsLabel => 'Ratings';

  @override
  String get landlordRating => 'Landlord';

  @override
  String get conditionRating => 'Property condition';

  @override
  String get locationRating => 'Location';

  @override
  String get securityRating => 'Safety';

  @override
  String get formalContract => 'Formal contract';

  @override
  String get avalRequired => 'Guarantor required';

  @override
  String get depositReturned => 'Deposit returned';

  @override
  String get utilitiesIncluded => 'Utilities included (water/electricity/gas)';

  @override
  String get badgeVerified => '✓ Document attached';

  @override
  String get badgeFormalContract => 'Formal contract';

  @override
  String get badgeAvalRequired => 'Guarantor required';

  @override
  String get badgeDepositNotReturned => 'Deposit not returned';

  @override
  String get badgeUtilitiesIncluded => 'Utilities included';

  @override
  String get reviewPublished => 'Review published!';

  @override
  String get reviewUpdated => 'Review updated!';

  @override
  String get reviewDeleted => 'Review deleted';

  @override
  String get selectDates => 'Please select move-in and move-out dates';

  @override
  String get selectAddress => 'Please select an address from the list';

  @override
  String publishedOn(String date) {
    return 'Published on $date';
  }

  @override
  String get useMyLocation => 'Use my current location';

  @override
  String get locationPermissionDenied =>
      'Please enable location permissions in Settings';

  @override
  String get locationError => 'Could not get location';

  @override
  String get loginSignIn => 'I already have an account — Sign in';

  @override
  String get onb1Title => 'Welcome to RentaVoz';

  @override
  String get onb1Body =>
      'The platform where tenants share real experiences about their rentals in Mexico.\n\nShare freely and help others make better decisions.';

  @override
  String get onb2Title => 'Write a review';

  @override
  String get onb2Body =>
      'Tap \"New review\" to share your experience.\n\nRate the landlord, property, location, and safety. Your opinion matters!';

  @override
  String get onb3Title => 'Verify your review';

  @override
  String get onb3Body =>
      'Attach your proof of payment to make your review more credible.\n\nRecent documents (less than 3 months) earn the \"Document attached\" badge.';

  @override
  String get onb4Title => 'Explore the map';

  @override
  String get onb4Body =>
      'Check reviews on the map before renting.\n\n🟢 Green = excellent  🟡 Yellow = average  🔴 Red = bad experience\n\nTap a pin to see details.';

  @override
  String get onb5Title => 'Update your review';

  @override
  String get onb5Body =>
      'In \"My reviews\" you can edit your review when the situation changes — for example, when you receive (or don\'t receive) your deposit back.';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get getStarted => 'Get started!';

  @override
  String get back => 'Back';

  @override
  String get loginNeedAccount => 'Sign in to see your reviews';

  @override
  String get loginToSeeReviews => 'Sign in';

  @override
  String get swipeToDelete =>
      'Swipe left to delete · Long press for more options';

  @override
  String get translateButton => 'Translate';

  @override
  String get showOriginal => 'Show original';

  @override
  String get translating => 'Translating…';

  @override
  String get translationLabel => 'Auto-translated';

  @override
  String get translationError => 'Translation failed. Please try again.';

  @override
  String get authErrNotFound => 'No account found with that email.';

  @override
  String get authErrWrongPw => 'Incorrect email or password.';

  @override
  String get authErrInvalidEmail => 'Invalid email address.';

  @override
  String get authErrTooMany => 'Too many attempts. Please try again later.';

  @override
  String get authErrDefault => 'Sign-in failed. Please try again.';

  @override
  String get authErrEmailInUse => 'An account already exists with that email.';

  @override
  String get authErrWeakPw => 'Password is too weak.';

  @override
  String get authErrRegDefault => 'Account creation failed. Please try again.';

  @override
  String get forgotPassword => 'Forgot your password?';

  @override
  String get forgotPasswordTitle => 'Reset password';

  @override
  String get forgotPasswordBody =>
      'Enter your email and we\'ll send you a link to reset your password.';

  @override
  String get forgotPasswordSend => 'Send link';

  @override
  String get forgotPasswordSent => 'Email sent. Check your inbox.';

  @override
  String get forgotPasswordErrNotFound => 'No account found with that email.';

  @override
  String get forgotPasswordErrDefault =>
      'Could not send email. Please try again.';

  @override
  String get filterAll => 'All';

  @override
  String get filterHouse => 'House';

  @override
  String get filterRoom => 'Room';

  @override
  String get sortNewest => 'Newest';

  @override
  String get sortHighest => 'Top rated';

  @override
  String get sortLowest => 'Lowest rated';

  @override
  String get rentalTypeLabel => 'Rental type';

  @override
  String get rentalTypeHouse => 'Full house';

  @override
  String get rentalTypeRoom => 'Room';

  @override
  String get sharedBathroom => 'Shared bathroom';

  @override
  String get sharedKitchen => 'Shared kitchen';

  @override
  String get badgeRoom => 'Room';

  @override
  String get reportButton => 'Report review';

  @override
  String get reportTitle => 'Why are you reporting this review?';

  @override
  String get reportReasonFalse => 'False or misleading information';

  @override
  String get reportReasonSpam => 'Spam or advertisement';

  @override
  String get reportReasonInappropriate => 'Inappropriate or offensive content';

  @override
  String get reportReasonOther => 'Other reason';

  @override
  String get reportSubmit => 'Submit report';

  @override
  String get reportSuccess => 'Report submitted. We\'ll review it soon.';

  @override
  String get reportAlready => 'You have already reported this review.';

  @override
  String get reportOwnReview => 'You cannot report your own review.';

  @override
  String get reportError => 'Failed to submit report. Please try again.';

  @override
  String get tabProfile => 'Profile';

  @override
  String get profileTitle => 'My profile';

  @override
  String get profileGuest => 'Anonymous';

  @override
  String get profileEditNameTitle => 'Edit name';

  @override
  String get profileEditNameHint => 'Your name';

  @override
  String get profileSave => 'Save';

  @override
  String get profileSaveSuccess => 'Name updated';

  @override
  String get profileSaveError => 'Failed to update name';

  @override
  String get profileEmailLabel => 'Email';

  @override
  String profileMemberSince(String date) {
    return 'Member since $date';
  }

  @override
  String profileReviewCount(int count) {
    return '$count reviews';
  }

  @override
  String get profileAvgRating => 'Avg. rating';

  @override
  String get profileMyReviews => 'My reviews';

  @override
  String get profileNoReviews => 'You haven\'t written any reviews yet';

  @override
  String get addressReviewsTitle => 'Reviews for this address';

  @override
  String addressReviewsCount(int count) {
    return '$count reviews total';
  }

  @override
  String addressReviewsOther(int count) {
    return 'See $count more reviews for this address';
  }

  @override
  String get addressReviewsNone => 'No other reviews for this address';

  @override
  String get addressReviewsAvg => 'Overall average';

  @override
  String get verifyEmailTitle => 'Verify your email';

  @override
  String verifyEmailBody(String email) {
    return 'We sent a verification link to $email. Check your inbox.';
  }

  @override
  String get verifyEmailResend => 'Resend email';

  @override
  String get verifyEmailResent => 'Email resent. Check your inbox.';

  @override
  String get verifyEmailContinue => 'I verified, continue';

  @override
  String get verifyEmailNotYet =>
      'Email not verified yet. Please check your inbox.';

  @override
  String get verifyEmailRequired =>
      'You must verify your email to post reviews.';

  @override
  String get verifyEmailLogout => 'Sign out and go back';
}
