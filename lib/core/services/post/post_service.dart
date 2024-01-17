
import 'package:sos_app/core/services/post/post_firebase_service.dart';
import 'package:sos_app/models/post_form_data.dart';

abstract class PostService {
  Future<void> post(PostFormData formData);

  Future<void> deleteFromFirebase(String collection, String doc, List<String> imagesURLs);

  Future<void> deleteFilesFromStorage(List<String> fileUrls, String bucketName);

  Future<void> setStatus(String collection, String docId);

  Future<void> sendReport(String userId, String postId, String collectionPost, String report, String comment, DateTime dateReport);

  Future<void> update(PostFormData formData, String docId, bool isMissingPost, List<String> currentImages);

  factory PostService() {
    return PostFirebaseService();
  }
}