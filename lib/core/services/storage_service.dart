import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadProfilePhoto(File file, String driverId) async {
    return _uploadFile(file, 'drivers/$driverId/profile.jpg');
  }

  Future<String> uploadVehiclePhoto(File file, String driverId) async {
    return _uploadFile(file, 'drivers/$driverId/vehicle.jpg');
  }

  Future<String> _uploadFile(File file, String path) async {
    final ref = _storage.ref().child(path);
    final task = await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return await task.ref.getDownloadURL();
  }
}
