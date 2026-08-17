import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of S
/// returned by `S.of(context)`.
///
/// Applications need to include `S.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: S.localizationsDelegates,
///   supportedLocales: S.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the S.supportedLocales
/// property.
abstract class S {
  S(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static S? of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('ja'),
    Locale('ko'),
    Locale('zh'),
  ];

  /// No description provided for @appSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Reseñas honestas de arrendamientos en México'**
  String get appSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get passwordLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In es, this message translates to:
  /// **'Confirmar contraseña'**
  String get confirmPasswordLabel;

  /// No description provided for @loginButton.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get loginButton;

  /// No description provided for @registerButton.
  ///
  /// In es, this message translates to:
  /// **'Registrarse'**
  String get registerButton;

  /// No description provided for @createAccount.
  ///
  /// In es, this message translates to:
  /// **'Crear cuenta nueva'**
  String get createAccount;

  /// No description provided for @passwordMismatch.
  ///
  /// In es, this message translates to:
  /// **'Las contraseñas no coinciden'**
  String get passwordMismatch;

  /// No description provided for @passwordMinLength.
  ///
  /// In es, this message translates to:
  /// **'Mínimo 6 caracteres'**
  String get passwordMinLength;

  /// No description provided for @emailInvalid.
  ///
  /// In es, this message translates to:
  /// **'Ingresa un correo válido'**
  String get emailInvalid;

  /// No description provided for @tabHome.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get tabHome;

  /// No description provided for @tabMap.
  ///
  /// In es, this message translates to:
  /// **'Mapa'**
  String get tabMap;

  /// No description provided for @tabMyReviews.
  ///
  /// In es, this message translates to:
  /// **'Mis reseñas'**
  String get tabMyReviews;

  /// No description provided for @newReview.
  ///
  /// In es, this message translates to:
  /// **'Nueva reseña'**
  String get newReview;

  /// No description provided for @searchHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar por dirección o colonia…'**
  String get searchHint;

  /// No description provided for @noReviewsYet.
  ///
  /// In es, this message translates to:
  /// **'No hay reseñas aún'**
  String get noReviewsYet;

  /// No description provided for @noResultsFor.
  ///
  /// In es, this message translates to:
  /// **'Sin resultados para \"{query}\"'**
  String noResultsFor(String query);

  /// No description provided for @mapTitle.
  ///
  /// In es, this message translates to:
  /// **'Mapa de reseñas'**
  String get mapTitle;

  /// No description provided for @reviewCount.
  ///
  /// In es, this message translates to:
  /// **'{count} reseñas'**
  String reviewCount(int count);

  /// No description provided for @legendGood.
  ///
  /// In es, this message translates to:
  /// **'★ 4–5  Bueno'**
  String get legendGood;

  /// No description provided for @legendRegular.
  ///
  /// In es, this message translates to:
  /// **'★ 3–4  Regular'**
  String get legendRegular;

  /// No description provided for @legendBad.
  ///
  /// In es, this message translates to:
  /// **'★ 1–3  Malo'**
  String get legendBad;

  /// No description provided for @centerMap.
  ///
  /// In es, this message translates to:
  /// **'Centrar mapa'**
  String get centerMap;

  /// No description provided for @myReviewsEmpty.
  ///
  /// In es, this message translates to:
  /// **'Aún no has escrito reseñas'**
  String get myReviewsEmpty;

  /// No description provided for @myReviewsEmptyHint.
  ///
  /// In es, this message translates to:
  /// **'Toca \"Nueva reseña\" para empezar'**
  String get myReviewsEmptyHint;

  /// No description provided for @editReview.
  ///
  /// In es, this message translates to:
  /// **'Editar reseña'**
  String get editReview;

  /// No description provided for @deleteReview.
  ///
  /// In es, this message translates to:
  /// **'Eliminar reseña'**
  String get deleteReview;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar reseña'**
  String get deleteConfirmTitle;

  /// No description provided for @deleteConfirmBody.
  ///
  /// In es, this message translates to:
  /// **'¿Seguro que quieres eliminar esta reseña?'**
  String get deleteConfirmBody;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get delete;

