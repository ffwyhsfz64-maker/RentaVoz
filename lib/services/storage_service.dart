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

  static Future<List<String>> uploadPhotos(String reviewId, List<File> files) async {
    final urls = <String>[];
    for (var i = 0; i < files.length; i++) {
      final ext = files[i].path.split('.').last;
      final ref = _storage.ref('photos/$reviewId/$i.$ext');
      await ref.putFile(files[i]);
      urls.add(await ref.getDownloadURL());
    }
    return urls;
  }
}
