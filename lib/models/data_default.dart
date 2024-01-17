// ignore_for_file: file_names
import 'package:cloud_firestore/cloud_firestore.dart';

class DataDefault {
  final String docId;
  final String userId;
  final String name;
  final String age;
  final String gender;
  final double lat;
  final double long;
  final String city;
  final String uf;
  final String address;
  final String date;
  final String description;
  final Timestamp datePost;
  final List<String> images;
  final bool isMissing;
  final String status;

  DataDefault({    
    required this.docId,
    required this.userId,
    required this.name,
    required this.age,
    required this.gender,
    required this.lat,
    required this.long,
    required this.city,
    required this.uf,
    required this.address,
    required this.date,
    required this.description,
    required this.datePost,
    required this.images,
    required this.isMissing,
    required this.status,
  });
}