  /// No description provided for @logout.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get logout;

  /// No description provided for @settingsTitle.
  ///
  /// In es, this message translates to:
  /// **'Configuración'**
  String get settingsTitle;

  /// No description provided for @languageLabel.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get languageLabel;

  /// No description provided for @detailTitle.
  ///
  /// In es, this message translates to:
  /// **'Detalle de reseña'**
  String get detailTitle;

  /// No description provided for @overallOf5.
  ///
  /// In es, this message translates to:
  /// **'de 5.0'**
  String get overallOf5;

  /// No description provided for @moveIn.
  ///
  /// In es, this message translates to:
  /// **'Entrada'**
  String get moveIn;

  /// No description provided for @moveOut.
  ///
  /// In es, this message translates to:
  /// **'Salida'**
  String get moveOut;

  /// No description provided for @rent.
  ///
  /// In es, this message translates to:
  /// **'Renta'**
  String get rent;

  /// No description provided for @contractSection.
  ///
  /// In es, this message translates to:
  /// **'Detalles del contrato'**
  String get contractSection;

  /// No description provided for @comprobanteSection.
  ///
  /// In es, this message translates to:
  /// **'Comprobante de pago'**
  String get comprobanteSection;

  /// No description provided for @comprobanteOptional.
  ///
  /// In es, this message translates to:
  /// **'Opcional · Tu reseña aparecerá con el sello \"Documento adjunto\"'**
  String get comprobanteOptional;

  /// No description provided for @uploadComprobante.
  ///
  /// In es, this message translates to:
  /// **'Subir comprobante (imagen o PDF)'**
  String get uploadComprobante;

  /// No description provided for @analyzingDoc.
  ///
  /// In es, this message translates to:
  /// **'Analizando documento…'**
  String get analyzingDoc;

  /// No description provided for @removeDoc.
  ///
  /// In es, this message translates to:
  /// **'Quitar'**
  String get removeDoc;

  /// No description provided for @pdfAttached.
  ///
  /// In es, this message translates to:
  /// **'PDF adjunto (sin verificación de fecha)'**
  String get pdfAttached;

  /// No description provided for @goodSection.
  ///
  /// In es, this message translates to:
  /// **'¿Qué te gustó?'**
  String get goodSection;

  /// No description provided for @badSection.
  ///
  /// In es, this message translates to:
  /// **'¿Qué no te gustó?'**
  String get badSection;

  /// No description provided for @photosSection.
  ///
  /// In es, this message translates to:
  /// **'Fotos'**
  String get photosSection;

  /// No description provided for @addPhotos.
  ///
  /// In es, this message translates to:
  /// **'Agregar fotos'**
  String get addPhotos;

  /// No description provided for @publishButton.
  ///
  /// In es, this message translates to:
  /// **'Publicar reseña'**
  String get publishButton;

  /// No description provided for @saveButton.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get saveButton;

  /// No description provided for @publishAction.
  ///
  /// In es, this message translates to:
  /// **'Publicar'**
  String get publishAction;

  /// No description provided for @addressLabel.
  ///
  /// In es, this message translates to:
  /// **'Dirección'**
  String get addressLabel;

  /// No description provided for @addressHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. Calle Morelos 123, Col. Centro, Querétaro'**
  String get addressHint;

  /// No description provided for @periodLabel.
  ///
  /// In es, this message translates to:
  /// **'Período de arrendamiento'**
  String get periodLabel;

  /// No description provided for @rentLabel.
  ///
  /// In es, this message translates to:
  /// **'Renta mensual (MXN)'**
  String get rentLabel;

  /// No description provided for @ratingsLabel.
  ///
  /// In es, this message translates to:
  /// **'Calificaciones'**
  String get ratingsLabel;

  /// No description provided for @landlordRating.
  ///
  /// In es, this message translates to:
  /// **'Arrendador / Propietario'**
  String get landlordRating;

