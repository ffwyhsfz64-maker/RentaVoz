import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

enum LegalType { privacy, terms }

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key, required this.type});
  final LegalType type;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context)!;
    final title = type == LegalType.privacy ? s.privacyPolicy : s.termsOfService;
    final sections = type == LegalType.privacy ? _privacySections(s) : _termsSections(s);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        itemCount: sections.length,
        itemBuilder: (_, i) => _LegalSection(
          heading: sections[i].$1,
          body: sections[i].$2,
        ),
      ),
    );
  }

  List<(String, String)> _privacySections(S s) => [
        (
          'Última actualización: agosto 2025',
          'Esta Política de Privacidad describe cómo RentaVoz ("nosotros") recopila, usa y protege tu información personal cuando utilizas nuestra aplicación móvil.',
        ),
        (
          '1. Información que recopilamos',
          '• Dirección de correo electrónico (al registrarse con email)\n'
          '• Nombre de usuario que elijas\n'
          '• Fotos e imágenes que subas voluntariamente\n'
          '• Ubicación aproximada (solo cuando la usas para autocompletar la dirección)\n'
          '• Comprobantes de pago que adjuntes (almacenados de forma segura)\n'
          '• Datos de uso: pantallas visitadas, reseñas creadas',
        ),
        (
          '2. Cómo usamos tu información',
          '• Permitirte publicar y gestionar tus reseñas de arrendamiento\n'
          '• Autenticar tu identidad y proteger tu cuenta\n'
          '• Mejorar la calidad y relevancia del contenido\n'
          '• Enviar correos de verificación o restablecimiento de contraseña\n'
          '• Detectar y prevenir uso fraudulento o abusivo',
        ),
        (
          '3. Terceros y servicios externos',
          'Utilizamos los siguientes servicios de terceros:\n\n'
          '• Firebase (Google LLC) — autenticación, base de datos y almacenamiento de archivos\n'
          '• Google Maps Platform — visualización de mapas y geocodificación\n\n'
          'Estos servicios tienen sus propias políticas de privacidad. No vendemos tu información a terceros.',
        ),
        (
          '4. Retención de datos',
          'Conservamos tu información mientras tu cuenta esté activa. Al eliminar tu cuenta, tus datos personales se borran en un plazo de 30 días, excepto cuando la ley exija conservarlos.',
        ),
        (
          '5. Tus derechos',
          '• Acceder a los datos que tenemos sobre ti\n'
          '• Corregir información incorrecta\n'
          '• Solicitar la eliminación de tu cuenta y datos\n\n'
          'Para ejercer estos derechos contáctanos en: rentavozmx@gmail.com',
        ),
        (
          '6. Seguridad',
          'Aplicamos medidas técnicas razonables (cifrado en tránsito y en reposo, reglas de seguridad en Firestore y Storage) para proteger tu información. Sin embargo, ningún sistema es 100% seguro.',
        ),
        (
          '7. Cambios a esta política',
          'Podemos actualizar esta política en cualquier momento. Te notificaremos mediante la aplicación si los cambios son significativos.',
        ),
        (
          '8. Contacto',
          'Si tienes preguntas sobre esta política, escríbenos a:\nrentavozmx@gmail.com',
        ),
      ];

  List<(String, String)> _termsSections(S s) => [
        (
          'Última actualización: agosto 2025',
          'Al usar RentaVoz ("la App") aceptas estos Términos de Servicio. Si no estás de acuerdo, no uses la App.',
        ),
        (
          '1. Descripción del servicio',
          'RentaVoz es una plataforma donde inquilinos pueden compartir reseñas honestas sobre arrendamientos en México. No somos una agencia inmobiliaria ni verificamos de forma exhaustiva la veracidad de las reseñas.',
        ),
        (
          '2. Cuenta de usuario',
          '• Debes tener al menos 18 años para registrarte\n'
          '• Eres responsable de mantener la confidencialidad de tu contraseña\n'
          '• Solo puedes crear una cuenta por persona\n'
          '• Debes proporcionar información veraz al registrarte',
        ),
        (
          '3. Contenido del usuario',
          'Al publicar una reseña:\n\n'
          '• Declaras que la información es verídica y basada en tu experiencia personal\n'
          '• Nos otorgas una licencia no exclusiva para mostrar el contenido en la App\n'
          '• Eres el único responsable del contenido que publicas',
        ),
        (
          '4. Contenido prohibido',
          'Está prohibido publicar:\n\n'
          '• Información falsa o engañosa intencionalmente\n'
          '• Contenido ofensivo, discriminatorio o de acoso\n'
          '• Datos personales de propietarios sin su consentimiento\n'
          '• Spam, publicidad o contenido comercial no relacionado\n'
          '• Contenido que viole derechos de terceros',
        ),
        (
          '5. Moderación y suspensión',
          'Nos reservamos el derecho de eliminar contenido que viole estos términos y de suspender cuentas de usuarios que los incumplan, sin previo aviso.',
        ),
        (
          '6. Limitación de responsabilidad',
          'RentaVoz no garantiza la exactitud de las reseñas publicadas por terceros. No somos responsables de decisiones tomadas en base al contenido de la App. El uso de la App es bajo tu propio riesgo.',
        ),
        (
          '7. Propiedad intelectual',
          'El diseño, código fuente y marca de RentaVoz son propiedad de sus creadores. No puedes reproducir ni distribuir la App sin autorización.',
        ),
        (
          '8. Cambios a los términos',
          'Podemos modificar estos términos en cualquier momento. El uso continuado de la App después de los cambios implica tu aceptación.',
        ),
        (
          '9. Contacto',
          'Para consultas sobre estos términos:\nrentavozmx@gmail.com',
        ),
      ];
}

class _LegalSection extends StatelessWidget {
  const _LegalSection({required this.heading, required this.body});
  final String heading;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            heading,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(body, style: theme.textTheme.bodyMedium?.copyWith(height: 1.6)),
          const SizedBox(height: 4),
          const Divider(),
        ],
      ),
    );
  }
}
