// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class SEs extends S {
  SEs([String locale = 'es']) : super(locale);

  @override
  String get appSubtitle => 'Reseñas honestas de arrendamientos en México';

  @override
  String get emailLabel => 'Correo electrónico';

  @override
  String get passwordLabel => 'Contraseña';

  @override
  String get confirmPasswordLabel => 'Confirmar contraseña';

  @override
  String get loginButton => 'Iniciar sesión';

  @override
  String get registerButton => 'Registrarse';

  @override
  String get createAccount => 'Crear cuenta nueva';

  @override
  String get passwordMismatch => 'Las contraseñas no coinciden';

  @override
  String get passwordMinLength => 'Mínimo 6 caracteres';

  @override
  String get emailInvalid => 'Ingresa un correo válido';

  @override
  String get tabHome => 'Inicio';

  @override
  String get tabMap => 'Mapa';

  @override
  String get tabMyReviews => 'Mis reseñas';

  @override
  String get newReview => 'Nueva reseña';

  @override
  String get searchHint => 'Buscar por dirección o colonia…';

  @override
  String get noReviewsYet => 'No hay reseñas aún';

  @override
  String noResultsFor(String query) {
    return 'Sin resultados para \"$query\"';
  }

  @override
  String get mapTitle => 'Mapa de reseñas';

  @override
  String reviewCount(int count) {
    return '$count reseñas';
  }

  @override
  String get legendGood => '★ 4–5  Bueno';

  @override
  String get legendRegular => '★ 3–4  Regular';

  @override
  String get legendBad => '★ 1–3  Malo';

  @override
  String get centerMap => 'Centrar mapa';

  @override
  String get myReviewsEmpty => 'Aún no has escrito reseñas';

  @override
  String get myReviewsEmptyHint => 'Toca \"Nueva reseña\" para empezar';

  @override
  String get editReview => 'Editar reseña';

  @override
  String get deleteReview => 'Eliminar reseña';

  @override
  String get deleteConfirmTitle => 'Eliminar reseña';

  @override
  String get deleteConfirmBody => '¿Seguro que quieres eliminar esta reseña?';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get languageLabel => 'Idioma';

  @override
  String get detailTitle => 'Detalle de reseña';

  @override
  String get overallOf5 => 'de 5.0';

  @override
  String get moveIn => 'Entrada';

  @override
  String get moveOut => 'Salida';

  @override
  String get rent => 'Renta';

  @override
  String get contractSection => 'Detalles del contrato';

  @override
  String get comprobanteSection => 'Comprobante de pago';

  @override
  String get comprobanteOptional =>
      'Opcional · Tu reseña aparecerá con el sello \"Documento adjunto\"';

  @override
  String get uploadComprobante => 'Subir comprobante (imagen o PDF)';

  @override
  String get analyzingDoc => 'Analizando documento…';

  @override
  String get removeDoc => 'Quitar';

  @override
  String get pdfAttached => 'PDF adjunto (sin verificación de fecha)';

  @override
  String get goodSection => '¿Qué te gustó?';

  @override
  String get badSection => '¿Qué no te gustó?';

  @override
  String get photosSection => 'Fotos';

  @override
  String get addPhotos => 'Agregar fotos';

  @override
  String get publishButton => 'Publicar reseña';

  @override
  String get saveButton => 'Guardar';

  @override
  String get publishAction => 'Publicar';

  @override
  String get addressLabel => 'Dirección';

  @override
  String get addressHint => 'Ej. Calle Morelos 123, Col. Centro, Querétaro';

  @override
  String get periodLabel => 'Período de arrendamiento';

  @override
  String get rentLabel => 'Renta mensual (MXN)';

  @override
  String get ratingsLabel => 'Calificaciones';

  @override
  String get landlordRating => 'Arrendador / Propietario';

  @override
  String get conditionRating => 'Estado del inmueble';

  @override
  String get locationRating => 'Ubicación';

  @override
  String get securityRating => 'Seguridad';

  @override
  String get formalContract => 'Contrato formal';

  @override
  String get avalRequired => 'Requirió aval';

  @override
  String get depositReturned => 'Depósito devuelto';

  @override
  String get utilitiesIncluded => 'Servicios incluidos (agua/luz/gas)';

  @override
  String get badgeVerified => '✓ Documento adjunto';

  @override
  String get badgeFormalContract => 'Contrato formal';

  @override
  String get badgeAvalRequired => 'Requirió aval';

  @override
  String get badgeDepositNotReturned => 'Depósito no devuelto';

  @override
  String get badgeUtilitiesIncluded => 'Servicios incluidos';

  @override
  String get reviewPublished => '¡Reseña publicada!';

  @override
  String get reviewUpdated => '¡Reseña actualizada!';

  @override
  String get reviewDeleted => 'Reseña eliminada';

  @override
  String get selectDates => 'Selecciona las fechas de entrada y salida';

  @override
  String get selectAddress => 'Selecciona una dirección de la lista';

  @override
  String publishedOn(String date) {
    return 'Publicada el $date';
  }

  @override
  String get useMyLocation => 'Usar mi ubicación actual';

  @override
  String get locationPermissionDenied =>
      'Activa los permisos de ubicación en Ajustes';

  @override
  String get locationError => 'No se pudo obtener la ubicación';

  @override
  String get loginSignIn => 'Ya tengo cuenta — Iniciar sesión';

  @override
  String get onb1Title => 'Bienvenido a RentaVoz';

  @override
  String get onb1Body =>
      'La plataforma donde los arrendatarios comparten experiencias reales sobre sus viviendas en México.\n\nOpina con libertad y ayuda a otros a tomar mejores decisiones.';

  @override
  String get onb2Title => 'Escribe una reseña';

  @override
  String get onb2Body =>
      'Toca \"Nueva reseña\" para compartir tu experiencia.\n\nCalifica al propietario, el inmueble, la ubicación y la seguridad. ¡Tu opinión vale!';

  @override
  String get onb3Title => 'Verifica tu reseña';

  @override
  String get onb3Body =>
      'Adjunta tu comprobante de pago para que tu reseña sea más confiable.\n\nLos comprobantes recientes (menos de 3 meses) obtienen el sello \"Documento adjunto\".';

  @override
  String get onb4Title => 'Explora el mapa';

  @override
  String get onb4Body =>
      'Consulta las reseñas en el mapa antes de rentar.\n\n🟢 Verde = excelente  🟡 Amarillo = regular  🔴 Rojo = mala experiencia\n\nToca un pin para ver el detalle.';

  @override
  String get onb5Title => 'Actualiza tu reseña';

  @override
  String get onb5Body =>
      'En \"Mis reseñas\" puedes editar tu reseña cuando cambie la situación — por ejemplo, cuando te devuelvan (o no) el depósito.';

  @override
  String get skip => 'Omitir';

  @override
  String get next => 'Siguiente';

  @override
  String get getStarted => '¡Empezar!';

  @override
  String get back => 'Atrás';

  @override
  String get loginNeedAccount => 'Inicia sesión para ver tus reseñas';

  @override
  String get loginToSeeReviews => 'Iniciar sesión';

  @override
  String get swipeToDelete =>
      'Desliza a la izquierda para eliminar · Mantén presionado para más opciones';

  @override
  String get translateButton => 'Traducir';

  @override
  String get showOriginal => 'Ver original';

  @override
  String get translating => 'Traduciendo…';

  @override
  String get translationLabel => 'Traducción automática';

  @override
  String get translationError => 'No se pudo traducir. Intenta de nuevo.';

  @override
  String get authErrNotFound => 'No existe una cuenta con ese correo.';

  @override
  String get authErrWrongPw => 'Correo o contraseña incorrectos.';

  @override
  String get authErrInvalidEmail => 'Correo no válido.';

  @override
  String get authErrTooMany => 'Demasiados intentos. Intenta más tarde.';

  @override
  String get authErrDefault => 'Error al iniciar sesión. Intenta de nuevo.';

  @override
  String get authErrEmailInUse => 'Ya existe una cuenta con ese correo.';

  @override
  String get authErrWeakPw => 'La contraseña es muy débil.';

  @override
  String get authErrRegDefault => 'Error al crear cuenta. Intenta de nuevo.';

  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get forgotPasswordTitle => 'Restablecer contraseña';

  @override
  String get forgotPasswordBody =>
      'Ingresa tu correo y te enviaremos un enlace para restablecer tu contraseña.';

  @override
  String get forgotPasswordSend => 'Enviar enlace';

  @override
  String get forgotPasswordSent =>
      'Correo enviado. Revisa tu bandeja de entrada.';

  @override
  String get forgotPasswordErrNotFound =>
      'No existe una cuenta con ese correo.';

  @override
  String get forgotPasswordErrDefault =>
      'No se pudo enviar el correo. Intenta de nuevo.';

  @override
  String get filterAll => 'Todos';

  @override
  String get filterHouse => 'Casa';

  @override
  String get filterRoom => 'Cuarto';

  @override
  String get sortNewest => 'Más recientes';

  @override
  String get sortHighest => 'Mejor calificados';

  @override
  String get sortLowest => 'Peor calificados';

  @override
  String get rentalTypeLabel => 'Tipo de arrendamiento';

  @override
  String get rentalTypeHouse => 'Casa completa';

  @override
  String get rentalTypeRoom => 'Cuarto / Habitación';

  @override
  String get sharedBathroom => 'Baño compartido';

  @override
  String get sharedKitchen => 'Cocina compartida';

  @override
  String get badgeRoom => 'Cuarto';

  @override
  String get reportButton => 'Reportar reseña';

  @override
  String get reportTitle => '¿Por qué reportas esta reseña?';

  @override
  String get reportReasonFalse => 'Información falsa o engañosa';

  @override
  String get reportReasonSpam => 'Spam o publicidad';

  @override
  String get reportReasonInappropriate => 'Contenido inapropiado u ofensivo';

  @override
  String get reportReasonOther => 'Otro motivo';

  @override
  String get reportSubmit => 'Enviar reporte';

  @override
  String get reportSuccess => 'Reporte enviado. Lo revisaremos pronto.';

  @override
  String get reportAlready => 'Ya reportaste esta reseña anteriormente.';

  @override
  String get reportOwnReview => 'No puedes reportar tu propia reseña.';

  @override
  String get reportError => 'No se pudo enviar el reporte. Intenta de nuevo.';

  @override
  String get tabProfile => 'Perfil';

  @override
  String get profileTitle => 'Mi perfil';

  @override
  String get profileGuest => 'Anónimo';

  @override
  String get profileEditNameTitle => 'Editar nombre';

  @override
  String get profileEditNameHint => 'Tu nombre';

  @override
  String get profileSave => 'Guardar';

  @override
  String get profileSaveSuccess => 'Nombre actualizado';

  @override
  String get profileSaveError => 'No se pudo actualizar el nombre';

  @override
  String get profileEmailLabel => 'Correo';

  @override
  String profileMemberSince(String date) {
    return 'Miembro desde $date';
  }

  @override
  String profileReviewCount(int count) {
    return '$count reseñas';
  }

  @override
  String get profileAvgRating => 'Promedio';

  @override
  String get profileMyReviews => 'Mis reseñas';

  @override
  String get profileNoReviews => 'Aún no has escrito reseñas';
}