  /// No description provided for @conditionRating.
  ///
  /// In es, this message translates to:
  /// **'Estado del inmueble'**
  String get conditionRating;

  /// No description provided for @locationRating.
  ///
  /// In es, this message translates to:
  /// **'Ubicación'**
  String get locationRating;

  /// No description provided for @securityRating.
  ///
  /// In es, this message translates to:
  /// **'Seguridad'**
  String get securityRating;

  /// No description provided for @formalContract.
  ///
  /// In es, this message translates to:
  /// **'Contrato formal'**
  String get formalContract;

  /// No description provided for @avalRequired.
  ///
  /// In es, this message translates to:
  /// **'Requirió aval'**
  String get avalRequired;

  /// No description provided for @depositReturned.
  ///
  /// In es, this message translates to:
  /// **'Depósito devuelto'**
  String get depositReturned;

  /// No description provided for @utilitiesIncluded.
  ///
  /// In es, this message translates to:
  /// **'Servicios incluidos (agua/luz/gas)'**
  String get utilitiesIncluded;

  /// No description provided for @badgeVerified.
  ///
  /// In es, this message translates to:
  /// **'✓ Documento adjunto'**
  String get badgeVerified;

  /// No description provided for @badgeFormalContract.
  ///
  /// In es, this message translates to:
  /// **'Contrato formal'**
  String get badgeFormalContract;

  /// No description provided for @badgeAvalRequired.
  ///
  /// In es, this message translates to:
  /// **'Requirió aval'**
  String get badgeAvalRequired;

  /// No description provided for @badgeDepositNotReturned.
  ///
  /// In es, this message translates to:
  /// **'Depósito no devuelto'**
  String get badgeDepositNotReturned;

  /// No description provided for @badgeUtilitiesIncluded.
  ///
  /// In es, this message translates to:
  /// **'Servicios incluidos'**
  String get badgeUtilitiesIncluded;

  /// No description provided for @reviewPublished.
  ///
  /// In es, this message translates to:
  /// **'¡Reseña publicada!'**
  String get reviewPublished;

  /// No description provided for @reviewUpdated.
  ///
  /// In es, this message translates to:
  /// **'¡Reseña actualizada!'**
  String get reviewUpdated;

  /// No description provided for @reviewDeleted.
  ///
  /// In es, this message translates to:
  /// **'Reseña eliminada'**
  String get reviewDeleted;

  /// No description provided for @selectDates.
  ///
  /// In es, this message translates to:
  /// **'Selecciona las fechas de entrada y salida'**
  String get selectDates;

  /// No description provided for @selectAddress.
  ///
  /// In es, this message translates to:
  /// **'Selecciona una dirección de la lista'**
  String get selectAddress;

  /// No description provided for @publishedOn.
  ///
  /// In es, this message translates to:
  /// **'Publicada el {date}'**
  String publishedOn(String date);

  /// No description provided for @useMyLocation.
  ///
  /// In es, this message translates to:
  /// **'Usar mi ubicación actual'**
  String get useMyLocation;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In es, this message translates to:
  /// **'Activa los permisos de ubicación en Ajustes'**
  String get locationPermissionDenied;

  /// No description provided for @locationError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo obtener la ubicación'**
  String get locationError;

  /// No description provided for @loginSignIn.
  ///
  /// In es, this message translates to:
  /// **'Ya tengo cuenta — Iniciar sesión'**
  String get loginSignIn;

  /// No description provided for @onb1Title.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido a RentaVoz'**
  String get onb1Title;

  /// No description provided for @onb1Body.
  ///
  /// In es, this message translates to:
  /// **'La plataforma donde los arrendatarios comparten experiencias reales sobre sus viviendas en México.\n\nOpina con libertad y ayuda a otros a tomar mejores decisiones.'**
  String get onb1Body;

  /// No description provided for @onb2Title.
  ///
  /// In es, this message translates to:
  /// **'Escribe una reseña'**
  String get onb2Title;

