import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

/// Handles uploading profile photos to Firebase Storage and returning the
/// public download URL.
///
/// Uses `putData` so the same code works across mobile and web.
class ProfilePhotoService {
  ProfilePhotoService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  Future<String?> uploadProfilePhotoBytes({
    required String uid,
    required Uint8List bytes,
    required String fileExtension,
  }) async {
    final ext = fileExtension.toLowerCase();
    final allowedExt = <String>{'jpg', 'jpeg', 'png'};
    final safeExt = allowedExt.contains(ext) ? ext : 'jpg';

    final ref = _storage.ref().child('profile_pictures/$uid.$safeExt');

    final contentType = safeExt == 'png'
        ? 'image/png'
        : 'image/jpeg';

    final uploadTask = ref.putData(
      bytes,
      SettableMetadata(contentType: contentType),
    );

    await uploadTask;
    return ref.getDownloadURL();
  }
}



