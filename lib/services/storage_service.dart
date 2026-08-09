import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  static final _storage = FirebaseStorage.instance;

  static Future<String> uploadComprobante(String reviewId, File file) async {
    final ext = file.path.split('.').last;
    final ref = _storage.ref('comprobantes/$reviewId.$ext');
    await ref.putFile(file);
    return ref.getDownloadURL();
  }
}