  /// No description provided for @onb2Body.
  ///
  /// In es, this message translates to:
  /// **'Toca \"Nueva reseña\" para compartir tu experiencia.\n\nCalifica al propietario, el inmueble, la ubicación y la seguridad. ¡Tu opinión vale!'**
  String get onb2Body;

  /// No description provided for @onb3Title.
  ///
  /// In es, this message translates to:
  /// **'Verifica tu reseña'**
  String get onb3Title;

  /// No description provided for @onb3Body.
  ///
  /// In es, this message translates to:
  /// **'Adjunta tu comprobante de pago para que tu reseña sea más confiable.\n\nLos comprobantes recientes (menos de 3 meses) obtienen el sello \"Documento adjunto\".'**
  String get onb3Body;

  /// No description provided for @onb4Title.
  ///
  /// In es, this message translates to:
  /// **'Explora el mapa'**
  String get onb4Title;

  /// No description provided for @onb4Body.
  ///
  /// In es, this message translates to:
  /// **'Consulta las reseñas en el mapa antes de rentar.\n\n🟢 Verde = excelente  🟡 Amarillo = regular  🔴 Rojo = mala experiencia\n\nToca un pin para ver el detalle.'**
  String get onb4Body;

  /// No description provided for @onb5Title.
  ///
  /// In es, this message translates to:
  /// **'Actualiza tu reseña'**
  String get onb5Title;

  /// No description provided for @onb5Body.
  ///
  /// In es, this message translates to:
  /// **'En \"Mis reseñas\" puedes editar tu reseña cuando cambie la situación — por ejemplo, cuando te devuelvan (o no) el depósito.'**
  String get onb5Body;

  /// No description provided for @skip.
  ///
  /// In es, this message translates to:
  /// **'Omitir'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In es, this message translates to:
  /// **'Siguiente'**
  String get next;

  /// No description provided for @getStarted.
  ///
  /// In es, this message translates to:
  /// **'¡Empezar!'**
  String get getStarted;

  /// No description provided for @back.
  ///
  /// In es, this message translates to:
  /// **'Atrás'**
  String get back;

  /// No description provided for @loginNeedAccount.
  ///
  /// In es, this message translates to:
  /// **'Inicia sesión para ver tus reseñas'**
  String get loginNeedAccount;

  /// No description provided for @loginToSeeReviews.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get loginToSeeReviews;

  /// No description provided for @swipeToDelete.
  ///
  /// In es, this message translates to:
  /// **'Desliza a la izquierda para eliminar · Mantén presionado para más opciones'**
  String get swipeToDelete;

  /// No description provided for @translateButton.
  ///
  /// In es, this message translates to:
  /// **'Traducir'**
  String get translateButton;

  /// No description provided for @showOriginal.
  ///
  /// In es, this message translates to:
  /// **'Ver original'**
  String get showOriginal;

  /// No description provided for @translating.
  ///
  /// In es, this message translates to:
  /// **'Traduciendo…'**
  String get translating;

  /// No description provided for @translationLabel.
  ///
  /// In es, this message translates to:
  /// **'Traducción automática'**
  String get translationLabel;

  /// No description provided for @translationError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo traducir. Intenta de nuevo.'**
  String get translationError;

  /// No description provided for @authErrNotFound.
  ///
  /// In es, this message translates to:
  /// **'No existe una cuenta con ese correo.'**
  String get authErrNotFound;

  /// No description provided for @authErrWrongPw.
  ///
  /// In es, this message translates to:
  /// **'Correo o contraseña incorrectos.'**
  String get authErrWrongPw;

  /// No description provided for @authErrInvalidEmail.
  ///
  /// In es, this message translates to:
  /// **'Correo no válido.'**
  String get authErrInvalidEmail;

  /// No description provided for @authErrTooMany.
  ///
  /// In es, this message translates to:
  /// **'Demasiados intentos. Intenta más tarde.'**
  String get authErrTooMany;

  /// No description provided for @authErrDefault.
  ///
  /// In es, this message translates to:
  /// **'Error al iniciar sesión. Intenta de nuevo.'**
  String get authErrDefault;

