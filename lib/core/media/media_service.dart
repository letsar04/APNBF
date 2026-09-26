import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../session/app_session.dart';

class MediaService {
  final _picker = ImagePicker();
  final _storage = Supabase.instance.client.storage;
  final _db = Supabase.instance.client;
  final _session = AppSession();

  Future<XFile?> pickImage() => _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 82,
        maxWidth: 1600,
      );

  Future<String> uploadProductImage({required String productId, required XFile file}) async {
    final businessId = await _session.businessId();
    final bytes = await file.readAsBytes();
    final ext = _extension(file.name);
    final path = '$businessId/products/$productId/${DateTime.now().millisecondsSinceEpoch}.$ext';
    await _storage.from('apnbf-media').uploadBinary(
      path,
      bytes,
      fileOptions: const FileOptions(cacheControl: '31536000', upsert: false),
    );
    await _db.from('product_images').insert({
      'product_id': productId,
      'storage_path': path,
    });
    return _storage.from('apnbf-media').getPublicUrl(path);
  }

  Future<String> uploadServiceImage({required String serviceId, required XFile file}) async {
    final businessId = await _session.businessId();
    final bytes = await file.readAsBytes();
    final ext = _extension(file.name);
    final path = '$businessId/services/$serviceId/${DateTime.now().millisecondsSinceEpoch}.$ext';
    await _storage.from('apnbf-media').uploadBinary(
      path,
      bytes,
      fileOptions: const FileOptions(cacheControl: '31536000', upsert: false),
    );
    final url = _storage.from('apnbf-media').getPublicUrl(path);
    await _db.from('services').update({'image_url': url}).eq('id', serviceId);
    return url;
  }

  String _extension(String name) {
    final dot = name.lastIndexOf('.');
    if (dot < 0) return 'jpg';
    final ext = name.substring(dot + 1).toLowerCase();
    return const ['jpg', 'jpeg', 'png', 'webp'].contains(ext) ? ext : 'jpg';
  }
}
