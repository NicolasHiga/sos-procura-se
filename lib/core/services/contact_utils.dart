import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUtils {
  static Future<String> getUserPhone(String userId) async {
    final String? phoneNumber;
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final CollectionReference usersCollection = firestore.collection('users');
      final DocumentSnapshot userData = await usersCollection.doc(userId).get();

      if (userData.exists) {
        phoneNumber = await userData.get('phone') as String;
      } else {
        throw 'Usuário não encontrado no Firestore.';
      }
      return phoneNumber;
    } catch (e) {
      throw Exception(e);
    }
  }

  static void openWhatsApp(String userId) async {
    final String userNumber = await getUserPhone(userId);
    // final Uri url = Uri.parse('https://api.whatsapp.com/send?phone=$userNumber&text=');
    final Uri url = Uri.parse('https://wa.me/${Uri.encodeComponent(userNumber)}');

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  static void callAuthorPost(String userId) async {
    final String userNumber = await getUserPhone(userId);
    final Uri telLaunchUrl = Uri(scheme: 'tel', path: "+$userNumber");

    if (!await launchUrl(telLaunchUrl)) {
      throw Exception('Could not launch $telLaunchUrl');
    }
  }
}