  /// No description provided for @authErrEmailInUse.
  ///
  /// In es, this message translates to:
  /// **'Ya existe una cuenta con ese correo.'**
  String get authErrEmailInUse;

  /// No description provided for @authErrWeakPw.
  ///
  /// In es, this message translates to:
  /// **'La contraseña es muy débil.'**
  String get authErrWeakPw;

  /// No description provided for @authErrRegDefault.
  ///
  /// In es, this message translates to:
  /// **'Error al crear cuenta. Intenta de nuevo.'**
  String get authErrRegDefault;

  /// No description provided for @forgotPassword.
  ///
  /// In es, this message translates to:
  /// **'¿Olvidaste tu contraseña?'**
  String get forgotPassword;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In es, this message translates to:
  /// **'Restablecer contraseña'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordBody.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu correo y te enviaremos un enlace para restablecer tu contraseña.'**
  String get forgotPasswordBody;

  /// No description provided for @forgotPasswordSend.
  ///
  /// In es, this message translates to:
  /// **'Enviar enlace'**
  String get forgotPasswordSend;

  /// No description provided for @forgotPasswordSent.
  ///
  /// In es, this message translates to:
  /// **'Correo enviado. Revisa tu bandeja de entrada.'**
  String get forgotPasswordSent;

  /// No description provided for @forgotPasswordErrNotFound.
  ///
  /// In es, this message translates to:
  /// **'No existe una cuenta con ese correo.'**
  String get forgotPasswordErrNotFound;

  /// No description provided for @forgotPasswordErrDefault.
  ///
  /// In es, this message translates to:
  /// **'No se pudo enviar el correo. Intenta de nuevo.'**
  String get forgotPasswordErrDefault;

  /// No description provided for @continueWithGoogle.
  ///
  /// In es, this message translates to:
  /// **'Continuar con Google'**
  String get continueWithGoogle;

  /// No description provided for @pickFromGallery.
  ///
  /// In es, this message translates to:
  /// **'Galería'**
  String get pickFromGallery;

  /// No description provided for @pickFromCamera.
  ///
  /// In es, this message translates to:
  /// **'Cámara'**
  String get pickFromCamera;

  /// No description provided for @photoUploadFailTitle.
  ///
  /// In es, this message translates to:
  /// **'Error al subir fotos'**
  String get photoUploadFailTitle;

  /// No description provided for @photoUploadFailBody.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron subir las fotos. ¿Deseas publicar la reseña sin ellas?'**
  String get photoUploadFailBody;

  /// No description provided for @publishAnyway.
  ///
  /// In es, this message translates to:
  /// **'Publicar igual'**
  String get publishAnyway;

  /// No description provided for @dateOrderError.
  ///
  /// In es, this message translates to:
  /// **'La fecha de salida debe ser posterior a la de entrada.'**
  String get dateOrderError;

  /// No description provided for @signInError.
  ///
  /// In es, this message translates to:
  /// **'Error al iniciar sesión'**
  String get signInError;

  /// No description provided for @googleSignInError.
  ///
  /// In es, this message translates to:
  /// **'Error al iniciar sesión con Google'**
  String get googleSignInError;

  /// No description provided for @filterAll.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get filterAll;

  /// No description provided for @filterHouse.
  ///
  /// In es, this message translates to:
  /// **'Casa'**
  String get filterHouse;

  /// No description provided for @filterRoom.
  ///
  /// In es, this message translates to:
  /// **'Cuarto'**
  String get filterRoom;

  /// No description provided for @filterApartment.
  ///
  /// In es, this message translates to:
  /// **'Departamento'**
  String get filterApartment;

  /// No description provided for @sortNewest.
  ///
  /// In es, this message translates to:
  /// **'Más recientes'**
  String get sortNewest;

  /// No description provided for @sortHighest.
  ///
  /// In es, this message translates to:
  /// **'Mejor calificados'**
  String get sortHighest;

  /// No description provided for @sortLowest.
  ///
  /// In es, this message translates to:
  /// **'Peor calificados'**
  String get sortLowest;

