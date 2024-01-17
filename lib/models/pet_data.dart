// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sos_app/models/data_default.dart';

class PetData extends DataDefault {
  final String specie;
  final String size;
  final String breed;
  final String reward;

  PetData({
    required this.specie,
    required this.size,
    required this.breed,
    required this.reward,
    required String docId,
    required String userId,
    required String name,
    required String age,
    required String gender,
    required double lat,
    required double long,
    required String city,
    required String uf,
    required String address,
    required String date,
    required String description,
    required Timestamp datePost,
    required List<String> images,
    required bool isMissing,
    required String status,
  }) : super(
          docId: docId,
          userId: userId,
          name: name,
          age: age,
          gender: gender,
          lat: lat,
          long: long,
          city: city,
          uf: uf,
          address: address,
          date: date,
          description: description,
          datePost: datePost,
          images: images,
          isMissing: isMissing,
          status: status,
        );

  factory PetData.fromFirebase(
      Map<String, dynamic> data, String doc, bool isMissing) {
    return PetData(
      docId: doc,
      specie: data['specie'] ?? '',
      size: data['size'] ?? '',
      breed: data['breed'] ?? '',
      reward: data['reward'] ?? '',
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      age: data['age'] ?? '',
      gender: data['gender'] ?? '',
      lat: data['latitude'] ?? 0.0,
      long: data['longitude'] ?? 0.0,
      city: data['city'] ?? '',
      uf: data['uf'] ?? '',
      address: data['address'] ?? '',
      date: data['date'] ?? '',
      description: data['description'] ?? '',
      datePost: data['datePost'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      isMissing: isMissing,
      status: data['status'],
    );
  }
}