  /// No description provided for @rentalTypeLabel.
  ///
  /// In es, this message translates to:
  /// **'Tipo de arrendamiento'**
  String get rentalTypeLabel;

  /// No description provided for @rentalTypeHouse.
  ///
  /// In es, this message translates to:
  /// **'Casa completa'**
  String get rentalTypeHouse;

  /// No description provided for @rentalTypeRoom.
  ///
  /// In es, this message translates to:
  /// **'Cuarto / Habitación'**
  String get rentalTypeRoom;

  /// No description provided for @rentalTypeApartment.
  ///
  /// In es, this message translates to:
  /// **'Departamento'**
  String get rentalTypeApartment;

  /// No description provided for @sharedBathroom.
  ///
  /// In es, this message translates to:
  /// **'Baño compartido'**
  String get sharedBathroom;

  /// No description provided for @sharedKitchen.
  ///
  /// In es, this message translates to:
  /// **'Cocina compartida'**
  String get sharedKitchen;

  /// No description provided for @badgeRoom.
  ///
  /// In es, this message translates to:
  /// **'Cuarto'**
  String get badgeRoom;

  /// No description provided for @reportButton.
  ///
  /// In es, this message translates to:
  /// **'Reportar reseña'**
  String get reportButton;

  /// No description provided for @reportTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Por qué reportas esta reseña?'**
  String get reportTitle;

  /// No description provided for @reportReasonFalse.
  ///
  /// In es, this message translates to:
  /// **'Información falsa o engañosa'**
  String get reportReasonFalse;

  /// No description provided for @reportReasonSpam.
  ///
  /// In es, this message translates to:
  /// **'Spam o publicidad'**
  String get reportReasonSpam;

  /// No description provided for @reportReasonInappropriate.
  ///
  /// In es, this message translates to:
  /// **'Contenido inapropiado u ofensivo'**
  String get reportReasonInappropriate;

  /// No description provided for @reportReasonOther.
  ///
  /// In es, this message translates to:
  /// **'Otro motivo'**
  String get reportReasonOther;

  /// No description provided for @reportSubmit.
  ///
  /// In es, this message translates to:
  /// **'Enviar reporte'**
  String get reportSubmit;

  /// No description provided for @reportSuccess.
  ///
  /// In es, this message translates to:
  /// **'Reporte enviado. Lo revisaremos pronto.'**
  String get reportSuccess;

  /// No description provided for @reportAlready.
  ///
  /// In es, this message translates to:
  /// **'Ya reportaste esta reseña anteriormente.'**
  String get reportAlready;

  /// No description provided for @reportOwnReview.
  ///
  /// In es, this message translates to:
  /// **'No puedes reportar tu propia reseña.'**
  String get reportOwnReview;

  /// No description provided for @reportError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo enviar el reporte. Intenta de nuevo.'**
  String get reportError;

  /// No description provided for @tabProfile.
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get tabProfile;

  /// No description provided for @profileTitle.
  ///
  /// In es, this message translates to:
  /// **'Mi perfil'**
  String get profileTitle;

  /// No description provided for @profileGuest.
  ///
  /// In es, this message translates to:
  /// **'Anónimo'**
  String get profileGuest;

  /// No description provided for @profileEditNameTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar nombre'**
  String get profileEditNameTitle;

  /// No description provided for @profileEditNameHint.
  ///
  /// In es, this message translates to:
  /// **'Tu nombre'**
  String get profileEditNameHint;

  /// No description provided for @profileSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get profileSave;

  /// No description provided for @profileSaveSuccess.
  ///
  /// In es, this message translates to:
  /// **'Nombre actualizado'**
  String get profileSaveSuccess;

  /// No description provided for @profileSaveError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo actualizar el nombre'**
  String get profileSaveError;

  /// No description provided for @profileEmailLabel.
  ///
  /// In es, this message translates to:
  /// **'Correo'**
  String get profileEmailLabel;

  /// No description provided for @profileMemberSince.
  ///
  /// In es, this message translates to:
  /// **'Miembro desde {date}'**
  String profileMemberSince(String date);

  /// No description provided for @profileReviewCount.
  ///
  /// In es, this message translates to:
  /// **'{count} reseñas'**
  String profileReviewCount(int count);

  /// No description provided for @profileAvgRating.
  ///
  /// In es, this message translates to:
  /// **'Promedio'**
  String get profileAvgRating;

  /// No description provided for @profileMyReviews.
  ///
  /// In es, this message translates to:
  /// **'Mis reseñas'**
  String get profileMyReviews;

  /// No description provided for @profileNoReviews.
  ///
  /// In es, this message translates to:
  /// **'Aún no has escrito reseñas'**
  String get profileNoReviews;

  /// No description provided for @addressReviewsTitle.
  ///
  /// In es, this message translates to:
  /// **'Reseñas en esta dirección'**
  String get addressReviewsTitle;

  /// No description provided for @addressReviewsCount.
  ///
  /// In es, this message translates to:
  /// **'{count} reseñas en total'**
  String addressReviewsCount(int count);

  /// No description provided for @addressReviewsOther.
  ///
  /// In es, this message translates to:
  /// **'Ver {count} reseñas más de esta dirección'**
  String addressReviewsOther(int count);

  /// No description provided for @addressReviewsNone.
  ///
  /// In es, this message translates to:
  /// **'Sin más reseñas para esta dirección'**
  String get addressReviewsNone;

  /// No description provided for @addressReviewsAvg.
  ///
  /// In es, this message translates to:
  /// **'Promedio general'**
  String get addressReviewsAvg;

  /// No description provided for @verifyEmailTitle.
  ///
  /// In es, this message translates to:
  /// **'Verifica tu correo'**
  String get verifyEmailTitle;

  /// No description provided for @verifyEmailBody.
  ///
  /// In es, this message translates to:
  /// **'Enviamos un enlace de verificación a {email}. Revisa tu bandeja de entrada.'**
  String verifyEmailBody(String email);

  /// No description provided for @verifyEmailResend.
  ///
  /// In es, this message translates to:
  /// **'Reenviar correo'**
  String get verifyEmailResend;

  /// No description provided for @verifyEmailResent.
  ///
  /// In es, this message translates to:
  /// **'Correo reenviado. Revisa tu bandeja de entrada.'**
  String get verifyEmailResent;

  /// No description provided for @verifyEmailContinue.
  ///
  /// In es, this message translates to:
  /// **'Ya verifiqué, continuar'**
  String get verifyEmailContinue;

  /// No description provided for @verifyEmailNotYet.
  ///
  /// In es, this message translates to:
  /// **'Aún no hemos detectado la verificación. Por favor revisa tu correo.'**
  String get verifyEmailNotYet;

  /// No description provided for @verifyEmailRequired.
  ///
  /// In es, this message translates to:
  /// **'Debes verificar tu correo electrónico para publicar reseñas.'**
  String get verifyEmailRequired;

  /// No description provided for @verifyEmailLogout.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión y volver'**
  String get verifyEmailLogout;

  /// No description provided for @bookmarkAdd.
  ///
  /// In es, this message translates to:
  /// **'Guardar reseña'**
  String get bookmarkAdd;

  /// No description provided for @bookmarkRemove.
  ///
  /// In es, this message translates to:
  /// **'Quitar de guardados'**
  String get bookmarkRemove;

  /// No description provided for @bookmarkAdded.
  ///
  /// In es, this message translates to:
  /// **'Reseña guardada'**
  String get bookmarkAdded;

  /// No description provided for @bookmarkRemoved.
  ///
  /// In es, this message translates to:
  /// **'Eliminada de guardados'**
  String get bookmarkRemoved;

  /// No description provided for @profileSavedReviews.
  ///
  /// In es, this message translates to:
  /// **'Guardados'**
  String get profileSavedReviews;

  /// No description provided for @profileNoSavedReviews.
  ///
  /// In es, this message translates to:
  /// **'No tienes reseñas guardadas'**
  String get profileNoSavedReviews;

  /// No description provided for @shareReviewSubject.
  ///
  /// In es, this message translates to:
  /// **'Reseña en RentaVoz'**
  String get shareReviewSubject;

  /// No description provided for @shareAppPromo.
  ///
  /// In es, this message translates to:
  /// **'Descarga RentaVoz y consulta reseñas honestas de arrendamientos en México.'**
  String get shareAppPromo;

  /// No description provided for @shareRent.
  ///
  /// In es, this message translates to:
  /// **'Renta'**
  String get shareRent;

  /// No description provided for @sharePeriod.
  ///
  /// In es, this message translates to:
  /// **'Período'**
  String get sharePeriod;

  /// No description provided for @privacyPolicy.
  ///
  /// In es, this message translates to:
  /// **'Política de privacidad'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In es, this message translates to:
  /// **'Términos de servicio'**
  String get termsOfService;

  /// No description provided for @legalSection.
  ///
  /// In es, this message translates to:
  /// **'Legal'**
  String get legalSection;

  /// No description provided for @registerTermsConsent.
  ///
  /// In es, this message translates to:
  /// **'He leído y acepto la {privacy} y los {terms}.'**
  String registerTermsConsent(String privacy, String terms);

  /// No description provided for @registerTermsRequired.
  ///
  /// In es, this message translates to:
  /// **'Debes aceptar los términos para continuar.'**
  String get registerTermsRequired;

  /// No description provided for @appVersion.
  ///
  /// In es, this message translates to:
  /// **'Versión'**
  String get appVersion;

  /// No description provided for @appAbout.
  ///
  /// In es, this message translates to:
  /// **'Acerca de'**
  String get appAbout;

  /// No description provided for @appAboutDesc.
  ///
  /// In es, this message translates to:
  /// **'RentaVoz es una plataforma donde inquilinos comparten reseñas honestas de arrendamientos en México.'**
  String get appAboutDesc;

  /// No description provided for @appContact.
  ///
  /// In es, this message translates to:
  /// **'Contacto'**
  String get appContact;

  /// No description provided for @appOpenSource.
  ///
  /// In es, this message translates to:
  /// **'Licencias de código abierto'**
  String get appOpenSource;

  /// No description provided for @changePhoto.
  ///
  /// In es, this message translates to:
  /// **'Cambiar foto de perfil'**
  String get changePhoto;

  /// No description provided for @photoUploadSuccess.
  ///
  /// In es, this message translates to:
  /// **'Foto actualizada'**
  String get photoUploadSuccess;

  /// No description provided for @photoUploadError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo actualizar la foto'**
  String get photoUploadError;

  /// No description provided for @followAddress.
  ///
  /// In es, this message translates to:
  /// **'Seguir dirección'**
  String get followAddress;

  /// No description provided for @unfollowAddress.
  ///
  /// In es, this message translates to:
  /// **'Dejar de seguir'**
  String get unfollowAddress;

  /// No description provided for @followedSuccess.
  ///
  /// In es, this message translates to:
  /// **'Ahora sigues esta dirección'**
  String get followedSuccess;

  /// No description provided for @unfollowedSuccess.
  ///
  /// In es, this message translates to:
  /// **'Ya no sigues esta dirección'**
  String get unfollowedSuccess;

  /// No description provided for @followedAddresses.
  ///
  /// In es, this message translates to:
  /// **'Direcciones seguidas'**
  String get followedAddresses;

  /// No description provided for @noFollowedAddresses.
  ///
  /// In es, this message translates to:
  /// **'No sigues ninguna dirección aún'**
  String get noFollowedAddresses;

  /// No description provided for @followedAddressesHint.
  ///
  /// In es, this message translates to:
  /// **'Sigue una dirección desde las reseñas para recibir notificaciones'**
  String get followedAddressesHint;
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'ja', 'ko', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return SEn();
    case 'es':
      return SEs();
    case 'ja':
      return SJa();
    case 'ko':
      return SKo();
    case 'zh':
      return SZh();
  }

  throw FlutterError(
    'S.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
